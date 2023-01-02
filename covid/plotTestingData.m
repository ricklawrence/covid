function plotTestingData(data, entityName0, figureNum)
%
% plot new cases and new deaths
%
global parameters;
fprintf('\n--> plotTestingData\n');

%=== get data for this entity (state)
nameIndex  = find(strcmp(entityName0, data.names));
dateIndex  = [1:data.numDates]';
entityName = sprintf(data.entityFormat,  char(entityName0));

%=== get data
numDates     = length(dateIndex);
dates        = data.dates(dateIndex);
newCases     = data.newCases(dateIndex, nameIndex);
newTests     = data.newTests(dateIndex, nameIndex);
testPositive = data.testPositive(dateIndex, nameIndex);

%=== set date limits
numWeeks    = 8;
window      = numWeeks*7;
d2          = numDates;
d1          = numDates - window;
interval    = window / 10;               % ~10 date labels
interval    = 7 * ceil(interval/7);      % round up to integer number of weeks
xTicks      = [d1:interval:d2]';
xTicks      = xTicks + d2 - max(xTicks); % insure last tick is latest date
xTicks      = xTicks - d1 + 1;           % ticks begin at 1
xLabels     = dates(d1:d2);              % labels begin at 1

%=== get factor to convert cases per 100000 back to unnormalized cases
factor = data.population(nameIndex) / 100000;

%-----------------------------------------------------------------------------------------------------
%=== 1a. BAR PLOT OF NEW CASES
figure(figureNum); fprintf('Figure %d.\n', figureNum);
subplot(3,1,1);
barWidth = 1.0;

%=== bar plot
y = max(0,newCases);
h = bar(y(d1:d2), barWidth);  set(h, 'FaceColor', 'b');
hold on;

MA1 = factor*data.features(dateIndex,nameIndex,2);
MA1 = max(MA1, 0);
h   = plot(MA1(d1:d2),'r-'); set(h, 'LineWidth', 2);
hold off;

%=== get trend and legends
latest     = y(end);
strLegend1 = sprintf('Daily Cases (Latest = %d)', latest);
latest     = MA1(end);
trend      = data.features(end,nameIndex,1);
strLegend2 = sprintf('%d-Day Moving Average (Latest = %2.1f  Week-over-Week Change = %2.1f%%', parameters.maWindow, latest, trend);

%=== add axis labels
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 1);
set(gca,'FontSize',10);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
%xlabel(sprintf('Reporting Date (last %d Weeks)', numWeeks), 'FontSize', 12);
ylabel('New Cases Per Day','FontSize', 12);
strLegend = {strLegend1; strLegend2};
strTitle = sprintf('%s: Number of New Cases (as of %s)', entityName, data.lastDate);
legend(strLegend,'Location', 'NorthWest', 'FontSize', 10);
title(strTitle, 'FontSize', 16);

%=== return if no testing data
if isnan(sum(newTests(end-14:end-7)))
  return;
end

%-----------------------------------------------------------------------------------------------------
%=== 1b. BAR PLOT OF NEW TESTS
subplot(3,1,2);

%=== bar plot
y = max(0,newTests);
h = bar(y(d1:d2), barWidth);  set(h, 'FaceColor', 'g');
hold on;

MA2 = factor*data.features(dateIndex,nameIndex,4);
h   = plot(MA2(d1:d2),'r-'); set(h, 'LineWidth', 2);
hold off;

%=== get trend and legends
latest     = y(end);
strLegend1 = sprintf('Daily Tests (Latest = %d)', latest);
latest     = MA2(end);
trend      = data.features(end,nameIndex,3);
strLegend2 = sprintf('%d-Day Moving Average (Latest = %2.1f  Week-over-Week Change = %2.1f%%', parameters.maWindow, latest, trend);

%=== add axis labels
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 1);
set(gca,'FontSize',10);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
%xlabel(sprintf('Reporting Date (last %d Weeks)', numWeeks), 'FontSize', 12);
ylabel('New Tests Per Day','FontSize', 12);
strLegend = {strLegend1; strLegend2};
strTitle = sprintf('%s: Number of New Tests', entityName);
legend(strLegend,'Location', 'NorthWest', 'FontSize', 10);
title(strTitle, 'FontSize', 16);

%-----------------------------------------------------------------------------------------------------
%=== 1c. BAR PLOT OF POSITIVE RATE
subplot(3,1,3);

%=== compute positive rate from MAs of new cases and new tests
MA3 = 100*MA1 ./ MA2;
MA3 = max(MA3,0);

%=== bar plot of daily positive rates
y = max(100*testPositive,0);
h = bar(y(d1:d2), barWidth);  set(h, 'FaceColor', 'c');
hold on;

%=== moving average
h   = plot(MA3(d1:d2),'r-'); set(h, 'LineWidth', 2);
hold off;

%=== get final value and legend
latest = y(end);
strLegend1 = sprintf('Daily Test Positivity (Latest = %2.1f%%)', latest);
latest = MA3(end);
strLegend2 = sprintf('%d-Day Moving Average (Latest = %2.1f%%)', parameters.maWindow, latest);

%=== add data source
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = xmin - 0.05*(xmax - xmin);
y0   = ymin - 0.35*(ymax - ymin);
if strcmp(entityName, 'United States')
  strText = sprintf('%s\n%s',parameters.covidTrackingSource, 'Analysis by Rick Lawrence (Ridgefield COVID Task Force)');
else
  strText = sprintf('%s\n%s',parameters.ctDataSource, 'Analysis by Rick Lawrence (Ridgefield COVID Task Force)');
end
h = text(x0, y0, strText); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== add axis labels
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 1);
set(gca,'FontSize',10);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(sprintf('Reporting Date (last %d Weeks)', numWeeks), 'FontSize', 12);
ylabel('Test Positivity (%)','FontSize', 12);
ytickformat('%1.0f%%');
strLegend  = {strLegend1; strLegend2};
strTitle = sprintf('%s: Test Positivity', entityName);
legend(strLegend,'Location', 'NorthWest', 'FontSize', 10);
title(strTitle, 'FontSize', 16);

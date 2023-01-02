function plotTownLineChart(townName, countyName, town, county, state, figureNum)
%
% plot line charts of new case rate and test positivity for town, county, and state
%
global parameters;
if figureNum < 0
  return;
end
fprintf('\n--> plotTownLineChart\n');

%=== get feature labels for new case rate and test positivity
featureLabel1  = char(town.featureLabels(2));      
featureTitle1  = char(town.featureTitles(2));  
featureLabel2  = char(town.featureLabels(5));      
featureTitle2  = char(town.featureTitles(5));  

%=== get dates from the town data
dates       = town.dates;
numDates    = length(dates);

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

%=== get Connecticut data
stateName      = 'Connecticut';
index          = find(strcmp(state.names, stateName));
newCaseRates1  = state.features(:,index,2);
positivity1    = state.features(:,index,5);

%=== get County data
index          = find(strcmp(county.names, countyName));
newCaseRates2  = county.features(:,index,2);
positivity2    = county.features(:,index,5);

%=== get Ridgefield data
index          = find(strcmp(town.names, townName));
newCaseRates3  = town.features(:,index,2);
positivity3    = town.features(:,index,5);
%positivity3    = 100*movingAverage(town.newPositives(:,index),7) ./ movingAverage(town.newTests(:,index),7);

%------------------------------------------------------------------------
%=== 1a. PLOT LINE CHART OF NEW CASE RATES
figure(figureNum); fprintf('Figure %d.\n', figureNum);
subplot(2,1,1);
yMax = 0;

%=== Connecticut
y  = max(newCaseRates1,0); yMax = max(max(yMax, y(d1:d2)));
h  = plot(y(d1:d2));  set(h, 'Color', 'r'); set(h, 'LineWidth', 2);
y1 = y(d2);
strText1 = sprintf('%2.1f', y1);
hold on;

%=== County
y  = max(newCaseRates2,0); yMax = max(max(yMax, y(d1:d2)));
h  = plot(y(d1:d2));  set(h, 'Color', 'b'); set(h, 'LineWidth', 2);
y2 = y(d2);
strText2 = sprintf('%2.1f', y2);
hold on;

%=== Town
y  = max(newCaseRates3,0); yMax = max(max(yMax, y(d1:d2)));
h  = plot(y(d1:d2));  set(h, 'Color', 'k'); set(h, 'LineWidth', 2);
y3 = y(d2);
strText3 = sprintf('%2.1f', y3);
hold on;

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);

%=== set axis limits
ymin = 0;
ymax = 1.5*yMax;
ylim([ymin ymax]);

%=== set legends and title
strLegends(1)  = {sprintf('%s      (Latest = %s)',   stateName,  strText1)};
strLegends(2)  = {sprintf('%s County (Latest = %s)', countyName, strText2)};
strLegends(3)  = {sprintf('%s       (Latest = %s)',  townName,   strText3)};
strTitle       =  sprintf('%s (as of %s)',           featureLabel1, town.lastDate);

%=== add explanatory text
x0   = xmin + 0.01*(xmax - xmin);
y0   = ymin + 0.95*(ymax - ymin);
strText1 = sprintf('The New Case Rate is the number of new cases per day per 100,000 residents.');
strText2 = sprintf('It is computed using a %d-day moving average.', parameters.maWindow);
strText  = sprintf('%s\n%s', strText1, strText2);
h = text(x0, y0, strText); set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
set(h,'Horiz','Left'); set(h,'Vert','Top');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',10);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(sprintf('Reporting Date (last %d Weeks)', numWeeks), 'FontSize', 14);
ylabel(sprintf('%s', featureTitle1),'FontSize', 14);
legend(strLegends,'Location', 'NorthEast', 'FontSize', 12,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

%------------------------------------------------------------------------
%=== 1b. PLOT LINE CHART OF TEST POSITIVITY
subplot(2,1,2);
yMax = 0;

%=== Connecticut
y  = max(positivity1,0);  yMax = max(max(yMax, y(d1:d2)));
h  = plot(y(d1:d2));  set(h, 'Color', 'r'); set(h, 'LineWidth', 2);
y1 = y(d2);
strText1 = sprintf('%2.1f%%', y1);
hold on;

%=== County
y  = max(positivity2,0);  yMax = max(max(yMax, y(d1:d2)));
h  = plot(y(d1:d2));  set(h, 'Color', 'b'); set(h, 'LineWidth', 2);
y2 = y(d2);
strText2 = sprintf('%2.1f%%', y2);
hold on;

%=== Town
y  = max(positivity3,0);  yMax = max(max(yMax, y(d1:d2)));
h  = plot(y(d1:d2));  set(h, 'Color', 'k'); set(h, 'LineWidth', 2);
y3 = y(d2);
strText3 = sprintf('%2.1f%%', y3);
hold on;

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);

%=== set legends and title
strLegends(1)  = {sprintf('%s      (Latest = %s)',   stateName,  strText1)};
strLegends(2)  = {sprintf('%s County (Latest = %s)', countyName, strText2)};
strLegends(3)  = {sprintf('%s       (Latest = %s)',  townName,   strText3)};
%strLegends(4)  = {sprintf('CDC Low Transmission    <= %s    ',   strText4)};
strTitle       =  sprintf('%s (as of %s)',           featureLabel2, town.lastDate);

%=== set axis limits
ymin = 0;
ymax = 1.5*yMax;
ylim([ymin ymax]);

%=== add explanatory text
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = xmin + 0.01*(xmax - xmin);
y0   = ymin + 0.95*(ymax - ymin);
strText1 = sprintf('The Test Positivity is the fraction of tests that come back positive (expressed as percent).');
strText2 = sprintf('It is computed using a %d-day moving average.', parameters.maWindow);
strText  = sprintf('%s\n%s', strText1, strText2);
h = text(x0, y0, strText); set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
set(h,'Horiz','Left'); set(h,'Vert','Top');

%=== add data source
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = xmin - 0.1*(xmax - xmin);
y0   = ymin - 0.2*(ymax - ymin);
strSource = parameters.ctDataSource;
strSource = sprintf('%s\n%s',parameters.ctDataSource, 'Analysis by Rick Lawrence (Ridgefield COVID Task Force)');
h = text(x0, y0, strSource); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',10);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(sprintf('Reporting Date (last %d Weeks)', numWeeks), 'FontSize', 14);
ylabel(sprintf('%s', featureTitle2),'FontSize', 14);
ytickformat('%2.1f%%');
legend(strLegends,'Location', 'NorthEast', 'FontSize', 12,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

if ~isfield(town,'vaxDataN')
  return;
end
return;

%------------------------------------------------------------------------
%=== 2. PLOT LINE CHART OF NEW CASE RATES FOR THIS YEAR AND A YEAR AGO
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get dates from the town data
dates       = town.dates;
numDates    = length(dates);

%=== set date limits
numWeeks    = 8;
numFuture   = 28;              % number of days into future
shortWindow = numWeeks*7;
d2          = numDates;
d1          = numDates - shortWindow;
dd          = 7*52;  % so thanksgiving is same date
dd          = 365;
d3          = d1 - dd;
d4          = d2 - dd + numFuture;
interval    = 14;
xLabels     = dates(d3:d4);
xTicks      = [d3:interval:d4]';
xTicks      = xTicks - d3 + 1;

%=== get Ridgefield data
index          = find(strcmp(town.names, townName));
newCaseRates1  = town.features(:,index,2);

%=== plot current data
i    = 1:d2-d1+1;
y    = NaN(length(d3:d4),1);
y(i) = newCaseRates1(d1:d2);
h    = plot(y, 'k-', 'LineWidth', 2); hold on;

%=== plot data from 1 year ago
h = plot(newCaseRates1(d3:d4), 'k:', 'LineWidth', 2); hold on;

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at today's date
x0 = i(end);
h  = plot([x0,x0], [ymin, ymax], 'r-', 'LineWidth', 2); hold on;

%=== set legends and title
t              = find(strcmp(town.names, townName));
strLegends(1)  = {sprintf('%s (2021): Vaccination Rate = %2.1f%%',  townName, 100*town.vaxDataN(end,t,10,2))};
strLegends(2)  = {sprintf('%s (2020): Vaccination Rate = 0.0%%',    townName)};
strLegends(3)  = {sprintf('Current Date = %s', char(dates(end)))};
strTitle       =  sprintf('%s New Case Rate: 2021 vs 2020', townName);

%=== add data source
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = xmin - 0.04*(xmax - xmin);
y0   = ymin - 0.09*(ymax - ymin);
strSource = sprintf('%s\n%s',parameters.ctDataSource, 'Analysis by Rick Lawrence (Ridgefield COVID Task Force)');
h = text(x0, y0, strSource); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',12);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(sprintf('Reporting Date', numWeeks), 'FontSize', 14);
ylabel(sprintf('%s', featureTitle1),'FontSize', 14);
legend(strLegends,'Location', 'NorthWest', 'FontSize', 14,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

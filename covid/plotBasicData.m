function plotBasicData(data, entityName0, figureNum)
%
% plot new cases, deaths and hospitalizations
%
global parameters;
fprintf('\n--> plotBasicData\n');

%=== get index for this entity and create entityName used in plotting
firstDate  = parameters.startDate;
entityName = sprintf(data.entityFormat,  char(entityName0));
nameIndex  = find(strcmp(data.names, entityName0));

%=== set dates to be plots
if parameters.shortWindow <= 0
  dateIndex = find(data.datenums >= datenum(firstDate));                   % all dates
  interval  = 28;  
  strDates  = sprintf('Reporting Date (starting at %s)', firstDate);
else
  dateIndex = data.numDates - parameters.shortWindow + 1 : data.numDates;  % last N weeks
  interval  = 7;
  strDates  = sprintf('Reporting Date (Last %d weeks)', parameters.shortWindow / 7);
end

%=== get data
numDates     = length(dateIndex);
dates        = data.dates(dateIndex);
newCases     = data.newCases(dateIndex, nameIndex);
newDeaths    = data.newDeaths(dateIndex, nameIndex);
hospitalized = data.hospitalized(dateIndex, nameIndex);

%=== set month labels for plots
xLabels   = dates;
d1        = mod(numDates,interval);    % so last date is final tick mark
xTicks    = [d1:interval:numDates]';
if d1 == 0
  d1        = interval;
  xTicks    = [1 d1:interval:numDates]';
end

%=== get factor to convert cases per 100000 back to unnormalized cases
factor = data.population(nameIndex) / 100000;

%-----------------------------------------------------------------------------------------------------
%=== 1a. BAR PLOT OF NEW CASES
figure(figureNum); fprintf('Figure %d.\n', figureNum);
subplot(3,1,1);

%=== bar plot
y = newCases;
barWidth = 1.0;
bar(y, barWidth, 'FaceColor', 'b');
latest     = newCases(end);
strLegend1 = sprintf('Number of New Confirmed Cases (Latest = %d)', latest);
hold on;

%=== moving average
MA = factor*data.features(dateIndex,nameIndex,2);
h = plot(MA,'r-'); set(h, 'LineWidth', 2);
latest = MA(end);
strLegend2 = sprintf('%d-Day Moving Average (Latest = %2.0f)', parameters.maWindow, latest);
hold off;

%=== add axis labels
grid on;
set(gca, 'LineWidth', 1);
set(gca,'FontSize',10);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(strDates, 'FontSize', 12);
ylabel('New Cases','FontSize', 12);
strLegend = {strLegend1; strLegend2};
strTitle = sprintf('%s: Number of New Cases (as of %s)', entityName, data.lastDate);
legend(strLegend,'Location', 'NorthWest', 'FontSize', 10);
title(strTitle, 'FontSize', 16);

%=== return if no death data
if isnan(sum(newDeaths(end-14:end)))
  return;
end

%-----------------------------------------------------------------------------------------------------
%=== 1b. BAR PLOT OF NEW DEATHS
subplot(3,1,2);

%=== bar plot
y = newDeaths; 
bar(y, barWidth, 'FaceColor', parameters.orange); 
latest     = newDeaths(end);
strLegend1 = sprintf('Number of Deaths (Latest = %d)', latest);
hold on;

%=== moving average
MA = factor*data.features(dateIndex,nameIndex,7);
h = plot(MA,'r-'); set(h, 'LineWidth', 2);
latest = MA(end);
strLegend2 = sprintf('%d-Day Moving Average (Latest = %2.0f)', parameters.maWindow, latest);
hold off;

%=== add axis labels
grid on;
set(gca, 'LineWidth', 1);
set(gca,'FontSize',10);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(strDates, 'FontSize', 12);
ylabel('Deaths','FontSize', 12);
strLegend = {strLegend1; strLegend2};
strTitle = sprintf('%s: Number of Deaths', entityName);
legend(strLegend,'Location', 'NorthWest', 'FontSize', 10);
title(strTitle, 'FontSize', 16);

%=== return if no hospitalization data
if isnan(sum(hospitalized(end-14:end)))
  return;
end

%-----------------------------------------------------------------------------------------------------
%=== 1c. BAR PLOT OF CURRENT HOSPITALIZATIONS
subplot(3,1,3);

%=== bar plot
y = hospitalized;
bar(y, barWidth, 'FaceColor', 'y');
latest = y(end);
strLegend1 = sprintf('Number of Hospitalizations (Latest = %d)', latest);
hold on;

%=== moving average
MA = factor*data.features(dateIndex,nameIndex,6);
h = plot(MA,'r-'); set(h, 'LineWidth', 2);
latest = MA(end);
strLegend2 = sprintf('%d-Day Moving Average (Latest = %2.0f)', parameters.maWindow, latest);
hold off;

%=== add data source
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = xmin - 0.05*(xmax - xmin);
y0   = ymin - 0.25*(ymax - ymin);
if strcmp(data.level, 'Country') || strcmp(data.level, 'State')
  strText = parameters.covidTrackingSource;
else
  strText = parameters.ctDataSource;
end
h = text(x0, y0, strText); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== add axis labels
grid on;
set(gca, 'LineWidth', 1);
set(gca,'FontSize',10);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(strDates, 'FontSize', 12);
ylabel('Currently Hospitalized','FontSize', 12);
strLegend = {strLegend1; strLegend2};
strTitle = sprintf('%s: Number of Patients Currently Hospitalized with COVID-19', entityName);
legend(strLegend,'Location', 'South', 'FontSize', 10);
title(strTitle, 'FontSize', 16);
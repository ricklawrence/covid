function plotOmicronPeak(state, county,  town, figureNum)
%
% plot change in new case rate vs omicron cases 
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> plotOmicronPeak\n');

%---------------------------------------------------------------------------------------------
%=== 1. SCATTER PLOT OF STATE-LEVEL LATEST CASE RATE VS TREND IN CASE RATE
%figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);
clear strLegend

%=== set whether we look at trend in cases or hospitalizations
m = 1;   strMetric = 'New Case Rate';
%m = 10;  strMetric = 'Hospitalizations';

%=== compute new cases since window start date
windowDate    = '12/01/2021'; 
d0            = find(strcmp(windowDate, state.dates));
window        = state.numDates - d0;
t1            = window+1 : state.numDates;
t2            = 1 : state.numDates-window;
newCaseRates  = (state.cumCases(t1,:) - state.cumCases(t2,:)) ./ repmat(state.population', length(t1), 1);
newCaseRates  = 100000 * newCaseRates ./ window;
newCaseTrends = state.features(:,:,m);

%=== get latest data
date2       = char(state.dates(end));
x2          = newCaseRates(end,:)';        % new case rate
y2          = newCaseTrends(end,:)';       % trend in new case rate
stateNames0 = state.names0;

%=== get previous data if showing it
showPrevious = 0;
numDays      = 7;
if showPrevious
  date1     = char(state.dates(end-numDays));
  x1        = x2;
  y1        = newCaseTrends(end-numDays,:,1)';
else
  date1     = date2;
  x1        = x2;
  y1        = y2;
end

%=== plot big circles for each point
N  = 1;
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); hold on;
strLegend(N) = {sprintf('Data as of %s', date2)}; subset(N) = h1;

%=== plot small dots for each each previous point
if showPrevious
  h2 = plot(x1, y1, '.', 'Color', 'k', 'MarkerSize', 10); 
  N  = N+1;
  strLegend(N) = {sprintf('Data as of %s', date1)}; subset(N) = h2;

  %=== plot lines connecting current data to previous data
  colormap(jet(length(x2)));
  for i=1:length(x2)
    plot([x1(i), x2(i)], [y1(i), y2(i)], ':', 'LineWidth', 1); hold on;
  end
end

%=== add fairfield county
countyName    = 'Fairfield';
if strcmp(county.level, 'CountyUS')
  countyName    = 'Fairfield County, Connecticut';
end
c             = find(strcmp(county.names, countyName));
d0            = find(strcmp(windowDate, county.dates));
window        = state.numDates - d0;
t1            = window+1 : county.numDates;
t2            = 1 : county.numDates-window;
newCaseRates  = (county.cumCases(t1,:) - county.cumCases(t2,:)) ./ repmat(county.population', length(t1), 1);
newCaseRates  = 100000 * newCaseRates ./ window;
newCaseTrends = county.features(:,:,m);
x2c           = newCaseRates(end,c);
y2c           = newCaseTrends(end,c);
N             = N+1;
h             = plot(x2c, y2c, '.', 'Color','b', 'Markersize', 30); hold on;
strLegend(N)  = {sprintf('%s County', countyName)}; subset(N) = h;

%=== add ridgefield
if strcmp(county.level, 'County')
t             = find(strcmp(town.names, 'Ridgefield'));
d0            = find(strcmp(windowDate, town.dates));
window        = state.numDates - d0;
t1            = window+1 : town.numDates;
t2            = 1 : town.numDates-window;
newCaseRates  = (town.cumCases(t1,:) - town.cumCases(t2,:)) ./ repmat(town.population', length(t1), 1);
newCaseRates  = 100000 * newCaseRates ./ window;
newCaseTrends = town.features(:,:,m);
x2t           = newCaseRates(end,t);
y2t           = newCaseTrends(end,t);
N             = N+1;
h             = plot(x2t, y2t, '.', 'Color','r', 'Markersize', 30); hold on;
strLegend(N)  = {sprintf('Ridgefield')}; subset(N) = h;
end

%=== add state short names inside circles
for i=1:length(x2)
  h = text(x2(i),y2(i), char(stateNames0(i))); hold on;
  set(h,'HorizontalAlignment','Center'); 
  set(h,'FontWeight', 'bold');
  if strcmp(stateNames0(i), 'CT') || strcmp(stateNames0(i), 'US')
    set(h,'Color','b'); 
    set(h,'FontSize', 14);
  else
    set(h,'Color','k'); 
    set(h,'FontSize', 8);
  end
end

%=== set labels

strTitle  = sprintf('Week-Over-Week Change in %s vs Daily New Case Rate (since %s)', strMetric, windowDate);
yTitle    = sprintf('Most Recent Week-Over-Week Change in %s', strMetric);
xTitle    = sprintf('Daily New Case Rate (Per 100,000 Residents) since %s', windowDate);
strText   = sprintf('The dashed lines (''jet plumes'') show the trajectory for each state over the past %d days', numDays);
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDC, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
%xmax = 250;        % override if horizontal lines do not go all the way across

%=== vertical line at US new case rate
us = find(strcmp('US', stateNames0));
x3 = x2(us);
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Daily New Case Rate = %2.0f since %s', x3, windowDate)}; subset(N) = h2;

%=== horizontal line at US trend
y3 = y2(us);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Week-Over-Week Change in New Case Rate = %2.1f%%', y3)}; subset(N) = h3;

%=== horizontal line at zero
h4 = plot([xmin,xmax], [0,0], 'k-', 'LineWidth', 3);

%=== add explanatory text
if showPrevious
  x0 = xmin + 0.99*(xmax - xmin);
  y0 = ymin + 0.74*(ymax - ymin);
  h  = text(x0, y0, strText); 
  set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
  set(h,'HorizontalAlignment','Right'); set(h,'VerticalAlignment','Top');
end

%=== compute correlation
filter = ~isnan(x2) & ~isnan(y2);
R    = corrcoef(x2(filter),y2(filter));
corr = R(1,2);
h5 = plot([xmin,xmin], [ymin,ymin], '.');
N  = N + 1;
strLegend(N) = {sprintf('Correlation = %4.3f', corr)}; subset(N) = h5;

%=== add data source
x0   = xmin - 0.150*(xmax - xmin);
y0   = ymin - 0.100*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== finish plot
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 1);
set(gca,'FontSize',16);
xlabel(xTitle);
ylabel(yTitle);
ytickformat('%1.0f%%');
legend(subset, strLegend, 'Location', 'NorthEast', 'Fontsize', 12);
title(strTitle, 'Fontsize', 16);

%---------------------------------------------------------------------------------------------
%=== 2. SCATTER PLOT OF TOWN-LEVEL LATEST CASE RATE VS TREND IN CASE RATE
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);
clear strLegend

%=== compute new cases since window start date
windowDate    = '12/01/2021'; 
d0            = find(strcmp(windowDate, town.dates));
window        = town.numDates - d0;
t1            = window+1 : town.numDates;
t2            = 1 : town.numDates-window;
newCaseRates  = (town.cumCases(t1,:) - town.cumCases(t2,:)) ./ repmat(town.population', length(t1), 1);
newCaseRates  = 100000 * newCaseRates ./ window;
newCaseTrends = town.features(:,:,1);

%=== get latest data
index       = find(strcmp(town.countyNames, 'Fairfield'));
date2       = char(town.dates(end));
x2          = newCaseRates(end,index)';        % new case rate
y2          = newCaseTrends(end,index)';       % trend in new case rate
townNames   = town.names0(index);

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); hold on;
strLegend(1) = {sprintf('Data as of %s', date2)}; subset(1) = h1;

%=== add town names inside circles
for i=1:length(x2)
  h = text(x2(i),y2(i), char(townNames(i))); hold on;
  set(h,'HorizontalAlignment','Center'); 
  set(h,'FontWeight', 'bold');
  if strcmp(townNames(i), 'Ridgefield')
    set(h,'Color','b'); 
    set(h,'FontSize', 14);
  else
    set(h,'Color','k'); 
    set(h,'FontSize', 8);
  end
end

%=== get fairfield county
c             = find(strcmp(county.names, 'Fairfield'));
d0            = find(strcmp(windowDate, county.dates));
window        = state.numDates - d0;
t1            = window+1 : county.numDates;
t2            = 1 : county.numDates-window;
newCaseRates  = (county.cumCases(t1,:) - county.cumCases(t2,:)) ./ repmat(county.population', length(t1), 1);
newCaseRates  = 100000 * newCaseRates ./ window;
newCaseTrends = county.features(:,:,1);
x2c           = newCaseRates(end,c);
y2c           = newCaseTrends(end,c);

%=== set labels
strTitle  = sprintf('Week-Over-Week Change in New Case Rate vs Daily New Case Rate (since %s)', windowDate);
xTitle    = sprintf('Daily New Case Rate (Per 100,000 Residents) since %s', windowDate);
yTitle    = sprintf('Most Recent Week-Over-Week Change in New Case Rate');
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDC, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at County new case rate
h2 = plot([x2c,x2c], [ymin,ymax], 'r:', 'LineWidth', 2);
strLegend(2) = {sprintf('Fairfield County Daily New Case Rate = %2.0f since %s', x2c, windowDate)}; subset(2) = h2;

%=== horizontal line at County trend
h3 = plot([xmin,xmax], [y2c,y2c], 'k:', 'LineWidth', 2);
strLegend(3) = {sprintf('Fairfield County Week-Over-Week Change in New Case Rate = %2.1f%%', y2c)}; subset(3) = h3;

%=== add data source
x0   = xmin - 0.150*(xmax - xmin);
y0   = ymin - 0.100*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== finish plot
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 1);
set(gca,'FontSize',16);
xlabel(xTitle);
ylabel(yTitle);
ytickformat('%1.0f%%');
legend(subset, strLegend, 'Location', 'NorthEast', 'Fontsize', 12);
title(strTitle, 'Fontsize', 16);
%return;

%---------------------------------------------------------------------------------------------
%=== 3. BAR PLOT OF WEEK OVER WEEK CHANGE FOR FAIRFIELD COUNTY
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);
barWidth = 0.8;

%=== set date limits
date1       = '12/01/2021';
d1          = find(strcmp(county.dates, date1));
d2          = county.numDates;
window      = length(d1:d2);
interval    = window / 10;               % ~10 date labels
interval    = 7 * ceil(interval/7);      % round up to integer number of weeks
xTicks      = [d1:interval:d2]';
xTicks      = xTicks + d2 - max(xTicks); % insure last tick is latest date
xTicks      = xTicks - d1 + 1;           % ticks begin at 1
xLabels     = county.dates(d1:d2);       % labels begin at 1

%=== get data
countyName    = 'Fairfield';
c             = find(strcmp(county.names, 'Fairfield'));
newCaseTrends = county.features(:,:,1);

%=== bar plot
y = newCaseTrends;
h = bar(newCaseTrends(d1:d2), barWidth, 'FaceColor', 'g', 'EdgeColor', 'k', 'LineWidth', 1);  hold on;

%=== labels
strTitle     = sprintf('%s County: Week-Over-Week Change in New Case Rate (as of %s)', countyName, county.lastDate);
xLabel       = sprintf('Reporting Date (since %s)', date1);
yLabel       = 'Week-Over-Week Change in New Case Rate';
strLegend    = sprintf('%s County (Latest = %2.1f%%)', countyName, newCaseTrends(d2));
strSource    = sprintf('%s\n%s', parameters.ctDataSource, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add data source
x0   = xmin - 0.150*(xmax - xmin);
y0   = ymin - 0.100*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== finish plot
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 1);
set(gca,'FontSize',16);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(xLabel, 'FontSize', 16);
ylabel(yLabel,'FontSize', 16);
ytickformat('%1.0f%%');
legend(strLegend, 'Location', 'NorthWest', 'Fontsize', 16);
title(strTitle, 'Fontsize', 16);

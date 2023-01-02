function plotMay2022_2(town, state, county, countyUS, figureNum)
%
% additional figures for 30 minutes show in May 2022
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> plotMay2022_2\n');

%---------------------------------------------------------------------------------------------
%=== 1. SCATTER PLOT OF VACCINATION RATE VS NEW CASE RATES AT STATE LEVEL
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get latest data
date2       = char(state.dates(end));
x2          = state.vaxData(end,:,26)';    % completed 5+
y2          = state.features(end,:,2)';    % new case rate
stateNames0 = state.names0;

%=== get previous data if showing it
showPrevious = 1;
numDays      = 7;
if showPrevious
  date1     = char(state.dates(end-numDays));
  x1        = state.vaxData(end-numDays,:,26)';  % completed 5+
  y1        = state.features(end-numDays,:,2)';  % new case rate
else
  date1     = date2;
  x1        = x2;
  y1        = y2;
end

%=== eliminate ID with zero 12+ vax data
filter      = x1 > 0 & x2 > 0;
x1          = x1(filter); 
x2          = x2(filter);
y1          = y1(filter); 
y2          = y2(filter);
stateNames0 = stateNames0(filter);

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); 
strLegend(1) = {sprintf('Data as of %s', date2)}; subset(1) = h1;

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

%=== plot small dots for each each previous point
N = 1;
if showPrevious
  h2 = plot(x1, y1, '.', 'Color', 'k', 'MarkerSize', 10); 
  N  = 2;
  strLegend(2) = {sprintf('Data as of %s', date1)}; subset(N) = h2;

  %=== plot lines connecting current data to previous data
  colormap(jet(length(x2)));
  for i=1:length(x2)
    plot([x1(i), x2(i)], [y1(i), y2(i)], ':', 'LineWidth', 1); hold on;
  end
end

%=== set labels
strTitle  = sprintf('New Case Rates vs Percent of Eligible (Age 5+) Population Fully Vaccinated');
xTitle    = sprintf('Percent of Age 5+ Population Fully Vaccinated');
yTitle    = sprintf('New Case Rate (Per 100,000 Residents)');
strText   = sprintf('The dashed lines (''jet plumes'') show the trajectory for each state over the past %d days', numDays);
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at US initiated
us = find(strcmp('US', stateNames0));
x3 = x2(us);
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Fully Vaccinated Rate = %2.1f%%', x3)}; subset(N) = h2;

%=== horizontal line at US case rate
y3 = y2(us);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US New Case Rate = %2.1f', y3)}; subset(N) = h3;

%=== add explanatory text
if showPrevious
  x0 = xmin + 0.99*(xmax - xmin);
  y0 = ymin + 0.99*(ymax - ymin);
  h  = text(x0, y0, strText); 
  set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
  set(h,'HorizontalAlignment','Right'); set(h,'VerticalAlignment','Top');
end

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
xtickformat('%1.0f%%');
legend(subset, strLegend, 'Location', 'NorthWest', 'Fontsize', 16);
title(strTitle, 'Fontsize', 16);
return;

%---------------------------------------------------------------------------------------------
%=== 1. LINE PLOT OF CONNECTICUT VS FLORIDA CUMULATIVE DEATHS
%figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== set date indices 
interval = 7*13;
d1       = find(strcmp(state.dates, '05/01/2020'));  % first date
d2       = find(strcmp(state.dates, '08/07/2022'));  % last  date
d2       = length(state.dates);
d0       = mod(d2-d1,interval) + 1;
xLabels  = state.dates(d1:d2);
xTicks   = [d0:interval:length(xLabels)]';

%=== get data
CT          = find(strcmp(state.names, 'Connecticut'));
FL          = find(strcmp(state.names, 'Florida'));
cumDeathsCT = 100000*cumsum(state.newDeaths(d1:d2,CT)) ./ state.population(CT);
cumDeathsFL = 100000*cumsum(state.newDeaths(d1:d2,FL)) ./ state.population(FL);
plot(cumDeathsCT, 'b-',  'LineWidth', 2); hold on;
plot(cumDeathsFL, 'r-',  'LineWidth', 2); hold on;

%=== lives saved had Florida had the same per capita death rate
livesSaved = (cumDeathsFL(end) - cumDeathsCT(end)) .* state.population(FL) / 100000;
livesSaved

%=== title and legends
strTitle   = sprintf('Cumulative Deaths per 100,000 Residents (%s to %s)', char(xLabels(1)), char(xLabels(end)));
xLabel     = sprintf('CDC Report Date');
yLabel     = sprintf('Cumulative Death Rate (per 100,000 Residents)');
strSource  = sprintf('Data Source: http://data.cdc.gov\n%s', parameters.rickAnalysis);
clear strLegends;
strLegends(1) = {sprintf('Connecticut (Latest = %4.1f', cumDeathsCT(end))};
strLegends(2) = {sprintf('Florida     (Latest = %4.1f', cumDeathsFL(end))};

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add data source
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.095*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== finish plot
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',14);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(xLabel, 'FontSize', 16);
ylabel(yLabel, 'FontSize', 16);
ytickformat('%1.0f');
legend(strLegends,'Location', 'NorthWest', 'FontSize', 14,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);
return;

%---------------------------------------------------------------------------------------------
%=== 2. SCATTER PLOT OF PREVIOUS INFECTION RATE VS BA2 CASE RATE AT STATE LEVEL
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== set date window for BA2
date1       = '03/01/2022';
date2       = char(state.dates(end));
d1          = find(strcmp(date1, state.dates));
d2          = find(strcmp(date2, state.dates));

%=== get previous infection data
x2          = 100*state.infectedFraction(:,1);

%===- get BA2 case rate
y2          = nansum(state.newCases(d1:d2,:),1)' ./ length(d1:d2);  % daily death rate
y2          = 100000 * y2 ./ state.population;

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); 
strLegend(1) = {sprintf('State-Level Data')}; subset(1) = h1;

%=== add state short names inside circles
stateNames0 = state.names0;
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
strTitle  = sprintf('Daily New Case Rate During BA2 Phase vs Previous Infection Rates');
xTitle    = sprintf('Estimated Percent of Population Previously Infected');
yTitle    = sprintf('Daily New Case Rate During BA2 Phase');
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at US 
N  = 1;
us = find(strcmp('US', stateNames0));
x3 = x2(us);
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Previously Infected Percent = %2.1f%%', x3)}; subset(N) = h2;

%=== horizontal line at US
y3 = y2(us);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Daily New Case Rate During BA2 Phase (%s to %s) = %2.1f', date1, date2, y3)}; subset(N) = h3;

%=== compute correlation
filter = find(~isnan(x2));
R      = corrcoef(x2(filter),y2(filter));
corr   = R(1,2);
h4     = plot([xmin,xmin], [ymin,ymin], '.');
N      = N + 1;
strLegend(N) = {sprintf('Correlation = %4.3f', corr)}; subset(N) = h4;

%=== add counts in each quadrant
us       = find(strcmp('US', stateNames0));
xx       = x2(us);       % quadrant defined by us vax rate
yy       = y2(us);       % quadrant definded by US case rate
x2       = x2(1:end-1);  % omit US
y2       = y2(1:end-1);  % omit US
count(1) = length(find(x2 <= xx & y2 <= yy));  xpos(1) = (xmin+xx)/2; ypos(1) = (ymin+yy)/2; 
count(2) = length(find(x2 >  xx & y2 <= yy));  xpos(2) = (xmax+xx)/2; ypos(2) = (ymin+yy)/2;
count(3) = length(find(x2 <= xx & y2 >  yy));  xpos(3) = (xmin+xx)/2; ypos(3) = (ymax+yy)/2;
count(4) = length(find(x2 >  xx & y2 >  yy));  xpos(4) = (xmax+xx)/2; ypos(4) = (ymax+yy)/2;
for i=1:4
  h = text(xpos(i), ypos(i), sprintf('%d states', count(i)));
  set(h,'Color','k'); set(h, 'BackgroundColor', 'y');  set(h,'FontWeight', 'bold'); set(h,'FontSize', 14);
  set(h,'HorizontalAlignment','Center'); set(h,'VerticalAlignment','Middle');
end

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
xtickformat('%1.0f%%');
legend(subset, strLegend, 'Location', 'NorthWest', 'Fontsize', 12);
title(strTitle, 'Fontsize', 16);

%---------------------------------------------------------------------------------------------
%=== 3. SCATTER PLOT OF VACCINATION RATE VS HOSPITALIZATIONS AT STATE LEVEL
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== set date window for BA2
date1       = '03/01/2022';
date2       = char(state.dates(end));
d1          = find(strcmp(date1, state.dates));
d2          = find(strcmp(date2, state.dates));

%=== get vax data as of start date
d2v         = find(strcmp(date1, state.vaxDates));
x2          = state.vaxData(d2v,:,26)';          % completed 5+

%===- get hospitalizations
y2          = nansum(state.hospitalized(d1:d2,:),1)' ./ length(d1:d2);  % daily hospitalization rate
y2          = 100000 * y2 ./ state.population;

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); 
strLegend(1) = {sprintf('State-Level Data')}; subset(1) = h1;

%=== add state short names inside circles
stateNames0 = state.names0;
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
strTitle  = sprintf('Daily Hospitalization Rate During BA2 Phase vs Vaccination Rates');
xTitle    = sprintf('Percent of Age 5+ Population Fully Vaccinated');
yTitle    = sprintf('Daily Hospitalization Rate During BA2 Phase');
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at US 
N  = 1;
us = find(strcmp('US', stateNames0));
x3 = x2(us);
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Fully Vaccinated Rate (on %s) = %2.1f%%', date1, x3)}; subset(N) = h2;

%=== horizontal line at US
y3 = y2(us);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US New Hospitalization Rate During BA2 Phase (%s to %s) = %2.1f', date1, date2, y3)}; subset(N) = h3;

%=== compute correlation
R    = corrcoef(x2,y2);
corr = R(1,2);
h4   = plot([xmin,xmin], [ymin,ymin], '.');
N    = N + 1;
strLegend(N) = {sprintf('Correlation = %4.3f', corr)}; subset(N) = h4;

%=== add counts in each quadrant
us       = find(strcmp('US', stateNames0));
xx       = x2(us);       % quadrant defined by us vax rate
yy       = y2(us);       % quadrant definded by US case rate
x2       = x2(1:end-1);  % omit US
y2       = y2(1:end-1);  % omit US
count(1) = length(find(x2 <= xx & y2 <= yy));  xpos(1) = (xmin+xx)/2; ypos(1) = (ymin+yy)/2; 
count(2) = length(find(x2 >  xx & y2 <= yy));  xpos(2) = (xmax+xx)/2; ypos(2) = (ymin+yy)/2;
count(3) = length(find(x2 <= xx & y2 >  yy));  xpos(3) = (xmin+xx)/2; ypos(3) = (ymax+yy)/2;
count(4) = length(find(x2 >  xx & y2 >  yy));  xpos(4) = (xmax+xx)/2; ypos(4) = (ymax+yy)/2;
for i=1:4
  h = text(xpos(i), ypos(i), sprintf('%d states', count(i)));
  set(h,'Color','k'); set(h, 'BackgroundColor', 'y');  set(h,'FontWeight', 'bold'); set(h,'FontSize', 14);
  set(h,'HorizontalAlignment','Center'); set(h,'VerticalAlignment','Middle');
end

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
xtickformat('%1.0f%%');
legend(subset, strLegend, 'Location', 'NorthWest', 'Fontsize', 12);
title(strTitle, 'Fontsize', 16);

%================================================================================================
%return;

%---------------------------------------------------------------------------------------------
%=== 4. SCATTER PLOT OF VACCINATION RATE VS BA1 CASES AT STATE LEVEL
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== set date window for BA1
date1       = '12/01/2021';
date2       = '02/28/2022';
d1          = find(strcmp(date1, state.dates));
d2          = find(strcmp(date2, state.dates));

%=== get vax data as of start date
d2v         = find(strcmp(date1, state.vaxDates));
x2          = state.vaxData(d2v,:,26)';          % completed 5+

%===- get BA1 case rate
y2          = nansum(state.newCases(d1:d2,:),1)' ./ length(d1:d2);  % daily death rate
y2          = 100000 * y2 ./ state.population;

%=== eliminate ID with zero vax data
filter      = x2 > 0;
x2          = x2(filter); 
y2          = y2(filter);
stateNames0 = stateNames0(filter);

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); 
strLegend(1) = {sprintf('State-Level Data')}; subset(1) = h1;

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
strTitle  = sprintf('Daily Case Rate During BA1 Phase vs Vaccination Rates');
xTitle    = sprintf('Percent of Age 5+ Population Fully Vaccinated');
yTitle    = sprintf('Daily Case Rate During BA1 Phase');
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at US 
N  = 1;
us = find(strcmp('US', stateNames0));
x3 = x2(us);
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Fully Vaccinated Rate (on %s) = %2.1f%%', date1, x3)}; subset(N) = h2;

%=== horizontal line at US
y3 = y2(us);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US New Case Rate During BA1 Phase (%s to %s) = %2.1f', date1, date2, y3)}; subset(N) = h3;

%=== compute correlation
R    = corrcoef(x2,y2);
corr = R(1,2);
h4   = plot([xmin,xmin], [ymin,ymin], '.');
N    = N + 1;
strLegend(N) = {sprintf('Correlation = %4.3f', corr)}; subset(N) = h4;

%=== add counts in each quadrant
us       = find(strcmp('US', stateNames0));
xx       = x2(us);       % quadrant defined by us vax rate
yy       = y2(us);       % quadrant definded by US case rate
x2       = x2(1:end-1);  % omit US
y2       = y2(1:end-1);  % omit US
count(1) = length(find(x2 <= xx & y2 <= yy));  xpos(1) = (xmin+xx)/2; ypos(1) = (ymin+yy)/2; 
count(2) = length(find(x2 >  xx & y2 <= yy));  xpos(2) = (xmax+xx)/2; ypos(2) = (ymin+yy)/2;
count(3) = length(find(x2 <= xx & y2 >  yy));  xpos(3) = (xmin+xx)/2; ypos(3) = (ymax+yy)/2;
count(4) = length(find(x2 >  xx & y2 >  yy));  xpos(4) = (xmax+xx)/2; ypos(4) = (ymax+yy)/2;
for i=1:4
  h = text(xpos(i), ypos(i), sprintf('%d states', count(i)));
  set(h,'Color','k'); set(h, 'BackgroundColor', 'y');  set(h,'FontWeight', 'bold'); set(h,'FontSize', 14);
  set(h,'HorizontalAlignment','Center'); set(h,'VerticalAlignment','Middle');
end

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
xtickformat('%1.0f%%');
legend(subset, strLegend, 'Location', 'NorthWest', 'Fontsize', 12);
title(strTitle, 'Fontsize', 16);

%---------------------------------------------------------------------------------------------
%=== 5. SCATTER PLOT OF BA1 CASES VS BA2 CASES AT STATE LEVEL
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== set date window for BA2
date1       = '03/01/2022';
date2       = char(state.dates(end));
d1          = find(strcmp(date1, state.dates));
d2          = find(strcmp(date2, state.dates));

%=== set date window for BA1
date3       = '12/01/2021';
date4       = '02/28/2022';
d3          = find(strcmp(date3, state.dates));
d4          = find(strcmp(date4, state.dates));

%===- get BA1 data
x2          = nansum(state.newCases(d3:d4,:),1)' ./ length(d3:d4);  % daily death rate
x2          = 100000 * x2 ./ state.population;

%===- get BA2 data
y2          = nansum(state.newCases(d1:d2,:),1)' ./ length(d1:d2);  % daily death rate
y2          = 100000 * y2 ./ state.population;

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); 
strLegend(1) = {sprintf('State-Level Data')}; subset(1) = h1;

%=== add state short names inside circles
stateNames0 = state.names0;
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
strTitle  = sprintf('Daily Case Rate During BA2 Phase vs Daily Case Rate During BA1 Phase');
xTitle    = sprintf('Daily Case Rate During BA1 Phase');
yTitle    = sprintf('Daily Case Rate During BA2 Phase');
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at US
N  = 1;
us = find(strcmp('US', stateNames0));
x3 = x2(us);
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US New Case Rate During BA1 Phase (%s to %s) = %2.1f', date3, date4, x3)}; subset(N) = h2;

%=== horizontal line at US death rate
y3 = y2(us);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US New Case Rate During BA2 Phase (%s to %s) = %2.1f', date1, date2, y3)}; subset(N) = h3;

%=== compute correlation
R    = corrcoef(x2,y2);
corr = R(1,2);
h4   = plot([xmin,xmin], [ymin,ymin], '.');
N    = N + 1;
strLegend(N) = {sprintf('Correlation = %4.3f', corr)}; subset(N) = h4;

%=== add counts in each quadrant
us       = find(strcmp('US', stateNames0));
xx       = x2(us);       % quadrant defined by us vax rate
yy       = y2(us);       % quadrant definded by US case rate
x2       = x2(1:end-1);  % omit US
y2       = y2(1:end-1);  % omit US
count(1) = length(find(x2 <= xx & y2 <= yy));  xpos(1) = (xmin+xx)/2; ypos(1) = (ymin+yy)/2; 
count(2) = length(find(x2 >  xx & y2 <= yy));  xpos(2) = (xmax+xx)/2; ypos(2) = (ymin+yy)/2;
count(3) = length(find(x2 <= xx & y2 >  yy));  xpos(3) = (xmin+xx)/2; ypos(3) = (ymax+yy)/2;
count(4) = length(find(x2 >  xx & y2 >  yy));  xpos(4) = (xmax+xx)/2; ypos(4) = (ymax+yy)/2;
for i=1:4
  h = text(xpos(i), ypos(i), sprintf('%d states', count(i)));
  set(h,'Color','k'); set(h, 'BackgroundColor', 'y');  set(h,'FontWeight', 'bold'); set(h,'FontSize', 14);
  set(h,'HorizontalAlignment','Center'); set(h,'VerticalAlignment','Middle');
end

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
legend(subset, strLegend, 'Location', 'NorthWest', 'Fontsize', 12);
title(strTitle, 'Fontsize', 16);

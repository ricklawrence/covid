function plotWestConn4(town, state, county, countyUS, figureNum)
%
% figures for west conn Q4: relationship between vax rates, natural immunity, and new case rates
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> plotWestConn4\n');

%---------------------------------------------------------------------------------------------
%=== 1. SCATTER PLOT OF VACCINATION RATE VS NEW CASE RATES AT STATE LEVEL
%figureNum = figureNum + 1;
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
%return;

%---------------------------------------------------------------------------------------------
%=== 2. SCATTER PLOT OF VACCINATION RATE VS LONG-TERM CASES AT STATE LEVEL
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get vax data
x2          = state.vaxData(end,:,26)';    % completed 5+

%=== set date window for long-term rates in next 4 figures
numDays     = 29;
lag         = 0;                         % lag from positive test to death for mortality calculation
date2       = char(state.vaxDates(end));
d2          = state.numDates;
date1       = char(state.dates(d2-numDays));
d1          = find(strcmp(date1, state.dates));

%===- get long-term case rate
y2          = nansum(state.newCases(d1:d2,:),1)' ./ length(d1:d2);  % daily death rate
y2          = 100000 * y2 ./ state.population;
stateNames0 = state.names0;

%=== eliminate ID with zero 12+ vax data
filter      = x2 > 0;
x2          = x2(filter);
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

%=== set labels
strTitle  = sprintf('Daily Case Rate (since %s) vs Percent of Eligible (Age 5+) Population Fully Vaccinated', date1);
xTitle    = sprintf('Percent of Age 5+ Population Fully Vaccinated');
yTitle    = sprintf('Daily Case Rate (Per 100,000 Residents) since %s', date1);
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at US initiated
N  = 1;
us = find(strcmp('US', stateNames0));
x3 = x2(us);
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Fully Vaccinated Rate = %2.1f%%', x3)}; subset(N) = h2;

%=== horizontal line at US death rate
y3 = y2(us);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Daily Case Rate since %s = %3.2f', date1, y3)}; subset(N) = h3;

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
%=== 3. SCATTER PLOT OF VACCINATION RATE VS LONG-TERM DEATHS AT STATE LEVEL
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get vax data
x2          = state.vaxData(end,:,26)';    % completed 5+

%===- get long-term death rate
y2          = nansum(state.newDeaths(d1:d2,:),1)' ./ length(d1:d2);  % daily death rate
y2          = 100000 * y2 ./ state.population;
stateNames0 = state.names0;

%=== eliminate ID with zero 12+ vax data
filter      = x2 > 0;
x2          = x2(filter);
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

%=== set labels
strTitle  = sprintf('Daily Death Rate (since %s) vs Percent of Eligible (Age 5+) Population Fully Vaccinated', date1);
xTitle    = sprintf('Percent of Age 5+ Population Fully Vaccinated');
yTitle    = sprintf('Daily Death Rate (Per 100,000 Residents) since %s', date1);
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ylim([0,1.4]);
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at US initiated
N  = 1;
us = find(strcmp('US', stateNames0));
x3 = x2(us);
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Fully Vaccinated Rate = %2.1f%%', x3)}; subset(N) = h2;

%=== horizontal line at US death rate
y3 = y2(us);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Daily Death Rate since %s = %3.2f', date1, y3)}; subset(N) = h3;

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
%=== 4. SCATTER PLOT OF VACCINATION RATE VS LONG-TERM MORTALITY RATE AT STATE LEVEL
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get vax data
x2          = state.vaxData(end,:,26)';    % completed 5+

%===- get long-term mortality rate
y2          = nansum(state.newDeaths(d1:d2,:),1)' ./ length(d1:d2);         % daily death rate
y2          = 100000 * y2 ./ state.population;
y3          = nansum(state.newCases(d1-lag:d2-lag,:),1)' ./ length(d1:d2);  % lagged daily case rate
y3          = 100000 * y3 ./ state.population;
y2          = 100 * y2 ./ y3;
stateNames0 = state.names0;

%=== eliminate ID with zero 12+ vax data
filter      = x2 > 0;
x2          = x2(filter);
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

%=== set labels
strTitle  = sprintf('Mortality Rate (since %s) vs Percent of Eligible (Age 5+) Population Fully Vaccinated', date1);
xTitle    = sprintf('Percent of Age 5+ Population Fully Vaccinated');
yTitle    = sprintf('Mortality Rate since %s', date1);
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at US initiated
N  = 1;
us = find(strcmp('US', stateNames0));
x3 = x2(us);
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Fully Vaccinated Rate = %2.1f%%', x3)}; subset(N) = h2;

%=== horizontal line at US death rate
y3 = y2(us);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Mortality Rate since %s = %3.2f%%', date1, y3)}; subset(N) = h3;

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

%=== add explanatory text
if lag > 0
  strText = sprintf('Mortality rate is the number of deaths as percent of cases over the same period %d days earlier.', lag);
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
ytickformat('%2.1f%%');
legend(subset, strLegend, 'Location', 'NorthWest', 'Fontsize', 12);
title(strTitle, 'Fontsize', 16);

%---------------------------------------------------------------------------------------------
%=== 5. SCATTER PLOT OF NEW CASE RATE VS CUMULATIVE CASE RATE AT STATE LEVEL
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);
clear strLegend;

%=== get cumulative case as percent at beginning of period
date2       = char(state.dates(end));
cumRate     = state.features(:,:,8);                                 % cum case rate per 100K
x2          = cumRate(end-numDays,:)' ./ 1000;                       % cumRate at beginning as percent

%===- get long-term case rate
y2          = nansum(state.newCases(d1:d2,:),1)' ./ length(d1:d2);  % daily death rate
y2          = 100000 * y2 ./ state.population;
stateNames0 = state.names0;

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

%=== set labels
strTitle  = sprintf('Daily Case Rate (since %s) vs Cumulative Case Rate', date1);
xTitle    = sprintf('Cumulative Case Rate (as %% of Residents)');
yTitle    = sprintf('Daily Case Rate (Per 100,000 Residents) since %s', date1);
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at US cumulative case rate
us = find(strcmp('US', stateNames0));
x3 = x2(us);
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2);
strLegend(2) = {sprintf('US Cumulative Case Rate = %2.1f%%', x3)}; subset(2) = h2;

%=== horizontal line at US new case rate
y3 = y2(us);
h3 = plot([xmin,xmax], [y3,y3], 'b:', 'LineWidth', 2);
strLegend(3) = {sprintf('US New Case Rate = %2.1f', y3)}; subset(3) = h3;

%=== fit data
[~, sortIndex] = sort(x2);
x3    = x2(sortIndex);
y3    = y2(sortIndex);
P     = polyfit(x3,y3,1);
yfit3 = polyval(P,x3);
h4    = plot(x3,yfit3,'k-'); set(h4, 'LineWidth', 1); hold on;

%=== compute correlation for legend
R    = corrcoef(x2,y2);
corr = R(1,2);
strLegend(4) = {sprintf('Correlation = %4.3f', corr)}; subset(4) = h4;

%=== add counts in each quadrant
us       = find(strcmp('US', stateNames0));
xx       = x2(us);       % quadrant defined by us vax rate
yy       = y2(us);       % quadrant definded by US test rate
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
legend(subset, strLegend, 'Location', 'NorthWest', 'Fontsize', 16);
title(strTitle, 'Fontsize', 16);

%---------------------------------------------------------------------------------------------
%=== 6. SCATTER PLOT OF VACCINATION RATE VS RATIO OF HOSPITALIZED / NEW CASE RATE
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get vax data
x2          = state.vaxData(end,:,26)';    % completed 5+

%=== get ratio of hospitalization rate to new case rate
d            = max(find(~isnan(state.features(:,52,6))));  % latest data with valid hospitalization data
d            = state.numDates - 2;                         % insure the hospitalization data is up to date
date2        = char(state.dates(d));
ratio        = state.features(d,:,9)';
y2           = ratio;
stateNames0  = state.names0;

%=== eliminate ID with zero 12+ vax data
filter      = x2 > 0;
x2          = x2(filter);
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

%=== set labels
strTitle  = sprintf('Ratio of Current Hospitalizations to Daily New Cases vs Percent of Eligible (Age 5+) Population Fully Vaccinated');
xTitle    = sprintf('Percent of Age 5+ Population Fully Vaccinated');
yTitle    = sprintf('Ratio of Current Hospitalizations to Daily New Case Rate');
strSource = sprintf('%s\n%s', 'Data Source: CDC and COVID-19 Hospitalization Tracking Project', parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at US initiated
N  = 1;
us = find(strcmp('US', stateNames0));
x3 = x2(us);
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Fully Vaccinated Rate = %2.1f%%', x3)}; subset(N) = h2;

%=== horizontal line at US ratio
y3 = y2(us);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Hospitalization Ratio = %3.2f', y3)}; subset(N) = h3;

%=== compute correlation
f    = ~isnan(y2);
R    = corrcoef(x2(f),y2(f));
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

%=== add explanatory text
skip = 1;
if ~skip
  strText = sprintf('');
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
ytickformat('%3.2f');
legend(subset, strLegend, 'Location', 'NorthEast', 'Fontsize', 12);
title(strTitle, 'Fontsize', 16);

%---------------------------------------------------------------------------------------------
%=== 7. SCATTER PLOT OF NEW CASE RATE VS STATE TEMPERATURE
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);
clear strLegend;

%=== get data
date2       = char(state.dates(end));
%date2       = '12/02/2020';
%date2       = datestr(datenum(date2)-365, 'mm/dd/yyyy');  % 1 year ago
d           = find(strcmp(date2, state.dates));
numDays     = 7;
temperature = state.temperature ;                                    % state temperature
x2          = temperature;                                           % state temperature
y2          = (cumRate(d,:)' - cumRate(d-numDays,:)') / numDays;     % daily  new cases over the period
stateNames0 = state.names0;
if ~strcmp(date2, state.dates(end))
  y2(7)
end

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

%=== set labels
strTitle  = sprintf('New Case Rate vs Mean Fall Temperature');
xTitle    = sprintf('Mean Fall Temperature (degrees Fahrenheit)');
yTitle    = sprintf('New Case Rate (Per 100,000 Residents)');
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at US cumulative case rate
us = find(strcmp('US', stateNames0));
x3 = x2(us);
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2);
strLegend(2) = {sprintf('US Mean Fall Temperature = %2.0f', x3)}; subset(2) = h2;

%=== horizontal line at US new case rate
y3 = y2(us);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2);
strLegend(3) = {sprintf('US New Case Rate = %2.1f', y3)}; subset(3) = h3;

%=== compute correlation
R    = corrcoef(x2,y2);
corr = R(1,2);
h4 = plot([xmin,xmin], [ymin,ymin], '.');
strLegend(4) = {sprintf('Correlation = %4.3f', corr)}; subset(4) = h4;

%=== add counts in each quadrant
us       = find(strcmp('US', stateNames0));
xx       = x2(us);       % quadrant defined by us vax rate
yy       = y2(us);       % quadrant definded by US test rate
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
xtickformat('%2.0f');
legend(subset, strLegend, 'Location', 'NorthWest', 'Fontsize', 16);
title(strTitle, 'Fontsize', 16);

%---------------------------------------------------------------------------------------------
%=== 8. SCATTER PLOT OF UNVACCINATED NEW CASE RATE VS TOTAL NEW CASE RATE
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);
clear strLegend;

%=== compute new case rate among unvaccinated
IRratio        = 5.5;                             % ratio of vaccinated to unvaccinated case rate (incidence)
fracVax        = 0.01*state.vaxData(end,:,9)';    % fraction of total population fully vaccinated
fracUnvax      = 1 - fracVax;
factor         = fracVax + fracUnvax * IRratio;
newCaseRates   = state.features(end,:,2)';
newCaseRatesV  = newCaseRates  ./ factor;
newCaseRatesUV = newCaseRatesV * IRratio;

%=== get new case rates from 1 year ago
numDays        = 365;
date1          = char(state.dates(end-numDays));
newCaseRates1  = state.features(end-numDays,:,2)';

%=== get dates
date2       = char(state.dates(end));
x2          = newCaseRates1;   % new case rate per 100000 residents
y2          = newCaseRatesUV;  % new case rate per 100000 unvaccinated residents
stateNames0 = state.names0;
[x2(7) y2(7)];

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); 
strLegend(1) = {sprintf('Data as of %s and %s', date2, date1)}; subset(1) = h1;

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
strTitle  = sprintf('New Case Rates: Unvaccinated Today vs One Year Ago');
xTitle    = sprintf('New Case Rate (per 100,000 Residents) One Year Ago');
yTitle    = sprintf('New Case Rate (Per 100,000 Unvaccinated Residents)');
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at total US new case rate
us = find(strcmp('US', stateNames0));
x3 = x2(us);
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2);
strLegend(2) = {sprintf('US New Case Rate on %s = %2.1f', date1, x3)}; subset(2) = h2;

%=== horizontal line at US unvaccinated new case rate 
y3 = y2(us);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2);
strLegend(3) = {sprintf('US New Case Rate (Unvaccinated) on %s = %2.1f', date2, y3)}; subset(3) = h3;

%=== diagonal line
h4 = plot([xmin,xmax],[xmin,xmax], 'k-', 'LineWidth', 1);
strLegend(4) = {sprintf('Diagonal Line')}; subset(4) = h4;

%=== compute correlation
R    = corrcoef(x2,y2);
corr = R(1,2);
h5 = plot([xmin,xmin], [ymin,ymin], '.');
%strLegend(5) = {sprintf('Correlation = %4.3f', corr)}; subset(5) = h5;

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
xtickformat('%2.0f');
legend(subset, strLegend, 'Location', 'NorthWest', 'Fontsize', 12);
title(strTitle, 'Fontsize', 14);

%=== return if no testing data to do test positivity scatter plot
if isnan(state.features(end,52,4))
  return;
end

%---------------------------------------------------------------------------------------------
%=== 9. SCATTER PLOT OF NEW CASE RATE VS TEST RATE RATE AT STATE LEVEL WITH TEST POSITIVITY LINES
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);
clear strLegend;

%=== get most recent date plus previous date (eg 1 week ago)
date2            = state.lastDate;                                         % latest date
dateIndex2       = find(strcmp(date2, state.dates));

%=== get new case rates and new test rates
xFeatureTitle = state.featureTitles(4);
yFeatureTitle = state.featureTitles(2);
x2            = state.features(dateIndex2,:,4)';  % new test rate
y2            = state.features(dateIndex2,:,2)';  % new case rate
stateNames0   = state.names0;
strTitle      = sprintf('New Case Rate vs New Test Rate for all States');

%=== all features should be positive unless there is a data glitch
x2 = max(x2, 0);
y2 = max(y2, 0);

%=== set clip bounds on test rates
minTestRate = 0;     % min test rate             
maxTestRate = 1200;  % max test rate              

%=== clip test rates
x2 = max(x2, minTestRate);
x2 = min(x2, maxTestRate);

%=== set axis limits
xmin = 100*floor(min([x2])/100);
xmax = 100*ceil(max([x2])/100);
ymin = 10*floor(min([y2])/10);
ymax = 10*ceil(max([y2])/10);
ymin = 0;                  % always zero
ymax = ymax + 16;          % leave room at top of figure for note etc

%=== plot big circles for each point
h2 = plot(x2, y2, 'o');  hold on;
set(h2,'Color','k'); 
set(h2,'Markersize', 20); % add big circles
subset(1) = h2;
strLegend(1) = {sprintf('Data as of %s', date2)};

%=== partition based on latest vaccination rates
partition = 0;
if partition
  vaxRates = state.vaxData(end,:,18)';
  us       = find(strcmp(state.names0, 'US'));
  index1   = find(vaxRates > vaxRates(us));
  index2   = find(vaxRates < vaxRates(us));
  h4       = plot(x2(index1), y2(index1), 'o', 'Color','b', 'Markersize', 20); hold on;
  h5       = plot(x2(index2), y2(index2), 'o', 'Color','r', 'Markersize', 20); hold on;
  strLegend(2) = {sprintf('Blue circles indicate states with higher vaccination rates than US')}; subset(2) = h4;
  strLegend(3) = {sprintf('Red  circles indicate states with lower  vaccination rates than US')}; subset(3) = h5;
end

%=== set axis limits
xlim([xmin xmax]);
ylim([ymin ymax]);

%=== add state abbreviations
for i=1:length(x2)
  h1 = text(x2(i),y2(i), char(stateNames0(i))); 
  set(h1,'HorizontalAlignment','Center'); 
  if strcmp(stateNames0(i), 'US') || strcmp(stateNames0(i), 'CT')
    set(h1,'Color','b'); 
    set(h1,'FontWeight', 'bold');
    set(h1,'FontSize', 14);
  else
    set(h1,'Color','k'); 
    set(h1,'FontWeight', 'normal');
    set(h1,'FontSize', 8);
  end
  hold on;
end

%=== plot lines for constant positive test rates
positiveRates1 = [0.01 0.02 0.03 0.04 0.05 : 0.05 : 0.60];
yLimit  = max([y1;y2]);  % max y value for positive test rate lines
xfit(1) = xmin;
xfit(2) = xmax;
for i=1:length(positiveRates1)
  positiveRate = positiveRates1(i);
  yfit         = positiveRate .* xfit;
  if yfit(2) > yLimit                 % limit the length of the positivity lines
    xfit(2) = yLimit / positiveRate;  
    yfit(2) = yLimit;
  end
  h            = plot(xfit,yfit,'r-');  set(h, 'LineWidth', 1); hold on;
  strText      = sprintf('%2.0f%%', 100*positiveRate);
  x0           = xfit(2);
  y0           = yfit(2);
  h            = text([x0,x0],[y0,y0], strText); 
  set(h,'Color','r', 'HorizontalAlignment','Left', 'FontWeight','bold', 'FontSize',10);
end

%=== add explanatory text
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = xmin + 0.01*(xmax - xmin);
y0   = ymin + 0.92*(ymax - ymin);
strText1 = sprintf('The open circles show the current values for each state.');
strText2 = sprintf('The solid Red lines show constant Test Positivity Rates.');
strText  = sprintf('%s\n%s\n%s', strText1, strText2);
strText  = sprintf('%s\n%s', strText1, strText2);
h = text(x0, y0, strText); 
set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
set(h,'HorizontalAlignment','Left'); set(h,'VerticalAlignment','Top');

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add data source
x0        = xmin - 0.09*(xmax - xmin);
y0        = ymin - 0.11*(ymax - ymin);  
strSource = sprintf('%s\n%s', parameters.covidTrackingSource, parameters.rickAnalysis);
h = text(x0, y0, strSource); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 1);
set(gca,'FontSize',14);
xlabel(xFeatureTitle);
ylabel(yFeatureTitle);
legend(subset, strLegend, 'Location', 'NorthWest', 'FontSize', 14);
title(strTitle, 'Fontsize', 16);

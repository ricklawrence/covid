function plotFirstDoseAcceleration(state, figureNum)
%
% plot bar chart of first dose acceleration for all states
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> plotFirstDoseAcceleration\n');

%=== set key dates
date1    = '10/19/2021';   % boosters
date2    = '11/02/2021';   % age 5-11
numDays  = datenum(date2) - datenum(date1);
datenum0 = datenum(date1) - numDays;
date0    = datestr(datenum0, 'mm/dd/yyyy');

%=== get dates
dates      = state.vaxDates;
numDates   = length(dates);

%=== compute first-doses in reference and booster windows plus acceleration
i0            = find(strcmp(date0, dates));
i1            = find(strcmp(date1, dates));
i2            = find(strcmp(date2, dates));
cumFirstDoses = state.vaxData(:,:,3);      
cumFirstDoses = 100000 * cumFirstDoses ./ repmat(state.population', numDates, 1);
doses1        = (cumFirstDoses(i1,:) - cumFirstDoses(i0,:)) / (i1 - i0);   % reference window
doses2        = (cumFirstDoses(i2,:) - cumFirstDoses(i1,:)) / (i2 - i1);   % booster window
acceleration  = doses2' ./ doses1' - 1;

%=== compute booster doses in booster window
cumBoosters   = state.vaxData(:,:,19);
cumBoosters   = 100000 * cumBoosters ./ repmat(state.population', numDates, 1);
doses3        = (cumBoosters(i2,:) - cumBoosters(i1,:)) / (i2 - i1);       % booster window

%=== sort acceleration
stateNames = state.names;
[~,sortIndex] = sort(acceleration, 'descend');
acceleration  = max(acceleration,-1);           % clip big negative values

%=== save acceleration data and key dates for plots of individual states
data.acceleration = acceleration;
data.date0        = date0;
data.date1        = date1;
data.date2        = date2;

%-------------------------------------------------------------------------------------------------------------
%=== 1. HORIZONTAL BAR CHART OF FIRST DOSE ACCELERATION FOR ALL STATES
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get data
us             = find(strcmp(state.names0, 'US'));
sortIndex      = setdiff(sortIndex, us, 'stable');   % remove US
yValues        = 100*acceleration(sortIndex);
yLabels        = stateNames(sortIndex);
yValues        = flip(yValues);     % reverse so biggest is at top of bar chart
yLabels        = flip(yLabels);     % reverse so biggest is at top of bar chart
y              = 1:length(yLabels);

%=== horizontal bar chart
h = barh(y, yValues, 'stacked'); 
set(h(1), 'FaceColor', 'r'); hold on;

%=== labels
strTitle     = sprintf('First Dose Acceleration');
xLabel       = sprintf('First Dose Acceleration (%%))');
strSource    = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add value next to US and CT
stateName = 'Connecticut';
s  = find(strcmp(stateName, yLabels));
x0 = yValues(s);
y0 = y(s);
h1 = text(max(x0,0),y0,sprintf(' %s = %2.1f%%', stateName, x0));
s  = find(strcmp('United States', yLabels));
x0 = yValues(s);
y0 = y(s);
h2 = text(max(x0,0),y0,sprintf(' United States = %2.1f%%',x0));
set(h1,'Color','k'); set(h1,'Horiz','Left'); set(h1, 'Vert', 'middle'); set(h1,'FontSize', 10); set(h1,'FontWeight', 'bold');
set(h2,'Color','k'); set(h2,'Horiz','Left'); set(h2, 'Vert', 'middle'); set(h2,'FontSize', 10); set(h2,'FontWeight', 'bold');

%=== add explanatory text
strText = sprintf('Reference Window: %s to %s\nBooster Window: %s to %s', date0, date1, date1, date2);
x0      = xmin + 0.70*(xmax - xmin);
y0      = ymin + 0.50*(ymax - ymin);
h       = text(x0, y0, strText); 
set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 14);
set(h,'HorizontalAlignment','Right'); set(h,'VerticalAlignment','Top');

%=== add data source
x0   = xmin - 0.150*(xmax - xmin);
y0   = ymin - 0.095*(ymax - ymin);
h = text(x0, y0, strSource); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== axis labels and everything else
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'FontSize',10);
set(gca,'YTick',y);
set(gca,'YTickLabel',yLabels(y));
xlabel(sprintf('%s', xLabel), 'FontSize', 14);
title(sprintf('%s', strTitle), 'FontSize', 16);

%---------------------------------------------------------------------------------------------
%=== 2. SCATTER PLOT OF BOOSTERS VS FIRST DOSES
skip = 1;
if ~skip
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get data
index       = find(~strcmp(state.names0, 'US'));
x2          = doses2(index);  % first doses in booster window
y2          = doses3(index);  % boosters in booster window
stateNames0 = state.names0(index);

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); 
strLegend(1) = {sprintf('Booster Window: %s to %s', date1, date2)};

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
strTitle  = sprintf('Booster Doses vs First Doses During the Booster Window %s to %s', date1, date2);
xTitle    = sprintf('Daily First Doses per 100,000 Residents');
yTitle    = sprintf('Daily Booster Doses per 100,000 Residents');
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at median first dose rate
us = find(strcmp('US', stateNames0));
x3 = median(x2);
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2);
strLegend(2) = {sprintf('Median First Doses = %2.1f', x3)}; 

%=== horizontal line at median booster rat
y3 = median(y2);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2);
strLegend(3) = {sprintf('Median Booster Doses = %2.1f', y3)}; 

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
legend(strLegend, 'Location', 'NorthEast', 'Fontsize', 16);
title(strTitle, 'Fontsize', 16);
end

%-------------------------------------------------------------------------------------------------------------
%=== PLOT INDIVIDIAL STATES

%=== connecticut is always first
figureNum = figureNum + 1;
stateName = 'Connecticut';
plotStateBoosterShots(stateName, state, data, figureNum);
fprintf('%s\n', stateName);

%=== other top states
for ss=1:7
  figureNum = figureNum + 1;
  s         = sortIndex(ss);
  stateName = char(stateNames(s));
  plotStateBoosterShots(stateName, state, data, figureNum);
  fprintf('%s\n', stateName);
end

%=== plot weird states
for ss=46:51
  figureNum = figureNum + 1;
  s         = sortIndex(ss);
  stateName = char(stateNames(s));
  plotStateBoosterShots(stateName, state, data, figureNum);
  fprintf('%s\n', stateName);
end


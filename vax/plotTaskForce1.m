function plotTaskForce1(town, state, county, figureNum)
%
% do subset of task force plots
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> plotTaskForce1\n');

stateName = 'Connecticut';
s = find(strcmp(stateName, state.names));

%---------------------------------------------------------------------------------------------
%=== 1. SCATTER PLOT OF VACCINATION RATE VS NEW CASE RATES AT TOWN LEVEL
%figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get latest data for towns in fairfield county
index       = find(strcmp(town.countyNames, 'Fairfield'));
x2          = 100*town.vaxDataN(end,index,10,2)';  % all ages
y2          = town.features(end,index,2)';         % new case rate
townNames   = town.names(index);
date2       = char(town.dates(end));

%=== get town data from previous week
numDays     = 7;
x1          = 100*town.vaxDataN(end-1,index,10,2)';  % completed 5+ (weekly)
y1          = town.features(end-7,index,2)';         % new case rate (daily)
date1       = char(town.dates(end-7));

%=== insure case rates are not negative
y1 = max(y1,0);
y2 = max(y2,0);

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); 
clear strLegend;
strLegend(1) = {sprintf('Data as of %s', date2)}; subset(1) = h1;

%=== add state town names inside circles
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

%=== plot small dots for each each previous point
h2 = plot(x1, y1, '.', 'Color', 'k', 'MarkerSize', 10); 
strLegend(2) = {sprintf('Data as of %s', date1)}; subset(2) = h2;

%=== plot lines connecting current data to previous data
colormap(jet(length(x2)));
for i=1:length(x2)
  plot([x1(i), x2(i)], [y1(i), y2(i)], ':', 'LineWidth', 1); hold on;
end
%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== compute population-weighted means
population   = town.population(index,1);         % all ages
population5  = town.populationAge(index,10);     % age 5+
meanX        = sum(population5 .* x2) ./ sum(population5);    % vax  data is for age 5+
meanY        = sum(population  .* y2) ./ sum(population);     % case data is for all ages

%=== get actual county case rate
c            = find(strcmp('Fairfield', county.names));
meanY        = county.features(end,c,2)';         % new case rate

%=== vertical line at mean vaccinated
h2 = plot([meanX,meanX], [ymin,ymax], 'r:', 'LineWidth', 2);
strLegend(3) = {sprintf('Fairfield County Fully Vaccinated Rate = %2.1f%%', meanX)}; subset(3) = h2;

%=== horizontal line at mean new cases
h3 = plot([xmin,xmax], [meanY, meanY], 'b:', 'LineWidth', 2);
strLegend(4) = {sprintf('Fairfield County New Case Rate = %2.1f', meanY)}; subset(4) = h3;

%=== set labels
strTitle  = sprintf('Fairfield County: New Case Rates vs Percent of Eligible (Age 5+) Population Fully Vaccinated');
xTitle    = sprintf('Percent of Population Fully Vaccinated');
yTitle    = sprintf('New Case Rate (Per 100,000 Residents)');
strText   = sprintf('The dashed lines (''jet plumes'') show the trajectory for each town over the past %d days', numDays);
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== add explanatory text
x0 = xmin + 0.01*(xmax - xmin);
y0 = ymin + 0.84*(ymax - ymin);
h  = text(x0, y0, strText); 
set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
set(h,'HorizontalAlignment','Left'); set(h,'VerticalAlignment','Top');

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
return;

%---------------------------------------------------------------------------------------------
%=== 2. DAILY PLOT OF INITIATED AND COMPLETED 12+ VACCINATIONS
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get state and US data
ct           = find(strcmp(stateName, state.names));
us           = find(strcmp('United States', state.names));
d1           = find(strcmp('05/16/2021', state.vaxDates));  % first day of json state data
d2           = length(state.vaxDates);
dates        = state.vaxDates(d1:d2);
initiatedCT  = state.vaxData(d1:d2,ct,17);
completedCT  = state.vaxData(d1:d2,ct,18);
initiatedUS  = state.vaxData(d1:d2,us,17);
completedUS  = state.vaxData(d1:d2,us,18);

%=== get ridgefield data
rf              = find(strcmp('Ridgefield', town.names));
datesRF         = town.vaxDates;
[~,i1,i2]       = intersect(dates, datesRF);
initiatedRF     = NaN(length(dates),1);
completedRF     = NaN(length(dates),1);
initiatedRF(i1) = 100*town.vaxDataN(i2,rf,9,1);
completedRF(i1) = 100*town.vaxDataN(i2,rf,9,2);

%=== get dates
numDates = length(dates);
interval = 28;
d6       = numDates;
d5       = mod(numDates,interval);    % so last date is final tick mark
if d5 == 0
  d5     = interval;
end
x        = d5:interval:d6;            % show only these dates
xLabels  = dates;

%=== plots
y1 = initiatedRF(i1);
y2 = initiatedCT;
y3 = initiatedUS;
y4 = completedRF(i1);
y5 = completedCT;
y6 = completedUS;
plot(i1, y1,'k:', 'LineWidth', 2); hold on;
plot(y2,'b:',     'LineWidth', 2); hold on;
plot(y3,'r:',     'LineWidth', 2); hold on;
plot(i1, y4,'k-', 'LineWidth', 2); hold on;
plot(y5,'b-',     'LineWidth', 2); hold on;
plot(y6,'r-',     'LineWidth', 2); hold on;

%=== add values next to lines
colors = ['k','b','r','k','b','r'];
y      = [y1(end), y2(end), y3(end), y4(end), y5(end), y6(end)];
for p=1:6
  x0 = 1.005*length(dates);
  y0 = y(p);
  t0 = sprintf('%2.1f', y0);
  %text(x0,y0,t0, 'vert','middle', 'horiz','left', 'FontWeight','bold', 'FontSize',10, 'color',colors(p));
end

%=== get labels for plot
strLegends(1) = {sprintf('%s Initiated Vaccination    (Latest = %3.1f%%)', 'Ridgefield',y1(end))};
strLegends(2) = {sprintf('%s Initiated Vaccination   (Latest = %3.1f%%)', stateName,    y2(end))};
strLegends(3) = {sprintf('United States Initiated Vaccination (Latest = %3.1f%%)',      y3(end))};
strLegends(4) = {sprintf('%s Completed Vaccination    (Latest = %3.1f%%)', 'Ridgefield',y4(end))};
strLegends(5) = {sprintf('%s Completed Vaccination   (Latest = %3.1f%%)', stateName,    y5(end))};
strLegends(6) = {sprintf('United States Completed Vaccination (Latest = %3.1f%%)',      y6(end))};
strTitle      = sprintf('Age 12+: Initiated and Completed Vaccinations in Ridgefield, %s and United States', stateName);
xTitle        = sprintf('Report Date');
yTitle        = sprintf('Percent of Age 12+ Population');
strSource     = sprintf('%s\n%s','Data Source: CDC and http://data.ct.gov', parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add data source
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.085*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 2);
set(gca,'FontSize',  12);
set(gca,'XTick',x);  
set(gca,'XTickLabel',xLabels(x));
xlabel(xTitle, 'FontSize', 12);
ylabel(yTitle, 'FontSize', 12);
ytickformat('%2.0f%%');
legend(strLegends,'FontSize', 12, 'Location','SouthEast', 'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle,   'FontSize', 16);
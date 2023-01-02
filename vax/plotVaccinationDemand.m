function plotVaccinationDemand(town, state, county, stateName, figureNum)
%
% do plots characterizing vaccine demand at state and county level
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> plotVaccinationDemand\n');
s = find(strcmp(stateName, state.names));

%---------------------------------------------------------------------------------------------
%=== 1. PLOT ACTUAL VS EXPECTED SECOND DOSES
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get time series
date1        = '03/15/2021';
d1           = find(strcmp(date1, state.vaxDates));  % first day of json state data
d2           = length(state.vaxDates);
dates        = state.vaxDates(d1:d2);
dose2(:,:,1) = state.vaxDataD(d1:d2,:,15);                  % pfizer  competed
dose2(:,:,2) = state.vaxDataD(d1:d2,:,14);                  % moderna completed
dose1(:,:,1) = state.vaxDataD(d1:d2,:,13) - dose2(:,:,1);   % pfizer  administered minus completed
dose1(:,:,2) = state.vaxDataD(d1:d2,:,12) - dose2(:,:,2);   % moderna administered minus completed
dose1(:,:,3) = state.vaxDataD(d1:d2,:,7);                   % J&J initiated and completed

%=== the pfizer & moderna first doses are computed using administered doses which are ADMINISTERED in the state
%=== the total pfizer + moderna INITIATED vaccinations are for RESIDENTS and hence are what we want
%=== we do not know these for pfizer and moderna separately ... hence we scale each to preserve correct sum of pfizer + moderna
rescale = 1;
if rescale
  vaxData      = state.vaxDataD;
  firstDosePM0 = vaxData(:,:,3)  - vaxData(:,:,7);      % all initiated minus J&J
  firstDosePM1 = vaxData(:,:,13) - vaxData(:,:,15) ...  % admin minus completed for pfizer
               + vaxData(:,:,12) - vaxData(:,:,14);
  factors      = firstDosePM0 ./ firstDosePM1;          % admin minus completed for moderna
  dose1(:,:,1) = factors(d1:d2,:) .* dose1(:,:,1);
  dose1(:,:,2) = factors(d1:d2,:) .* dose1(:,:,2);
  factors(d1:d2,7);
end

%=== get shifted data -- shifted first doses are expected second doses
d3            = 1 + 28;
d4            = length(dates);
secondDosesP  = dose2(d3:d4,      s,1);
secondDosesPE = dose1(d3-21:d4-21,s,1);
secondDosesM  = dose2(d3:d4,      s,2);
secondDosesME = dose1(d3-28:d4-28,s,2);
firstDosesP   = dose1(d3:d4,      s,1);
firstDosesM   = dose1(d3:d4,      s,2);
firstDosesJJ  = dose1(d3:d4,      s,3);

%=== smooth data via moving average
smoothData = 1;
if smoothData
  secondDosesP  = movingAverage(secondDosesP,  7);
  secondDosesPE = movingAverage(secondDosesPE, 7);
  secondDosesM  = movingAverage(secondDosesM,  7);
  secondDosesME = movingAverage(secondDosesME, 7);
  firstDosesP   = movingAverage(firstDosesP,   7);
  firstDosesM   = movingAverage(firstDosesM,   7);
  firstDosesJJ  = movingAverage(firstDosesJJ,  7);
end

%=== get dates
numDates = length(dates(d3:d4));
interval = 14;
d6       = numDates;
d5       = mod(numDates,interval);    % so last date is final tick mark
if d5 == 0
  d5     = interval;
end
x        = d5:interval:d6;            % show only these dates
xLabels  = dates(d3:d4);

%=== get data
y1 = (firstDosesP   + firstDosesM)   / 1000;
y2 = (secondDosesP  + secondDosesM)  / 1000;
y3 = (secondDosesPE + secondDosesME) / 1000;
y4 = firstDosesJJ                    / 1000;

%=== show data with full 7 days in moving average
y1(1:7) = NaN;
y2(1:7) = NaN;
y3(1:7) = NaN;
y4(1:7) = NaN;

%=== line plots
plot(y1,'k-', 'LineWidth', 2); hold on;
plot(y2,'b-', 'LineWidth', 2); hold on;
plot(y3,'r-', 'LineWidth', 2); hold on;
plot(y4,'g-', 'LineWidth', 2); hold on;

%=== make y-axis start at zero
ax   = gca; 
ymax = ax.YLim(2);
ylim([0,ymax]);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at EUA ages 12-15 date of may 10
date0 = '05/10/2021';
d0    = find(strcmp(date0, xLabels));
h2    = plot([d0,d0], [ymin,ymax], 'k:', 'LineWidth', 2);

%=== get labels for plot
strLegends(1) = {sprintf('Actual Pfizer + Moderna First Doses')};
strLegends(2) = {sprintf('Actual Pfizer + Moderna Second Doses')};
strLegends(3) = {sprintf('Expected Second Doses (Based on Previous First Doses)')};
strLegends(4) = {sprintf('Actual J&J Single Doses')};
strLegends(5) = {sprintf('FDA authorized Pfizer vaccine for Ages 12-15 on %s', char(xLabels(d0)))};
strTitle      = sprintf('%s: First and Second Doses (and Expected Second Doses)', stateName);
xTitle        = sprintf('CDC Report Date');
yTitle        = sprintf('Administered Doses (7-Day Moving Average)');

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
ytickformat('%2.0fK');
legend(strLegends,'FontSize', 10, 'Location','NorthEast', 'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle,   'FontSize', 16);

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
interval = 14;
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

%---------------------------------------------------------------------------------------------
%=== 3. SCATTER PLOT OF INITIATED AND COMPLETED 12+ VACCINATIONS AT STATE LEVEL
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get latest data
ageLabel    = 'Age 12+';
date2       = char(state.vaxDates(end));
x2          = state.vaxData(end,:,17);  % initiated 12+
y2          = state.vaxData(end,:,18);  % completed 12+
stateNames0 = state.names0;

%=== get previous data if showing it
showPrevious = 1;
numDays      = 7;
if showPrevious
  date1     = char(state.vaxDates(end-numDays));
  x1        = state.vaxData(end-numDays,:,17);
  y1        = state.vaxData(end-numDays,:,18);
else
  date1     = date2;
  x1        = x2;
  y1        = y2;
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
strTitle  = sprintf('Percent of %s Populations Initiating and Completing Vaccination', ageLabel);
xTitle    = sprintf('Percent of %s Population Initiating Vaccination', ageLabel);
yTitle    = sprintf('Percent of %s Population Completing Vaccination', ageLabel);
strText   = sprintf('The dashed lines (''jet plumes'') show the trajectory for each state over the past %d days', numDays);
strSource = sprintf('%s', parameters.vaxDataSourceCDCa);

%=== get axis limits
ylim([40,95]);   % ID has zero 12+ vax rates
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== horizontal line at herd immunity of 80% completed
h3 = plot([xmin,xmax], [80,80], 'k-', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('Herd Immunity at 80%% of Eligible Population Completing Vaccination')}; subset(N) = h3;

%=== vertical line at biden goal of 70% initiated
if strcmp(ageLabel, 'Age 18+')
  h2 = plot([70,70], [ymin,ymax], 'r-', 'LineWidth', 2);
  N  = N + 1;
  strLegend(N) = {sprintf('President Biden July 4 Goal: 70%% of US Adults Initiating Vaccination')}; subset(N) = h2;
end

%=== add explanatory text
x0 = xmin + 0.01*(xmax - xmin);
y0 = ymin + 0.88*(ymax - ymin);
h  = text(x0, y0, strText); 
set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
set(h,'HorizontalAlignment','Left'); set(h,'VerticalAlignment','Top');

%=== add data source
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.075*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== finish plot
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 1);
set(gca,'FontSize',14);
xlabel(xTitle);
ylabel(yTitle);
xtickformat('%1.0f%%');
ytickformat('%1.0f%%');
legend(subset, strLegend, 'Location', 'NorthWest', 'Fontsize', 10);
title(strTitle, 'Fontsize', 16);

%---------------------------------------------------------------------------------------------
%=== 4. SCATTER PLOT OF VACCINATION RATE VS NEW CASE RATES AT STATE LEVEL
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== set initialized or completed vaccination
m = 17; % initialized
m = 18; % completed

%=== get latest data
date2       = char(state.vaxDates(end));
x2          = state.vaxData(end,:,m)';    % initiated 12+
y2          = state.features(end,:,2)';    % new case rate
stateNames0 = state.names0;

%=== other ways of computing new cases
d1 = find(strcmp(state.dates, '06/18/2021'));                           % since US hit lowest case rate on this date
d2 = state.numDates;
%y2 = nansum(state.newCases(d1:d2,:),1) / length(d1:d2);
%y2 = 100000 * y2 ./ state.population';                                  % replace with cases per 100K since 6/18/2021
%y2 = 100*(state.features(end,:,2)' ./ state.features(end-7,:,2)' - 1);  % replace with week-over-week increase

%=== get previous data if showing it
showPrevious = 1;
numDays      = 7;
if showPrevious
  date1     = char(state.vaxDates(end-numDays));
  x1        = state.vaxData(end-numDays,:,m)';  % initiated 12+
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
strTitle  = sprintf('New Case Rates vs Percent of Eligible (Age 12+) Population Fully Vaccinated');
xTitle    = sprintf('Percent of Eligible Population Fully Vaccinated');
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
x0 = xmin + 0.99*(xmax - xmin);
y0 = ymin + 0.80*(ymax - ymin);
h  = text(x0, y0, strText); 
set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
set(h,'HorizontalAlignment','Right'); set(h,'VerticalAlignment','Top');

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
legend(subset, strLegend, 'Location', 'NorthEast', 'Fontsize', 16);
title(strTitle, 'Fontsize', 16);

%---------------------------------------------------------------------------------------------
%=== 5. SCATTER PLOT OF VACCINATION RATE VS TESTING RATE AT STATE LEVEL
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== set completed vaccination
m = 18; % completed

%=== get latest data
date2       = char(state.vaxDates(end));
x2          = state.vaxData(end,:,m)';     % completed 12+
y2          = state.features(end,:,4)';    % new test rate
stateNames0 = state.names0;

%=== get previous data if showing it
showPrevious = 1;
numDays      = 7;
if showPrevious
  date1     = char(state.vaxDates(end-numDays));
  x1        = state.vaxData(end-numDays,:,m)';   % completed 12+
  y1        = state.features(end-numDays,:,4)';  % new test rate
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
strTitle  = sprintf('New Test Rates vs Percent of Eligible (Age 12+) Population Fully Vaccinated');
xTitle    = sprintf('Percent of Eligible Population Fully Vaccinated');
yTitle    = sprintf('New Test Rate (Per 100,000 Residents)');
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
strLegend(N) = {sprintf('US New Test Rate = %2.1f', y3)}; subset(N) = h3;

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

%=== add explanatory text
x0 = xmin + 0.99*(xmax - xmin);
y0 = ymin + 0.80*(ymax - ymin);
h  = text(x0, y0, strText); 
set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
set(h,'HorizontalAlignment','Right'); set(h,'VerticalAlignment','Top');

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
legend(subset, strLegend, 'Location', 'NorthEast', 'Fontsize', 16);
title(strTitle, 'Fontsize', 16);

%---------------------------------------------------------------------------------------------
%=== 6. SCATTER PLOT OF VACCINATION RATE VS VACCINATION INITIATION AT STATE LEVEL
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== compute fraction of eligible unvaccinated people initiating vaccination each day
d1            = 8;
d2            = length(state.vaxDates);
index         = 1:state.numNames;
newPeople     = state.vaxData(d1:d2,index,3) - state.vaxData(d1-7:d2-7,index,3);     % weekly new people with at least one dose
newPeople     = newPeople / 7;                                                       % daily new people with at least one dose
fraction12    = state.vaxData(end,index,9) ./ state.vaxData(end,index,18);           % frac pop 12+ inferred from percents
peopleElig    = fraction12 .* state.population(index)';                              % number of eligible people
peopleElig    = repmat(peopleElig, length(d1:d2), 1);                                % number of eligible people replicated over time
peopleInit    = state.vaxData(d1:d2,index,3);                                        % number of people who have initiated over time                                      
peopleUnvax   = peopleElig - peopleInit;                                             % unvaccinated people over time
newPeopleN    = 100 * newPeople ./ peopleUnvax;                                      % new people as percent of unvaxed 12+ residents

%=== get latest data
m           = 18;                         % use completed 12+ vaccination rate
date2       = char(state.vaxDates(end));
x2          = state.vaxData(end,:,m)';    % completed 12+
y2          = newPeopleN(end,:)';         % new initiation rate
stateNames0 = state.names0;

%=== get previous data if showing it
showPrevious = 1;
numDays      = 7;
if showPrevious
  date1     = char(state.vaxDates(end-numDays));
  x1        = state.vaxData(end-numDays,:,m)';   % completed 12+
  y1        = state.features(end-numDays,:,2)';  % new case rate
  y1        = newPeopleN(end-numDays,:)';        % new initiation rate
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
strTitle  = sprintf('Rate of DAILY Vaccination Initiation vs Percent of Eligible (Age 12+) Population Fully Vaccinated');
xTitle    = sprintf('Percent of Eligible Population Fully Vaccinated');
yTitle    = sprintf('Percent of Eligible Unvaccinated People Initiating Vaccination Each Day');
strText   = sprintf('The dashed lines (''jet plumes'') show the trajectory for each state over the past %d days', numDays);
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ylim([0,1.2*max(y2)]);
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
strLegend(N) = {sprintf('US Vaccination Initiation Rate = %3.2f%%', y3)}; subset(N) = h3;

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
x0 = xmin + 0.99*(xmax - xmin);
y0 = ymin + 0.99*(ymax - ymin);
h  = text(x0, y0, strText); 
set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
set(h,'HorizontalAlignment','Right'); set(h,'VerticalAlignment','Top');

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
legend(subset, strLegend, 'Location', 'NorthWest', 'Fontsize', 16);
title(strTitle, 'Fontsize', 16);

%---------------------------------------------------------------------------------------------
%=== 7. SCATTER PLOT OF VACCINATION RATE VS NEW CASE RATES AT TOWN LEVEL
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get latest data for towns in fairfield county
index       = find(strcmp(town.countyNames, 'Fairfield'));
x2          = 100*town.vaxDataN(end,index,9,2)';  % completed 12+
y2          = town.features(end,index,2)';        % new case rate
townNames   = town.names(index);

%=== get town data from previous week
x1          = 100*town.vaxDataN(end-1,index,9,2)';  % completed 12+ (weekly)
y1          = town.features(end-7,index,2)';        % new case rate (daily)

%=== insure case rates are not negative
y1 = max(y1,0);
y2 = max(y2,0);

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); 
clear strLegend;
strLegend(1) = {sprintf('Most Recent Data')}; subset(1) = h1;

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
strLegend(2) = {sprintf('Data from Previous Week')}; subset(2) = h2;

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
population12 = town.populationAge(index,9);      % age 12+
meanX        = sum(population12 .* x2) ./ sum(population12);   % vax  data is for age 12+
meanY        = sum(population   .* y2) ./ sum(population);     % case data is for all ages

%=== vertical line at mean vaccinated
h2 = plot([meanX,meanX], [ymin,ymax], 'r:', 'LineWidth', 2);
strLegend(3) = {sprintf('Fairfield County Fully Vaccinated Rate = %2.1f%%', meanX)}; subset(3) = h2;

%=== horizontal line at mean new cases
h3 = plot([xmin,xmax], [meanY, meanY], 'b:', 'LineWidth', 2);
strLegend(4) = {sprintf('Fairfield County New Case Rate = %2.1f', meanY)}; subset(4) = h3;

%=== set labels
strTitle  = sprintf('Fairfield County: New Case Rates vs Percent of Eligible (Age 12+) Population Fully Vaccinated');
xTitle    = sprintf('Percent of Eligible Population Fully Vaccinated');
yTitle    = sprintf('New Case Rate (Per 100,000 Residents)');
strText   = sprintf('The dashed lines (''jet plumes'') show the trajectory for each town over the past %d days', numDays);
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== add explanatory text
x0 = xmin + 0.99*(xmax - xmin);
y0 = ymin + 0.84*(ymax - ymin);
h  = text(x0, y0, strText); 
set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
set(h,'HorizontalAlignment','Right'); set(h,'VerticalAlignment','Top');

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
legend(subset, strLegend, 'Location', 'NorthEast', 'Fontsize', 12);
title(strTitle, 'Fontsize', 16);

return;

%---------------------------------------------------------------------------------------------
%=== 8. SCATTER PLOT OF TOTAL VACCINATION RATE VS R-EFFECTIVE
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get data for towns in fairfield county
filter         = find(strcmp(town.countyNames, 'Fairfield'));
townNames      = town.names(filter);
date2V         = char(town.vaxDates(end));           % last vax date

%=== compute R effective
R0                   = 6;                                  % delta R0
vaxEffectiveness     = 0.80;                               % vaccine efficiency
vaxEffectiveness1    = 0.60;                               % efficiency after single dose
naturalEffectiveness = 0.60;                               % natural immunity efficiency
cumCases             = town.cumCases(end,filter)';         % total cases to date
population           = town.population(filter,1);          % total population
fracInfected         = cumCases ./ population;             % fraction of population infected
fracVaccinated       = town.vaxDataN(end,filter,8,2)';     % fraction of population fully vaccinated
fracInitiated        = town.vaxDataN(end,filter,8,1)';     % fraction of population initiated vaccinated -- includes full vaxed
fracInitiated        = fracInitiated - fracVaccinated;     % fraction of population with 1 dose ONLY
fracNotVaccinated    = 1 - fracVaccinated;                 % fraction of population not vaccinated
fracInfected         = fracInfected .* fracNotVaccinated;  % assume previously infected people vaccinated at same rate
fracImmune           = fracVaccinated .* vaxEffectiveness ...
                     + fracInfected   .* naturalEffectiveness ...
                     + fracInitiated  .* vaxEffectiveness1;
Reffective           = R0*(1 - fracImmune);

%=== compute mask rate needed to get R-eff to 1.0
requiredReduction    = Reffective;                   % reduction to get to Reff = 1 
maskEfficiency       = 0.80;                         % assumed
requiredMaskFraction = (sqrt(requiredReduction) - 1) ./ maskEfficiency;

%=== compute new case rate normalized to unvaccinated population
newCaseRate          = town.features(end,index,2)';        % new case rate
newCaseRateEffective = newCaseRate ./ fracNotVaccinated;
                           
%=== get data for plot
x2 = 100*fracVaccinated;
y2 = Reffective;

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); 
clear strLegend;
strLegend(1) = {sprintf('We assume immunity is acquired either by vaccination or previous infection.')}; subset(1) = h1;

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

%=== reset y axis
ylim([0,1.2*R0]);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add horizontal line at R0
h2 = plot([xmin,xmax], [R0,R0], 'b', 'LineWidth', 2);
strLegend(2) = {sprintf('We assume R_0 = %d (low end of CDC range for Delta variant)', R0)}; subset(2) = h2;

%=== add horizontal line at 1.0 for herd immunity
herdImmunity = 1;
h3 = plot([xmin,xmax], [herdImmunity, herdImmunity], 'r-', 'LineWidth', 2);
strLegend(3) = {sprintf('Herd Immunity achieved at R_{eff} < 1')}; subset(3) = h3;

%=== assumptions in legend
h4 = plot([xmin,xmin],[ymin,ymin], 'k'); subset(4) = h4;
strLegend(4) = {sprintf('Assumed immune efficiencies: Full vax = %3.2f, Initiated vax = %3.2f, Natural immunity = %3.2f', ...
                vaxEffectiveness, vaxEffectiveness1, naturalEffectiveness)};            

%=== set labels
strTitle  = sprintf('Fairfield County: R_{eff} vs Percent of Population Fully Vaccinated (as of %s)', date2V);
xTitle    = sprintf('Percent of Population Fully Vaccinated');
yTitle    = sprintf('R_{eff}');
strSource = sprintf('%s\n%s', parameters.ctDataSource, parameters.rickAnalysis);

%=== text labels
strText1(1) = {sprintf('We assume immunity is acquired either by full vaccination or previous infection.')};
strText     = sprintf('%s', char(strText1(1)));
for l=2:length(strText1)
  strText = sprintf('%s\n%s', strText, char(strText1(l)));
end

%=== add explanatory text
x0 = xmin + 0.40*(xmax - xmin);
y0 = ymin + 0.10*(ymax - ymin);
%h  = text(x0, y0, strText); 
%set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
%set(h,'HorizontalAlignment','Center'); set(h,'VerticalAlignment','Bottom');

%=== add data source
x0   = xmin - 0.150*(xmax - xmin);
y0   = ymin - 0.082*(ymax - ymin);
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
legend(subset, strLegend, 'Location', 'North', 'Fontsize', 12);
title(strTitle, 'Fontsize', 16);

%---------------------------------------------------------------------------------------------
%=== 9. SCATTER PLOT VACCINATION RATE VS REQUIRED MASK FRACTION
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);
                           
%=== get data for plot
x2 = 100*fracVaccinated;
y2 = requiredMaskFraction;

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); 
clear strLegend;
strLegend(1) = {sprintf('The required masking fraction is estimated empirically.')}; subset(1) = h1;

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

%=== reset y axis
%ylim([0,1.2*R0]);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== assumptions in legend
h4 = plot([xmin,xmin],[ymin,ymin], 'k'); subset(2) = h4;
strLegend(2) = {sprintf('Assumed immune efficiencies: Full vax = %3.2f, Initiated vax = %3.2f, Natural immunity = %3.2f', ...
                vaxEffectiveness, vaxEffectiveness1, naturalEffectiveness)};            

%=== set labels
strTitle  = sprintf('Fairfield County: Estimated Masking Fraction to Reach Herd Immunity (R_{eff} = 1) as of %s', date2V);
xTitle    = sprintf('Percent of Population Fully Vaccinated');
yTitle    = sprintf('Fraction of People Required to Practice Masking');
strSource = sprintf('%s\n%s', parameters.ctDataSource, parameters.rickAnalysis);

%=== text labels
strText1(1) = {sprintf('We assume immunity is acquired either by full vaccination or previous infection.')};
strText     = sprintf('%s', char(strText1(1)));
for l=2:length(strText1)
  strText = sprintf('%s\n%s', strText, char(strText1(l)));
end

%=== add data source
x0   = xmin - 0.150*(xmax - xmin);
y0   = ymin - 0.082*(ymax - ymin);
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
xtickformat('%2.0f%%');
ytickformat('%3.2f');
legend(subset, strLegend, 'Location', 'North', 'Fontsize', 12);
title(strTitle, 'Fontsize', 16);

%---------------------------------------------------------------------------------------------
%=== 10. SCATTER PLOT OF TOTAL VACCINATION RATE VS EFFECTIVE NEW CASE RATE
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

                           
%=== get data for plot
x2 = 100*fracVaccinated;
y2 = newCaseRateEffective;

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); 
clear strLegend;
strLegend(1) = {sprintf('Town Vaccination Data as of %s', date2V)}; subset(1) = h1;

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

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== set labels
strTitle  = sprintf('Fairfield County: Effective New Case Rate vs Percent of Population Fully Vaccinated');
xTitle    = sprintf('Percent of Population Fully Vaccinated');
yTitle    = sprintf('New Case Rate (per 100,000 Unvaccinated Residents)');
strText   = sprintf('The Effective New Case Rate is the number of daily new cases per 100,000 unvaccinated residents.' );
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== add explanatory text
x0 = xmin + 0.99*(xmax - xmin);
y0 = ymin + 0.93*(ymax - ymin);
h  = text(x0, y0, strText); 
set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
set(h,'HorizontalAlignment','Right'); set(h,'VerticalAlignment','Top');

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
legend(subset, strLegend, 'Location', 'NorthEast', 'Fontsize', 16);
title(strTitle, 'Fontsize', 16);

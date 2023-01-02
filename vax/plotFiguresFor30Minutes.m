function plotFiguresFor30Minutes(town, state, county, countyUS, figureNum)
%
% figures for 30 minutes -- superceded by plotWestConn1 etc
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> plotFiguresFor30Minutes\n');

%------------------------------------------------------------------------
%=== 1. PLOT LONG-TERM LINE CHART OF US NEW CASE RATES AND VACCINATION RATES
%figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get covid dates
dates       = state.dates;
numDates    = length(dates);

%=== get vaccination dates and intersection with covid dates
dates1      = state.vaxDates;
[~,i1,i2]   = intersect(dates, dates1);

%=== do all dates
interval  = 7*8;
xLabels   = dates;
d1        = mod(numDates,interval);    % so last date is final tick mark
d2        = numDates;
xTicks    = [d1:interval:d2]';
if d1 == 0
  d1        = interval;
  xTicks    = [1 d1:interval:d2]';
end
d1 = 1;

%=== get data
us            = find(strcmp(state.names, 'United States'));
ct            = find(strcmp(state.names, 'Connecticut'));
y             = zeros(numDates,4);
newCaseRates  = state.features(:,us,2);
y(:,1)        = newCaseRates(d1:d2);
newCaseRates  = state.features(:,ct,2);
y(:,2)        = newCaseRates(d1:d2);
completed     = state.vaxData(:,us,9);
y(i1,3)       = completed(i2);
completed     = state.vaxData(:,ct,9);
y(i1,4)       = completed(i2);

%=== plot data
yyaxis left;
h             = plot(y(:,1), 'r-'); set(h, 'LineWidth', 1.5); hold on;
h             = plot(y(:,2), 'b-'); set(h, 'LineWidth', 1.5); hold on;
yyaxis right;
h             = plot(y(:,3), 'r:'); set(h, 'LineWidth', 1.5); hold on;
h             = plot(y(:,4), 'b:'); set(h, 'LineWidth', 1.5); hold on;

%=== print data to determine relative peaks
printData = 0;
if printData
  for d=1:length(xLabels)
    fprintf('%s\t%4.2f\t%4.2f\t%4.2f\t%4.2f\n', char(xLabels(d)), y(d,1), y(d,2), y(d,3), y(d,4));
  end
end

%=== set legends
strLegends(1) = {sprintf('United States New Case Rate')};
strLegends(2) = {sprintf('Connecticut New Case Rate')};
strLegends(3) = {sprintf('United States Percent Vaccination (Right Axis)')};
strLegends(4) = {sprintf('Connecticut Percent Vaccination (Right Axis)')};

%=== set labels
strTitle  = sprintf('New Case Rates and Completed Vaccination Percents (as of %s)', char(xLabels(end)));
xLabel    = sprintf('CDC Reporting Date');
yLabel    = sprintf('New Case Rate (per 100,000 Residents)');
yLabelR   = sprintf('Percent of Total Population Completing Vaccination');
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
xlim([d1,d2]);
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

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',14);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(xLabel, 'FontSize', 14);
yyaxis left;
set(gca,'YColor', 'k');
ylabel(yLabel, 'FontSize', 14);

yyaxis right;
ylabel(yLabelR, 'FontSize', 14);
ytickformat('%2.0f%%');
set(gca,'YColor', 'k');
legend(strLegends,'Location', 'NorthWest', 'FontSize', 12,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

%------------------------------------------------------------------------
%=== 2. PLOT LINE CHART OF NEW CASE RATES
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get dates
dates       = state.dates;
numDates    = length(dates);

%=== set date limits
numWeeks    = 8;
window      = numWeeks*7;
d2          = numDates;
d1          = numDates - window;
interval    = window / 10;             % ~10 date labels
interval    = 7 * ceil(interval/7);    % round up to integer number of weeks
numWeeks    = round(window/7);
xLabels     = dates(d1:d2);
xTicks      = [d1:interval:d2]';
xTicks      = xTicks - d1 + 1;
clear y;

%=== plot US data
index         = find(strcmp(state.names, 'United States'));
newCaseRates  = state.features(:,index,2)';
y(:,1)        = newCaseRates(d1:d2);
h             = plot(y(:,1));  set(h, 'Color', 'r'); set(h, 'LineWidth', 2); hold on;
strLegends(1) = {sprintf('United States')};

%=== plot Connecticut data
index         = find(strcmp(state.names, 'Connecticut'));
newCaseRates  = state.features(:,index,2)';
y(:,2)        = newCaseRates(d1:d2);
h             = plot(y(:,2));  set(h, 'Color', 'b'); set(h, 'LineWidth', 2); hold on;
strLegends(2) = {sprintf('Connecticut')};

%=== plot Fairfield County
index         = find(strcmp(county.names, 'Fairfield'));
newCaseRates  = county.features(:,index,2)';
%y(:,3)        = newCaseRates(d1:d2);
%h             = plot(y(:,3));  set(h, 'Color', 'k'); set(h, 'LineWidth', 2); hold on;
%strLegends(3) = {sprintf('Fairfield County')};

%=== add values next to lines
colors = ['r','b','k'];
for p=1:2
  x0 = 1.005*length(y(:,p));
  y0 = y(end,p);
  t0 = sprintf('%2.1f', y0);
  text(x0,y0,t0, 'vert','middle', 'horiz','left', 'FontWeight','bold', 'FontSize',16, 'color',colors(p));
end

%=== set labels
strTitle  = sprintf('New Case Rates (as of %s)', char(xLabels(end)));
xLabel    = sprintf('CDC Reporting Date (Last %d Weeks)', numWeeks);
yLabel    = sprintf('New Case Rate (per 100,000 Residents)');
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

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

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',14);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(xLabel, 'FontSize', 16);
ylabel(yLabel, 'FontSize', 16);
legend(strLegends,'Location', 'NorthWest', 'FontSize', 16,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

%------------------------------------------------------------------------
%=== 3. PLOT LINE CHART OF PEOPLE INITIATING VACCINATION
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get dates
dates       = state.vaxDates;
numDates    = length(dates);

%=== set date limits
numWeeks    = 16;
window      = numWeeks*7;
d2          = numDates;
d1          = numDates - window;
interval    = window / 10;             % ~10 date labels
interval    = 7 * ceil(interval/7);    % round up to integer number of weeks
numWeeks    = round(window/7);
xLabels     = dates(d1:d2);
xTicks      = [d1:interval:d2]';
xTicks      = xTicks - d1 + 1;
clear y;
clear strLegends;

%=== compute fraction of eligible unvaccinated people initiating vaccination each day
index         = 1:state.numNames;
newPeople     = state.vaxData(d1:d2,index,3) - state.vaxData(d1-7:d2-7,index,3);     % weekly new people with at least one dose
newPeople     = newPeople / 7;                                                       % daily new people with at least one dose
fraction12    = state.vaxData(end,index,9) ./ state.vaxData(end,index,18);           % frac pop 12+ inferred from percents
peopleElig    = fraction12 .* state.population(index)';                              % number of eligible people
peopleElig    = repmat(peopleElig, length(d1:d2), 1);                                % number of eligible people replicated over time
peopleInit    = state.vaxData(d1:d2,index,3);                                        % number of people who have initiated over time                                      
peopleUnvax   = peopleElig - peopleInit;                                             % unvaccinated people over time
newPeopleN    = 100 * newPeople ./ peopleUnvax;                                      % new people as percent of unvaxed 12+ residents

%=== debug
s             = 7;
peopleElig(end,s)  / 1000000;
peopleInit(end,s)  / 1000000;
peopleUnvax(end,s) / 1000000;
newPeople(end,s)   / 1000000;

%=== set states to be plotted
stateNames = {'United States'; 'Connecticut'};
colors     = {'r'; 'b'; 'k'; 'g'; 'c'; 'm'};
for s=1:length(stateNames)
  stateName = char(stateNames(s));

  %=== plot data for each state
  index         = find(strcmp(stateName, state.names));
  y(:,s)        = newPeopleN(:,index);        
  color         = sprintf('%s-', char(colors(s)));
  h             = plot(y(:,s), color);  set(h, 'LineWidth', 2); hold on;
  strLegends(s) = {sprintf('%s (7-Day Moving Average)', stateName)};
end

%=== dump data for josh
dumpData = 0;
if dumpData
  fprintf('%s\n', 'Percent of Eligible Unvaccinated People Initiating Vaccination');
  fprintf('%s\t%s\t%s\n', 'Date', 'United States', 'Connecticut');
  for d=1:length(xLabels)
    fprintf('%s\t%5.4f\t%5.4f\n', char(xLabels(d)), y(d,1), y(d,2));
  end
end

%=== add values next to lines
for s=1:length(stateNames)
  x0 = 1.005*length(y(:,s));
  y0 = y(end,s);
  t0 = sprintf('%2.2f%%', y0);
  text(x0,y0,t0, 'vert','middle', 'horiz','left', 'FontWeight','bold', 'FontSize',12, 'color',char(colors(s)));
end

%=== set labels
strTitle  = sprintf('Percent of Eligible Unvaccinated People Initiating Vaccination Each Day (as of %s)', char(xLabels(end)));
xLabel    = sprintf('CDC Reporting Date (Last %d Weeks)', numWeeks);
yLabel    = sprintf('Percent of Eligible Unvaccinated People Initiating Vaccination');
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

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

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',14);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(xLabel, 'FontSize', 16);
ylabel(yLabel, 'FontSize', 16);
ytickformat('%2.1f%%');
legend(strLegends,'Location', 'North', 'FontSize', 16,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

%---------------------------------------------------------------------------------------------
%=== 4. LINE PLOT OF NEW CASE RATES FOR HIGHLY-VACCINATED STATES VS LESS-VACCINATED STATES
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== set initialized or completed vaccination
m = 17; % initialized
m = 18; % completed

%=== get data
date2       = char(state.vaxDates(end));
x2          = state.vaxData(end,:,m)';    % initiated 12+
y2          = state.features(end,:,2)';    % new case rate
populations = state.population;
stateNames0 = state.names0;
stateNames  = state.names;
us          = find(strcmp(stateNames0, 'US'));
usVaxRate   = x2(us);

%=== partition the states based on lastest vaccination rate
index1      = find(x2 >   usVaxRate & ~strcmp(stateNames0, 'US'));  
index2      = find(x2 <=  usVaxRate & ~strcmp(stateNames0, 'US'));
index3      = find(strcmp(stateNames0, 'US'));
index4      = find(strcmp(stateNames0, 'CT'));

%=== compute latest vaccination rates
vaxRates    = NaN(4,1);
vaxRates0   = state.vaxData(end,:,17)';    % initiated 12+
vaxRates(1) = sum(populations(index1) .* vaxRates0(index1)) / sum(populations(index1));
vaxRates(2) = sum(populations(index2) .* vaxRates0(index2)) / sum(populations(index2));
vaxRates(3) = sum(populations(index3) .* vaxRates0(index3)) / sum(populations(index3));
vaxRates(4) = sum(populations(index4) .* vaxRates0(index4)) / sum(populations(index4));

%=== compute new case rates
numWeeks     = 8;
numDates     = 7*numWeeks + 1;
d2           = length(state.dates);
d1           = d2 - numDates + 1;
dates        = state.dates(d1:d2);
newCaseRates = NaN(numDates,4);
for dd=d1:d2
  d = dd - d1 + 1;
  newCaseRates0     = state.features(dd,:,2)'; 
  newCaseRates(d,1) = sum(populations(index1) .* newCaseRates0(index1)) / sum(populations(index1));
  newCaseRates(d,2) = sum(populations(index2) .* newCaseRates0(index2)) / sum(populations(index2));
  newCaseRates(d,3) = sum(populations(index3) .* newCaseRates0(index3)) / sum(populations(index3));
  newCaseRates(d,4) = sum(populations(index4) .* newCaseRates0(index4)) / sum(populations(index4));
end

%=== get date labels
x        = 1:7:numDates;
xLabels  = dates;

%=== plots
plot(newCaseRates(:,2),'r-', 'LineWidth', 2); hold on;
plot(newCaseRates(:,1),'b-', 'LineWidth', 2); hold on;
plot(newCaseRates(:,3),'r:', 'LineWidth', 2); hold on;
plot(newCaseRates(:,4),'b:', 'LineWidth', 2); hold on;

%=== extend y axis
ylim([0,1.1*max(newCaseRates(:,2))]);

%=== add values next to lines
colors = ['b','r','r','b'];
for p=1:4
  x0 = 1.005*length(dates);
  y0 = newCaseRates(end,p);
  t0 = sprintf('%2.1f', y0);
  text(x0,y0,t0, 'vert','middle', 'horiz','left', 'FontWeight','bold', 'FontSize',16, 'color',colors(p));
end

%=== get labels for plot
strLegends(2) = {sprintf('%d states with higher vaccination rates than the US', length(index1))};
strLegends(1) = {sprintf('%d states with lower  vaccination rates than the US ', length(index2))};
strLegends(3) = {sprintf('%s', char(stateNames(index3)))};
strLegends(4) = {sprintf('%s', char(stateNames(index4)))};
strTitle      = sprintf('State-Level New Case Rates');
xTitle        = sprintf('CDC Report Date (Last %d Weeks)', numWeeks);
yTitle        = sprintf('New Case Rate (per 100,000 Residents)');
strSource     = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

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

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 2);
set(gca,'FontSize',  12);
set(gca,'XTick',x);  
set(gca,'XTickLabel',xLabels(x));
xlabel(xTitle, 'FontSize', 16);
ylabel(yTitle, 'FontSize', 16);
legend(strLegends,'FontSize', 12, 'Location','NorthWest', 'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle,   'FontSize', 16);
return;

%---------------------------------------------------------------------------------------------
%=== 5. SCATTER PLOT OF NEW CASE RATE VS CUMULATIVE CASE RATE AT STATE LEVEL
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get data
date2       = char(state.dates(end));
numDays     = 30;
cumRate     = state.features(:,:,8);                                 % cum case rate per 100K
x2          = cumRate(end-numDays,:)' ./ 1000;                       % cumRate at beggining as percent
y2          = (cumRate(end,:)' - cumRate(end-numDays,:)') / numDays; % daily  new cases over the perio
stateNames0 = state.names0;

%=== compute correlation
R    = corrcoef(x2,y2);
corr = R(1,2);
R2   = R(1,2) ^2;

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
strTitle  = sprintf('New Case Rate vs Cumulative Case Rate');
xTitle    = sprintf('Cumulative Case Rate (as %% of Residents)');
yTitle    = sprintf('New Caset Rate (Per 100,000 Residents)');
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
N  = 2;
strLegend(N) = {sprintf('US Cumulative Case Rate = %2.1f%%', x3)}; subset(N) = h2;

%=== horizontal line at US new case rate
y3 = y2(us);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2);
N  = 3;
strLegend(N) = {sprintf('US New Case Rate = %2.1f', y3)}; subset(N) = h3;

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
%=== 6. SCATTER PLOT OF NEW CASE RATE VS CUMULATIVE CASE RATE AT COUNTY LEVEL
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get latest data
date2       = char(county.dates(end));
cumRate     = countyUS.features(:,:,8);                                 % cum case rate per 100K
x2          = cumRate(end-numDays,:)' ./ 1000;                       % cumRate at beggining as percent
y2          = (cumRate(end,:)' - cumRate(end-numDays,:)') / numDays; % daily  new cases over the perio

%=== apply bounds 
x2          = min(x2,30);
y2          = max(y2,0);
y2          = min(y2,200);

%=== compute correlation
R    = corrcoef(x2,y2);
corr = R(1,2);
R2   = R(1,2) ^2;

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 2); hold on;
strLegend(1) = {sprintf('Data as of %s', date2)}; subset(1) = h1;

%=== set labels
strTitle  = sprintf('New Case Rate vs Cumulative Case Rate');
xTitle    = sprintf('Cumulative Case Rate (as %% of Residents)');
yTitle    = sprintf('New Caset Rate (Per 100,000 Residents)');
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at US cumulative case rate
us = find(strcmp('US', state.names0));
x3 = state.features(end-numDays,us,8) / 1000;
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2); hold on;
N  = 2;
strLegend(N) = {sprintf('US Cumulative Case Rate = %2.1f%%', x3)}; subset(N) = h2;

%=== horizontal line at US new case rate
y3 = state.features(end,us,2);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2); hold on;
N  = 3;
strLegend(N) = {sprintf('US New Case Rate = %2.1f', y3)}; subset(N) = h3;

%=== add counts in each quadrant
xx       = x3;           % quadrant defined by US cum case rate
yy       = y3;           % quadrant defined by US new case rate
count(1) = length(find(x2 <= xx & y2 <= yy));  xpos(1) = (xmin+xx)/2; ypos(1) = (ymin+yy)/2; 
count(2) = length(find(x2 >  xx & y2 <= yy));  xpos(2) = (xmax+xx)/2; ypos(2) = (ymin+yy)/2;
count(3) = length(find(x2 <= xx & y2 >  yy));  xpos(3) = (xmin+xx)/2; ypos(3) = (ymax+yy)/2;
count(4) = length(find(x2 >  xx & y2 >  yy));  xpos(4) = (xmax+xx)/2; ypos(4) = (ymax+yy)/2;
for i=1:4
  h = text(xpos(i), ypos(i), sprintf('%d counties', count(i)));
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
legend( strLegend, 'Location', 'NorthWest', 'Fontsize', 16);
title(strTitle, 'Fontsize', 16);


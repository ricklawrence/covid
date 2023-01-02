function plotWestConn1(town, state, county, countyUS, figureNum)
%
% figures for west conn Q1: state of pandemic
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> plotWestConn1\n');

%------------------------------------------------------------------------
%=== 1. PLOT LONG-TERM LINE CHART OF US NEW CASE RATES
%figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get covid dates
dates       = state.dates;
numDates    = length(dates);

%=== do all dates
interval  = 7*12;
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
y             = zeros(numDates,2);
newCaseRates  = state.features(:,us,2);
y(:,1)        = newCaseRates(d1:d2);
newCaseRates  = state.features(:,ct,2);
y(:,2)        = newCaseRates(d1:d2);

%=== plot data
h             = plot(y(:,1), 'r-'); set(h, 'LineWidth', 1.5); hold on;
h             = plot(y(:,2), 'b-'); set(h, 'LineWidth', 1.5); hold on;

%=== print data to determine relative peaks
printData = 0;
if printData
  for d=1:length(xLabels)
    fprintf('%s\t%4.2f\t%4.2f\n', char(xLabels(d)), y(d,1), y(d,2));
  end
end

%=== set legends
strLegends(1) = {sprintf('United States New Case Rate')};
strLegends(2) = {sprintf('Connecticut New Case Rate')};

%=== set labels
strTitle  = sprintf('New Case Rates (as of %s)', char(xLabels(end)));
xLabel    = sprintf('CDC Reporting Date');
yLabel    = sprintf('New Case Rate (per 100,000 Residents)');
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
ylabel(yLabel, 'FontSize', 14);
legend(strLegends,'Location', 'NorthWest', 'FontSize', 16,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

%------------------------------------------------------------------------
%=== 2. PLOT LONG-TERM LINE CHART OF US NEW CASE RATES AND VACCINATION RATES
figureNum = figureNum + 1;
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
h             = plot(y(:,1), 'r.'); set(h, 'LineWidth', 1.5); hold on;
h             = plot(y(:,2), 'b.'); set(h, 'LineWidth', 1.5); hold on;
yyaxis right;
h             = plot(y(:,3), 'r-'); set(h, 'LineWidth', 1.5); hold on;
h             = plot(y(:,4), 'b-'); set(h, 'LineWidth', 1.5); hold on;

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
strLegends(3) = {sprintf('United States Vaccination Percent (Right Axis)')};
strLegends(4) = {sprintf('Connecticut Vaccination Percent (Right Axis)')};

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
%=== 3. PLOT LINE CHART OF NEW CASE RATES
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get dates from state structure
dates       = state.dates;
numDates    = length(dates);

%=== set date limits
numWeeks    = 28;
window      = numWeeks*7;
d2          = numDates;
d1          = numDates - window;
interval    = window / 10;             % ~10 date labels
interval    = 7 * ceil(interval/7);    % round up to integer number of weeks
interval    = 28;
numWeeks    = round(window/7);
xLabels     = dates(d1:d2);
xTicks      = [d1:interval:d2]';
xTicks      = xTicks - d1 + 1;
y           = NaN(length(d1:d2), 3);

%=== plot US data
index         = find(strcmp(state.names, 'United States'));
newCaseRates  = state.features(:,index,2)';
y(:,1)        = newCaseRates(d1:d2);
h             = plot(y(:,1));  set(h, 'Color', 'r'); set(h, 'LineWidth', 2); hold on;
strLegends(1) = {sprintf('United States New Case Rate')};

%=== plot Connecticut data
index         = find(strcmp(state.names, 'Connecticut'));
newCaseRates  = state.features(:,index,2)';
y(:,2)        = newCaseRates(d1:d2);
h             = plot(y(:,2));  set(h, 'Color', 'b'); set(h, 'LineWidth', 2); hold on;
strLegends(2) = {sprintf('Connecticut New Case Rate')};

%=== plot Fairfield County (dates may be different for county than state structure)
index         = find(strcmp(county.names, 'Fairfield'));
newCaseRates  = county.features(:,index,2)';
[~,i1,i2]     = intersect(dates(d1:d2), county.dates);
y(i1,3)       = newCaseRates(i2);
h             = plot(y(:,3));  set(h, 'Color', 'k'); set(h, 'LineWidth', 2); hold on;
strLegends(3) = {sprintf('Fairfield County New Case Rate')};

%=== add values next to lines
colors = ['r','b','k'];
for p=1:3
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
ylim([0,ymax]);

%=== add data source
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.200*(ymax - ymin);
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

%-----------------------------------------------------------------------------
%===  4. HORIZONTAL BAR CHART OF STATE NEW CASE RATES
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get data
stateNames   = state.names;
newCaseRates = state.features(end,:,2)';

%=== get data for plots
yValues        = newCaseRates;
yLabels        = stateNames;
sortValues     = newCaseRates;
[~, sortIndex] = sort(sortValues, 'descend');
yValues        = yValues(sortIndex);
yLabels        = yLabels(sortIndex);
yValues        = flip(yValues);     % reverse so biggest is at top of bar chart
yLabels        = flip(yLabels);     % reverse so biggest is at top of bar chart
y              = 1:length(yLabels);

%=== horizontal bar chart
h = barh(y, yValues, 'stacked'); 
set(h(1), 'FaceColor', 'r'); hold on;

%=== labels
strTitle     = sprintf('New Case Rates (as of %s)', char(state.vaxDates(end)));
xLabel       = sprintf('New Case Rate (per 100,000 Residents)');
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
h1 = text(x0,y0,sprintf(' %s = %2.1f', stateName, x0));
s  = find(strcmp('United States', yLabels));
x0 = yValues(s);
y0 = y(s);
h2 = text(x0,y0,sprintf(' United States = %2.1f',x0));
set(h1,'Color','k'); set(h1,'Horiz','Left'); set(h1, 'Vert', 'middle'); set(h1,'FontSize', 10); set(h1,'FontWeight', 'bold');
set(h2,'Color','k'); set(h2,'Horiz','Left'); set(h2, 'Vert', 'middle'); set(h2,'FontSize', 10); set(h2,'FontWeight', 'bold');

%=== get fairfield county ranking
countyNewCaseRates = countyUS.features(:,2);
[~, sortIndex]     = sort(countyNewCaseRates, 'ascend');
rank               = find(strcmp('Fairfield County, Connecticut', countyUS.names(sortIndex)));
percentile         = 100 * rank / countyUS.numNames;
value              = countyNewCaseRates(sortIndex(rank));
strCounty          = sprintf('Fairfield County ranks %d (Lowest %2.1f%%) out of %d US counties in New Case Rate.', ...
                              rank, percentile, countyUS.numNames);

%=== add county ranking to plot
x0 = xmin + 0.99*(xmax - xmin);
y0 = ymin + 0.05*(ymax - ymin);
%h  = text(x0, y0, strCounty); 
%set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 14);
%set(h,'HorizontalAlignment','Right'); set(h,'VerticalAlignment','Top');

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
%legend(strLegend, 'location', 'NorthWest', 'Fontsize', 14, 'FontWeight','normal');


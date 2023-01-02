function plotBenjamin(town, state, county, countyUS, figureNum)
%
% figures for benjamin discussion
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> plotBenjamin\n');

%=== do first-dose acceleration analysis
plotFirstDoseAcceleration(state, figureNum)
return;

%------------------------------------------------------------------------
%=== 1. PLOT LINE CHART OF DPH vs CDC CUMULATIVE VACCINATION DATA
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== USE DAILY CDC DATES (and map weekly CT DPH data onto these dates)
date1        = town.vaxDates(1);              % CT DPH
date2        = town.vaxDates(end);            % CT DPH
d1           = find(strcmp(date1, state.vaxDates));  
d2           = find(strcmp(date2, state.vaxDates));  
dates        = state.vaxDates(d1:d2);             % daily dates
numDates     = length(dates);

%=== get indices
[~,i1,i2] = intersect(dates, town.vaxDates);
[~,i3,i4] = intersect(dates, state.vaxDates);

%=== get CT DPH data
clear strLegends;
y       = NaN(numDates,5);
y(i1,1) = town.vaxData(i2,170,8,1);   strLegends(1) = {sprintf('CT DPH Initiated Vaccination')};
y(i3,2) = state.vaxData(i4,7,3);      strLegends(2) = {sprintf('CDC    Initiated Vaccination')};
y(i1,3) = town.vaxData(i2,170,8,2);   strLegends(3) = {sprintf('CT DPH Completed Vaccination')};
y(i3,4) = state.vaxData(i4,7,4);      strLegends(4) = {sprintf('CDC    Completed Vaccination')};
y(i3,5) = state.vaxData(i4,7,19);     strLegends(5) = {sprintf('CDC    Additional Doses')};

%=== set date indices
interval = 28;
d2       = numDates;
d1       = mod(numDates,interval);    % so last date is final tick mark
if d1 == 0
  d1     = interval;
end
xLabels     = dates;
xTicks      = [d1:interval:d2]';

%=== plot data
plot(i1,y(i1,1), 'b:', 'LineWidth', 2); hold on;
plot(i3,y(i3,2), 'r:', 'LineWidth', 2); hold on;
plot(i1,y(i1,3), 'b-', 'LineWidth', 2); hold on;
plot(i3,y(i3,4), 'r-', 'LineWidth', 2); hold on;
plot(i3,y(i3,5), 'k-', 'LineWidth', 2); hold on;

%=== add values next to lines
colors     = {'b'; 'r'; 'b'; 'r'; 'k'};
for s=1:5
  x0 = 1.005*length(y(:,s));
  y0 = y(end,s);
  t0 = sprintf('%s', addComma(y0));
  h  = text(x0,y0,t0, 'vert','middle', 'horiz','left', 'FontWeight','bold', 'FontSize',12, 'color',char(colors(s)));
  %set(h, 'BackgroundColor', 'y'); 
end

%=== set labels
strTitle  = sprintf('Comparison of Connecticut Cumulative Vaccination Numbers (as of %s)', char(xLabels(end)));
xLabel    = sprintf('Reporting Date');
yLabel    = sprintf('Number of Connecticut Residents');
strSource = sprintf('Data Source: CDC and CT DPH\n%s', parameters.rickAnalysis);

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
ytickformat('%2.1f');
legend(strLegends,'Location', 'NorthWest', 'FontSize', 12,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

%------------------------------------------------------------------------
%=== 2. PLOT LINE CHART OF DPH vs CDC WEEKLY VACCINATION DATA
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== complete weekly new vaccinations
y(8:end,:) = y(8:end,:) - y(1:end-7,:);
y(1:7,:)   = NaN;

%=== plot data

%=== plot data
plot(i1,y(i1,1), 'b:', 'LineWidth', 2); hold on;
plot(i3,y(i3,2), 'r:', 'LineWidth', 2); hold on;
plot(i1,y(i1,3), 'b-', 'LineWidth', 2); hold on;
plot(i3,y(i3,4), 'r-', 'LineWidth', 2); hold on;
plot(i3,y(i3,5), 'k-', 'LineWidth', 2); hold on;

%=== add values next to lines
colors     = {'b'; 'r'; 'b'; 'r'; 'k'};
for s=1:5
  x0 = 1.005*length(y(:,s));
  y0 = y(end,s);
  t0 = sprintf('%s', addComma(y0));
  h  = text(x0,y0,t0, 'vert','middle', 'horiz','left', 'FontWeight','bold', 'FontSize',12, 'color',char(colors(s)));
  %set(h, 'BackgroundColor', 'y'); 
end

%=== set labels
strTitle  = sprintf('Comparison of Connecticut Weekly Vaccination Numbers (as of %s)', char(xLabels(end)));
xLabel    = sprintf('Reporting Date');
yLabel    = sprintf('Number of Connecticut Residents Vaccinated Each Week');
strSource = sprintf('Data Source: CDC and CT DPH\n%s', parameters.rickAnalysis);

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
ytickformat('%2.0f');
legend(strLegends,'Location', 'North', 'FontSize', 12,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

%---------------------------------------------------------------------------------------------
%=== 3. PLOT ACTUAL VS EXPECTED SECOND DOSES
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== set state name
stateName = 'Connecticut';
s = find(strcmp(stateName, state.names));

%=== get time series
date1        = '04/01/2021';
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
interval = 28;
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
%ylim([0,ymax]);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at EUA ages 12-15 date of may 10
date0 = '05/10/2021';
%d0    = find(strcmp(date0, xLabels));
%h2    = plot([d0,d0], [ymin,ymax], 'k:', 'LineWidth', 2);

%=== get labels for plot
strLegends(1) = {sprintf('Actual Pfizer + Moderna First Doses')};
strLegends(2) = {sprintf('Actual Pfizer + Moderna Second Doses')};
strLegends(3) = {sprintf('Expected Second Doses (Based on Previous First Doses)')};
strLegends(4) = {sprintf('Actual J&J Single Doses')};
%strLegends(5) = {sprintf('FDA authorized Pfizer vaccine for Ages 12-15 on %s', char(xLabels(d0)))};
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
ytickformat('%2.1fK');
legend(strLegends,'FontSize', 10, 'Location','NorthEast', 'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle,   'FontSize', 16);
return;


%------------------------------------------------------------------------
%=== 4. PLOT LINE CHART OF DPH vs CDC CUMULATIVE VACCINATION DATA
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== USE WEEKLY CT CPH DATES (and map daily CDC data on to these dates)
%dates)
dates1        = town.vaxDates;              % CT DPH
dates2        = state.vaxDates;             % CDC
[dates,i1,i2] = intersect(dates1, dates2);
numDates      = length(dates);

%=== get data for these dates
clear strLegends;
y      = NaN(numDates,4);
y(:,1) = town.vaxData(i1,170,8,1);   strLegends(1) = {sprintf('CT DPH Initiated Vaccination')};
y(:,2) = state.vaxData(i2,7,3);      strLegends(2) = {sprintf('CDC    Initiated Vaccination')};
y(:,3) = town.vaxData(i1,170,8,2);   strLegends(3) = {sprintf('CT DPH Completed Vaccination')};
y(:,4) = state.vaxData(i2,7,4);      strLegends(4) = {sprintf('CDC    Completed Vaccination')};
y(:,5) = state.vaxData(i2,7,19);     strLegends(5) = {sprintf('CDC    Additional Doses')};

%=== set date indices
d2          = numDates;
d1          = 1;
interval    = 4;
xLabels     = dates(d1:d2);
xTicks      = [d1:interval:d2]';
xTicks      = xTicks - d1 + 1;

%=== plot data
plot(y(:,1), 'b:', 'LineWidth', 2); hold on;
plot(y(:,2), 'r:', 'LineWidth', 2); hold on;
plot(y(:,3), 'b-', 'LineWidth', 2); hold on;
plot(y(:,4), 'r-', 'LineWidth', 2); hold on;
plot(y(:,5), 'k-', 'LineWidth', 2); hold on;

%=== add values next to lines
colors     = {'b'; 'r'; 'b'; 'r'; 'k'};
for s=1:5
  x0 = 1.005*length(y(:,s));
  y0 = y(end,s);
  t0 = sprintf('%s', addComma(y0));
  h  = text(x0,y0,t0, 'vert','middle', 'horiz','left', 'FontWeight','bold', 'FontSize',12, 'color',char(colors(s)));
  %set(h, 'BackgroundColor', 'y'); 
end

%=== set labels
strTitle  = sprintf('Comparison of Connecticut Cumulative Vaccination Numbers (as of %s)', char(xLabels(end)));
xLabel    = sprintf('Reporting Date');
yLabel    = sprintf('Number of Connecticut Residents');
strSource = sprintf('Data Source: CDC and CT DPH\n%s', parameters.rickAnalysis);

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
ytickformat('%2.1f');
legend(strLegends,'Location', 'NorthWest', 'FontSize', 12,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

%------------------------------------------------------------------------
%=== 5. PLOT LINE CHART OF DPH vs CDC WEEKLY VACCINATION DATA
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== complete weekly new vaccinations
y(2:end,:) = y(2:end,:) - y(1:end-1,:);
y(1,:)     = NaN;

%=== plot data
plot(y(:,1), 'b:', 'LineWidth', 2); hold on;
plot(y(:,2), 'r:', 'LineWidth', 2); hold on;
plot(y(:,3), 'b-', 'LineWidth', 2); hold on;
plot(y(:,4), 'r-', 'LineWidth', 2); hold on;
plot(y(:,5), 'k-', 'LineWidth', 2); hold on;

%=== add values next to lines
colors     = {'b'; 'r'; 'b'; 'r'; 'k'};
for s=1:5
  x0 = 1.005*length(y(:,s));
  y0 = y(end,s);
  t0 = sprintf('%s', addComma(y0));
  h  = text(x0,y0,t0, 'vert','middle', 'horiz','left', 'FontWeight','bold', 'FontSize',12, 'color',char(colors(s)));
  %set(h, 'BackgroundColor', 'y'); 
end

%=== set labels
strTitle  = sprintf('Comparison of Connecticut Weekly Vaccination Numbers (as of %s)', char(xLabels(end)));
xLabel    = sprintf('Reporting Date');
yLabel    = sprintf('Number of Connecticut Residents Vaccinated Each Week');
strSource = sprintf('Data Source: CDC and CT DPH\n%s', parameters.rickAnalysis);

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
ytickformat('%2.0f');
legend(strLegends,'Location', 'North', 'FontSize', 12,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

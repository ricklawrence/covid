function plotVaccineStateDataTime(state, figureNum)
%
% plot vaccine data over time
%
global parameters;
if figureNum < 0
  return;
end
fprintf('\n--> plotVaccineStateDataTime\n');

%=== get state (CT) and United States
usName         = 'United States';
stateName      = 'Connecticut';
ct             = find(strcmp(stateName, state.names));
us             = find(strcmp(usName, state.names));

%=== get date labels
numDates = length(state.vaxDates);
interval = numDates / 10;             % ~10 date labels
interval = 7 * ceil(interval/7);      % round up to integer number of weeks
d2       = numDates;
d1       = mod(numDates,interval);    % so last date is final tick mark
if d1 == 0
  d1     = interval;
end
x        = d1:interval:d2;            % show only these dates
xLabels  = state.vaxDates;            % all dates

%---------------------------------------------------------------------------------------------
%=== 1. DAILY BAR PLOT OF ADMINISTERED DOSES
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%-------------------------------------
%=== plot first and second doses for CT
subplot(2,1,1);

%=== get data
administered = state.vaxDataD(:,ct,2);
completed    = state.vaxDataD(:,ct,4);
completedJJ  = state.vaxDataD(:,ct,8);
completedJJ(isnan(completedJJ)) = 0;
firstJJ      = completedJJ;
secondPM     = completed - firstJJ;
firstPM      = administered - secondPM - firstJJ;

%=== fix march 13 when cdc corrected CT dose labeling
d = find(strcmp(state.vaxDates, '03/13/2021'));
firstPM(d) = 0;  

%=== plot data
y  = [secondPM, firstJJ, firstPM] / 1000;  % sum = administered
y  = max(y,0.0);
h  = bar(y, 0.8, 'stacked');
set(h(1), 'FaceColor', 'r'); 
set(h(2), 'FaceColor', 'g'); 
set(h(3), 'FaceColor', 'b'); 
hold on;

%=== plot moving average
MA = state.vaxDataMA(:,ct,2);
y  = MA / 1000;
plot(y,'k.-', 'MarkerSize', 20, 'Linewidth', 1); hold on;

%=== get labels for plot
strLegends(1) = {sprintf('Number of Pfizer + Moderna Second Doses')};
strLegends(2) = {sprintf('Number of J&J Single Doses')};
strLegends(3) = {sprintf('Number of Pfizer + Moderna First Doses')};
strLegends(4) = {sprintf('7-Day Moving Average (Latest = %s)', addComma(round(MA(end))))};
strTitle      = sprintf('%s: Doses Administered Each Day', stateName);
xTitle        = sprintf('CDC Report Date');
yTitle        = sprintf('Administered Doses (1000s)');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 2);
set(gca,'FontSize',  10);
set(gca,'XTick',x);  
set(gca,'XTickLabel',xLabels(x));
xlabel(xTitle,    'FontSize', 14);
ylabel(yTitle,    'FontSize', 14);
ytickformat('%1.0fK');
legend(strLegends,'FontSize', 9, 'Location','NorthEast', 'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle,   'FontSize', 16);

%-------------------------------------
%=== plot first and second doses for US
subplot(2,1,2);

%=== get data
administered = state.vaxDataD(:,us,2);
completed    = state.vaxDataD(:,us,4);
completedJJ  = state.vaxDataD(:,us,8);
completedJJ(isnan(completedJJ)) = 0;
firstJJ      = completedJJ;
secondPM     = completed - firstJJ;
firstPM      = administered - secondPM - firstJJ;

%=== plot data
y  = [secondPM, firstJJ, firstPM] / 1000000;   % sum = administered
h  = bar(y, 0.8, 'stacked');
set(h(1), 'FaceColor', 'r'); 
set(h(2), 'FaceColor', 'g'); 
set(h(3), 'FaceColor', 'b'); 
hold on;

%=== plot moving average
MA = state.vaxDataMA(:,us,2);
y  = MA / 1000000;
h  = plot(y,'k.-', 'MarkerSize', 20, 'Linewidth', 1); hold on;

%=== get labels for plot
strLegends(4) = {sprintf('7-Day Moving Average (Latest = %s)', addComma(round(MA(end))))};
strTitle      = sprintf('%s: Doses Administered Each Day', usName);
xTitle        = sprintf('CDC Report Date');
yTitle        = sprintf('Administered Doses (Millions)');
strSource     = sprintf('%s', parameters.vaxDataSourceCDCv);

%=== add data source
ax   = gca; 
xmin = ax.XLim(1);
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);  
x0   = xmin - 0.10*(xmax - xmin);
y0   = ymin - 0.15*(ymax - ymin);
h    = text(x0, y0, strSource); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');
hold on;

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 2);
set(gca,'FontSize',  10);
set(gca,'XTick',x);  
set(gca,'XTickLabel',xLabels(x));
xlabel(xTitle,    'FontSize', 14);
ylabel(yTitle,    'FontSize', 14);
ytickformat('%2.1fM');
legend(strLegends,'FontSize', 9, 'Location','NorthEast', 'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle,   'FontSize', 16);
return;

%---------------------------------------------------------------------------------------------
%=== 2. CUMULATIVE BAR PLOT OF PEOPLE INITIATING AND COMPLETING VACCINATION
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%-------------------------------------
%=== plot completed and initiated for CT
subplot(2,1,1);

%=== get data
initiated   = state.vaxDataN(:,ct,3);
completed   = state.vaxDataN(:,ct,4);
completedJJ = state.vaxDataN(:,ct,8);
completedJJ(isnan(completedJJ)) = 0;
completedPM = completed - completedJJ;
initiatedPM = initiated - completed;

%=== bar plot
y  = 100*[completedPM, completedJJ, initiatedPM];  % sum = initiated
h  = bar(y, 0.8, 'stacked');
set(h(1), 'FaceColor', 'r'); 
set(h(2), 'FaceColor', 'g'); 
set(h(3), 'FaceColor', 'b'); 

%=== get labels for plot
strLegends(1) = {sprintf('People Who Have Completed Pfizer & Moderna Vaccination')};
strLegends(2) = {sprintf('People Who Have Completed J&J Vaccination')};
strLegends(3) = {sprintf('People Who Have Initiated Vaccination')};
strTitle      = sprintf('%s: People Vaccinated (Cumulative as Percent of Population)', stateName);
xTitle        = sprintf('CDC Report Date');
yTitle        = sprintf('People (as Percent of Population)');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 2);
set(gca,'FontSize',  10);
set(gca,'XTick',x);  
set(gca,'XTickLabel',xLabels(x));
xlabel(xTitle,    'FontSize', 14);
ylabel(yTitle,    'FontSize', 14);
ytickformat('%1.0f%%');
legend(strLegends,'FontSize', 9, 'Location','NorthWest', 'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle,   'FontSize', 16);

%-------------------------------------
%=== plot completed and initiated for US
subplot(2,1,2);

%=== get data
initiated   = state.vaxDataN(:,us,3);
completed   = state.vaxDataN(:,us,4);
completedJJ = state.vaxDataN(:,us,8);
completedJJ(isnan(completedJJ)) = 0;
completedPM = completed - completedJJ;
initiatedPM = initiated - completed;

%=== bar plot
y  = 100*[completedPM, completedJJ, initiatedPM];  % sum = initiated
h  = bar(y, 0.8, 'stacked');
set(h(1), 'FaceColor', 'r'); 
set(h(2), 'FaceColor', 'g'); 
set(h(3), 'FaceColor', 'b'); 

%=== get labels for plot
strTitle      = sprintf('%s: People Vaccinated (Cumulative as Percent of Population)', usName);
xTitle        = sprintf('CDC Report Date');
yTitle        = sprintf('People (as Percent of Population)');
strSource     = sprintf('%s', parameters.vaxDataSourceCDCv);

%=== add data source
ax   = gca; 
xmin = ax.XLim(1);
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);  
x0   = xmin - 0.10*(xmax - xmin);
y0   = ymin - 0.15*(ymax - ymin);
h    = text(x0, y0, strSource); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');
hold on;

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 2);
set(gca,'FontSize',  10);
set(gca,'XTick',x);  
set(gca,'XTickLabel',xLabels(x));
ytickformat('%1.0f%%');
xlabel(xTitle,    'FontSize', 14);
ylabel(yTitle,    'FontSize', 14);
legend(strLegends,'FontSize', 9, 'Location','NorthWest', 'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle,   'FontSize', 16);

%---------------------------------------------------------------------------------------------
%=== 3. BAR CHART OF WEEKLY CDC ALLOCATIONS FOR CONNECTICUT
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get data
clear y;
y(:,1) = state.cdcAllocations(:,ct,1,1);
y(:,2) = state.cdcAllocations(:,ct,1,2);
y(:,3) = state.cdcAllocations(:,ct,2,1);
y(:,4) = state.cdcAllocations(:,ct,2,2);
y(:,5) = state.cdcAllocations(:,ct,1,3);
y      = y / 1000;
total  = nansum(y,2);

%=== bar chart
h = bar(y, 0.8, 'stacked');
set(h(1), 'FaceColor', 'b'); 
set(h(2), 'FaceColor', 'c'); 
set(h(3), 'FaceColor', 'r'); 
set(h(4), 'FaceColor', 'm'); 
set(h(5), 'FaceColor', 'g'); 
hold on;

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== weekly labels
xLabels1 = state.cdcAllocationDates;
xW       = 1:length(xLabels1);
xW2      = 1:2:length(xLabels1);

%=== horizontal line for most recent 7-day shipped doses
lastDate    = char(state.vaxDates(end));
x1          = 0.95*xmax;
x2          = xmax;
latest7Day1 = state.vaxData(end,ct,1) - state.vaxData(end-7,ct,1);
y0          = latest7Day1 / 1000;
plot([x1,x2], [y0,y0], '-', 'LineWidth', 3, 'Color', 'k');

%=== horizontal line for most recent 7-day administered doses
latest7Day2 = state.vaxData(end,ct,2) - state.vaxData(end-7,ct,2);
y0          = latest7Day2 / 1000;
plot([x1,x2], [y0,y0], ':', 'LineWidth', 3, 'Color', 'b');

%=== horizontal line for most recent 7-day completed (as proxy for 2nd doses)
latest7Day3 = state.vaxData(end,ct,4) - state.vaxData(end-7,ct,4);
y0          = latest7Day3 / 1000;
plot([x1,x2], [y0,y0], ':', 'LineWidth', 3, 'Color', 'r');

%=== get labels for plot
strLegends(1) = {sprintf('Pfizer  First  Dose Allocation')};
strLegends(2) = {sprintf('Moderna First  Dose Allocation')};
strLegends(3) = {sprintf('Pfizer  Second Dose Allocation')};
strLegends(4) = {sprintf('Moderna Second Dose Allocation')};
strLegends(5) = {sprintf('J&J     Single Dose Allocation')};
strLegends(6) = {sprintf('Delivered    Total  Doses (7 Days Ending %s) = %7s', lastDate, addComma(round(latest7Day1)))};
strLegends(7) = {sprintf('Administered Total  Doses (7 Days Ending %s) = %7s', lastDate, addComma(round(latest7Day2)))};
strLegends(8) = {sprintf('Administered Second Doses (7 Days Ending %s) = %7s', lastDate, addComma(round(latest7Day3)))};
strSource     = sprintf('%s', parameters.vaxDataSourceCDCa);
strTitle      = sprintf('%s: CDC Weekly Allocations (Compared with Actual Doses Delivered and Administered)', stateName);
xTitle        = sprintf('CDC Allocation Week');
yTitle        = sprintf('CDC Weekly Allocations (1000s of Doses)');

%=== add total allocation over the stacked bars
for w=1:length(xW)
  strText = sprintf('%s', addComma(round(1000*total(w))));
  x0      = xW(w);
  y0      = total(w);
  h       = text(x0,y0,strText); 
  set(h, 'Color', 'k'); set(h, 'FontSize', 10), set(h, 'FontWeight', 'bold'), set(h, 'vert', 'Bottom'), set(h, 'horiz', 'Center');
end

%=== add data source
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.075*(ymax - ymin);
h = text(x0, y0, strSource); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 2);
set(gca,'FontSize',  10);
set(gca,'XTick',xW2);  
set(gca,'XTickLabel',xLabels1(xW2));
xlabel(xTitle,    'FontSize', 14);
ylabel(yTitle,    'FontSize', 14);
ytickformat('%1.0fK');
legend(strLegends,'FontSize', 10, 'Location','NorthWest', 'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle,   'FontSize', 16);

%---------------------------------------------------------------------------------------------
%=== 4. DAILY BAR PLOT OF DELIVERED AND ADMINISTERED DOSES
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== DELIVERED
subplot(2,1,1);
delivered = state.vaxDataD(:,ct,1);
MA        = state.vaxDataMA(:,ct,1);

%=== bar plot
y = delivered / 1000;
bar(y, 0.8, 'stacked', 'FaceColor', 'g'); hold on;

%=== plot moving average
y = MA / 1000;
plot(y,'k.-', 'MarkerSize', 20, 'Linewidth', 1); hold on;

%=== get labels for plot
strLegends(1) = {sprintf('Number of Doses Delivered')};
strLegends(2) = {sprintf('7-Day Moving Average (Latest = %s)', addComma(round(MA(end))))};
strTitle      = sprintf('%s: Number of Doses Delivered Each Day', stateName);
xTitle        = sprintf('CDC Report Date');
yTitle        = sprintf('Delivered Doses (1000s)');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 2);
set(gca,'FontSize',  10);
set(gca,'XTick',x);  
set(gca,'XTickLabel',xLabels(x));
xlabel(xTitle,    'FontSize', 14);
ylabel(yTitle,    'FontSize', 14);
ytickformat('%1.0fK');
legend(strLegends,'FontSize', 9, 'Location','NorthWest', 'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle,   'FontSize', 16);

%=== ADMINISTERED
subplot(2,1,2);
administered = state.vaxDataD(:,ct,2);
MA           = state.vaxDataMA(:,ct,2);

%=== bar plot
y = administered / 1000;
bar(y, 0.8, 'stacked', 'FaceColor', 'c'); hold on;

%=== plot moving average
y = MA / 1000;
plot(y,'k.-', 'MarkerSize', 20, 'Linewidth', 1); hold on;

%=== get labels for plot
strLegends(1) = {sprintf('Number of Doses Administered')};
strLegends(2) = {sprintf('7-Day Moving Average (Latest = %s)', addComma(round(MA(end))))};
strTitle      = sprintf('%s: Number of Doses Administered Each Day', stateName);
xTitle        = sprintf('CDC Report Date');
yTitle        = sprintf('Administered Doses (1000s)');

%=== add data source
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.150*(ymax - ymin);
h = text(x0, y0, strSource); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 2);
set(gca,'FontSize',  10);
set(gca,'XTick',x);  
set(gca,'XTickLabel',xLabels(x));
xlabel(xTitle,    'FontSize', 14);
ylabel(yTitle,    'FontSize', 14);
ytickformat('%1.0fK');
legend(strLegends,'FontSize', 9, 'Location','NorthWest', 'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle,   'FontSize', 16);

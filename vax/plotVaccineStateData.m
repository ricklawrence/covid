function plotVaccineStateData(state, figureNum)
%
% plot vaccine data by state and return ranks for each metric
%
global parameters;

if figureNum < 0
  return;
end
fprintf('\n--> plotVaccineStateData\n');

%=== get cumulative delivered and administered
stateIndex   = find(~strcmp(state.names, 'United States1'));
delivered    = 100 * state.vaxDataN(end,stateIndex,1)';
administered = 100 * state.vaxDataN(end,stateIndex,2)';
ratio        = 100 * administered ./ delivered;
query        = ratio == Inf | isnan(ratio);
ratio(query) = 0;

%=== get people vaccinated
initiated    = 100*state.vaxDataN(end,stateIndex,3)';
completed    = 100*state.vaxDataN(end,stateIndex,4)';
singleDose   = initiated - completed;

%=== set state to focus on
stateName  = 'Connecticut';    stateName0 = 'CT';
yLabels    = state.names(stateIndex);

%------------------------------------------------------------------------
%=== 1. SCATTER PLOT OF VACCINATION FRACTIONS
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get data
stateNames   = state.names0;
date1        = char(state.vaxDates(end-7));
date2        = char(state.vaxDates(end));

%=== get total population percents
x1         = state.vaxData(end-7,:,9)';
x2         = state.vaxData(end,  :,9)';

%=== get 65+ population percents
y1         = state.vaxData(end-7,:,10)';
y2         = state.vaxData(end,  :,10)';

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); 
strLegend(1) = {sprintf('Data as of %s', date2)}; subset(1) = h1;

%=== add state names inside circles
for i=1:length(x2)
  h = text(x2(i),y2(i), char(stateNames(i))); hold on;
  set(h,'HorizontalAlignment','Center'); 
  set(h,'FontWeight', 'bold');
  if strcmp(stateNames(i), 'US') ||strcmp(stateNames(i), 'CT')
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

%=== set labels
strTitle  = sprintf('Percent of State Populations (Age 65+ vs Total) Completing Vaccination');
xTitle    = sprintf('Percent of Total Population Completing Vaccination');
yTitle    = sprintf('Percent of Age 65+ Population Completing Vaccination');
strSource = sprintf('%s', parameters.vaxDataSourceCDCv);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add data source
x0   = xmin - 0.150*(xmax - xmin);
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
legend(strLegend, 'Location', 'NorthWest', 'Fontsize', 12);
title(strTitle, 'Fontsize', 16);

return;

%------------------------------------------------------------------------
%=== 2. SCATTER PLOT OF COMPLETED VS INITIATED
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get most recent date
date2        = char(state.vaxDates(end));    % latest date
stateNames0  = state.names0(stateIndex);

%=== set labels
strTitle  = sprintf('Completed Vaccinations vs Initiated Vaccinations (as Percent of Population)');
xTitle    = sprintf('Initiated Vaccination (as Percent of Population)');
yTitle    = sprintf('Completed Vaccination (as Percent of Population)');
strSource = sprintf('%s', parameters.vaxDataSourceCDCv);
strText1  = sprintf('Initiated Vaccination: People who have received at least one dose.');
strText2  = sprintf('Completed Vaccination: People who have received all doses prescribed by the vaccination protocol.');
strText3  = sprintf('Connecticut ranks #%2d in Initiated Vaccinations.', ranks(1));
strText4  = sprintf('Connecticut ranks #%2d in Completed Vaccinations.', ranks(2));
strText   = sprintf('%s\n%s\n%s\n%s', strText1, strText2, strText3, strText4);

%=== get people initiated and completed
x2 = initiated;
y2 = completed;

%=== plot big circles for each point
h2 = plot(x2, y2, 'o'); 
set(h2,'Color','k'); 
set(h2,'Markersize', 20); % add big circles
subset(1) = h2(1); strLegend(1) = {sprintf('CDC Data as of %s', date2)};

%=== add state abbreviations
for i=1:length(x2)
  h1 = text(x2(i),y2(i), char(stateNames0(i))); 
  set(h1,'HorizontalAlignment','Center'); 
  if strcmp(stateNames0(i), 'US') || strcmp(stateNames0(i), stateName0)
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

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1);
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2); 

%=== linear fit
[~, sortIndex] = sort(x2);
x3    = x2(sortIndex);
y3    = y2(sortIndex);
P     = polyfit(x3,y3,1);
slope = P(1);
yfit3 = polyval(P,x3);
h3    = plot(x3,yfit3, 'r-', 'LineWidth', 2); hold on;
subset(2) = h3; strLegend(2) = {sprintf('Linear Fit (Slope = %4.3f)', slope)};

%=== add explanatory text
x0   = xmin + 0.30*(xmax - xmin);
y0   = ymin + 0.99*(ymax - ymin);
h    = text(x0, y0, strText); 
set(h,'FontSize', 9);  set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); set(h,'FontWeight', 'bold'); 
set(h,'Horiz','Left'); set(h,'Vert','Top');  set(h, 'FontName', 'FixedWidth');

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
legend(subset, strLegend, 'Location', 'NorthWest', 'FontSize', 14);
title(strTitle, 'Fontsize', 16);

%-----------------------------------------------------------------------------
%=== 3. HORIZONTAL BAR CHART OF PEOPLE WITH 1 AND 2 DOSES
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get data for plots
yValues        = [completed singleDose];
yLabels        = state.names(stateIndex);
sortValues     = completed + singleDose;
[~, sortIndex] = sort(sortValues, 'descend');
yValues        = yValues(sortIndex,:);
yLabels        = yLabels(sortIndex);
yValues        = yValues(end:-1:1,:);   % reverse so biggest is at top of bar chart
yLabels        = yLabels(end:-1:1);     % reverse so biggest is at top of bar chart
y              = 1:length(yLabels);

%=== horizontal bar chart
h = barh(y, yValues, 'stacked'); 
set(h(1), 'FaceColor', 'r'); hold on;
set(h(2), 'FaceColor', 'b'); hold on;
plot([0,0], [0,0], '.');     hold on;

%=== labels
strTitle     = sprintf('People Vaccinated in Each State (as of %s) As Percent of Population', char(state.vaxDates(end)));
strLegend(1) = {sprintf('People Who Have Received Second Dose (Fully Vaccinated)')}; 
strLegend(2) = {sprintf('People Who Have Received First Dose Only')};
strLegend(3) = {sprintf('%s ranks #%d in People Receiving at Least One Dose', stateName, ranks(1))};
xLabel       = 'People (as Percent of Population)';
strSource    = sprintf('%s', parameters.vaxDataSourceCDCv);

%=== add value next to target state
s = find(strcmp(stateName, yLabels));
x0 = yValues(s,1) + yValues(s,2);
y0 = y(s);
h = text(x0,y0,sprintf(' %3.2f%%',x0));
set(h,'Color','b'); set(h,'Horiz','Left'); set(h, 'Vert', 'middle'); set(h,'FontSize', 12); set(h,'FontWeight', 'bold');

%=== add data source
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.075*(ymax - ymin);
h = text(x0, y0, strSource); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== axis labels and everything else
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'FontSize',10);
set(gca,'YTick',y);
set(gca,'YTickLabel',yLabels(y));
xtickformat('%1.0f%%');
xlabel(sprintf('%s', xLabel), 'FontSize', 14);
title(sprintf('%s', strTitle), 'FontSize', 14);
legend(strLegend, 'location', 'SouthEast', 'fontsize', 10, 'FontName','FixedWidth', 'FontWeight','bold');

%------------------------------------------------------------------------
%=== 4. SCATTER PLOT OF DELIVERED VS ADMINISTRATION
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== determine number of days since last report
n = datenum(state.vaxReportDates(end)) - datenum(state.vaxReportDates(end-1));

%=== get most recent date plus previous date
date2            = char(state.vaxDates(end));    % latest date
date1            = char(state.vaxDates(end-n));  % previous date

%=== get date and state indices
dateIndex1       = find(strcmp(date1, state.vaxDates));
dateIndex2       = find(strcmp(date2, state.vaxDates));
exclude          = {'Alaska', 'District of Columbia'};    % exclude states with very high distribution
%exclude          = {};    
[~, stateIndex1] = setdiff(state.names, exclude);
stateNames0      = state.names0(stateIndex1);

%=== set labels
strTitle  = sprintf('Cumulative Administered Doses vs Cumulative Delivered Doses');
xTitle    = sprintf('Cumulative Delivered Doses (as Percent of Population)');
yTitle    = sprintf('Cumulative Administered Doses (as Percent of Population)');
strSource = sprintf('%s', parameters.vaxDataSourceCDCv);
strText1  = sprintf('The open circles show the latest CDC data for each state.');
strText2  = sprintf('The dashed lines (''jet plumes'') show the trajectory for each state since the previous CDC report.');
strText3  = sprintf('The solid Red lines show constant Administration Efficiencies.');
strText   = sprintf('%s\n%s\n%s', strText1, strText2, strText3);

%=== get distribution and administration data as percent of population at both dates
x1 = 100 * state.vaxDataN(dateIndex1,stateIndex1,1)';
y1 = 100 * state.vaxDataN(dateIndex1,stateIndex1,2)';
x2 = 100 * state.vaxDataN(dateIndex2,stateIndex1,1)';
y2 = 100 * state.vaxDataN(dateIndex2,stateIndex1,2)';

%=== plot big circles for each point
h2 = plot(x2, y2, 'o'); 
set(h2,'Color','k'); 
set(h2,'Markersize', 20); % add big circles
subset(1) = h2(1);
strLegend(1) = {sprintf('CDC Data as of %s', date2)};

%=== add state abbreviations
for i=1:length(x2)
  h1 = text(x2(i),y2(i), char(stateNames0(i))); 
  set(h1,'HorizontalAlignment','Center'); 
  if strcmp(stateNames0(i), 'US') || strcmp(stateNames0(i), stateName0)
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

%=== plot small dots for each each previous point
h3 = plot(x1, y1, '.'); 
set(h3,'Color','k'); 
set(h3,'Markersize', 10); % add small dots
subset(2) = h3(1);
strLegend(2) = {sprintf('CDC Data as of %s', date1)};

%=== increase ymax to accommodate explanatory text at top
ax   = gca; 
xmin = ax.XLim(1);
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2) + 1.0;  
xlim([xmin xmax]);
ylim([ymin ymax]);

%=== plot lines connecting current data to previous data
colormap(jet(length(x1)));
for i=1:length(x1)
  h3 = plot([x1(i), x2(i)], [y1(i), y2(i)], ':'); hold on;
  set(h3,'LineWidth', 1);
end

%=== plot lines for constant administration efficiency
efficiency1 = [0.6 0.7 0.8 0.9];
yLimit  = max([y1;y2]);  % max y value
xfit(1) = min([x1;x2]);  % min x value
xfit(2) = max([x1;x2]);  % max x value
for i=1:length(efficiency1)
  efficiency = efficiency1(i);
  yfit       = efficiency .* xfit;
  if yfit(2) > yLimit                 % limit the length of the lines
    xfit(2) = yLimit / efficiency;  
    yfit(2) = yLimit;
  end
  h            = plot(xfit,yfit,'r-');  set(h, 'LineWidth', 1); hold on;
  strText1     = sprintf('%2.0f%%', 100*efficiency);
  x0           = xfit(2);
  y0           = yfit(2);
  h            = text([x0,x0],[y0,y0], strText1); 
  set(h,'Color','r', 'HorizontalAlignment','Left', 'FontWeight','bold', 'FontSize',10);
end

%=== add explanatory text
x0   = xmin + 0.30*(xmax - xmin);
y0   = ymin + 0.99*(ymax - ymin);
h    = text(x0, y0, strText); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); set(h,'FontWeight', 'normal'); 
set(h,'Horiz','Left'); set(h,'Vert','Top'); 

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
legend(subset, strLegend, 'Location', 'NorthWest', 'FontSize', 14);
title(strTitle, 'Fontsize', 16);

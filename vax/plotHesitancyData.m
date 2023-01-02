function plotHesitancyData(county, state, figureNum)
%
% plot CDC hesitancy data
%
global parameters;
if figureNum < 0
  return;
end
fprintf('\n--> plotHesitancyData\n');

%-----------------------------------------------------------------------------
%=== 1. HORIZONTAL BAR CHART OF STATE-LEVEL HESITANCY DATA
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== compute hesitancy metrics at state level
index            = find(~strcmp(state.names0, 'DC'));   % no data for DC
stronglyHesitant = state.hesitancy(index,3);
hesitant         = state.hesitancy(index,2) - state.hesitancy(index,3);
unsure           = state.hesitancy(index,1) - state.hesitancy(index,2);

%=== get data for plots
yValues        = [stronglyHesitant hesitant  unsure] * 100;
yLabels        = state.names(index);
y              = 1:length(yLabels);
sortValues     = nansum(yValues,2);
[~, sortIndex] = sort(sortValues, 'descend');
yValues        = yValues(sortIndex,:);
yLabels        = yLabels(sortIndex);
yValues        = flip(yValues);     % reverse so biggest is at top of bar chart
yLabels        = flip(yLabels);     % reverse so biggest is at top of bar chart

%=== horizontal bar chart
h = barh(y, yValues, 'stacked'); 
set(h(1), 'FaceColor', 'r'); hold on; 
set(h(2), 'FaceColor', 'c'); hold on; 
set(h(3), 'FaceColor', 'b'); hold on; 

%=== add value next to US and CT
stateName = 'Connecticut';
s  = find(strcmp(stateName, yLabels));
x0 = sum(yValues(s,:),2);
y0 = y(s);
h1 = text(x0,y0,sprintf(' %s = %2.1f%%', stateName, x0));
s  = find(strcmp('United States', yLabels));
x0 = sum(yValues(s,:),2);
y0 = y(s);
h2 = text(x0,y0,sprintf(' United States = %2.1f%%',x0));
set(h1,'Color','k'); set(h1,'Horiz','Left'); set(h1, 'Vert', 'middle'); set(h1,'FontSize', 10); set(h1,'FontWeight', 'bold');
set(h2,'Color','k'); set(h2,'Horiz','Left'); set(h2, 'Vert', 'middle'); set(h2,'FontSize', 10); set(h2,'FontWeight', 'bold');

%=== labels 
strTitle      = sprintf('CDC Estimated Hesitancy Data by State');
xLabel        = 'CDC Hesitancy Estimates (%)';
strLegends(1) = {'Stongly Hesitant'};
strLegends(2) = {'Hesitant'};
strLegends(3) = {'Unsure'};
strSource    = sprintf('%s', 'https://data.cdc.gov/Vaccinations/COVID-19-County-Hesitancy/c4bi-8ytd');

%=== add data source
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
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
xtickformat('%1.0f%%');
xlabel(sprintf('%s', xLabel), 'FontSize', 14);
legend(strLegends,'FontSize', 12, 'Location','SouthEast', 'FontName','FixedWidth', 'FontWeight','bold');
title(sprintf('%s', strTitle), 'FontSize', 14);
return;

%-----------------------------------------------------------------------------
%=== 2. HORIZONTAL BAR CHART OF MOST HESITANT COUNTIES WITHIN EACH STATE
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== compute hesitancy metrics at county level
stronglyHesitant = NaN(state.numNames,1);
hesitant         = NaN(state.numNames,1);
unsure           = NaN(state.numNames,1);
countyNames      = cell(state.numNames,1);
stateIndex       = find(~strcmp(state.names0, 'DC') & ~strcmp(state.names0, 'US'));
for s=stateIndex'
  index0              = find(contains(county.names0, state.names0(s)));
  [~, index]          = max(county.hesitancy(index0,1));
  index               = index0(index(1));
  stronglyHesitant(s) = county.hesitancy(index,3);
  hesitant(s)         = county.hesitancy(index,2) - county.hesitancy(index,3);
  unsure(s)           = county.hesitancy(index,1) - county.hesitancy(index,2);
  countyNames(s)      = county.names0(index);
end

%=== get data for plots
yValues        = [stronglyHesitant hesitant  unsure] * 100;
yLabels        = countyNames;
y              = 1:length(yLabels);
sortValues     = nansum(yValues,2);
[~, sortIndex] = sort(sortValues, 'descend');
yValues        = yValues(sortIndex,:);
yLabels        = yLabels(sortIndex);
yValues        = flip(yValues);     % reverse so biggest is at top of bar chart
yLabels        = flip(yLabels);     % reverse so biggest is at top of bar chart

%=== horizontal bar chart
h = barh(y, yValues, 'stacked'); 
set(h(1), 'FaceColor', 'r'); hold on; 
set(h(2), 'FaceColor', 'c'); hold on; 
set(h(3), 'FaceColor', 'b'); hold on; 

%=== labels 
strTitle      = sprintf('County in Each State with the Highest CDC Hesitancy');
xLabel        = 'CDC Hesitancy Estimates (%)';
strLegends(1) = {'Stongly Hesitant'};
strLegends(2) = {'Hesitant'};
strLegends(3) = {'Unsure'};
strSource    = sprintf('%s', 'https://data.cdc.gov/Vaccinations/COVID-19-County-Hesitancy/c4bi-8ytd');

%=== add data source
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
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
xtickformat('%1.0f%%');
xlabel(sprintf('%s', xLabel), 'FontSize', 14);
legend(strLegends,'FontSize', 12, 'Location','SouthEast', 'FontName','FixedWidth', 'FontWeight','bold');
title(sprintf('%s', strTitle), 'FontSize', 14);
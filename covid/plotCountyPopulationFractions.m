function plotCountyPopulationFractions(county, figureNum)
%
%  plot time series of fraction of us population in surging counties
%
global parameters;
fprintf('\n--> plotCountyPopulationFractions\n');

%=== new cases and populations
strTitle     = sprintf('Percent of US Population Living in Counties with Increased New Case Rates');
newCaseRates = county.features(:,:, 2);
numCounties  = county.numNames;
populations  = county.population;
dates        = county.dates;
numDates     = county.numDates;

%=== compute fraction of US population in counties with increased news cases
limits      = [40, 60, 80, 100, 120];
numLimits   = length(limits);
fractions   = NaN(numDates, numLimits);
strLegends  = cell(numLimits,1);
strText     = cell(numLimits,1);
lastValue   = NaN(numLimits,1);
for f=1:numLimits
  for d=1:numDates
    index = find(newCaseRates(d,:) > limits(f));
    fractions(d,f) = nansum(populations(index)) ./ nansum(populations);
  end
  strLegends(f) = {sprintf('Greater than %2.0f New Cases per 100,000',limits(f))};
  lastValue(f)  = 100*fractions(end,f);
  strText(f)    = {sprintf('%4.1f%%', lastValue(f))};
end

%=== set dates to be plotted
shortWindow = 8*7;
d2          = numDates;
d1          = numDates - shortWindow;
d1a         = d2-floor(numDates/7)*7;
d1          = max(d1,d1a);   % rarely, counties can have less that shortWindow days
interval    = 7;             % weekly
xLabels     = dates(d1:d2);
xTicks      = [d1:interval:d2]';
xTicks      = xTicks - d1 + 1;

%-----------------------------------------------------------------------------------------------------
%=== LINE PLOT OF US POPULATION FRACTIONS
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== line plots
y = 100*fractions;
h = plot(y(d1:d2,:));  
set(h,    'LineWidth', 2);
set(h(1), 'Color', 'k');
set(h(2), 'Color', 'b');
set(h(3), 'Color', 'm');
set(h(4), 'Color', 'c');
set(h(5), 'Color', 'r');

%=== add final numbers
x = xTicks(end)+0.5;
y = lastValue(1); 
h = text([x,x],[y,y], strText(1)); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontWeight', 'bold'); set(h,'FontSize', 10);
y = lastValue(2); 
h = text([x,x],[y,y], strText(2)); set(h,'Color','b'); set(h,'HorizontalAlignment','Left'); set(h,'FontWeight', 'bold'); set(h,'FontSize', 10);
y = lastValue(3); 
h = text([x,x],[y,y], strText(3)); set(h,'Color','m'); set(h,'HorizontalAlignment','Left'); set(h,'FontWeight', 'bold'); set(h,'FontSize', 10);
y = lastValue(4); 
h = text([x,x],[y,y], strText(4)); set(h,'Color','c'); set(h,'HorizontalAlignment','Left'); set(h,'FontWeight', 'bold'); set(h,'FontSize', 10);
y = lastValue(5); 
h = text([x,x],[y,y], strText(5)); set(h,'Color','r'); set(h,'HorizontalAlignment','Left'); set(h,'FontWeight', 'bold'); set(h,'FontSize', 10);

%=== add axis labels
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'FontSize',12);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(sprintf('Reporting Date (Last %d weeks)', shortWindow/7), 'FontSize', 12);
ylabel('Percent of US Population','FontSize', 12);
legend(strLegends,'Location', 'NorthWest', 'FontSize', 10);
title(strTitle, 'FontSize', 16);

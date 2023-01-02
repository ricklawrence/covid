function plotKansasMaskData(county, figureNum)
%
% repeat CDC analysis of kansas mask experiment
%
global parameters;
if figureNum < 0
  return;
end
fprintf('\n--> plotKansasMaskData\n');

%=== set 24 counties that did not opt out of mask mandate
counties1 = {'Allen', 'Atchison', 'Bourbon', 'Crawford', 'Dickinson', 'Douglas', 'Franklin', 'Geary', ...
             'Gove', 'Harvey', 'Jewell', 'Johnson', 'Mitchell', 'Montgomery', 'Morris', 'Pratt', 'Reno', ...
             'Republic', 'Saline', 'Scott', 'Sedgwick', 'Shawnee', 'Stanton', 'Wyandotte'}';

%=== get all kansas counties
index0       = find(strcmp(county.stateNames0, 'KS'));
counties0    = strtok(county.names(index0));

%=== compute index for mask counties
[~,i1]       = intersect(counties0, counties1);
index1       = index0(i1);

%=== compute index for non-mask counties
counties2    = setdiff(counties0, counties1);
[~,i2]       = intersect(counties0, counties2);
index2       = index0(i2);

%=== debug
county.names0(index1);
county.names0(index2);

%=== compute new case rates (does not agree with CDC paper ...)
newCaseRate1 = 100000 * nansum(county.newCases(:,index1),2) ./ nansum(county.population(index1));
newCaseRate2 = 100000 * nansum(county.newCases(:,index2),2) ./ nansum(county.population(index2));
newCaseRate1 = movingAverage(newCaseRate1, 7);
newCaseRate2 = movingAverage(newCaseRate2, 7);

%=== overwrite with average case rates in each county (trying to get agreement with CDC paper)
%newCaseRate1 = nanmean(county.features(:,index1,2),2);
%newCaseRate2 = nanmean(county.features(:,index2,2),2);

%=== get new case rates for CDC period
d1           = find(strcmp(county.dates, '06/01/2020'));
d2           = find(strcmp(county.dates, '08/23/2020'));
dates        = county.dates(d1:d2);
numDates     = length(dates);
newCaseRate1 = newCaseRate1(d1:d2);
newCaseRate2 = newCaseRate2(d1:d2);
[newCaseRate1 newCaseRate2];

%-------------------------------------------------------------------------------------------------------------------
%=== LINE PLOT
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get date labels
x        = 1:14:numDates;
x(end+1) = numDates;
xLabels  = dates;

%=== do plots
plot(newCaseRate1,'b-', 'LineWidth', 2); hold on;
plot(newCaseRate2,'r-', 'LineWidth', 2); hold on;

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== plot vertical line at July 3 when mandate began
date0 = '07/03/2020';
d0    = find(strcmp(date0, dates));
plot([d0,d0],[ymin,ymax], 'k:', 'Linewidth', 2); hold on;

%=== get labels for plot
strLegends(1) = {sprintf('%d Kansas counties that retained mask mandate',     length(index1))};
strLegends(2) = {sprintf('%d Kansas counties that opted out of mask mandate', length(index2))};
strLegends(3) = {sprintf('Kansas mask mandate took effect on %s', date0)};
strTitle      = sprintf('Analysis of Kansas Counties that retained or opted out of mask mandate');
xTitle        = sprintf('CDC Report Date');
yTitle        = sprintf('New Case Rate (per 100,000 Residents)');
strSource     = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

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



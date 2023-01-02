function  data = plotConnecticutCasesByAge(stateAge, figureNum)
%
% plot age distribution of new cases and deaths
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> plotConnecticutCasesByAge\n');

%=== set 2 date bins
date1 = '01/01/2021';
date2 = '08/31/2021';
date3 = '09/01/2021';
date4 = '11/30/2021';
date5 = '12/01/2021';
date6 = char(stateAge.dates(end));
d1    = find(strcmp(date1, stateAge.dates));
d2    = find(strcmp(date2, stateAge.dates));
d3    = find(strcmp(date3, stateAge.dates));
d4    = find(strcmp(date4, stateAge.dates));
d5    = find(strcmp(date5, stateAge.dates));
d6    = find(strcmp(date6, stateAge.dates));

%=== bin new cases by date
newCases0     = stateAge.newCasesByAgeGroup;
newCases(1,:) = nansum(newCases0(d1:d2,:),1);
newCases(2,:) = nansum(newCases0(d3:d4,:),1);
newCases(3,:) = nansum(newCases0(d5:d6,:),1);

%=== normalize over age groups
newCasesN(1:3,:) = newCases(1:3,:) ./ nansum(newCases(1:3,:),2);

%----------------------------------------------------------------------------------------
%=== 1. PLOT NEW CASE DISTRIBUTIONS
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== plot data
y(:,1) = newCasesN(1,:)';
y(:,2) = newCasesN(2,:)';
y(:,3) = newCasesN(3,:)';
h      = bar(y, 1.0, 'grouped'); hold on;
set(h(1),'FaceColor', 'b');
set(h(2),'FaceColor', 'r');
set(h(3),'FaceColor', 'c');

%=== set labels
strTitle      = sprintf('State of Connecticut: Distribution of New Cases over Age Group');
strLegends(1) = {sprintf('%s to %s (Pre-Delta Variants)', date1, date2)};
strLegends(2) = {sprintf('%s to %s (Delta Dominant)', date3, date4)};
strLegends(3) = {sprintf('%s to %s (Omicron Prevalent) ', date5, date6)};
xLabels       = stateAge.AgeGroupLabels;

%=== add data source
ax   = gca; 
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = 0;
y0   = ymin - 0.07*(ymax - ymin);
strText = sprintf('%s\n%s', parameters.ctDataSource, parameters.rickAnalysis);
h = text(x0, y0, strText); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== finish plot
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',14);
set(gca,'XTickLabel',xLabels);
xlabel('Age Group', 'FontSize', 14);
ylabel('Fraction of New Cases','FontSize', 14);
strTitle = sprintf('State of Connecticut: Distribution of New Cases over Age Group');
legend(strLegends,'Location', 'NorthEast', 'FontSize', 14);
title(strTitle, 'FontSize', 16);
%return;

%----------------------------------------------------------------------------------------
%=== 2. PLOT NEW CASE DISTRIBUTIONS OVER TIME
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== set date limits
dates       = stateAge.dates;
numDates    = stateAge.numDates;

numWeeks    = floor(numDates / 7);  % all weeks
numWeeks    = 52;
window      = numWeeks*7;
d2          = numDates;
d1          = numDates - window;
interval    = window / 10;                  % ~20 date labels
interval    = 7 * ceil(interval/7);         % round up to integer number of weeks
xLabels     = dates(d1:d2);
xTicks      = [d1:interval:d2]';
xTicks      = xTicks - d1 + 1;

%=== replace negative new cases with NaN
newCases      = stateAge.newCasesByAgeGroup;
i             = find(min(newCases,[],2) < 0);
newCases(i,:) = NaN;

%=== plot normalized moving average
newCases = movingAverage(newCases, 7);
y        = newCases ./ repmat(nansum(newCases,2), 1,9);
h        = bar(y(d1:d2,:), 1.0, 'stacked'); hold on;
ylim([0,1]);

%=== set labels
strTitle      = sprintf('State of Connecticut: Distribution of New Cases over Age Group');
xLabel        = sprintf('Reporting Date');
yLabel        = sprintf('Fraction of New Cases in Each Age Group');
strLegends    = stateAge.AgeGroupLabels;

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add data source
ax   = gca; 
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = xmin - 0.07*(xmax - xmin);
y0   = ymin - 0.09*(ymax - ymin);
strText = sprintf('%s\n%s', parameters.ctDataSource, parameters.rickAnalysis);
h = text(x0, y0, strText); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== finish plot
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',14);
set(gca,'FontSize',14);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(xLabel, 'FontSize', 16);
ylabel(yLabel, 'FontSize', 16);
legend(strLegends,'Location', 'West', 'FontSize', 14);
title(strTitle, 'FontSize', 16);
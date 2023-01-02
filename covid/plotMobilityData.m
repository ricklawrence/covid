function plotMobilityData(stateName, countyName, mobilityData, covidData, figureNum)
%
% plot google mobility data
%
global parameters;
fprintf('\n--> plotMobilityData\n');

%=== get mobility data data
index      = find(strcmp(stateName, mobilityData.stateName) & strcmp(countyName, mobilityData.countyName1));
dates      = mobilityData.Date(index);
datenums   = mobilityData.Datenum(index);
data       = mobilityData.mobility(index,:);
dataLabels = mobilityData.labels;
numSignals = length(mobilityData.labels);
numDates   = length(dates);

%=== get new case data and align into same date structure
nameIndex                   = find(strcmp(countyName, covidData.names));
[~, dateIndex1, dateIndex2] = intersect(datenums, covidData.datenums);
newCaseRates                = NaN(numDates,1);
newCaseRates(dateIndex1)    = covidData.features(dateIndex2,nameIndex,2);

%=== entity name for plotting
if strcmp(countyName, 'MISSING')
  entityName = stateName;
else
  entityName = sprintf('%s (%s %s)', stateName, countyName, 'County');
end

%=== set colors for plots
colors    = {'k', 'k', 'k', 'k', 'k', 'k'};
barWidth  = 0.8;

%-------------------------------------------------------------------------------------
%=== 1. PLOT DATA IN GRID PLOTS
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== set date intervals
interval    =16*7;
d1          = 1;
d2          = numDates;
xLabels     = dates(d1:d2);
xTicks      = [d1:interval:d2]';
xTicks      = xTicks - d1 + 1;

%=== 3 x 2 grid of plots (there are 6 mobility signals)
numRow     = 3;
numCol     = 2;

%=== loop over signals
for sig=1:numSignals
  subplot(numRow, numCol, sig);
  
  %=== raw signal
  y = data(:,sig);
  h = bar(y, barWidth); set(h,'Facecolor', char(colors(sig)));
  hold on;
   
  %=== moving average
  MA = movingAverage(y, parameters.maWindow);
  h = plot(MA,'r-'); set(h, 'LineWidth', 2);
  hold on;

  %=== add axis labels
  hold off;
  grid on;
  set(gca,'LineWidth', 1);
  set(gca,'FontSize',8);
  set(gca,'XTick',xTicks);  
  set(gca,'XTickLabel',xLabels(xTicks));
  ylabel('Percent Change from Baseline', 'FontSize',10);
  title(sprintf('%s: %s', char(entityName), char(dataLabels(sig))), 'FontSize',14);
end
hold off;

%-------------------------------------------------------------------------------------
%=== 2. PLOT DATA AS INDIVIDUAL FIGURES

%=== set date intervals
shortTerm   = 1;
plotCases   = 0;
strLabel    = '';
if shortTerm
  numWeeks    = 8;
  interval    = 7;
  d2          = numDates;
  d1          = numDates - 7*numWeeks;
  strLabel    = sprintf('Last %d weeks', numWeeks);
end
xLabels     = dates(d1:d2);
xTicks      = [d1:interval:d2]';
xTicks      = xTicks - d1 + 1;

%=== loop over signals
for sig=1:numSignals
  
  %=== new figure for each signal
  figureNum = figureNum + 1;
  figure(figureNum); fprintf('Figure %d.\n', figureNum);
  
  %=== labels
  strTitle = sprintf('%s: %s', char(entityName), char(dataLabels(sig)));
  strLegends(1) = {sprintf('%s', char(dataLabels(sig)))};
  strLegends(2) = {sprintf('%d-day Moving Average', parameters.maWindow)};
  strLegends(3) = {sprintf('New Case Rate (per 100,000 Residents)')};
  
  %=== raw signal
  y = data(:,sig);
  h = bar(y(d1:d2), barWidth); set(h, 'Facecolor', char(colors(sig)));
  hold on;
   
  %=== moving average
  MA = movingAverage(y, parameters.maWindow);
  h = plot(MA(d1:d2),'r-');            set(h, 'LineWidth', 2);
  hold on;
  
  %=== new case rates
  if plotCases
    yyaxis right;
    h = plot(newCaseRates(d1:d2), 'b-'); set(h, 'LineWidth', 2);
    hold on;
  end
  
  %=== add axis labels
  hold off;
  grid on;
  set(gca,'LineWidth', 1);
  set(gca,'FontSize',10);
  set(gca,'XTick',xTicks);  
  set(gca,'XTickLabel',xLabels(xTicks));
  xlabel(strLabel);
  if plotCases
    set(gca,'YColor', 'b');
    yyaxis left
    ylabel('Percent Change from Baseline', 'FontSize',12);
    yyaxis right
    ylabel('New Case Rate (per 100,000 Residents)', 'FontSize',12); 
  else
    ylabel('Percent Change from Baseline', 'FontSize',12);
  end
  legend(strLegends, 'Location', 'NorthWest', 'Fontsize', 10);
  title(strTitle, 'FontSize',14);
  hold off;
end


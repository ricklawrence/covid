function linearModelImmunity(state, figureNum)
%
% build linear model for states or US counties
% target: longer-term new case rate
% variables: (1) vaccination rate, (2) cumulative case rate
%
global parameters;
if figureNum < 0
  return;
end
fprintf('\n--> linearModelImmunity\n');

%=== get dates for case data
dates       = state.dates;
lastDate    = char(dates(end));
names0      = state.names0;

%=== target is new cases since 12/1 (omicron)
windowDate    = '12/01/2021'; 
date1         = windowDate;
date2         = char(state.dates(end));
d0            = find(strcmp(windowDate, state.dates));
window        = state.numDates - d0;
t1            = window+1 : state.numDates;
t2            = 1 : state.numDates-window;
newCaseRates  = (state.cumCases(t1,:) - state.cumCases(t2,:)) ./ repmat(state.population', length(t1), 1);
newCaseRates  = 100000 * newCaseRates(end,:)' ./ window;
targetLabel   = sprintf('Daily New Case Rate from %s to %s', date1, date2);

%=== get features at beginning of the numDays period
numDays            = window;
d4                 = find(strcmp(state.vaxDates(end), state.vaxDates));
d3                 = d4 - numDays;
featureValues      = zeros(state.numNames, 2);
featureValues(:,1) = state.vaxData(d4,:,9)';          % fully vaccinated percent at end of period
featureValues(:,2) = state.features(d4,:,8)' ./ 1000; % cumulative cases at end of period
featureValues(:,3) = state.temperature;               % mean Fall temperature
featureLabels(1)   = {sprintf('Fully Vaccinated (%% of Population) as of %s', date1)};
featureLabels(2)   = {sprintf('Cumulative Cases (%% of Population) as of %s', date1)};
featureLabels(3)   = {sprintf('Mean Fall Temperature')};

%=== fit model
y    = newCaseRates;
X    = featureValues;
mdl  = fitlm(X,y);  
yfit = predict(mdl,X);
mdl

%------------------------------------------------------------------------
%=== 1. SCATTER PLOT OF ACTUAL VS PREDICTED
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== scatter plot of actul vs predicted models
x1 = y;      % actual values
y1 = yfit;   % predicted
h1 = plot(x1, y1, 'o', 'Color','k', 'Markersize', 20); 

%=== add state short names inside circles
for i=1:length(x1)
  h = text(x1(i),y1(i), char(names0(i))); hold on;
  set(h,'HorizontalAlignment','Center'); 
  set(h,'FontWeight', 'bold');
  if strcmp(names0(i), 'CT') || strcmp(names0(i), 'US')
    set(h,'Color','b'); 
    set(h,'FontSize', 14);
  else
    set(h,'Color','k'); 
    set(h,'FontSize', 8);
  end
end

%=== compute R2 (same as fitlm computes)
R    = corrcoef(x1,y1);
R2   = R(1,2) ^2;

%=== fit predictions vs actual
[~, sortIndex] = sort(x1);
x2    = x1(sortIndex);
y2    = y1(sortIndex);
P     = polyfit(x2,y2,1);
yfit2 = polyval(P,x2);
%h     = plot(x2,yfit2,'k-'); set(h, 'LineWidth', 2); hold on;
h     = plot(x2,x2,'k-'); set(h, 'LineWidth', 2); hold on;

%=== legends
strLegend1 = sprintf('New Case Rate as of %s', date2);
strLegend2 = sprintf('Linear Model (R^2 = %4.3f)', R2);
strLegend  = {strLegend1, strLegend2};
strTitle   = sprintf('Linear Model: Target = %s', targetLabel);

%=== axis labels and everything else
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'FontSize',12);
xlabel(sprintf('Actual New Case Rate (per 100,000 Residents)'),    'FontSize', 14);
ylabel(sprintf('Predicted New Case Rate (per 100,000 Residents)'), 'FontSize', 14);
legend(strLegend, 'Location', 'NorthWest', 'FontSize', 12);
title(strTitle, 'FontSize', 14);

%------------------------------------------------------------------------
%=== 2. SCATTER PLOTS OF NEW CASE RATE VS EACH SINGLE FEATURE
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

numPlots = length(featureLabels);
for f=1:numPlots
  subplot(numPlots,1,f);

  %=== set feature
  featureValue   = featureValues(:,f);
  featureLabel   = char(featureLabels(f));

  %=== scatter plot
  x  = featureValue;
  y  = newCaseRates;
  h1 = plot(x, y, 'o', 'Color','k', 'Markersize', 20); 

  %=== add state short names inside circles
  for i=1:length(x)
    h = text(x(i),y(i), char(names0(i))); hold on;
    set(h,'HorizontalAlignment','Center'); 
    set(h,'FontWeight', 'bold');
    if strcmp(names0(i), 'CT') || strcmp(names0(i), 'US')
      set(h,'Color','b'); 
      set(h,'FontSize', 14);
    else
      set(h,'Color','k'); 
      set(h,'FontSize', 8);
    end
  end

  %=== compute correlation coefficient
  mdl  = fitlm(x,y);     % confirm R2 via linear model
  R    = corrcoef(x,y);
  R2   = R(1,2) ^2;

  %=== linear model
  [~, sortIndex] = sort(x);
  x1   = x(sortIndex);
  y1   = y(sortIndex);
  P    = polyfit(x1,y1,1);
  yfit = polyval(P,x1);
  h    = plot(x1,yfit,'k-'); set(h, 'LineWidth', 2); hold on;

  %=== legends
  strLegend1 = sprintf('New Case Rate as of %s', date2);
  strLegend2 = sprintf('Linear Model (R^2 = %4.3f)', R2);
  strLegend  = {strLegend1, strLegend2};
  strTitle   = sprintf('New Case Rate vs %s', featureLabel);

  %=== axis labels and everything else
  hold off;
  grid on;
  set(gca,'Color',parameters.bkgdColor);
  set(gca,'FontSize',12);
  xlabel(sprintf('%s', featureLabel), 'FontSize', 12);
  ylabel(sprintf('New Case Rate'), 'FontSize', 12);
  xtickformat('%1.0f%%');
  if f == 1
    legend(strLegend, 'Location', 'NorthEast', 'FontSize', 12);
  else
    legend(strLegend, 'Location', 'NorthWest', 'FontSize', 12);
  end
  title(strTitle, 'FontSize', 14);
end

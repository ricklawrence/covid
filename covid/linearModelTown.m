function linearModelTown(demoFeatures, town, figureNum)
%
% build linear model for CT towns
%
global parameters;
fprintf('\n--> linearModelTown\n');

%=== get dates from the town data
dates       = town.dates;
lastDate    = char(dates(end));
lastDay     = find(strcmp(lastDate, dates));

%=== get new case rates for all towns using longer moving average
maWindow       = 21;
newCases       = town.newCases; 
newCasesMA     = movingAverage(newCases, maWindow);
population     = town.population;
newCaseRates   = computeCaseRates(newCasesMA, population);

%=== optionally consider only fairfield county
fairfieldOnly = 1;
if fairfieldOnly
  index = find(strcmp(town.countyNames, 'Fairfield'));          % fairfield county
else
  index = [1:town.numNames]';
end

%=== get index to features
[commonNames, index1 ,index2] = intersect(town.names(index), demoFeatures.names);
index1 = index(index1);
fprintf('Demographic features exist for %d out of %d towns.\n', length(commonNames), length(town.names));
setdiff(town.names(index1), demoFeatures.names(index2));  % should be null set

%=== get town data for all CT towns with feature data
newCaseRates = newCaseRates(:,index1);
townNames    = town.names(index1);

%=== set features for model and normalize
featureIndex   = 1:2;
featureValues  = demoFeatures.features(index2,featureIndex);
featureValues  = normalize(featureValues,1);

%=== remove all towns that have any NaN features
logical = ~isnan(featureValues);
L = true(length(logical),1);
for f=featureIndex
  L = and(L, logical(:,f));
end
index         = find(L); 
featureValues = featureValues(index,:);
newCaseRates  = newCaseRates(:,index);
townNames     = townNames(index);

%=== create feature string for printing
featureLabels  = demoFeatures.featureLabels(featureIndex);
featureString  = sprintf('(%s ', char(featureLabels(1)));
for f=2:length(featureLabels)-1
  featureString = strcat(featureString,', ',char(featureLabels(f)));
end
featureString     = sprintf('%s, %s)', featureString, char(featureLabels(end)));

%=== fit model
y    = newCaseRates(lastDay,:);   % final values
X    = featureValues;
mdl  = fitlm(X,y);                % linear model
yfit = predict(mdl,X);

%------------------------------------------------------------------------
%=== 1. SCATTER PLOT OF ACTUAL VS PREDICTED
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== scatter plot of actul vs predicted models
x1 = y;      % actual values
y1 = yfit;   % predicted
h  = plot(x1,y1,'b.'); hold on; set(h,'MarkerSize', 20);

%=== plot ridgefield
i = find(strcmp(townNames, 'Ridgefield'));
h = plot(x1(i), y1(i), 'r.'); hold on; set(h,'MarkerSize', 20);

%=== compute R2 (same as fitlm computes)
R    = corrcoef(x1,y1);
R2   = R(1,2) ^2;

%=== fit predictions vs actual
[~, sortIndex] = sort(x1);
x2    = x1(sortIndex);
y2    = y1(sortIndex);
P     = polyfit(x2,y2,1);
yfit2 = polyval(P,x2);
h     = plot(x2,yfit2,'k-'); set(h, 'LineWidth', 2); hold on;

%=== legends
strLegend1 = sprintf('Towns (N = %d)', length(townNames));
strLegend2 = sprintf('Town of Ridgefield');
strLegend3 = sprintf('Linear Model (R^2 = %4.3f)', R2);
strLegend  = {strLegend1, strLegend2, strLegend3};

%=== axis labels and everything else
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'FontSize',12);
xlabel(sprintf('Actual New Case Rate (per 100,000 Residents)'),    'FontSize', 14);
ylabel(sprintf('Predicted New Case Rate (per 100,000 Residents)'), 'FontSize', 14);
legend(strLegend, 'Location', 'NorthWest', 'FontSize', 12);
title(sprintf('Linear Model Using %d Predictors %s', length(featureLabels), featureString), 'FontSize', 14);

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
  x = featureValue;
  y = newCaseRates(lastDay,:);   % final values
  h = plot(x,y,'b.'); hold on; set(h,'MarkerSize', 20);

  %=== plot ridgefield
  i = find(strcmp(townNames, 'Ridgefield'));
  h = plot(x(i), y(i), 'r.'); hold on; set(h,'MarkerSize', 20);

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
  strLegend1 = sprintf('Towns (N = %d)', length(townNames));
  strLegend2 = sprintf('Town of Ridgefield');
  strLegend3 = sprintf('Linear Model (R^2 = %4.3f)', R2);
  strLegend  = {strLegend1, strLegend2, strLegend3};

  %=== axis labels and everything else
  hold off;
  grid on;
  set(gca,'Color',parameters.bkgdColor);
  set(gca,'FontSize',12);
  xlabel(sprintf('%s', featureLabel), 'FontSize', 12);
  ylabel(sprintf('Predicted New Case Rate'), 'FontSize', 12);
  if f == 1
    legend(strLegend, 'Location', 'NorthWest', 'FontSize', 8);
  else
    legend(strLegend, 'Location', 'SouthWest', 'FontSize', 8);
  end
  title(sprintf('New Case Rates vs %s (as of %s)', featureLabel, lastDate), 'FontSize', 14);
end

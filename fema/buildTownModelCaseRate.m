function buildTownModelCaseRate(town, figureNum, printFlag)
%
% build linear model to predict town case rates using vaccination rates plus SVI data as explanatory features
% this also works for states
%
global parameters;
if figureNum < 0
  return;
end
fprintf('\n--> buildTownModelCaseRate\n');
fprintf('Level = %s\n', town.level);
rng('default');  % so lasso cross validation returns same results every time

%=== set cross over date
N     = 60;
date1 = datestr(town.datenums(end)-N, 'mm/dd/yyyy');  % N days ago
d2    = find(strcmp(town.dates, date1)) - 1;
d1    = 1;
d3    = d2 + 1;
d4    = town.numDates;

%=== compute number of cases before cross over date
newCases1 = nansum(town.newCases(d1:d2,:), 1)';
newCases1 = 100000 * newCases1 ./ town.population(:,1);
newCases1 = newCases1 ./ length(d1:d2); 

%=== compute number of cases since cross over date
newCases2 = nansum(town.newCases(d3:d4,:), 1)';
newCases2 = 100000 * newCases2 ./ town.population(:,1);
newCases2 = newCases2 ./ length(d3:d4); 

%=== prediction target is number of cases since cross over date
y = newCases2;                         % new cases since cross over date
targetLabel = sprintf('New Case Rate Per 100,000 Residents since %s', date1);

%=== add all SVI values as features
f             = 1:15;
X             = town.sviValues(:,f,1);       % weighted sum for each of 15 values
featureLabels = town.sviValueLabels;

%=== add the single SVI theme
f                = 16;
X(:,f)           = town.sviThemes(:,5,1);     
featureLabels(f) = {'Overall SVI Theme'}; 

%=== add republican vote
f                = 17;
X(:,f)           = town.republicanVote;
featureLabels(f) = {sprintf('2020 Republican Presidential Vote')};

%=== add vaccination rate at beginning of period
dd               = find(strcmp(date1, town.vaxDates));
f                = 18;
if strcmp(town.level, 'Town')
  X(:,f) = town.vaxDataN(end,:,8,1)';      % fraction of total population initiated
elseif strcmp(town.level, 'CountyUS')
  X(:,f) = town.vaxDataN(dd,:,3)';         % latest fraction of total people vaccinated
elseif strcmp(town.level, 'State')
  X(:,f) = town.vaxData(end,:,9)';         % fraction total population fully vaccination
end
featureLabels(f) = {sprintf('Fully Vaccinated')};

%=== add absolute previous cases as feature
includePrevious = 1;
if includePrevious
  f                = 19;
  X(:,f)           = newCases1;
  featureLabels(f) = {sprintf('Number of Cases Before %s', date1)};
end

%=== remove any NaNs
filter    = find(~isnan(sum(X,2)));
y         = y(filter);
X         = X(filter,:);
townNames = town.names(filter);

%=== if this CountyUS, filter to specified state
if strcmp(town.level, 'CountyUS')
  stateName  = 'Florida';
  filter     = find(contains(townNames, stateName));
  y          = y(filter);
  X          = X(filter,:);
  townNames  = townNames(filter);
end

%=== normalize
y = normalize(y);
X = normalize(X);

%=== build univariate models for each feature
[numObservations, numFeatures] = size(X);
R2    = NaN(numFeatures,1);
coefs = NaN(numFeatures,1);
for f=1:numFeatures
  Xf       = X(:,f);
  model    = fitlm(Xf,y); 
  R2(f)    = model.Rsquared.Ordinary;
  coefs(f) = model.Coefficients.Estimate(end);
end
R2;

%=== print univariate coefficients
if printFlag
  fprintf('Univariate Models: Coefficients\n');
  for f=1:numFeatures
    fprintf('  %40s\t%10.6f\n', char(featureLabels(f)), coefs(f));
  end
  fprintf('\n');
end

%===  build lasso model using cross validation
f                = numFeatures+1;
featureLabels(f) = {'Cross-Validated Lasso SVI Model'};
[B1, info]       = lasso(X, y, 'CV', 10);
i   = info.IndexMinMSE;
i   = info.Index1SE;     % index to optimal lambda
B0  = info.Intercept(i);
B   = B1(:,i);
N   = length(find(B ~= 0));

%=== get lasso predictions with intercept
yfit    = X * B + B0;
R       = corrcoef(y,yfit);
R2lasso = R(1,2) * R(1,2);
R2(f)   = R2lasso;
MAE     = sum(abs(y-yfit)) / length(y);
meanY   = mean(y);
fprintf('Lasso Model retained %d SVI features: R2 = %6.4f  MAE = %6.4f (Mean = %6.4f).\n', N, R2(f), MAE, meanY);
if printFlag
  fprintf('Lasso Model: Coefficients\n');
  fIndex  = find(B ~= 0);
  for f=fIndex'
    fprintf('  %40s\t%10.6f\n', char(featureLabels(f)), B(f));
  end
end

%=== plot lasso cross validation
%lassoPlot(B1,info,'PlotType','CV'); legend('show');

%=== get lasso features and coefficients for plots
lassoCoefficients = B;
numCoefficients   = length(lassoCoefficients);
lassoFeatures     = featureLabels(1:numCoefficients);
numLassoFeatures  = length(find(lassoCoefficients ~= 0));

%-----------------------------------------------------------------------------
%=== 1. HORIZONTAL BAR CHART OF TOWN-LEVEL R2 VALUES
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get data for plots
yValues        = R2;
yLabels        = featureLabels;
y              = 1:length(yLabels);

%=== flip data so final feature (ie lasso model) is at bottom
yValues        = flip(yValues);
yLabels        = flip(yLabels);
B              = flip(B);

%=== horizontal bar chart
i  = 2:length(yLabels);
h  = barh(y(i), yValues(i), 'FaceColor', 'c'); hold on;
h  = barh(y(1), yValues(1), 'FaceColor', 'r'); hold on;
plot([0,0], [0 0], 'r-', 'LineWidth', 3);      hold on; % to force legend entry

%=== labels
if strcmp(town.level, 'Town')
  strTitle     = sprintf('Target Variable = %s at the Connecticut Town Level (N = %d Towns)', ...
                        targetLabel, length(townNames));
elseif strcmp(town.level, 'CountyUS')
  strTitle   = sprintf('Target Variable = %s at the %s County Level (N = %d Counties)', ...
                       targetLabel, stateName, length(townNames));
elseif strcmp(town.level, 'State')
  strTitle     = sprintf('Target Variable = %s at the State Level (N = %d States + DC)', ...
                        targetLabel, length(townNames));
end
xLabel       = 'R^2';
strLegend(1) = {'Univariate Model for Each Feature'};
strLegend(2) = {'10-Fold Cross-Validated Lasso SVI Model'};
strLegend(3) = {'Features with Red Numbers Selected by Lasso'};

%=== add value next to bars
for p=1:numFeatures+1
  f = max(p-1,1);  % index into B coefficients
  x0 = yValues(p);
  y0 = y(p);
  h = text(x0,y0,sprintf(' %4.3f',x0));
  if p ~= 1 && B(f) ~= 0
    set(h,'Color','r'); set(h,'Horiz','Left'); set(h, 'Vert', 'middle'); set(h,'FontSize', 12); set(h,'FontWeight', 'bold');
  else
    set(h,'Color','k'); set(h,'Horiz','Left'); set(h, 'Vert', 'middle'); set(h,'FontSize', 12); set(h,'FontWeight', 'bold');
  end
end

%=== axis labels and everything else
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'FontSize',12);
set(gca,'YTick',y);
set(gca,'YTickLabel',yLabels);
xtickformat('%3.2f');
xlabel(sprintf('%s', xLabel), 'FontSize', 14);
title(sprintf('%s', strTitle), 'FontSize', 14);
legend(strLegend, 'Location', 'East', 'Fontsize', 12);

%-----------------------------------------------------------------------------
%=== 2. HORIZONTAL BAR CHART OF LASSO COEFFICIENTS

if numLassoFeatures == 0
  return;
end
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get data for plots
yValues        = lassoCoefficients;
yLabels        = lassoFeatures;
y              = 1:length(yLabels);

%=== flip data so final feature (ie lasso model) is at bottom
yValues        = flip(yValues);
yLabels        = flip(yLabels);

%=== horizontal bar chart
h = barh(y, yValues, 'FaceColor', 'b'); hold on;

%=== labels
xLabel     = 'Lasso Coefficient';
strLegend  = 'Coefficients for Features Selected by Lasso';

%=== axis labels and everything else
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'FontSize',12);
set(gca,'YTick',y);
set(gca,'YTickLabel',yLabels);
xtickformat('%3.2f');
xlabel(sprintf('%s', xLabel), 'FontSize', 14);
title(sprintf('%s', strTitle), 'FontSize', 14);
legend(strLegend, 'Location', 'North', 'Fontsize', 12);
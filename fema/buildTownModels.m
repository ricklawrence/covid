function model = buildTownModels(town, figureNum, printFlag, stateName)
%
% build linear model to predict town vaccination rates using SVI data as explanatory features
% also works at state level
% apply model to census-tract data
%
global parameters;
if figureNum < 0
  model = 0;
  return;
end
fprintf('\n--> buildTownModels\n');
fprintf('Level = %s\n', town.level);
rng('default');  % so lasso cross validation returns same results every time

%=== set prediction target -- 'town' can also be State or CountyUS
if strcmp(town.level, 'Town')
  y = town.vaxDataN(end,:,8,1)';       % fraction of total population initiated
elseif strcmp(town.level, 'Census Tract')
  y = town.vaxDataN(end,:,1)';         % fraction of total population initiated
elseif strcmp(town.level, 'CountyUS')
  y = town.vaxDataN(end,:,3)';         % latest fraction of total people vaccinated
elseif strcmp(town.level, 'State')
  y = town.vaxData(end,:,11)';         % fraction 18+ initiated vaccination
end

%=== add all SVI values as features
f             = 1:15;
X             = town.sviValues(:,f,1);       % weighted sum for each of 15 values
featureLabels = town.sviValueLabels;

%=== add the single SVI theme (used by State to prioritize towns)
f                = 16;
X(:,f)           = town.sviThemes(:,5,1);     
featureLabels(f) = {'Overall SVI Theme'}; 

%=== add republican vote
if isfield(town,'republicanVote')
  f                = 17;
  X(:,f)           = town.republicanVote;
  featureLabels(f) = {sprintf('2020 Republican Presidential Vote')};
end

%=== add hesitancy at county and state level
if isfield(town,'hesitancy')
  f                = 18;
  %X(:,f)           = town.hesitancy(:,1);  % strongly hesitant + hesitant + unsure
  %featureLabels(f) = {sprintf('CDC Estimated Vaccine Hesitancy')};
end

%=== remove any NaNs
filter1   = find(~isnan(sum(X,2)));
filter2   = find(~isnan(y));
filter    = intersect(filter1, filter2);
y         = y(filter);
X         = X(filter,:);
townNames = town.names(filter);

%=== if this CountyUS, filter to specified state
if strcmp(town.level, 'CountyUS')
  fprintf('Modeling counties in %s.\n', stateName);
  filter     = find(contains(townNames, stateName));
  y          = y(filter);
  X          = X(filter,:);
  townNames  = townNames(filter);
end

%=== save properties
[numObservations, numFeatures] = size(X);
meanX = mean(X);
stdX  = std(X);

%=== normalize data
y = normalize(y);
X = normalize(X);

%-----------------------------------------------------------------------------
% UNIVARIATE TOWN MODELS 

%=== build univariate models for each SVI feature plus total theme
R2    = NaN(numFeatures+1,1);
coefs = NaN(numFeatures,1);
for f=1:numFeatures
  Xf       = X(:,f);
  uvModel  = fitlm(Xf,y); 
  R2(f)    = uvModel.Rsquared.Ordinary;
  coefs(f) = uvModel.Coefficients.Estimate(end);
end

%=== print univariate coefficients
if printFlag
  fprintf('Univariate Models: Coefficients\n');
  for f=1:numFeatures
    fprintf('  %40s\t%10.6f\n', char(featureLabels(f)), coefs(f));
  end
  fprintf('\n');
end

%-----------------------------------------------------------------------------
% MULTI-VARIATE MODEL

%=== fit multi-variate model using all SVI variables without theme
f                = numFeatures + 1;
featureLabels(f) = {'Multivariate SVI Model'};
X                = X; 
mvModel          = fitlm(X,y);
R2(f)            = mvModel.Rsquared.Ordinary;
B1               = mvModel.Coefficients.Estimate;

%=== get predictions manually to double-check R2
yfit             = B1(1) + X * B1(2:end);
R                = corrcoef(y,yfit);
R2check          = R(1,2) * R(1,2);
N                = numFeatures - 1;
fprintf('Multivariate Linear Model with %d SVI features: R2 = %6.4f\n', N, R2(f));
[R2(f) R2check];

%-----------------------------------------------------------------------------
% LASSO MODEL

%=== override full multivariate model with lasso model using cross validation
featureLabels(f) = {'Cross-Validated Lasso SVI Model'};
N                = min(numObservations,10);   % cross validation folds
[B2, info]       = lasso(X, y, 'CV', N);
i   = info.IndexMinMSE;
i   = info.Index1SE;     % index to optimal lambda
B30 = info.Intercept(i);
B3  = B2(:,i);
N   = length(find(B3 ~= 0));
featureLabels(B3 ~= 0);

%=== get lasso predictions with intercept
yfit    = X * B3 + B30;
R       = corrcoef(y,yfit);
R2lasso = R(1,2) * R(1,2);
R2(f)   = R2lasso;
MAE     = sum(abs(y-yfit)) / length(y);
meanY   = mean(y);
fprintf('Lasso Model retained %d SVI features:            R2 = %6.4f  MAE = %6.4f (Mean = %6.4f).\n', N, R2(f), MAE, meanY);
if printFlag
  fprintf('Lasso Model: Coefficients\n');
  fIndex  = find(B3 ~= 0);
  for f=fIndex'
    fprintf('  %40s\t%10.6f\n', char(featureLabels(f)), B3(f));
  end
end

%=== plot lasso cross validation
%lassoPlot(B2,info,'PlotType','CV'); legend('show');

%=== save lasso model data
model.level         = town.level;
model.target        = 'Vaccination Rates';
model.numFeatures   = length(B3);
model.meanX         = meanX;
model.stdX          = stdX;
model.B             = B3;
model.B0            = B30;
model.featureLabels = featureLabels;

%=== get lasso features and coefficients for plots
lassoCoefficients = model.B;
numCoefficients   = length(lassoCoefficients);
lassoFeatures     = model.featureLabels(1:numCoefficients);
numLassoFeatures  = length(find(lassoCoefficients ~= 0));

%-----------------------------------------------------------------------------
%=== 1. HORIZONTAL BAR CHART OF R2 VALUES
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get data for plots
yValues        = R2;
yLabels        = featureLabels;
y              = 1:length(yLabels);

%=== flip data so final feature (ie lasso model) is at bottom
yValues        = flip(yValues);
yLabels        = flip(yLabels);
B              = flip(B3);

%=== horizontal bar chart
i = 2:length(yLabels);
h = barh(y(i), yValues(i), 'FaceColor', 'c'); hold on;
h = barh(y(1), yValues(1), 'FaceColor', 'r'); hold on;  % lasso model
plot([0,0], [0 0], 'r-', 'LineWidth', 3);     hold on;  % to force legend entry

%=== labels
if strcmp(town.level, 'Town')
  strTitle   = sprintf('Target Variable = Total Vaccination Rates at the Connecticut Town Level (N = %d Towns)', length(townNames));
elseif strcmp(town.level, 'Census Tract')
  strTitle   = sprintf('Target Variable = Total Vaccination Rates at the Connecticut Census Tract Level (N = %d Tracts)', length(townNames));
elseif strcmp(town.level, 'CountyUS')
  strTitle   = sprintf('Target Variable = Total Vaccination Rates at the %s County Level (N = %d Counties)', stateName, length(townNames));
elseif strcmp(town.level, 'State')
  strTitle   = sprintf('Target Variable = Total Vaccination Rates at the State Level (N = %d States + DC)', length(townNames));
end
xLabel       = 'R^2';
strLegend(1) = {'Univariate Model for Each Variable'};
strLegend(2) = {'10-Fold Cross-Validated Lasso SVI Model'};
strLegend(3) = {'Features with Red Numbers Selected by Lasso'};

%=== add value next to bars -- lasso-selected features are red
for p=1:length(yLabels)
  f  = max(p-1,1);   % index into B coefficients
  x0 = yValues(p);
  y0 = y(p);
  h = text(x0,y0,sprintf(' %4.3f',x0));
  if p >= 2 && B(f) ~= 0
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

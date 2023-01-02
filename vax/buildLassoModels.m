function model = buildLassoModels(target, state, figureNum, printFlag)
%
% build lasso models at state level
% target can be 'vaxRate' or 'caseRate' 
%
global parameters;
if figureNum < 0
  model = 0;
  return;
end
fprintf('\n--> buildLassoModels\n');
rng('default');  % so lasso cross validation returns same results every time

%=== set which vaccination number to use
m = 16;      % 18+ completed
m = 17;      % 12+ initialized
m = 18;      % 12+ completed
m = 11;      % 18+ initialized

%=== SET TARGET
%=== set prediction target
if strcmp(target, 'vaxRate')
  vaxRate      = state.vaxData(end,:,m)';         % fraction 18+ initiated vaccination
  y            = vaxRate;
  targetLabel  = sprintf('Vaccination Percent at the State Level');
  targetLabel0 = targetLabel;
  
elseif strcmp(target, 'caseRate')
  numDays      = 90;
  date1        = datestr(state.datenums(end)-numDays, 'mm/dd/yyyy');  % N days ago
  d1           = find(strcmp(state.dates, date1));
  d2           = state.numDates;
  newCases     = nansum(state.newCases(d1:d2,:), 1)';
  newCases     = 100000 * newCases ./ state.population(:,1);
  newCases     = newCases  ./ length(d1:d2); 
  y            = newCases;
  targetLabel  = sprintf('New Case Rate over the past %d days at the State Level', numDays);
  targetLabel0 = sprintf('New Case Rate at the State Level');

else
  fprintf('Target %s not found.\n', target);
  return
end

%=== SET FEATURES
%=== add all SVI values as features
f             = 1:15;
X             = state.sviValues(:,f,1);       % weighted sum for each of 15 values
featureLabels = state.sviValueLabels;

%=== add republican vote
f                = 16;
X(:,f)           = state.republicanVote;
featureLabels(f) = {sprintf('2020 Republican Presidential Vote')};

%=== if target is case rate, add cumulative cases up to numDays ago
if strcmp(target, 'caseRate')
  f                = 17;
  cumCases         = state.cumCases(d1,:)';                       % numDays ago
  cumCases         = 100000 * cumCases ./ state.population(:,1);
  cumCases         = cumCases  ./ d1;
  X(:,f)           = cumCases;
  featureLabels(f) = {sprintf('Cumulative Cases')};
end

%=== if target is case rate, add vaccination rate
if strcmp(target, 'caseRate')
  f                = 18;
  X(:,f)           = state.vaxData(end,:,m)';
  featureLabels(f) = {sprintf('Vaccination Percent')};
end

%=== remove any NaNs or zero targets (eg Iowa 12+ vax percent)
filter1    = find(~isnan(sum(X,2)));
filter2    = find(~isnan(y) & y > 0);
filter     = intersect(filter1, filter2);
y          = y(filter);
X          = X(filter,:);

%=== save properties
[numObservations, numFeatures] = size(X);
meanX = mean(X);
stdX  = std(X);

%=== normalize data
y = normalize(y);
X = normalize(X);

%-----------------------------------------------------------------------------
% UNIVARIATE MODELS 

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
if printFlag > 0
  fprintf('Univariate Models: Coefficients\n');
  for f=1:numFeatures
    fprintf('  %40s\t%10.6f\n', char(featureLabels(f)), coefs(f));
  end
  fprintf('\n');
end

%-----------------------------------------------------------------------------
% MULTI-VARIATE MODEL

%=== fit multi-variate model using all features 
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

%=== print multi-variate model
if printFlag >= 0
  fprintf('Multivariate Linear Model with %d features: R2 = %6.4f\n', N, R2(f));
  [R2(f) R2check];
end

%-----------------------------------------------------------------------------
% LASSO MODEL

%=== override full multivariate model with lasso model using cross validation
featureLabels(f) = {'Cross-Validated Lasso Model'};
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

%=== print lasso summary
if printFlag >= 0
  fprintf('Lasso Model retained %d features:            R2 = %6.4f  MAE = %6.4f (Mean = %6.4f).\n', N, R2(f), MAE, meanY);
end
if printFlag > 0
  fprintf('Lasso Model: Coefficients\n');
  fIndex  = find(B3 ~= 0);
  for f=fIndex'
    fprintf('  %40s\t%10.6f\n', char(featureLabels(f)), B3(f));
  end
end

%=== plot lasso cross validation
if printFlag > 0
  lassoPlot(B2,info,'PlotType','CV'); legend('show');
end

%=== save lasso model data
model.level         = state.level;
model.target        = 'Vaccination Rates';
model.numFeatures   = length(B3);
model.meanX         = meanX;
model.stdX          = stdX;
model.B             = B3;
model.B0            = B30;
model.featureLabels = featureLabels;

%-----------------------------------------------------------------------------
%=== 1. HORIZONTAL BAR CHART OF R2 VALUES
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== PRINT RESULTS FOR WEST CONN TABLES -- paste this into Excel
i = find(B3 ~= 0);
[~,sortIndex] = sort(R2(i), 'descend');
fprintf('Target Variable = %s\n', targetLabel0);
fprintf('%s\t%s\t%s\n', 'Explanatory Variable', 'Contribution', 'R2 Value');
fprintf('%s\t%s\t%4.3f\n', 'Full Lasso Model', '', R2(end));
for f=sortIndex'
  ff = i(f);
  if B3(ff) > 0
    contribution = 'Positive';
  else
    contribution = 'Negative';
  end
  fprintf('%s\t%s\t%4.3f\n', char(featureLabels(ff)), contribution, R2(ff));
end

%=== get data for plots
yValues        = R2;
yLabels        = featureLabels;
y              = 1:length(yLabels);
N              = length(y);

%=== flip data so final feature (ie lasso model) is at bottom
yValues        = flip(yValues);
yLabels        = flip(yLabels);

%=== save regression coefficients -- these are all non-zero
BR             = flip(B1);
BR(2:N)        = BR(1:N-1);
BR(1)          = 0;

%=== save lasso coefficients -- these are zero if not selected by lasso
BL             = flip(B3);
BL(2:N)        = BL(1:N-1);
BL(1)          = 0;

%=== horizontal bar chart
k = 1:length(yLabels);
i = find(BL ~=  0)';
h = barh(y(k), yValues(k), 'FaceColor', 'c');   hold on;  subset(1) = h(1); % all features
for p=i
  h = barh(y(p), yValues(p), 'FaceColor', 'r'); hold on;  subset(2) = h;    % lasso features
end
h = barh(y(1), yValues(1), 'FaceColor', 'k');   hold on;  subset(3) = h;    % lasso model


%=== labels
xLabel       = 'R^2';
strLegend(1) = {'Univariate Model for Each Variable -- Not selected by Lasso'};
strLegend(2) = {'Univariate Model for Each Variable -- Selected by Lasso'};
strLegend(3) = {'10-Fold Cross-Validated Lasso Model'};
strTitle     = sprintf('Target Variable = %s', targetLabel);
strSource    = sprintf('%s\n%s', 'Data Source: http://data.cdc.gov', parameters.rickAnalysis);

%=== add value next to bars with indication of positive or negative contribution
for p=1:length(yLabels)
  x0 = yValues(p);
  y0 = y(p);
  if BR(p) == 0
    h = text(x0,y0,sprintf(' %4.3f',x0));
    set(h,'Color','k'); set(h,'Horiz','Left'); set(h, 'Vert', 'middle'); set(h,'FontSize', 12); set(h,'FontWeight', 'bold');
    %set(h, 'BackgroundColor', 'w'); 
  elseif BR(p) > 0
    h = text(x0,y0,sprintf(' %4.3f Positive Contribution',x0));
    set(h,'Color','k'); set(h,'Horiz','Left'); set(h, 'Vert', 'middle'); set(h,'FontSize', 10); set(h,'FontWeight', 'bold');
    %set(h, 'BackgroundColor', 'w'); 
  elseif BR(p) < 0
    h = text(x0,y0,sprintf(' %4.3f Negative Contribution',x0));
    set(h,'Color','k'); set(h,'Horiz','Left'); set(h, 'Vert', 'middle'); set(h,'FontSize', 10); set(h,'FontWeight', 'bold');
    %set(h, 'BackgroundColor', 'w'); 
  end
end

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add data source
x0   = xmin - 0.250*(xmax - xmin);
y0   = ymin - 0.095*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

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
legend(subset, strLegend, 'Location', 'NorthEast', 'Fontsize', 12);

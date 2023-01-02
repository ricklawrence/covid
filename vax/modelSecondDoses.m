function modelSecondDoses(state, stateName, figureNum)
%
% model moderna and pfizer 2nd doses as function of 1st doses
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> modelSecondDoses\n');
rng('default');  % so lasso cross validation returns same results every time

%=== for models only
company    = 'Moderna';
company    = 'Pfizer';

%=== get time series
d1           = find(strcmp('03/15/2021', state.vaxDates));  % first day of json state data
d2           = length(state.vaxDates);
dates        = state.vaxDates(d1:d2);
dose2(:,:,1) = state.vaxDataD(d1:d2,:,15);                  % pfizer  2nd dose
dose2(:,:,2) = state.vaxDataD(d1:d2,:,14);                  % moderna 2nd dose
dose1(:,:,1) = state.vaxDataD(d1:d2,:,13) - dose2(:,:,1);   % pfizer  1st dose
dose1(:,:,2) = state.vaxDataD(d1:d2,:,12) - dose2(:,:,2);   % moderna 1st dose

%=== set offsets (days around exact window)
offsets     = [+2 +1 0, -1 -2];
offsets     = [0];              % if we are not plotting model
N           = length(dates);
numFeatures = length(offsets);
labels      = cell(numFeatures,1);
numStates   = 51;

%=== set comapny with window between doses
if strcmp(company, 'Pfizer')
  m = 1;
  w = 21;
else
  m = 2;
  w = 28;
end
d3        = 1 + w + max(offsets);
d4        = N;
numPoints = length(d3:d4);
for i=1:length(offsets)
  o         = offsets(i);
  labels(i) = {sprintf('%d days before 2nd dose', w+o)};
end
labels;

%== construct target and features for each state
y = NaN(numPoints, numStates);
X = NaN(numPoints, numFeatures, numStates);
for s=1:52
  y(:,s) = dose2(d3:d4,s,m);
  for i=1:length(offsets)
    o        = offsets(i);
    X(:,i,s) = dose1(d3-w-o:d4-w-o,s,m);
  end
end

%=== concatenate all states except US
y1 = y(:,1);
X1 = X(:,:,1);
for s=2:51
  y1 = [y1; y(:,s)];
  X1 = [X1; X(:,:,s)];
end
[numObservations, ~] = size(X1);

%=== normalize (skip normalization since we want to plot real data)
%y1 = normalize(y1);
%X1 = normalize(X1);

%=== univariate models
R2 = NaN(numFeatures,1);
for f=1:numFeatures
  model = fitlm(X1(:,f),y1);
  R2(f) = model.Rsquared.Ordinary;
end

%=== full model
f     = numFeatures + 1;
model = fitlm(X1,y1);
R2(f) = model.Rsquared.Ordinary;
R2;

%=== lasso model
[B1, info] = lasso(X1, y1, 'CV', 10);
i   = info.Index1SE;     % index to optimal lambda
B0  = info.Intercept(i);
B   = B1(:,i);
labels(B ~= 0);

%=== get prediction for individual state
s          = find(strcmp(stateName,state.names));
prediction = predict(model,X(:,:,s));

%-----------------------------------------------------------------------------------------------
% FORGET MODEL AND JUST PLOT SHIFTED FIRST DOSES

%=== get actual data
d3           = 1 + 28;
d4           = length(dates);
secondDosesP = dose2(d3:d4,      s,1);
firstDosesP  = dose1(d3-21:d4-21,s,1);
secondDosesM = dose2(d3:d4,      s,2);
firstDosesM  = dose1(d3-28:d4-28,s,2);

%=== smooth data
doMA = 1;
if doMA
  secondDosesP = movingAverage(secondDosesP, 7);
  firstDosesP  = movingAverage(firstDosesP,  7);
  secondDosesM = movingAverage(secondDosesM, 7);
  firstDosesM  = movingAverage(firstDosesM,  7);
end

%---------------------------------------------------------------------------------------------
%=== 1. PLOT SECOND AND FIRST DOSES
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get dates
numDates = length(dates(d3:d4));
interval = 7;
d6       = numDates;
d5       = mod(numDates,interval);    % so last date is final tick mark
if d5 == 0
  d5     = interval;
end
x        = d5:interval:d6;            % show only these dates
xLabels  = dates(d3:d4);

%-----------------
subplot(2,1,1);

%=== line plots
company = 'Pfizer'; w = 21;
y1 = firstDosesP  / 1000;
y2 = secondDosesP / 1000;
plot(y1,'r-', 'LineWidth', 2); hold on;
plot(y2,'b-', 'LineWidth', 2); hold on;

%=== get labels for plot
strLegends(1) = {sprintf('Expected %s Second Doses Based on First Doses Shifted %d Days', company, w)};
strLegends(2) = {sprintf('Actual %s Second Doses', company)};
strTitle      = sprintf('%s: %s Actual Second Doses Compared with Expected Second Doses', stateName, company);
xTitle        = sprintf('CDC Report Date');
if doMA
  yTitle        = sprintf('Administered Doses (7-Day Moving Average)');
else
  yTitle        = sprintf('Administered Doses');
end

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 2);
set(gca,'FontSize',  12);
set(gca,'XTick',x);  
set(gca,'XTickLabel',xLabels(x));
xlabel(xTitle, 'FontSize', 12);
ylabel(yTitle, 'FontSize', 12);
ytickformat('%2.1fK');
legend(strLegends,'FontSize', 10, 'Location','SouthEast', 'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle,   'FontSize', 16);

%-----------------
subplot(2,1,2);

%=== line plots
company = 'Moderna'; w = 28;
y1 = firstDosesM  / 1000;
y2 = secondDosesM / 1000;
plot(y1,'r-', 'LineWidth', 2); hold on;
plot(y2,'b-', 'LineWidth', 2); hold on;

%=== get labels for plot
strLegends(1) = {sprintf('Expected %s Second Doses Based on First Doses Shifted %d Days', company, w)};
strLegends(2) = {sprintf('Actual %s Second Doses', company)};
strTitle      = sprintf('%s: %s Actual Second Doses Compared with Expected Second Doses', stateName, company);

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 2);
set(gca,'FontSize',  12);
set(gca,'XTick',x);  
set(gca,'XTickLabel',xLabels(x));
xlabel(xTitle, 'FontSize', 12);
ylabel(yTitle, 'FontSize', 12);
ytickformat('%2.1fK');
legend(strLegends,'FontSize', 10, 'Location','SouthEast', 'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle,   'FontSize', 16);

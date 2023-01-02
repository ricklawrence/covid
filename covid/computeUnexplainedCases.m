function computeUnexplainedCases(townName0, town, demoFeatures, figureNum)
%
%  compute unexplained new cases for CT towns using kNN prediction
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> computeUnexplainedCases\n');
or = parameters.orange;

%=== set parameters here
fairfieldOnly = 0;    % use only fairfield county towns as potential neighbors
unitWeight    = 0;    % use unit weights (as oppposed to inverse distance)
numNeighborsP = 5;    % number of neighbors used in prediction
featureIndex  = 1:2;  % 1 = population; 2 = household income; 3 = fraction white

%=== get dates from the town data
dates       = town.dates;
numDates    = length(dates);

%=== get new case rates for all towns
newCaseRates   = town.features(:,:,2);

%=== optionally consider only fairfield county towns as potential neighbors
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
countyNames  = town.countyNames(index1);
numTowns     = length(townNames);

%=== get features for all CT towns and normalize
featureValues  = demoFeatures.features(index2,featureIndex);
featureValues  = normalize(featureValues,1);
townNamesCT    = demoFeatures.names(index2);

%=== restrict towns to fairfield county
index          = find(strcmp(countyNames, 'Fairfield'));
newCaseRatesFC = newCaseRates(:,index);
townNamesFC    = townNames(index);
numTownsFC     = length(townNamesFC);

%=== we predict only towns in fairfield county
actual         = NaN(numDates, numTownsFC);
explained      = NaN(numDates, numTownsFC);
unexplained    = NaN(numDates, numTownsFC);
for t=1:numTownsFC

  %=== compute distances between target town and all other CT towns
  targetTown     = townNamesFC(t);
  targetIndex    = find(strcmp(targetTown, townNamesCT));
  featureValues0 = repmat(featureValues(targetIndex,:), numTowns, 1);
  diff           = featureValues - featureValues0;
  distance       = sqrt(sum(diff.*diff,2));

  %=== determine neighbors and get new case data for them
  [~, sortIndex] = sort(distance);
  newCaseRatesN  = newCaseRates(:, sortIndex);
  distanceN      = distance(sortIndex);
  
  %=== save sortIndex for input town (for plotting) and write distance data (for datamapper CT map)
  if strcmp(targetTown, townName0)
    sortIndex0 = sortIndex;
    names      = townNamesCT(sortIndex);
    data       = distance(sortIndex) / max(distance(sortIndex));
    descriptor = sprintf('Demographic Distance from %s', townName0);
    fid        = -1;
    %writeDatamapperData(fid, names, data, descriptor);
  end

  %=== set the weights and index to N neighbors
  if unitWeight
    weights         = ones(numDates, length(distanceN));     % unit weights
  else
    inverseDistance = 1.0 ./ distanceN';
    weights         = repmat(inverseDistance, numDates, 1);  % inverse distance weighting
  end
  index            = 2:numNeighborsP+1;                      % ignore target town and keep N neighbors
  
  %=== make weighted kNN prediction and save results
  prediction       = sum(weights(:,index) .* newCaseRatesN(:,index), 2) ./ sum(weights(:,index),2);
  actual(:,t)      = newCaseRatesFC(:,t);
  explained(:,t)   = prediction;
  unexplained(:,t) = actual(:,t) - explained(:,t);
  unexplained(:,t) = max(unexplained(:,t), 0);     % always positive
end
fractionUnexplained = unexplained ./ actual;

%=== set date labels
if parameters.shortWindow > 0
  numWeeks = parameters.shortWindow / 7; % number of weeks to show
else
  numWeeks = 8;
end
numDays     = 7*numWeeks;
d2          = numDates;
d1          = numDates -  numDays;
interval    = 7;
xLabels     = dates(d1:d2);
x           = 1:interval:length(xLabels);
xTicks      = [d1:interval:d2]';
xTicks      = xTicks - d1 + 1;

%------------------------------------------------------------------------
%=== 1. HEATMAP OF UNEXPLAINED CASES
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== set labels
featureLabel = 'Fraction of New Cases that Are Unexplained';
strTitle     = sprintf('Town Anomaly Signal: Fraction of New Cases that Are Unexplained');
yLabels      = townNamesFC;
y            = 1:length(yLabels);

%=== plot heat map
z = fractionUnexplained(d1:d2,:);
imagesc(z');
colormap jet;
h = colorbar;
set(get(h,'label'),'string',featureLabel, 'FontSize', 14);

%=== add axis labels
grid on;
set(gca,'LineWidth',1);
set(gca,'FontSize',12);
set(gca,'YTick',y);
set(gca,'YTickLabel',yLabels(y));
set(gca,'XTick',x);  
set(gca,'XTickLabel',xLabels(x));
xlabel(sprintf('Reporting Date (Last %d Weeks)', numWeeks), 'FontSize', 14);
title(strTitle, 'FontSize', 16);

%------------------------------------------------------------------------
%=== 2. PLOT HORIZONTAL BAR CHART
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get data
yValues  = fractionUnexplained(end,:);   % final values
yLabels  = townNamesFC;
[~, sortIndex] = sort(yValues, 'descend');
yValues  = yValues(sortIndex);
yLabels  = yLabels(sortIndex);
yValues  = yValues(end:-1:1);   % reverse so biggest is at top of bar chart
yLabels  = yLabels(end:-1:1);   % reverse so biggest is at top of bar chart
y        = 1:length(yLabels);

%=== save the worst town
worstTown = char(yLabels(end));

%=== colored horizontal bar charts
cutoff1 = 0.3;
cutoff2 = 0.1;
index  = find(yValues > cutoff1);
h = barh(y(index), yValues(index), 'stacked'); set(h, 'FaceColor', 'r'); hold on;
index  = find(yValues > cutoff2 & yValues <= cutoff1);
h = barh(y(index), yValues(index), 'stacked'); set(h, 'FaceColor', or); hold on;
index  = find(yValues <= cutoff2);
h = barh(y(index), yValues(index), 'stacked'); set(h, 'FaceColor', 'y'); hold on;

%=== plot vertical lines at cutoff points
ax   = gca; 
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
h    = plot([cutoff1, cutoff1], [ymin,ymax], 'k-'); set(h, 'Linewidth', 2); hold on;
h    = plot([cutoff2, cutoff2], [ymin,ymax], 'k-'); set(h, 'Linewidth', 2); hold on;

%=== labels
featureLabel = 'Fraction of New Cases that Are Unexplained';
strTitle     = sprintf('Town Anomaly Signal: Fraction of New Cases that Are Unexplained as of %s', town.lastDate);

%=== axis labels and everything else
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'FontSize',10);
set(gca,'YTick',y);
set(gca,'YTickLabel',yLabels(y));
xlabel(sprintf('%s', featureLabel), 'FontSize', 14);
title(strTitle, 'FontSize', 14);

%------------------------------------------------------------------------
%=== 3. BAR CHART FOR SELECTED TOWN
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== override with worst town if not foundW
t = find(strcmp(townName0, townNamesFC));
if isempty(t)
  townName0 = worstTown;
  t         = find(strcmp(townName0, townNamesFC));
end

%=== set data
clear data;
data(:,1)     = actual(:,t) - unexplained(:,t);          % insure stacked bars sum to actual case rates
data(:,2)     = unexplained(:,t);
strLegends(1) = {sprintf('%s Explained New Case Rate',    townName0)};
strLegends(2) = {sprintf('%s Unexplained New Case Rate',  townName0)};
strTitle      = sprintf('%s New Case Rate: Explained vs Unexplained Cases', townName0);

%=== plot explained and unexplained
h = bar(data(d1:d2,:), 'stacked');
set(h(1), 'FaceColor', 'k');
set(h(2), 'FaceColor', 'r');

%=== add explanatory text
ax   = gca; 
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = 0.01*xTicks(end);
y0   = ymin + 0.85*(ymax - ymin);
strText1 = sprintf('Unexplained cases refer to the fraction of observed cases that cannot be explained by a simple demographic model.');
strText2 = sprintf('We believe that unexplained cases are an indicator of a localized (town-level) surge in new cases.');
strText  = sprintf('%s\n%s', strText1, strText2);
h = text(x0, y0, strText); set(h,'Color','k'); set(h,'HorizontalAlignment','left'); set(h,'FontWeight', 'bold'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',14);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel('Reporting Date (Last 8 Weeks)', 'FontSize', 14);
ylabel(sprintf('New Case Rate (per 100,000 Residents)'),'FontSize', 14);
legend(strLegends,'Location', 'NorthWest', 'FontSize', 14);
title(strTitle, 'FontSize', 16);
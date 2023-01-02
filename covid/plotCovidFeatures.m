function plotCovidFeatures(featureNumber, data, figureNum)
%
% plot specified covid feature
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> plotCovidFeatures\n');
fprintf('Level = %s\n', data.level);

%=== get data -- features are taken at final date
featureLabel  = char(data.featureLabels(featureNumber));      
featureTitle  = char(data.featureTitles(featureNumber));  
featureValues = data.features(end, :, featureNumber);
featureValues = featureValues';
names         = data.names;
fprintf('Feature = %s \n', featureLabel);

%=== eliminate NaN and Inf features
index         = find(~isnan(featureValues) & ~isinf(featureValues));
featureValues = featureValues(index);
names         = names(index);

%=== if this is CT towns, optionally only plot Fairfield County
fairfieldCountyOnly = 0;
if strcmp(data.level, 'Town') && fairfieldCountyOnly
  filter        = find(strcmp(data.countyNames, 'Fairfield'));
  featureValues = featureValues(filter);
  names         = names(filter);
end

%=== inverse sort by feature values
[sortValues, sortIndex] = sort(featureValues, 'descend');
allNames      = names(sortIndex);

%=== get fairfield county ranking
if strcmp(data.level, 'CountyUS')
  rank        = find(strcmp('Fairfield County, Connecticut', names(sortIndex)));
  percentile  = 100 * rank / data.numNames;
  value       = featureValues(sortIndex(rank));
  fprintf('Fairfield County ranks %d (Highest %2.1f%%) out of %d US counties in %s\n', ...
           rank, percentile, data.numNames, featureTitle);
end

%=== set values to display
numDisplay    = min(70, length(featureValues));   % limits number of counties shown
sortIndex     = sortIndex(1:numDisplay);
featureValues = featureValues(sortIndex);
names         = names(sortIndex);

%-------------------------------------------------------------------------------------
%=== HORIZONTAL BAR CHART 
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get data
yValues  = featureValues;
yLabels  = names;
yValues  = yValues(end:-1:1,:);   % reverse so biggest is at top of bar chart
yLabels  = yLabels(end:-1:1);     % reverse so biggest is at top of bar chart
y        = 1:length(yLabels);
lastDate = data.lastDate;

%=== horizontal bar chart
if featureNumber == 1
  index = find(yValues > 0);
  for s=index
    h = barh(y(s), yValues(s), 'stacked'); 
    set(h(1), 'FaceColor', 'r'); hold on;
  end
  index = find(yValues <= 0);
  for s=index
    h = barh(y(s), yValues(s), 'stacked'); 
    set(h(1), 'FaceColor', 'g'); hold on;
  end
elseif featureNumber == 2
  h = barh(y, yValues, 'stacked');    set(h, 'FaceColor', 'r'); hold on;
elseif featureNumber == 4
  h = barh(y, yValues, 'stacked');    set(h, 'FaceColor', 'g'); hold on;
elseif featureNumber == 5
  h = barh(y, yValues, 'stacked');    set(h, 'FaceColor', 'b'); hold on;
elseif featureNumber == 6
  h = barh(y, yValues, 'stacked');    set(h, 'FaceColor', 'c'); hold on;
elseif featureNumber == 7
  h = barh(y, yValues, 'stacked');    set(h, 'FaceColor', 'r'); hold on;
end

hold off;

%=== add explanatory text
if strcmp(data.level, 'Town')
  ax   = gca; 
  xmin = ax.XLim(1); 
  xmax = ax.XLim(2);
  ymin = ax.YLim(1); 
  ymax = ax.YLim(2);
  x0   = xmin + 0.9*(xmax - xmin);
  y0   = ymin + 0.1*(ymax - ymin);
  strText1 = sprintf('We show only the %d towns in Connecticut with the highest rates.', numDisplay);
  r        = find(strcmp(allNames, 'Ridgefield'));
  strText2 = sprintf('Ridgefield ranks %d on this list (out of %d Connecticut towns).', r, length(allNames));
  strText  = sprintf('%s\n%s', strText1, strText2);
  h = text(x0, y0, strText); set(h,'Color','k'); set(h,'HorizontalAlignment','Right'); set(h,'FontWeight', 'normal'); set(h,'FontSize', 12);
  set(h, 'BackgroundColor', 'c');
end

%=== add data source
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = xmin - 0.05*(xmax - xmin);
y0   = ymin - 0.10*(ymax - ymin);
if strcmp(data.level, 'Country') || strcmp(data.level, 'State')
  strText = parameters.covidTrackingSource;
elseif strcmp(data.level, 'CountyUS')
  strText = parameters.jhuDataSource;
else
  strText = parameters.ctDataSource;
end
h = text(x0, y0, strText); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== axis labels and everything else
grid on;
set(gca,'Color',parameters.bkgdColor);
if numDisplay > 52
  set(gca,'FontSize',8);
else
  set(gca,'FontSize',10);
end
set(gca,'YTick',y);
set(gca,'YTickLabel',yLabels(y));
xlabel(sprintf('%s', featureTitle), 'FontSize', 14);
title(sprintf('%s (as of %s)', featureLabel, lastDate), 'FontSize', 14);
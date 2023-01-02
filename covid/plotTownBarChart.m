function plotTownBarChart(featureNumber, town, countyName, figureNum)
%
% plot horizontal bar chart of new case rates for all towns in Fairfield County
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> plotTownBarChart\n');

%=== set custom colors
or = parameters.orange;

%=== get data for all towns in county
index         = find(strcmp(town.countyNames, countyName));
featureLabel  = char(town.featureLabels(featureNumber));      
featureTitle  = char(town.featureTitles(featureNumber));  
featureValues = town.features(:, index, featureNumber);
townNames     = town.names(index);

%------------------------------------------------------------------------
%=== PLOT HORIZONTAL BAR CHART
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get data
yValues  = featureValues(end,:);   % final values
yLabels  = townNames;
[~, sortIndex] = sort(yValues, 'descend');
yValues  = yValues(sortIndex);
yLabels  = yLabels(sortIndex);
yValues  = yValues(end:-1:1);   % reverse so biggest is at top of bar chart
yLabels  = yLabels(end:-1:1);   % reverse so biggest is at top of bar chart
y        = 1:length(yLabels);

%=== set xlabel
xLabel      = sprintf('%s', featureTitle);
xTickFormat = '%d';

%=== SPECIAL TREATMENT FOR NEW CASE RATE
if ~strcmp(featureLabel, 'New Case Rate')
  
  %=== horizontal bar chart for test rate or positivity
  if strcmp(featureLabel, 'New Test Rate')
    h = barh(y, yValues, 'stacked'); set(h(1), 'FaceColor', 'g'); hold on;
  elseif strcmp(featureLabel, 'Test Positivity')
    h = barh(y, yValues, 'stacked'); set(h(1), 'FaceColor', 'c'); hold on;
    xTickFormat = '%1.0f%%';
  end
  
else

  %=== horizontal bar chart for case rate
  index = find(yValues >= 15);
  for s=index
    h = barh(y(s), yValues(s), 'stacked'); 
    set(h(1), 'FaceColor', 'r'); hold on;
  end
  index = find(yValues >= 10 & yValues < 15);
  for s=index
    h = barh(y(s), yValues(s), 'stacked'); 
    set(h(1), 'FaceColor', or); hold on;
  end
  index = find(yValues >= 5 & yValues < 10);
  for s=index
    h = barh(y(s), yValues(s), 'stacked'); 
    set(h(1), 'FaceColor', 'y'); hold on;
  end
  index = find(yValues < 5);
  for s=index
    h = barh(y(s), yValues(s), 'stacked'); 
    set(h(1), 'FaceColor', 'w'); hold on;
  end

%=== add vertical lines for alerts
  ax   = gca; 
  ymin = ax.YLim(1); 
  ymax = ax.YLim(2);
  h = plot([15,15],[ymin,ymax], 'k-'); set(h,'LineWidth', 2);
  h = plot([10,10],[ymin,ymax], 'k-'); set(h,'LineWidth', 2);
  h = plot([ 5, 5],[ymin,ymax], 'k-'); set(h,'LineWidth', 2);

  %=== note on moving average
  xmin = ax.XLim(1); 
  xmax = ax.XLim(2);
  x0   = 0.99*xmax;
  y0   = ymin + 0.09*(ymax - ymin);
  strText1 = sprintf('The New Case Rate is the number of new cases per day per 100,000 residents.');
  strText2 = sprintf('New Case Rates are computed using a %d-day moving average.',parameters.maWindow);
  strText3 = sprintf('The colors indicate Connecticut Alert Levels -- these may differ from those issued by the State.');
  strText  = sprintf('%s\n%s\n%s', strText1, strText2, strText3);
  h = text([x0,x0],[y0,y0], strText); set(h,'Color','k'); set(h,'HorizontalAlignment','Right'); set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
  set(h, 'BackgroundColor', 'c');
end

%=== add data source
ax   = gca; 
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = -5;
y0   = ymin - 0.075*(ymax - ymin);
strText = parameters.ctDataSource;
h = text(x0, y0, strText); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== axis labels and everything else
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'FontSize',10);
set(gca,'YTick',y);
set(gca,'YTickLabel',yLabels(y));
xtickformat(xTickFormat);
xlabel(xLabel, 'FontSize', 14);
title(sprintf('%s as of %s', featureTitle, town.lastDate), 'FontSize', 14);

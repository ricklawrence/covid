function plotHeatmap(featureNumber, data, countyName, figureNum)
%
% plot heatmap for all towns, counties, or states
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> plotHeatmap\n');

%=== get feature labels
featureLabel  = char(data.featureLabels(featureNumber));      
featureTitle  = char(data.featureTitles(featureNumber));  

%=== get index for all towns in county, all counties in Connecticut or all states in US
if strcmp(data.level, 'Town')
 index    = find(strcmp(data.countyNames, countyName));
 strTitle = sprintf('%s for all Towns in %s County', featureTitle, countyName);
elseif strcmp(data.level, 'County')
 index    = [1:data.numNames]';
 strTitle = sprintf('%s for all Counties in Connecticut', featureTitle);
elseif strcmp(data.level, 'State')
 index    = [1:data.numNames]';
 strTitle = sprintf('%s for all States', featureTitle);
elseif strcmp(data.level, 'CountyNY')
 index    = [1:data.numNames]';
 strTitle = sprintf('%s for all Counties in New York', featureTitle);
end

%=== get data
featureValues = data.features(:, index, featureNumber);
names         = data.names(index);

%=== if this is test rates, clip rates since some towns are really high
if featureNumber == 4
  featureValues = min(parameters.maxTestRate, featureValues);
end

%=== get dates
dates       = data.dates;
numDates    = length(dates);

%=== set date labels
if parameters.shortWindow > 0
  numWeeks = parameters.shortWindow / 7; % number of weeks to show
else
  numWeeks = 8;
end
numDays     = 7*numWeeks;
d2          = numDates;
d1          = numDates -  numDays;
interval    = parameters.shortWindow / 20;   % ~20 date labels
interval    = 7 * ceil(interval/7);          % round up to integer number of weeks
xLabels     = dates(d1:d2);
x           = 1:interval:length(xLabels);

%=== set labels
yLabels     = names;
y           = 1:length(yLabels);

%------------------------------------------------------------------------
%=== PLOT  HEATMAP
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== plot heat map
z = featureValues(d1:d2,:);
imagesc(z');
colormap jet;
h = colorbar;
set(get(h,'label'),'string',featureTitle, 'FontSize', 14);

%=== add data source
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = -2;
y0   =  1.07*ymax;
strText = parameters.ctDataSource;
h = text(x0, y0, strText); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== add subtitle
x0   = 0.5*(xmin + xmax);
y0   = -1;
strText = sprintf('The magnitude of the %s is indicated by the color bar at the right. Red indicates the highest values.', featureLabel);
%h = text(x0, y0, strText); set(h,'Color','k'); set(h,'HorizontalAlignment','Center'); set(h,'FontSize', 10);
%set(h, 'BackgroundColor', 'c');

%=== add axis labels
grid on;
set(gca,'LineWidth',1);
set(gca,'FontSize',10);
set(gca,'YTick',y);
set(gca,'YTickLabel',yLabels(y));
set(gca,'XTick',x);  
set(gca,'XTickLabel',xLabels(x));
xlabel(sprintf('Reporting Date (Last %d Weeks)', numWeeks), 'FontSize', 14);
title(strTitle, 'FontSize', 16);

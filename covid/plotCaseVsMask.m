function plotCaseVsMask(dataFileFB, featureIndex, data, figureNum)
%
% read facebook mask data and plot correlations between new cases and mask wearing
% this works at both the State and CountyUS levels
%
global parameters;
fprintf('\n--> plotCaseVsMask\n');

%=== determine which date we use in file as number of days before last date in file
if strcmp(data.level, 'State')
  numDaysBeforeLast = 28;
elseif strcmp(data.level, 'CountyUS')
  numDaysBeforeLast = 14;
end

%-------------------------------------------------------------------------------------------
% READ DATA FILE
  
%=== read facebook file
dataTable  = readtable(dataFileFB);
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dataTable.geo_value);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows, dataFileFB);
head(dataTable,52);

%=== sort by date ... each state has all dates
datenums = datenum(dataTable.time_value);
[~,sortIndex] = sort(datenums, 'ascend');
datenums             = datenums(sortIndex);
dataTable.time_value = dataTable.time_value(sortIndex);
dataTable.geo_value  = dataTable.geo_value(sortIndex);
dataTable.value      = dataTable.value(sortIndex);

%=== set which date to use
datenum1 = datenums(1);
datenum2 = datenums(end);
datenum0 = datenum2 - numDaysBeforeLast;
datenum0 = max(datenum0, datenum1);
maskDate = datestr(datenum0, 'mm/dd/yyyy');
fprintf('Using Facebook mask data from %s.\n', maskDate);

%=== get mask fraction at target date
index         = find(datenums == datenum0); 
fbNames       = dataTable.geo_value(index);
maskFraction0 = 0.01*dataTable.value(index);

%=== map data into existing data structure using state abbreviations or county FIPS
numNames      = data.numNames;
maskFractions = NaN(numNames,1);
sum1 = 0;
sum2 = 0;
for n=1:numNames
  if strcmp(data.level, 'State')
    i = find(strcmpi(data.names0(n), fbNames));  % case insensitive match on state abbrev (e.g. ct)
  elseif strcmp(data.level, 'CountyUS')
    i = find(data.fips(n) == fbNames);           % match fips in county-level FB data to county fips
  end
  if ~isempty(i)    
    maskFractions(n) = maskFraction0(i);
    sum1 = sum1 + maskFractions(n) .* data.population(n);
    sum2 = sum2 + data.population(n);
  end
end

%=== compute population-weighted US fraction
usMaskFraction = sum1 / sum2;
us             = find(strcmp(data.names0, 'US'));
maskFractions(us) = usMaskFraction;

%=== check
if strcmp(data.level, 'State')
  n = find(strcmp(data.names0, 'CT'));
  fprintf('Connecticut mask fraction = %6.4f\n', maskFractions(n));
elseif strcmp(data.level, 'CountyUS')
  n = find(data.fips == 9001);
  fprintf('Fairfield County mask fraction = %6.4f\n', maskFractions(n));
end
fprintf('Weighted US mask fraction = %6.4f\n', usMaskFraction); 

%-----------------------------------------------------------------------------------------
% PREPARE DATA FOR PLOT

%=== titles
featureLabel  = char(data.featureLabels(featureIndex));
strTitle      = sprintf('%s vs %s', featureLabel, 'Percentage of People Wearing Mask');
xFeatureTitle = 'Percentage of people who wear a mask most or all of the time while in public (from Facebook Surveys)';
yFeatureTitle = char(data.featureTitles(featureIndex));

%=== get features and names
xFeatures = maskFractions;
yFeatures = data.features(end,:,featureIndex);
names     = data.names0;   

%=== eliminate NaNs (not all counties have FB data)
filter    = find(~isnan(xFeatures));
xFeatures = xFeatures(filter);
yFeatures = yFeatures(filter);
names     = names(filter);

%=== only counties in selected state
onlyCT = 1;
name   = 'KS';
if onlyCT && strcmp(data.level, 'CountyUS')
  filter    = contains(names, name);
  xFeatures = xFeatures(filter);
  yFeatures = yFeatures(filter);
  names     = names(filter);
end  
  
%-----------------------------------------------------------------------------------------
%=== SCATTER PLOT
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get all data
x = xFeatures;
y = yFeatures;

%=== plot big circles for each point
h2 = plot(x,y,'o'); 
set(h2,'Color','k'); 
if length(names) <= 52
  set(h2,'Markersize', 20); % add big circles
else
  set(h2,'Markersize', 2); % add smaller circles
end
hold on;

%=== compute correlation coefficient
mdl  = fitlm(x,y);      % confirm R2 via linear model
R    = corrcoef(x,y);
R2   = R(1,2) ^2;

%=== linear model
[sortValues, sortIndex] = sort(x);
x1   = x(sortIndex);
y1   = y(sortIndex);
P    = polyfit(x1,y1,1);
yfit = polyval(P,x1);
h    = plot(x1,yfit,'r-'); set(h, 'LineWidth', 2); hold on;

%=== add abbreviations inside circles
if length(names) <= 52
  for i=1:length(x)
    h1 = text(x(i),y(i), char(names(i))); 
    set(h1,'Color','k'); 
    set(h1,'HorizontalAlignment','Center'); 
    if strcmp(names(i), 'US') || strcmp(names(i), 'CT') || length(names) < 5
      set(h1,'FontWeight', 'bold');
      set(h1,'FontSize', 14);
    else
      set(h1,'FontWeight', 'normal');
      set(h1,'FontSize', 8);
    end
  end
end

%=== add explanatory text
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = xmin + 0.99*(xmax - xmin);
y0   = ymin + 0.83*(ymax - ymin);
numDays  = datenum(data.lastDate) - datenum(maskDate);
strText = sprintf('The mask data explains %2.1f%% of the variance in %s.', 100*R2, featureLabel);
h = text(x0, y0, strText); set(h,'Color','k'); set(h,'HorizontalAlignment','Right'); set(h,'FontWeight', 'normal'); set(h,'FontSize', 12);
set(h, 'BackgroundColor', 'c');

%=== add data source
hold off;
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = xmin - 0.15*(xmax - xmin);
y0   = ymin - 0.11*(ymax - ymin);  
if strcmp(data.level, 'State')
  strText1 = parameters.ctDataSource;
elseif strcmp(data.level, 'CountyUS')
  strText1 = parameters.jhuDataSource;
end
strText2 = 'Mask Survey Data: Delphi COVIDcast, covidcast.cmu.edu';
strText  = sprintf('%s\n%s', strText1, strText2);
h = text(x0, y0, strText); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 8);
set(h, 'BackgroundColor', 'c');

%=== legends
strLegend1 = sprintf('COVID-19 Data as of %s\nFacebook Mask Survey as of %s', data.lastDate, maskDate);
strLegend2 = sprintf('Linear Model (R^2 = %4.3f)', R2);
strLegend  = {strLegend1, strLegend2};

%=== labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 1);
set(gca,'FontSize',14);
xlabel(xFeatureTitle);
ylabel(yFeatureTitle);
legend(strLegend, 'Location', 'NorthEast', 'FontSize', 12);
title(strTitle, 'Fontsize', 16);
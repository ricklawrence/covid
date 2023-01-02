function plotCaseVsTestTown(town, figureNum)
%
% plot new case rate vs new test rate for CT towns
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> plotCaseVsTestTown\n');

%=== we compute second set of features from previous town report
numDaysEarlier = datenum(town.reportDates(end)) - datenum(town.reportDates(end-1));

%=== get dates
date2            = town.lastDate;                                          % latest date
date1            = datestr(datenum(date2) - numDaysEarlier, 'mm/dd/yyyy'); % previous date
dateIndex1       = find(strcmp(date1, town.dates));
dateIndex2       = find(strcmp(date2, town.dates));

%=== get features at both dates
xFeatureTitle = town.featureTitles(4);            % new test rate
yFeatureTitle = town.featureTitles(2);            % new case rate
x1            = town.features(dateIndex1,:,4)';
y1            = town.features(dateIndex1,:,2)';
x2            = town.features(dateIndex2,:,4)';
y2            = town.features(dateIndex2,:,2)';
townNames     = town.names0;
strTitle      = sprintf('New Case Rate vs New Test Rate for all Towns in Fairfield County');

%=== only do fairfield county
countyName  = 'Fairfield';  
filter      = find(strcmp(town.countyNames, countyName));
townNames   = townNames(filter);
x1          = x1(filter);
x2          = x2(filter);
y1          = y1(filter);
y2          = y2(filter);

%=== separate out the towns with zero values at the current date
filter      = y2 > 0;                 % only positive current case rates
townNames0  = townNames;
townNames   = townNames(filter);
x1          = x1(filter);
x2          = x2(filter);
y1          = y1(filter);
y2          = y2(filter);

%=== save towns with zero values
filter2     = ~filter;
townNames2  = townNames0(filter2);

%=================================
%=== set clip bounds on test rates
minTestRate = 100;                     % min test rate             
maxTestRate = parameters.maxTestRate;  % max test rate              

%=== clip test rates
x1 = max(x1, minTestRate);
x2 = max(x2, minTestRate);
x1 = min(x1, maxTestRate);
x2 = min(x2, maxTestRate);

%=== set axis limits
xmin = 100*floor(min([x1;x2])/100);
xmax = 100*ceil(max([x1;x2])/100);
ymin = 10*floor(min([y1;y2])/10);
ymax = 10*ceil(max([y1;y2])/10);
ymin = 0;                   % always zero
ymax = ymax + 5;           % leave room at top of figure for note etc
%=================================

%=== compute max positivity for number of positivity lines to plot
positivity    = [y1; y2] ./ [x1; x2];
maxPositivity = max(positivity,[],'all');
maxPositivity = ceil(maxPositivity*100)/100;

%-----------------------------------------------------------
%=== SCATTER PLOT
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== plot big circles for each point
h2 = plot(x2 ,y2, 'o'); 
set(h2,'Color','k'); 
set(h2,'Markersize', 10);
subset(1)    = h2;
strLegend(1) = {sprintf('Data as of %s', date2)};

%=== add town names inside circles
for i=1:length(x2)
  h1 = text(x2(i),y2(i), char(townNames(i))); hold on;
  set(h1,'HorizontalAlignment','Center'); 
  set(h1,'FontWeight', 'bold');
  if strcmp(townNames(i), 'Ridgefield')
    set(h1,'Color','b'); 
    set(h1,'FontSize', 14);
  else
    set(h1,'Color','k'); 
    set(h1,'FontSize', 8);
  end
end
  
%=== set axis limits
xlim([xmin xmax]);
ylim([ymin ymax]);

%=== plot small dots for each each previous point
h3 = plot(x1, y1, '.'); 
set(h3,'Color','k'); 
set(h3,'Markersize', 10); % add small dots
subset(2) = h3;
strLegend(2) = {sprintf('Data as of %s', date1)};

%=== plot lines connecting current data to previous data
colormap(jet(length(x2)));
for i=1:length(x2)
  h3 = plot([x1(i), x2(i)], [y1(i), y2(i)], ':'); hold on;
  set(h3,'LineWidth', 1);
end

%=== plot lines for constant positive test rates
positiveRates1 = 0.01 : 0.01 : maxPositivity;
yLimit  = max([y1;y2]);      % max y value for positive test rate lines
xfit(1) = xmin;
xfit(2) = xmax;
for i=1:length(positiveRates1)
  positiveRate = positiveRates1(i);
  yfit         = positiveRate .* xfit;
  if yfit(2) > yLimit                     % limit the length of the positivity lines
    xfit(2) = yLimit / positiveRate;
    yfit(2) = yLimit;
  end
  h            = plot(xfit,yfit,'r-');  set(h, 'LineWidth', 1); hold on;
  strText      = sprintf('%2.0f%%', 100*positiveRate);
  x0           = xfit(2);
  y0           = yfit(2);
  h            = text([x0,x0],[y0,y0], strText); 
  set(h,'Color','r', 'HorizontalAlignment','Left', 'FontWeight','bold', 'FontSize',10);
end

%=== add explanatory text
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = xmin + 0.25*(xmax - xmin);
y0   = ymin + 0.99*(ymax - ymin);
strText1 = sprintf('The open circles show the current values for each state.');
strText2 = sprintf('The dashed lines (''jet plumes'') show the trajectory for each state since the previous report.');
strText3 = sprintf('The solid Red lines show constant Test Positivity Rates.');
strText4 = sprintf('The New Case Rate and the New Test Rate are averaged over %d days.', parameters.maWindow);
strText  = sprintf('%s\n%s\n%s', strText1, strText2, strText3);
h = text(x0, y0, strText); 
set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
set(h,'HorizontalAlignment','Left'); set(h,'VerticalAlignment','Top');

%=== add quadrant labels
x0   = xmin + 0.99*(xmax - xmin);
y0   = ymin + 0.01*(ymax - ymin);
strText = sprintf('Best Quadrant');
h = text(x0, y0, strText); 
set(h,'Color','k', 'BackgroundColor','g', 'Horiz','Right', 'Vert','Bottom', 'FontWeight','bold', 'FontSize',12);
x0   = xmin + 0.01*(xmax - xmin);
y0   = ymin + 0.90*(ymax - ymin);
strText = sprintf('Worst Quadrant');
h = text(x0, y0, strText); 
set(h,'Color','k', 'BackgroundColor','r', 'Horiz','Left', 'Vert', 'Top', 'FontWeight','bold', 'FontSize',12);
x0   = xmin + 0.01*(xmax - xmin);
y0   = ymin + 0.01*(ymax - ymin);
strText = sprintf('Low Case Rates, Low Testing');
h = text(x0, y0, strText); 
set(h,'Color','w', 'BackgroundColor','b', 'Horiz','Left', 'Vert', 'Bottom', 'FontWeight','bold', 'FontSize',10);
x0   = xmin + 0.99*(xmax - xmin);
y0   = ymin + 0.99*(ymax - ymin);
strText = sprintf('High Case Rates, High Testing');
h = text(x0, y0, strText); 
set(h,'Color','w', 'BackgroundColor','b', 'Horiz','Right', 'Vert', 'Top',  'FontWeight','bold', 'FontSize',10);

%=== add data source
x0      = xmin - 0.09*(xmax - xmin);
y0      = ymin - 0.11*(ymax - ymin);  
strText = parameters.ctDataSource;
h = text(x0, y0, strText); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== construct string showing towns with zero new cases
if length(townNames2) > 0
  strNote   = sprintf('The following %d towns have No New Cases over past 7 days:', length(townNames2));
  for t=1:length(townNames2)
    strNote = sprintf('%s\n   %s', strNote, char(townNames2(t)));
  end

  %=== write as text
  ax    = gca;
  xmin  = ax.XLim(1); xmax = ax.XLim(2);
  ymin  = ax.YLim(1); ymax = ax.YLim(2);
  xText = xmin + 0.01*(xmax - xmin);
  yText = ymin + 0.86*(ymax - ymin);
  h     = text(xText, yText, strNote);
  set(h, 'FontSize',             8);
  set(h, 'FontWeight',          'bold');
  set(h, 'BackgroundColor',     '[1 1 0.6]');
  set(h, 'HorizontalAlignment', 'left');
  set(h, 'VerticalAlignment',   'top');
end

%=== labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 1);
set(gca,'FontSize',14);
xlabel(xFeatureTitle);
ylabel(yFeatureTitle);
legend(subset, strLegend, 'Location', 'NorthWest', 'Fontsize', 12);
title(strTitle, 'Fontsize', 16);
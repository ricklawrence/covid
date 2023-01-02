function plotCaseVsTestState(state, figureNum)
%
% plot new case rate vs new test rate for states
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> plotCaseVsTestState\n');

%=== set parameters
numDaysEarlier   = 1;     % we compute second set of features N days before current date

%=== get most recent date plus previous date (eg 1 week ago)
date2            = state.lastDate;                                         % latest date
date1            = datestr(datenum(date2) - numDaysEarlier, 'mm/dd/yyyy'); % previous date
dateIndex1       = find(strcmp(date1, state.dates));
dateIndex2       = find(strcmp(date2, state.dates));

%=== get features at both dates
xFeatureTitle = state.featureTitles(4);
yFeatureTitle = state.featureTitles(2);
x1            = state.features(dateIndex1,:,4)';
y1            = state.features(dateIndex1,:,2)';
x2            = state.features(dateIndex2,:,4)';
y2            = state.features(dateIndex2,:,2)';
stateNames0   = state.names0;
strTitle      = sprintf('New Case Rate vs New Test Rate for all States');

%=== all features should be positive unless there is a data glitch
x1 = max(x1, 0);
y1 = max(y1, 0);
x2 = max(x2, 0);
y2 = max(y2, 0);

%=================================
%=== set clip bounds on test rates
minTestRate = 0;     % min test rate             
maxTestRate = 1200;  % max test rate              

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
ymin = 0;                  % always zero
ymax = ymax + 16;          % leave room at top of figure for note etc
%=================================

%-----------------------------------------------------------------------------------------
%=== SCATTER PLOT
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== plot big circles for each point
h2 = plot(x2, y2, 'o'); 
set(h2,'Color','k'); 
set(h2,'Markersize', 20); % add big circles
subset(1) = h2;
strLegend(1) = {sprintf('Data as of %s', date2)};
  
%=== set axis limits
xlim([xmin xmax]);
ylim([ymin ymax]);

%=== add state abbreviations
for i=1:length(x2)
  h1 = text(x2(i),y2(i), char(stateNames0(i))); 
  set(h1,'HorizontalAlignment','Center'); 
  if strcmp(stateNames0(i), 'US') || strcmp(stateNames0(i), 'CT')
    set(h1,'Color','b'); 
    set(h1,'FontWeight', 'bold');
    set(h1,'FontSize', 14);
  else
    set(h1,'Color','k'); 
    set(h1,'FontWeight', 'normal');
    set(h1,'FontSize', 8);
  end
  hold on;
end

plotPrevious = 0;
if plotPrevious
  %=== plot small dots for each each previous point
  h3 = plot(x1, y1, '.'); 
  set(h3,'Color','k'); 
  set(h3,'Markersize', 10); % add small dots
  subset(2) = h3;
  strLegend(2) = {sprintf('Data as of %s', date1)};

  %=== plot lines connecting current data to previous data
  colormap(jet(length(x1)));
  for i=1:length(x1)
    h3 = plot([x1(i), x2(i)], [y1(i), y2(i)], ':'); hold on;
    set(h3,'LineWidth', 1);
  end
end

%=== plot lines for constant positive test rates
positiveRates1 = [0.01 0.02 0.03 0.04 0.05 : 0.05 : 0.25];
yLimit  = max([y1;y2]);  % max y value for positive test rate lines
xfit(1) = xmin;
xfit(2) = xmax;
for i=1:length(positiveRates1)
  positiveRate = positiveRates1(i);
  yfit         = positiveRate .* xfit;
  if yfit(2) > yLimit                 % limit the length of the positivity lines
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
strText  = sprintf('%s\n%s', strText1, strText3);
h = text(x0, y0, strText); 
set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
set(h,'HorizontalAlignment','Left'); set(h,'VerticalAlignment','Top');

%=== add quadrant labels
skip = 1;
if ~skip
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
end

%=== add data source
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = xmin - 0.09*(xmax - xmin);
y0   = ymin - 0.11*(ymax - ymin);  
strText = parameters.covidTrackingSource;
h = text(x0, y0, strText); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 1);
set(gca,'FontSize',14);
xlabel(xFeatureTitle);
ylabel(yFeatureTitle);
legend(subset, strLegend, 'Location', 'NorthWest', 'FontSize', 14);
title(strTitle, 'Fontsize', 16);
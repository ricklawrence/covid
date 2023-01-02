function plotStateBoosterShots(stateName, state, data, figureNum)
%
% plot booster shots and first doses for individual state
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> plotStateBoosterShots\n');

%=== unpack data
acceleration = data.acceleration;
date0        = data.date0;
date1        = data.date1;
date2        = data.date2;

%------------------------------------------------------------------------
%=== 1. PLOT LINE CHART OF CDC FIRST DOSE AND BOOSTER SHOTS
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get state
s = find(strcmp(stateName, state.names));

%=== get daily moving averages
firstDoses = state.vaxDataMA(:,:,3);     
boosters   = state.vaxDataMA(:,:,19);

%=== convert to per 100K
dates      = state.vaxDates;
numDates   = length(dates);
firstDoses = 100000 * firstDoses ./ repmat(state.population', numDates, 1);
boosters   = 100000 * boosters   ./ repmat(state.population', numDates, 1);

%=== set date indices
numWeeks = 8;
interval = 7;
d2       = numDates;
d1       = numDates - 7*numWeeks;
xLabels  = dates(d1:d2);
xTicks   = [d1:interval:d2]';
xTicks   = xTicks - d1 + 1;
i0       = find(strcmp(date0, xLabels));
i1       = find(strcmp(date1, xLabels));
i2       = find(strcmp(date2, xLabels));

%=== get data for plot
y(:,1) = firstDoses(d1:d2,s);
y(:,2) = boosters(d1:d2,s);

%=== plot data
plot(y(:,1), 'b-', 'LineWidth', 2); hold on; strLegends(1) = {'First Doses (7-Day Moving Average)'};
plot(y(:,2), 'k-', 'LineWidth', 2); hold on; strLegends(2) = {'Booster Doses (7-Day Moving Average)'};

%=== set labels
strTitle  = sprintf('%s: First Doses and Booster Shots (as of %s)', stateName, char(xLabels(end)));
xLabel    = sprintf('CDC Reporting Date');
yLabel    = sprintf('Number of Daily Doses Per 100,000 Residents');
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at start of background period
plot([i0,i0], [ymin,ymax], 'r-', 'LineWidth', 2);
strLegends(3) = {sprintf('Reference Window starts on    %s', date0)}; 

%=== vertical line CDC booster approval date
plot([i1,i1], [ymin,ymax], 'r-', 'LineWidth', 2);
strLegends(4) = {sprintf('CDC Approved Booster Doses on %s', date1)}; 

%=== vertical line ages 5-11 approval date
plot([i2,i2], [ymin,ymax], 'r-', 'LineWidth', 2);
strLegends(5) = {sprintf('CDC Approved Ages 5-11 on     %s', date2)}; 

%=== add acceleration to legend
plot([xmin,xmin], [ymin,ymin], 'k.', 'MarkerSize', 1);
strLegends(6) = {sprintf('First Dose Acceleration       = %2.1f%%', 100*acceleration(s))};

%=== add data source
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.095*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',14);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(xLabel, 'FontSize', 16);
ylabel(yLabel, 'FontSize', 16);
ytickformat('%2.0f');
legend(strLegends,'Location', 'NorthWest', 'FontSize', 12,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

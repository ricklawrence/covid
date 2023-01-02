function plotHospitalized(county, state, figureNum)
%
% plot CT county currently hospitalized
%
global parameters;
if figureNum < 0
  return;
end
fprintf('\n--> plotHospitalized\n');

%=== set county and state
countyName   = 'Fairfield';
stateName    = 'Connecticut';
countryName  = 'United States';
c            = find(strcmp(countyName,  county.names));
s            = find(strcmp(stateName,   state.names));
us           = find(strcmp(countryName, state.names));

%=== get hospitalization and deaths for this county
dates        = county.dates;
numDates     = length(dates);
hospitalized = county.hospitalized(:, c);
deaths       = county.newDeaths(:, c);

%=== set date limits
numWeeks    = 116;
window      = numWeeks*7;
d2          = numDates;
d1          = numDates - window;
interval    = window / 10;               % ~10 date labels
interval    = 7 * ceil(interval/7);      % round up to integer number of weeks
xTicks      = [d1:interval:d2]';
xTicks      = xTicks + d2 - max(xTicks); % insure last tick is latest date
xTicks      = xTicks - d1 + 1;           % ticks begin at 1
xLabels     = dates(d1:d2);              % labels begin at 1

%=== optionally print data
printData = 0;
if printData
  for i=1:length(ratio1)
    fprintf('%s\t%4.3f\n', char(county.dates(i)), ratio1(i));
  end
end

%-----------------------------------------------------------------------------------------------------
%=== 1. BAR PLOT OF NEW CASE RATES
figure(figureNum); fprintf('Figure %d.\n', figureNum);
barWidth = 0.8;

%=== get data 
newCaseRates = county.features(:,c,2);

%=== bar plot
y = newCaseRates;
h = bar(y(d1:d2), barWidth, 'FaceColor','b'); hold on;

%=== labels
clear strLegend;
strTitle     = sprintf('%s County: New Case Rate (as of %s)', countyName, county.lastDate);
xLabel       = sprintf('Reporting Date (Last %d weeks)', numWeeks);
yLabel       = 'New Case Rate (Per 100,000 Residents)';
strLegend(1) = {sprintf('New Case Rate (Latest = %2.1f)', y(end))};
strSource    = sprintf('%s\n%s', parameters.ctDataSource, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add data source
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.105*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 1);
set(gca,'FontSize',14);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(xLabel, 'FontSize', 16);
ylabel(yLabel,'FontSize', 16);
legend(strLegend,'Location', 'North', 'FontSize', 16);
title(strTitle, 'FontSize', 16);

%-----------------------------------------------------------------------------------------------------
%=== 2. BAR PLOT OF CURRENTLY HOSPITALIZED
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== bar plot
y  = hospitalized;
MA = movingAverage(y,7);
h = bar(y(d1:d2), barWidth, 'FaceColor', parameters.orange);  hold on;
h = plot(MA(d1:d2), 'r-');    set(h, 'LineWidth', 2);   hold on;

%=== labels
clear strLegend;
strTitle     = sprintf('%s County: Currently Hospitalized (as of %s)', countyName, county.lastDate);
xLabel       = sprintf('Reporting Date (Last %d weeks)', numWeeks);
yLabel       = 'Currently Hospitalized';
strLegend(1) = {sprintf('Currently Hospitalized (Latest = %d)', y(end))};
strLegend(2) = {sprintf('%d-Day Moving Average (Latest = %2.1f)', parameters.maWindow, MA(end))};
strSource    = sprintf('%s\n%s', parameters.ctDataSource, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add data source
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.105*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 1);
set(gca,'FontSize',14);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(xLabel, 'FontSize', 16);
ylabel(yLabel,'FontSize', 16);
legend(strLegend,'Location', 'North', 'FontSize', 16);
title(strTitle, 'FontSize', 16);

%-----------------------------------------------------------------------------------------------------
%=== 3. BAR PLOT OF HOSPIALIZED AS PERCENT OF NEW CASES
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== bar plot
y = 100*county.features(d1:d2,c,9);                    % use value computed in features
h = bar(y, barWidth, 'FaceColor', 'k');  hold on;

%=== labels
clear strLegend;
strTitle     = sprintf('%s County: Hospitalizations as Percent of New Cases (as of %s)', countyName, county.lastDate);
xLabel       = sprintf('Reporting Date (Last %d weeks)', numWeeks);
yLabel       = 'Hospitalizations as Percent of New Cases';
strLegend(1) = {sprintf('Hospitalizations as Percent of New Cases (Latest = %2.1f%%)', y(end))};
strSource    = sprintf('%s\n%s', parameters.ctDataSource, parameters.rickAnalysis);
strNote1     = sprintf('This metric is computed as [Weekly Average of Currently Hospitalized] / [Weekly New Cases (two weeks earlier)].');
strNote2     = sprintf('This is a measure of case severity.  It cannot be interpreted as the percent of Covid cases resulting in hospitalization.');
strNote      = sprintf('%s\n%s', strNote1, strNote2);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add note
x0   = xmin + 0.50*(xmax - xmin);
y0   = ymin + 0.90*(ymax - ymin);
h    = text(x0, y0, strNote); 
set(h,'FontSize', 10); set(h,'FontWeight', 'bold'); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Center'); set(h,'Vert','Middle');

%=== add data source
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.105*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 1);
set(gca,'FontSize',14);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(xLabel, 'FontSize', 16);
ylabel(yLabel,'FontSize', 16);
ytickformat('%1.0f%%');
legend(strLegend,'Location', 'North', 'FontSize', 16);
title(strTitle, 'FontSize', 16);

%-----------------------------------------------------------------------------------------------------
%=== 4. BAR PLOT OF DEATHS
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== bar plot
y  = deaths;
MA = movingAverage(y,7);
y  = max(y,0);
MA = max(MA,0);
h  = bar(y(d1:d2), barWidth, 'FaceColor', 'r');  hold on;
h  = plot(MA(d1:d2), 'k-');    set(h, 'LineWidth', 2);   hold on;

%=== labels
clear strLegend;
strTitle     = sprintf('%s County: Number of Deaths (as of %s)', countyName, county.lastDate);
xLabel       = sprintf('Reporting Date (Last %d weeks)', numWeeks);
yLabel       = 'Number of Deaths';
strLegend(1) = {sprintf('Deaths (Latest = %d)', y(end))};
strLegend(2) = {sprintf('%d-Day Moving Average (Latest = %2.1f)', parameters.maWindow, MA(end))};
strSource    = sprintf('%s\n%s', parameters.ctDataSource, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add data source
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.105*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 1);
set(gca,'FontSize',14);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(xLabel, 'FontSize', 16);
ylabel(yLabel,'FontSize', 16);
legend(strLegend,'Location', 'North', 'FontSize', 16);
title(strTitle, 'FontSize', 16);
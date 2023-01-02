function computeCovidLags(country, figureNum)
%
% compute lags between cases, hospitilizations and deaths
%
global parameters;
fprintf('\n--> computeCovidLags\n');

%=== get US data
dates           = country.dates;
newCases        = country.newCases;
newHospitalized = country.hospitalized;
newDeaths       = country.newDeaths;

%=== compute moving averages
newCases        = movingAverage(newCases,        parameters.maWindow);
newHospitalized = movingAverage(newHospitalized, parameters.maWindow);
newDeaths       = movingAverage(newDeaths,       parameters.maWindow);

%=== compute correlations
numDates     = length(dates);
numWeeks     = 16;
numLags      = 4*7;
numWindow    = numWeeks*7; 
correlations = zeros(numLags,3);
d2 = numDates;
d1 = d2 - numWindow;
for lag=1:numLags
  w1 = d1:d2-lag;
  w2 = lag+d1:d2;
  
  %=== cases -> hospitalization
  y1 = newCases(w1);
  y2 = newHospitalized(w2);
  R  = corrcoef(y1,y2);
  R2 = R(1,2) ^2;
  correlations(lag,1) = R2;
  labels(1) = {'Cases --> Hospitalizations'};

  
  %=== hospitalizations -> deaths
  y1 = newHospitalized(w1);
  y2 = newDeaths(w2);
  R  = corrcoef(y1,y2);
  R2 = R(1,2) ^2;
  correlations(lag,2) = R2;
  labels(2) = {'Hospitalizations --> Deaths'};
    
  %=== cases -> deaths
  y1 = newCases(w1);
  y2 = newDeaths(w2);
  R  = corrcoef(y1,y2);
  R2 = R(1,2) ^2;
  correlations(lag,3) = R2;
  labels(3) = {'Cases --> Deaths'};

end

%=== compute lags that maximize correltations
[maxCorrelation, maxLag] = max(correlations, [], 1);

%=== summary
fprintf('Cases            --> Hospitalizations = %2d days (R2 = %4.3f)\n', maxLag(1), maxCorrelation(1));
fprintf('Hospitalizations --> Deaths           = %2d days (R2 = %4.3f)\n', maxLag(2), maxCorrelation(2));
fprintf('Cases            --> Deaths           = %2d days (R2 = %4.3f)\n', maxLag(3), maxCorrelation(3));

%---------------------------------------------------------------------------------------------
%=== plot summary
figure(figureNum); fprintf('Figure %d.\n', figureNum);
y = maxLag'; 
h = bar(y); 
set(h, 'FaceColor', 'b');

%=== add explanatory text
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = xmin + 0.01*(xmax - xmin);
y0   = ymin + 0.95*(ymax - ymin);
strText = sprintf('The Lead Times are computed as the shift (in days) that maximizes the respective time-series correlations.');
h = text(x0, y0, strText); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c'); set(h,'VerticalAlignment','Top');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 2);
set(gca,'FontSize',14);
set(gca,'XTickLabel',labels);
ylabel('Lead Time (Days');
strTitle = sprintf('Lead Times (in Days) Between New Cases, Hospitalizations, and Deaths (US Data from %s to %s)', ...
                   char(dates(d1)), char(dates(d2)));
title(strTitle, 'FontSize', 16);
%return;

%---------------------------------------------------------------------------------------------
%=== plot raw data
figureNum = figureNum+1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get date labels
xLabels   = dates(d1:d2);
xTicks    = [d1:14:d2]';
xTicks    = xTicks - d1 + 1;

%=== plot
clear y;
y(:,1) = newCases(d1:d2);
y(:,2) = newHospitalized(d1:d2);
y(:,3) = 100*newDeaths(d1:d2);
h  = plot(y);  set(h, 'LineWidth', 2); colormap jet;

%=== labels
grid on;
set(gca,'FontSize',14);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
ylabel('Counts');
xlabel('Date');
title(sprintf('Raw Data: New Cases, Hospitalizations, and Deaths over Last %d weeks', numWeeks));
legend({'New Cases', 'New Hospitalizations', 'New Deaths (x100)'}, 'Location', 'NorthWest');

%---------------------------------------------------------------------------------------------
%=== plot shifted data
figureNum = figureNum+1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get date labels
xLabels   = dates(d1:d2);
xTicks    = [d1:14:d2]';
xTicks    = xTicks - d1 + 1;

%=== plot shifted data
offset1 = maxLag(1);
offset2 = maxLag(3);
y1 = newCases(d1:d2);
y2 = newHospitalized(d1+offset1:d2);
y3 = 100*newDeaths(d1+offset2:d2);
h  = plot(y1); hold on; set(h, 'LineWidth', 2); colormap jet;
h  = plot(y2); hold on; set(h, 'LineWidth', 2); colormap jet;
h  = plot(y3); hold on; set(h, 'LineWidth', 2); colormap jet;

%=== labels
hold off;
grid on;
set(gca,'FontSize',14);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
ylabel('Counts');
xlabel('Date');
title(sprintf('Shifted Data: New Cases, Hospitalizations, and Deaths over Last %d weeks', numWeeks));
legend({'New Cases', 'New Hospitalizations', 'New Deaths (x100)'}, 'Location', 'NorthWest');

%---------------------------------------------------------------------------------------------
%=== plot correlations as function of lag
figureNum = figureNum+1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== plot
y = correlations;
h = plot(y);  set(h, 'LineWidth', 1); colormap jet;

%=== labels
grid on;
set(gca,'FontSize',14);
ylabel('R^2');
xlabel('Lag');
title('Correlations as Function of Lag');
legend({'Cases --> Hospitalizations', 'Hospitalizations --> Deaths', 'Cases --> Deaths'}, 'Location', 'South');
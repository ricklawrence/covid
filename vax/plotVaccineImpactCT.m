function plotVaccineImpactCT(state, stateAge, figureNum)
%
% plot vaccinations vs new case rate
%
global parameters;
if figureNum < 0
  return;
end
fprintf('\n--> plotVaccineImpactCT\n');

%=== set color used for the right hand axis
rColor = 'k'; 

%=== only works for Connecticut
stateName  = 'Connecticut';
ct         = find(strcmp(stateName, state.names));

%=== set dates to be plotted -- start before 12/15/2020 when first vaccination was done
date1      = '11/01/2020';                    % ahead of first vaccination on 12/17/2020 (also catch TG surge)
date2      = state.vaxDates(end);             % last date in vax data (typically later than covid data)
datenums   = datenum(date1) : datenum(date2);
dates      = cellstr(datestr(datenums,'mm/dd/yyyy'));
numDates   = length(dates);

%=== map covid data onto this date range
state.datenums = datenum(state.datesCT);                      % need to use the stateCT dates here since we do only CT
[~,index]      = intersect(state.datenums, datenums);
newCaseRates   = state.features(index,ct,2);
[~,index]      = intersect(stateAge.datenums, datenums);
newCasesAge    = stateAge.newCasesByAgeGroup(index,:);
newDeathsAge   = stateAge.newDeathsByAgeGroup(index,:);

%=== map vax data onto this date range
d1         = find(strcmp(state.vaxDates(1),   dates));
d2         = find(strcmp(state.vaxDates(end), dates));
y          = NaN(numDates,3);
initiated  = state.vaxData(:,ct,3);
completed  = state.vaxData(:,ct,4);
y(d1:d2,1) = initiated - completed; 
y(d1:d2,2) = completed;

% === convert to percent of population
y1         = 100 * [y(:,2) y(:,1)] / state.population(ct);

%=== set date labels for x-axis
interval = numDates / 10;             % ~10 date labels
interval = 7 * ceil(interval/7);      % round up to integer number of weeks
x2       = numDates;
x1       = mod(numDates,interval);    % so last date is final tick mark
if x1 == 0
  x1     = interval;
end
x        = x1:interval:x2;            % show only these dates
xLabels  = dates;                     % all dates

%----------------------------------------------------------------------------------------
%=== 1. PLOT VAX RATES VS NEW CASES FOR 70+
figure(figureNum); fprintf('Figure %d.\n', figureNum);  

%=== get moving average of ratio of 70+ to all ages
%=== (since we take ratios of moving averages, no need to worry about holiday corrections to MAs)
newCasesAge70  = sum(newCasesAge(:,8:9), 2);   % 70+ = the last 2 bins of the 9 age groups)
newCasesAge70  = movingAverage(newCasesAge70, parameters.maWindow);
newCasesAgeAll = sum(newCasesAge(:,:), 2);
newCasesAgeAll = movingAverage(newCasesAgeAll, parameters.maWindow);
newCaseRatio   = newCasesAge70 ./ newCasesAgeAll;

%=== plot cumulative vaccinations with first and second dose
h  = bar(y1, 0.8, 'stacked');
set(h(1), 'FaceColor', 'r'); 
set(h(2), 'FaceColor', 'b'); 
hold on;

%=== plot age ratio on right axis
yyaxis right;
h = plot(100*newCaseRatio, '.-', 'MarkerSize', 20, 'LineWidth', 2);
set(h, 'Color', rColor);
hold on;
yyaxis left;

%=== get labels for plot
strLegends(1) = {sprintf('People Who Have Completed Vaccination (Left Axis)')};
strLegends(2) = {sprintf('People Who Have Initiated Vaccination (Left Axis)')};
strLegends(3) = {sprintf('7-day Moving Average of Percent of New Cases in Age 70+ (Right Axis)')};
strTitle      = sprintf('%s: Number of People Vaccinated vs Percent of New Cases in Age 70+', stateName);
xTitle        = sprintf('CDC Report Date');
yTitle        = sprintf('Number of People Vaccinated (as Percent of Population)');
yTitleR       = sprintf('Percent of New Cases in Age 70+');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 2);
set(gca,'FontSize',  10);
set(gca,'XTick',x);  
set(gca,'XTickLabel',xLabels(x));
xlabel(xTitle,    'FontSize', 14);
ylabel(yTitle,    'FontSize', 14);
ytickformat('%1.0f%%');

yyaxis right
ylabel(yTitleR,   'FontSize', 14);
ytickformat('%2.1f%%');
set(gca,'YColor', rColor);

legend(strLegends,'FontSize', 10, 'Location','SouthWest', 'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle,   'FontSize', 16);

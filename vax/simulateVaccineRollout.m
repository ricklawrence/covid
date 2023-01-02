function simulateVaccineRollout(state, entityName0, figureNum)
%
% simuluate US vaccine rollout
%
global parameters;
fprintf('\n--> simulateVaccineRollout\n');

%=== compute population ratio
us = find(strcmp(state.names, 'United States'));
ct = find(strcmp(state.names, 'Connecticut'));
populationRatio = state.population(us) / state.population(ct);

%=== set index based on input
if strcmp(entityName0, 'CT')
  entityName = 'Connecticut';   
else
  entityName = 'United States'; entityName0 = 'US';
end
us = find(strcmp(state.names, entityName));  %'us' points to input entity name

%----------------------------------------------------------------------------------------------
%=== SET PARAMETERS AND DATES

endDate         = '12/30/2021'; % needs to be long enough to get herd immunity -- plot ends at herd immunity
dateJJ2         = '05/01/2021'; % date when JJ allocation reaches peak
dailyJJ2        = 100000;       % JJ daily allocation at peak
if strcmp(entityName, 'Connecticut')
  dailyJJ2      = dailyJJ2 / populationRatio;
end
herdFraction    = 0.75;
pfizerFraction  = 0.5;
modernaFraction = 0.5;
pfizerWindow    = 21;
modernaWindow   = 28;
  
%=== set dates
date1          = state.vaxDates(1);    % first date with data
date2          = state.vaxDates(end);  % last  date with data
date4          = endDate;              % last  date of simulation
datenum1       = datenum(date1);
datenum2       = datenum(date2);
datenum3       = datenum2 + 1;         % first date of simulation
datenum4       = datenum(date4);
date3          = datestr(datenum3, 'mm/dd/yyyy');
d1             = 1;
d2             = datenum2 - datenum1 + 1;
d3             = datenum3 - datenum1 + 1;
d4             = datenum4 - datenum1 + 1;

%=== save dates over entire interval
dates   = datestr(datenum1:datenum4, 'mm/dd/yyyy');
dates   = cellstr(dates);
numDays = length(dates);

%=== allocate arrays
numDoses         = 3;                                % 1 = first dose, 2 = second dose, 3 = total doses
numManuf         = 4;                                % 1 = pfizer,     2 = moderna      3 = P&M Total    4 = J&J
dailyDoses       = zeros(numDays,numDoses,numManuf);
cumDoses         = zeros(numDays,numDoses,numManuf);
people           = zeros(numDays,numDoses,numManuf);       
dailyAllocations = zeros(numDays,numManuf);     

%----------------------------------------------------------------------------------------------
%=== POPULATE ARRAYS WITH KNOWN DATA

%=== daily doses
administered          = state.vaxDataD(:,us,2);
completed             = state.vaxDataD(:,us,4);
completedJJ           = state.vaxDataD(:,us,8);
completedJJ(isnan(completedJJ)) = 0;
firstJJ               = completedJJ;
secondPM              = completed - firstJJ;
firstPM               = administered - secondPM - firstJJ;  % insure that we replicate administered
dailyDoses(d1:d2,1,1) = pfizerFraction  * firstPM;
dailyDoses(d1:d2,1,2) = modernaFraction * firstPM;
dailyDoses(d1:d2,1,3) = firstPM;
dailyDoses(d1:d2,1,4) = firstJJ;
dailyDoses(d1:d2,2,1) = pfizerFraction  * secondPM;
dailyDoses(d1:d2,2,2) = modernaFraction * secondPM;
dailyDoses(d1:d2,2,3) = secondPM;
dailyDoses(d1:d2,2,4) = 0;
dailyDoses(d1:d2,3,1) = dailyDoses(d1:d2,1,1) + dailyDoses(d1:d2,2,1);
dailyDoses(d1:d2,3,2) = dailyDoses(d1:d2,1,2) + dailyDoses(d1:d2,2,2);
dailyDoses(d1:d2,3,3) = dailyDoses(d1:d2,1,3) + dailyDoses(d1:d2,2,3);
dailyDoses(d1:d2,3,4) = dailyDoses(d1:d2,1,4) + dailyDoses(d1:d2,2,4);

%=== cumulative doses
administered          = state.vaxData(:,us,2);
completed             = state.vaxData(:,us,4);
completedJJ           = state.vaxData(:,us,8);
completedJJ(isnan(completedJJ)) = 0;
firstJJ               = completedJJ;
secondPM              = completed - firstJJ;
firstPM               = administered - secondPM - firstJJ;  % insure that we replicate administered
cumDoses(d1:d2,1,1)   = pfizerFraction  * firstPM;
cumDoses(d1:d2,1,2)   = modernaFraction * firstPM;
cumDoses(d1:d2,1,3)   = firstPM;
cumDoses(d1:d2,1,4)   = firstJJ;
cumDoses(d1:d2,2,1)   = pfizerFraction  * secondPM;
cumDoses(d1:d2,2,2)   = modernaFraction * secondPM;
cumDoses(d1:d2,2,3)   = secondPM;
cumDoses(d1:d2,2,4)   = 0;
cumDoses(d1:d2,3,1)   = cumDoses(d1:d2,1,1) + cumDoses(d1:d2,2,1);
cumDoses(d1:d2,3,2)   = cumDoses(d1:d2,1,2) + cumDoses(d1:d2,2,2);
cumDoses(d1:d2,3,3)   = cumDoses(d1:d2,1,3) + cumDoses(d1:d2,2,3);
cumDoses(d1:d2,3,4)   = cumDoses(d1:d2,1,4) + cumDoses(d1:d2,2,4);

%=== daily allocations are actual doses in known history
administered              = state.vaxDataD(:,us,2);
adminJJ                   = state.vaxDataD(:,us,6);
adminJJ(isnan(adminJJ))   = 0;
adminPM                   = administered - adminJJ; 
dailyAllocations(d1:d2,1) = pfizerFraction  * adminPM;
dailyAllocations(d1:d2,2) = modernaFraction * adminPM;
dailyAllocations(d1:d2,3) = adminPM;
dailyAllocations(d1:d2,4) = adminJJ;

%----------------------------------------------------------------------------------------------
%=== SPECIFY DAILY ALLOCATIONS DURING SIMULATION PERIOD  

%=== pfizer + moderna: retain latest 7-day moving averages
latestTotal               = state.vaxDataMA(end,us,2);
latestJJ                  = state.vaxDataMA(end,us,6);
latestPM                  = latestTotal - latestJJ; 
dailyAllocations(d3:d4,1) = pfizerFraction  * latestPM;
dailyAllocations(d3:d4,2) = modernaFraction * latestPM;
dailyAllocations(d3:d4,3) = latestPM;

%=== J&J: retain latest 7-day moving average
dailyAllocations(d3:d4,4) = latestJJ;

%=== J&J: start with latest 7-day moving average and ramp up
dailyAllocations(d3:d4,4) = dailyJJ2;
dailyJJ1                  = latestJJ;
dPeak                     = datenum(dateJJ2) - datenum1 + 1;  % peak date for JJ
for d=d3:dPeak 
  slope                 = (d - d3) / length(d3:dPeak)
  %dailyAllocations(d,4) = dailyJJ1 + slope*(dailyJJ2 - dailyJJ1);
end

%----------------------------------------------------------------------------------------------
%=== DO SIMULATION

for d=d3:d4
  
  %=== total dose at each day is the allocation
  dailyDoses(d,3,1) = dailyAllocations(d,1);
  dailyDoses(d,3,2) = dailyAllocations(d,2);
  dailyDoses(d,3,3) = dailyDoses(d,3,1) + dailyDoses(d,3,2);
  dailyDoses(d,1,4) = dailyAllocations(d,4);                    % one dose of J&J so no need to worry about window

  %=== second doses are simply first doses given 21 or 28 days ago
  dp = d - pfizerWindow;
  dm = d - modernaWindow;
  
  %=== allocate the second dose, and then compute first dose to preserve total dose
  %=== pfizer
  dailyDoses(d,2,1) = dailyDoses(dp,1,1);                        % second doses required are first doses from N days ago
  dailyDoses(d,3,1) = max(dailyDoses(d,3,1), dailyDoses(d,2,1)); % increase the total allocation to accomodate 2nd dose
  dailyDoses(d,1,1) = dailyDoses(d,3,1) - dailyDoses(d,2,1);     % modify first dose, preserving total dose
  
  %=== moderna
  dailyDoses(d,2,2) = dailyDoses(dm,1,2);                        % second doses required are first doses from N days ago
  dailyDoses(d,3,2) = max(dailyDoses(d,3,2), dailyDoses(d,2,2)); % increase the total allocation to accomodate 2nd dose
  dailyDoses(d,1,2) = dailyDoses(d,3,2) - dailyDoses(d,2,2);     % modify first dose, preserving total dose
  
  %=== pfizer + moderna
  dailyDoses(d,1,3) = dailyDoses(d,1,1) + dailyDoses(d,1,2);     % total of first doses
  dailyDoses(d,2,3) = dailyDoses(d,2,1) + dailyDoses(d,2,2);     % total of second doses
  dailyDoses(d,3,3) = dailyDoses(d,3,1) + dailyDoses(d,3,2);     % total of all doses
  
  %=== update cumulative doses
  cumDoses(d,:,:) = cumDoses(d-1,:,:) + dailyDoses(d,:,:);
end

%----------------------------------------------------------------------------------------------
% COMPUTE PEOPLE WHO HAVE INITIATED AND COMPLETED VACCINATION

%=== initiated vaccination: people with first dose ONLY
people(:,1,1) = cumDoses(:,1,1) - cumDoses(:,2,1);  % pfizer:  subtract off people who have had both doses
people(:,1,2) = cumDoses(:,1,2) - cumDoses(:,2,2);  % moderna: subtract off people who have had both doses
people(:,1,3) = cumDoses(:,1,3) - cumDoses(:,2,3);  % total:   subtract off people who have had both doses

%=== fully vaccinated: people with second dose of P&M
people(:,2,1) = cumDoses(:,2,1);
people(:,2,2) = cumDoses(:,2,2);
people(:,2,3) = cumDoses(:,2,3);

%=== fully vaccinated: people with one dose of J&J
people(:,1,4)  = cumDoses(:,1,4);

%=== fully vaccinated: people with 2 doses P&M or 1 dose J&J
fullyVaccinated = people(:,2,3) + people(:,1,4);

%=== get date of herd immunity
totalHerd       = herdFraction * state.population(us);
dHerd           = min(find(fullyVaccinated > totalHerd));

%=== problem if we did not reach herd immunity
if isempty(dHerd)
  error('Did not reach herd immunity ... need to increase final date of simulation.\n');
end
dateHerd        = char(dates(dHerd));

if figureNum <= 0
  fprintf('Herd Immunity reached on %s.\n', dateHerd);
  return;
end

%----------------------------------------------------------------------------------------------
%=== 1. PLOT DAILY ALLOCATIONS
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get dates
x3      = find(strcmp(date3, dates));  % first day of simulation
x4      = find(strcmp(date4, dates));  % last day of simulation
xLabels = dates(x3:x4);                % show these dates

%=== get data
if strcmp(entityName0, 'US')
  factor = 1000000;
else
  factor = 1000;
end
y(:,1) = dailyAllocations(x3:x4,3) / factor;   % allocation of pfizer + moderna
y(:,2) = dailyAllocations(x3:x4,4) / factor;   % allocation of J&J

%=== line plots
h      = plot(y, '-', 'Linewidth', 4);
set(h(1), 'Color', 'b'); subset(1) = h(1);
set(h(2), 'Color', 'k'); subset(2) = h(2);
hold on;

%=== set axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = 0; 
ymax = ax.YLim(2) + 0.5;
xlim([xmin xmax]);
ylim([ymin ymax]);

%=== get labels for plot
strTitle      = sprintf('Assumed Daily Dose Rates used in Simulation');
xTitle        = sprintf('Date');
if strcmp(entityName0, 'US')
  yTitle        = sprintf('%s Dose Administration Rate (Millions Per Day)', entityName0);
  strLegends(1) = {sprintf('Pfizer + Moderna (Current = %3.2fM Doses Per Day)', latestPM / factor)};
  strLegends(2) = {sprintf('J&J              (Current = %3.2fM Doses Per Day)', latestJJ / factor)};
  ytickformat('%2.1fM');
else
  yTitle        = sprintf('%s Dose Administration Rate (1000s Per Day)', entityName0);
  strLegends(1) = {sprintf('Pfizer + Moderna (Current = %3.2fK Doses Per Day)', latestPM / factor)};
  strLegends(2) = {sprintf('J&J              (Current = %3.2fK Doses Per Day)', latestJJ / factor)};
  ytickformat('%2.0fK');
end

%=== show peak J&J on labels
xJJ2 = find(strcmp(dateJJ2, xLabels));   % peak J&J
x4   = x4 - x3 + 1;
x3   = 1;
x    = [x3 xJJ2 x4];

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 2);
set(gca,'FontSize',  12);
set(gca,'XTick',x);  
set(gca,'XTickLabel',xLabels(x));
xlabel(xTitle,    'FontSize', 14);
ylabel(yTitle,    'FontSize', 14);
legend(strLegends,'FontSize', 14, 'Location','NorthWest', 'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle,   'FontSize', 16);

%----------------------------------------------------------------------------------------------
%=== 2. PLOT SIMULATION RESULTS
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== set interval to plot
interval = 7*round(numDays,-2)/100;
x1       = 1;                           % first day of actual data
x2       = find(strcmp(date3, dates));  % first day of simulation
x3       = dHerd;                       % stop plot at date of herd immunity
xLabels  = dates(x1:x3);                % show these dates
x        = x1:interval:x3;              % show these dates

%=== bar plot
clear y;
y(:,1) = people(x1:x3,1,4) / 1000000;      % people who have competed J&J
y(:,2) = people(x1:x3,2,3) / 1000000;      % people who have completed P&M
y(:,3) = people(x1:x3,1,3) / 1000000 ;     % people who have initiated P&M
h      = bar(y, 0.8, 'stacked');
set(h(1), 'FaceColor', 'g'); 
set(h(2), 'FaceColor', 'r'); 
set(h(3), 'FaceColor', 'b'); 
clear strLegends;
strLegends(1) = {sprintf('People Who Have Completed J&J Vaccination')};
strLegends(2) = {sprintf('People Who Have Completed Pfizer or Moderna Vaccination')};
strLegends(3) = {sprintf('People Who Have Initiated Pfizer or Moderna Vaccination')};
hold on;

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line showing start of simulation
x0 = x2;
y0 = sum(y(x0,:));
h  = plot([x0,x0], [ymin,y0], 'c-', 'LineWidth', 3); hold on; 
strLegends(4) = {sprintf('Simulation starts on          %s', date3)};

%=== horizonal line showing herd immunity
yHerd = totalHerd / 1000000; 
h     = plot([xmin,xmax], [yHerd,yHerd], 'g- ', 'LineWidth', 3); hold on; 
strLegends(5) = {sprintf('Herd Immmunity (%1.0f%%) achieved %s',  100*herdFraction, dateHerd)};

%=== get labels for plot
strTitle = sprintf('Simulation of %s Vaccination Rollout', entityName0);
xTitle   = sprintf('Date');
yTitle   = sprintf('Number of People Vaccinated');
yTitleR  = sprintf('As Percent of %s Population', entityName0);

%=== translate doses to percent of population for right axis
yTicksL  = get(gca,'YTick');
yTicksR  = 1000000 * yTicksL / state.population(us);
yTicksR  = 100     * yTicksR;
yLabelsR = cell(length(yTicksR), 1);
for i=1:length(yTicksR)
  yLabelsR(i) = {sprintf('%3.0f%%', yTicksR(i))};
end

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 2);
set(gca,'FontSize',  14);
set(gca,'XTick',x);  
set(gca,'XTickLabel',xLabels(x));
xlabel(xTitle,    'FontSize', 14);
ylabel(yTitle,    'FontSize', 14);
ytickformat('%2.1fM');
yyaxis right
set(gca,'YTickLabel',yLabelsR);
set(gca,'YTick',     yTicksL);
set(gca,'YColor', 'k');
ylabel(yTitleR,   'FontSize', 14);
legend(strLegends,'FontSize', 12, 'Location','NorthWest', 'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle,   'FontSize', 16);

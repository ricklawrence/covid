function computeMaCorrections(town, figureNum)
%
% compute corrections to moving averages due to holidays and put them in parameters 
% this version uses actual report dates from CT data structure
%
global parameters; 
if figureNum >= 0
  fprintf('\n--> computeMaCorrections\n');
end

%=== compute corrections since Thanksgiving
datenum1 = datenum('11/01/2020');            % useful if this a sunday so grid points are sundays
datenum1 = max(datenum1, town.datenums(1));  % so we can call this function with the vax dates
datenum2 = town.datenums(end);
datenums = datenum1:datenum2;
dates    = datestr(datenums, 'mm/dd/yyyy');
dates    = cellstr(dates);
numDates = length(dates);

%=== determine days covered by each report day (eg normal sunday covers 3 days)
numDaysInReport = zeros(numDates,1);
reportDatenums  = datenum(town.reportDates);
for d=2:numDates
  dd = find(reportDatenums == datenums(d));
  if ~isempty(dd)
    numDaysInReport(d) = reportDatenums(dd) - reportDatenums(dd-1);
  end
end

%=== compute moving average of numDaysInReport -- it should be 1.00 for every day
maWindow = parameters.maWindow;
y        = numDaysInReport;
MA       = movingAverage(y, maWindow);

%=== the MA should be all 1.0 -- problem dates are not 1.0 so correction factors are 1 / MA
days            = [1:numDates]';
index           = find(MA ~= 1 & days > maWindow+1);
problemDates    = dates(index);
problemFactors  = 1.0 ./ MA(index);

%=== save data
parameters.problemDates   = problemDates;
parameters.problemFactors = problemFactors;
if figureNum >= 0
  fprintf('Created %d problem dates due to holidays where we correct moving averages.\n', length(problemDates));
end

%=== check by correcting the MA (as we do in computeCovidFeatures)
MA1 = MA;
for d=1:length(parameters.problemDates)
  dateIndex      = find(strcmp(parameters.problemDates(d), dates));
  MA1(dateIndex) = parameters.problemFactors(d) * MA(dateIndex);
end

if figureNum < 1
  return;
end
problemDates;
problemFactors;

%------------------------------------
%=== PLOT DATA
figure(figureNum); fprintf('Figure %d.\n',   figureNum);

%=== bar and line plot
h = bar(y, 1.0);    set(h, 'FaceColor', 'c');  hold on;
h = plot(MA, 'r-'); set(h, 'LineWidth', 2);    hold on;
h = plot(MA1,'b:'); set(h, 'LineWidth', 2);    hold on;

%=== labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
interval = 7;
xTicks   = [1:interval:numDates]';
xLabels  = dates;
set(gca, 'Fontsize', 10);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel('Date', 'Fontsize', 14);
ylabel('Computed Moving Average', 'Fontsize', 14);
legend({'Days in Report', 'Uncorrected Moving Average', 'Corrected Moving Average'}, 'Location', 'NorthWest', 'Fontsize', 14);
title(sprintf('Corrections to Computed Moving Average (Last Date = %s)', char(dates(end))), 'Fontsize', 16);

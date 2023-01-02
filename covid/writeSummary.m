function writeSummary(town, county)
%
% write summary table for powerpoint
%
global parameters;
fprintf('\n--> writeSummary\n');

%=== get dates and days of week
N                    = parameters.stateDateOffset;
latestDate           = cellstr(datestr(town.datenums(end),   'mm/dd/yyyy'));    % latest date is the last day of data
todaysDate           = cellstr(datestr(town.datenums(end)+N, 'mm/dd/yyyy'));    % todays date is the download date plus date of our report
todaysDate1          = cellstr(datestr(town.datenums(end)+N, 'mmmm dd, yyyy')); % for powerpoint cover sheet
[~, latestDayOfWeek] = weekday(latestDate, 'long');
[~, todaysDayOfWeek] = weekday(todaysDate, 'long');

%=== use actual report dates to get date of previous report and days since previous report
previousDate           = town.reportDates(end-1);                        % previous report
[~, previousDayOfWeek] = weekday(previousDate, 'long');
n                      = datenum(town.reportDates(end)) - datenum(town.reportDates(end-1));

%=== for printing
latestDate   = char(latestDate);
todaysDate   = char(todaysDate);
todaysDate1  = char(todaysDate1);
previousDate = char(previousDate);

%=== get indices
townName   = 'Ridgefield';
countyName = 'Fairfield';
t          = find(strcmp(town.names,   townName));
c          = find(strcmp(county.names, countyName));

%=== insure positive numbers
town.newCases(:,t)   = max(town.newCases(:,t),0);
town.features(:,t,2) = max(town.features(:,t,2),0);
town.features(:,t,5) = max(town.features(:,t,5),0);

%=== write summary header
fprintf('--------------------------------------------------------------------------------------\n');
fprintf('Ridgefield COVID Summary\n%s, %s\n',     todaysDayOfWeek, todaysDate1);
fprintf('\n');

%=== write summary table to stdout -- this is pasted into a formatted excel table
fprintf('%s\t%s %s\t%s %s\n',       townName, latestDayOfWeek, latestDate, previousDayOfWeek, previousDate);
fprintf('%s\t%1.0f\t%1.0f\n', 'Number of New Cases Reported',          town.newCases(end,t),   town.newCases(end-n,t));
fprintf('%s\t%2.1f\t%2.1f\n', 'New Case Rate (per 100,000 Residents)', town.features(end,t,2), town.features(end-n,t,2));
fprintf('%s\t%2.1f\t%2.1f\n', 'New Test Rate (per 100,000 Residents)', town.features(end,t,4), town.features(end-n,t,4));
fprintf('%s\t%2.1f%%\t%2.1f%%\n', 'Test Positivity',                   town.features(end,t,5), town.features(end-n,t,5));
fprintf('\n');
fprintf('%s County\t%s %s\t%s %s\n', countyName, latestDayOfWeek, latestDate, previousDayOfWeek, previousDate);
fprintf('%s\t%1.0f\t%1.0f\n', 'Number of New Cases Reported',          county.newCases(end,c),     county.newCases(end-n,c));
fprintf('%s\t%2.1f\t%2.1f\n', 'New Case Rate (per 100,000 Residents)', county.features(end,c,2),   county.features(end-n,c,2));
fprintf('%s\t%2.1f\t%2.1f\n', 'New Test Rate (per 100,000 Residents)', county.features(end,c,4),   county.features(end-n,c,4));
fprintf('%s\t%2.1f%%\t%2.1f%%\n', 'Test Positivity',                   county.features(end,c,5),   county.features(end-n,c,5));
fprintf('%s\t%2.0f\t%2.0f\n', 'Currently Hospitalized',                county.hospitalized(end,c), county.hospitalized(end-n,c));

%=== write footnotes
strText1 = sprintf('%s', parameters.ctDataSource);
strText2 = sprintf('This report reflects data reported to the State through %s %s.', latestDayOfWeek, latestDate);
strText3 = sprintf('The New Case Rate, New Test Rate, and Test Positivity are computed using 7-day moving averages.');
strText4 = sprintf('NOTE: The Number of New Cases Reported for Sunday is the TOTAL over the last THREE DAYS (Friday, Saturday, Sunday).');
strText4 = sprintf('These data do not include Covid-19 tests administered at home and hence under-estimate the actual number of cases.');
fprintf('%s.  %s\n', strText1,strText2);
fprintf('%s\n', strText3);
fprintf('%s\n', strText4);
fprintf('\n');

%=== deaths
fprintf('--------------------------------------------------------------------------------------\n');
fprintf('There were %d deaths reported in %s\n',        town.newDeaths(end,t),   townName);
fprintf('There were %d deaths reported in %s County\n', county.newDeaths(end,c), countyName);
fprintf('--------------------------------------------------------------------------------------\n');

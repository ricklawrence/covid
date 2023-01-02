function writeSummaryVax(state, town)
%
% write vaccine summary table for powerpoint
%
global parameters;
fprintf('\n--> writeSummaryVax\n');

%=== get download date as the last date in the file
todaysDate           = char(state.vaxDates(end)); 
[~, todaysDayOfWeek] = weekday(todaysDate, 'long');

%=== get date of last valid report (us daily doses > 0)
us                   = find(strcmp('United States', state.names));
dailyUSdoses         = state.vaxDataD(:,us,2);
d                    = max(find(dailyUSdoses > 0));
latestDate           = char(state.vaxDates(d));      
[~, latestDayOfWeek] = weekday(latestDate, 'long');

%=== get indices
stateName  = 'Connecticut';
usName     = 'United States';
ct         = find(strcmp(state.names,  stateName));
us         = find(strcmp(state.names,  usName));
d          = find(strcmp(latestDate,   state.vaxDates));

%=== set feature indices for initiated and completed vaccinations
f1      = 25;    % 5+ population initiated
f2      = 26;    % 5+ population completed
f3      = 20;    % 18+ population boosted
f4      = 28;    % 5-11 population completed
string1 = 'Percent of Age 5+ Population Who Have Initiated Vaccination';  
string2 = 'Percent of Age 5+ Population Who Have Completed Vaccination';  
string3 = 'Percent of Age 18+ Population Who Have Received Booster Shot';  
string4 = 'Percent of Age 5-11 Population Who Have Completed Vaccination';  
string5 = 'Connecticut Rank Among 50 States and DC';  

%=== OPTIONALLY REPLACE CDC NUMBERS WITH CT DPH NUMBERS
replaceCDC = 0;
if replaceCDC
  state.vaxData(end,ct,f1) = 100*town.vaxDataN(end,170,9,1);
  state.vaxData(end,ct,f2) = 100*town.vaxDataN(end,170,9,2);
  state.vaxData(end,ct,f4) = 100*town.vaxDataN(end,170,7,2);
end

%=== get data 
initiatedCT = state.vaxData(end,ct,f1);
completedCT = state.vaxData(end,ct,f2);
boostedCT   = state.vaxData(end,ct,f3);
c511CT      = state.vaxData(end,ct,f4);
initiatedUS = state.vaxData(end,us,f1);
completedUS = state.vaxData(end,us,f2);
boostedUS   = state.vaxData(end,us,f3);
c511US      = state.vaxData(end,us,f4);

%=== compute ranks
stateIndex     = find(~strcmp(state.names, 'United States'));
stateNames     = state.names(stateIndex);
initiated      = state.vaxData(end,stateIndex,f1);
completed      = state.vaxData(end,stateIndex,f2);
boosted        = state.vaxData(end,stateIndex,f3);
c511           = state.vaxData(end,stateIndex,f4);
[~, sortIndex] = sort(initiated, 'descend');
rank           = find(strcmp(stateName, stateNames(sortIndex)));
stateRanks(1)  = rank;
[~, sortIndex] = sort(completed, 'descend');
rank           = find(strcmp(stateName, stateNames(sortIndex)));
stateRanks(2)  = rank;
[~, sortIndex] = sort(boosted, 'descend');
rank           = find(strcmp(stateName, stateNames(sortIndex)));
stateRanks(3)  = rank;
[~, sortIndex] = sort(c511, 'descend');
rank           = find(strcmp(stateName, stateNames(sortIndex)));
stateRanks(4)  = rank;

%=== convert dates to January 1, 2021
todaysDate = datestr(todaysDate, 'mmmm dd, yyyy');
latestDate = datestr(latestDate, 'mmmm dd, yyyy');

%=== print CT and US data for Excel table
fprintf('--------------------------------------------------------------------------------------\n');
fprintf('Connecticut Vaccination Summary\n%s, %s\n', todaysDayOfWeek, todaysDate);
fprintf('\n');

%=== write summary table to stdout -- this is pasted into a formatted excel table
fprintf('%s (as of %s %s)\t%s\t%s\n',stateName, latestDayOfWeek, latestDate, 'Cumulative', 'Daily');
fprintf('%s\t%2.0f\t%2.0f\n',        char(state.vaxLabels(2)), state.vaxData(d,ct,2),     state.vaxDataMA(d,ct,2));
fprintf('%s\t%3.2f%%\n',             string1,                  initiatedCT);
fprintf('%s\t%d\n',                  string5,                  stateRanks(1));
fprintf('%s\t%3.2f%%\n',             string2,                  completedCT);
fprintf('%s\t%d\n',                  string5,                  stateRanks(2));
fprintf('%s\t%3.2f%%\n',             string3,                  boostedCT);
fprintf('%s\t%d\n',                  string5,                  stateRanks(3));
fprintf('%s\t%3.2f%%\n',             string4,                  c511CT);
fprintf('%s\t%d\n',                  string5,                  stateRanks(4));
fprintf('\n');
fprintf('%s (as of %s %s)\t%s\t%s\n',usName, latestDayOfWeek, latestDate, 'Cumulative', 'Daily');
fprintf('%s\t%2.0f\t%2.0f\n',        char(state.vaxLabels(2)), state.vaxData(d,us,2),     state.vaxDataMA(d,us,2));
fprintf('%s\t%3.2f%%\n',             string1,                  initiatedUS);
fprintf('%s\t%3.2f%%\n',             string2,                  completedUS);
fprintf('%s\t%3.2f%%\n',             string3,                  boostedUS);
fprintf('%s\t%3.2f%%\n',             string4,                  c511US);

%=== write footnote
strText1 = sprintf('%s.', 'Data Source: https://covid.cdc.gov/covid-data-tracker/#vaccinations');
strText2 = sprintf('The Daily numbers are the most recent 7-day moving averages.');
fprintf('%s\n%s\n', strText1,strText2);
fprintf('--------------------------------------------------------------------------------------\n');

%=== compare age 5-11 vax rates between CDC (state) and DPH (town)
[state.vaxData(end,7,27) 100*town.vaxDataN(end,170,7,1)];
[state.vaxData(end,7,28) 100*town.vaxDataN(end,170,7,2)];

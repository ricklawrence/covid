function county = readDataFileJHUcounty(dataFileJHUCases, dataFileJHUDeaths, dataFileCounty)
%
% read covid county-level data from JHU 
%
global parameters;
fprintf('\n--> readDataFileJHUcounty\n');

%=== read cases
dataTable1 = readtable(dataFileJHUCases);
head(dataTable1,10);
numColumns1 = length(dataTable1.Properties.VariableNames);
numRows1    = length(dataTable1.Var1);
fprintf('Read %d columns and %d rows from %s.\n', numColumns1, numRows1, dataFileJHUCases);

%=== read deaths
dataTable2 = readtable(dataFileJHUDeaths);
head(dataTable2,10);
numColumns2 = length(dataTable2.Properties.VariableNames);
numRows2    = length(dataTable2.Var2);
fprintf('Read %d columns and %d rows from %s.\n', numColumns2, numRows2, dataFileJHUDeaths);
  
%=== read county data
dataTable3 = readtable(dataFileCounty);
head(dataTable3,10);
numColumns3 = length(dataTable3.Properties.VariableNames);
numRows3    = length(dataTable3.fips);
fprintf('Read %3d columns and %d rows from %s.\n', numColumns3, numRows3, dataFileCounty);

%=== create dates since readtable cannot process them in a header record
numDates = numColumns1 - 11;         % assume dates start here in case file
datenums = zeros(numDates,1);
datenums(1) = datenum('01/22/2020'); % assume this will always be the first date 
for d=2:numDates
  datenums(d) = datenums(d-1) + 1;   % assume all dates are present
end
dates = cellstr(datestr(datenums, 'mm/dd/yyyy'));

%=== get data
index1     = 2:numRows1;       % first row is jumbled header
index2     = 12:numColumns1;   % cases-file dates start here
fips       = dataTable1.Var5(index1);
cases      = table2array(dataTable1(index1, index2));

%=== deaths file may be out-dated -- only process it if it has same number of dates as case file
numDates1 = numColumns1 - 12;  % cases file
numDates2 = numColumns2 - 13;  % deaths file
if numDates2 == numDates1
  index3     = 13:numColumns2;   % deaths-file dates start here since there is extra column (population) !!
  deaths     = table2array(dataTable2(index1, index3));
else
  deaths     = NaN(length(index1), length(index2));
  fprintf('%s appears to be out of date -- replacing deaths with NaNs.\n', dataFileJHUDeaths);
end

%=== transpose cases and deaths so they are numDates x numNames
cases     = cases';
deaths    = deaths';
newCases  = computeNewCases(cases);
newDeaths = computeNewCases(deaths);

%=== no tests or hospitalizations here
[numDates, numNames] = size(cases);
newTests             = NaN(numDates, numNames);
testPositive         = NaN(numDates, numNames);
hospitalized         = NaN(numDates, numNames); 

%=== create names
space  = cell(numRows3,1); space(1:end) = {' County, '};
names0 = strcat(dataTable3.county0(1:end), space, dataTable3.state0(1:end));
names  = strcat(dataTable3.county0(1:end), space, dataTable3.State(1:end));

%=== join JHU to county data using fips
[~, i1, i2] = intersect(fips, dataTable3.fips);

%=== only keep data within specific date range
datenum1   = datenum(parameters.startDate);
datenum2   = datenum(parameters.endDate);
range      = datenum1 : datenum2;
logical    = ismember(datenums, range);
i3         = find(logical);
datenums   = datenums(i3);
dates      = dates(i3);
fprintf('Start Date = %s\n', char(dates(1)));
fprintf('Last  Date = %s\n', char(dates(end)));

%=== save data in usual format
county.level        = 'CountyUS';
county.entityFormat = '%s';
county.firstDate    = char(dates(1));
county.lastDate     = char(dates(end));
county.numDates     = length(dates);
county.numNames     = length(i1);
county.datenums     = datenums;
county.dates        = dates;
county.names0       = names0(i2);
county.names        = names(i2);
county.stateNames0  = dataTable3.state0(i2);
county.stateNames   = dataTable3.State(i2);
county.population   = dataTable3.population(i2);
county.fips         = dataTable3.fips(i2);
county.cumCases     = cases(i3,i1);
county.newCases     = newCases(i3,i1);
county.newTests     = newTests(i3,i1);
county.newDeaths    = newDeaths(i3,i1);
county.hospitalized = hospitalized(i3,i1);
county.testPositive = testPositive(i3,i1);

%=== check
return;
i = find(strcmp(county.names, 'Fairfield County, Connecticut'));
county.names0(i)
county.population(i)
county.newCases(end-10:end,i)
county.newDeaths(end-10:end,i)

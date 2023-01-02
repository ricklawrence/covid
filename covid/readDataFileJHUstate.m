   function  data = readDataFileJHUstate(dataFile, stateData)
%
% read US and state-level cases and tests from JHU state-level github file
% unlike covidtracking, this file has no deaths and hospitalization data
%
global parameters;
fprintf('\n--> readDataFileJHUstate\n');
debug = 0;

%=== read file as a table
dataTable = readtable(dataFile);
head(dataTable,8);

%=== summary
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dataTable.date);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows, dataFile);

%=== get dates
dates0            = dataTable.date;
datenums          = datenum(dates0);

%=== JHU sometimes uses data format '3/17/0021' so need to correct datenums
problem           = find(datenums < datenum('01/01/2020'));
if length(problem) > 0
  correction        = datenum('01/01/2020') - datenum('01/01/0020');
  datenums(problem) = datenums(problem) + correction;
  fprintf('Fixed %d dates with format 01/01/20', length(problem));
end
dates = cellstr(datestr(datenums, 'mm/dd/yyyy'));

%=== only keep data within specific date range
datenum1   = datenum(parameters.startDate);
datenum2   = datenum(parameters.endDate);
range      = datenum1 : datenum2;
logical    = ismember(datenums, range);
index      = find(logical);

%=== get all short names
names0     = dataTable.state;

%=== sort all data by date and then name, retaining index into FULL DATA
[~, sortIndex] = sort(datenums(index));
index          = index(sortIndex);
[~, sortIndex] = sort(names0(index));
index          = index(sortIndex);

%=== save first and last date in file
data.firstDate = char(dates(index(1)));
data.lastDate  = char(dates(index(end)));
fprintf('Start Date = %s\n', data.firstDate);
fprintf('Last  Date = %s\n', data.lastDate);

%=== create 2D arrays as numDates x numNames
data.numDates = length(unique(dates(index)));
data.numNames = length(unique(names0(index)));
datenums2D    = reshape(datenums(index), data.numDates, data.numNames);
dates2D       = reshape(dates(index),    data.numDates, data.numNames);
names02D      = reshape(names0(index),   data.numDates, data.numNames);
data.datenums = datenums2D(:,1);
data.dates    = dates2D(:,1);
data.names0   = names02D(1,:)';

%=== get full data as 2D arrays (numDates x numNames)
cumCases      = reshape(dataTable.cases_conf_probable(index),  data.numDates, data.numNames);     % starts 1/29/2020 (problem with FL)
cumCases      = reshape(dataTable.cases_confirmed(index),      data.numDates, data.numNames);     % starts 4/9/2021
cumTests      = reshape(dataTable.tests_combined_total(index), data.numDates, data.numNames);

%=== get new cases and new tests
newCases      = computeNewCases(cumCases);
newTests      = computeNewCases(cumTests);

%=== we are doing states ... save only the actual states + DC
if ~isempty(stateData)
  fprintf('Processing data for all states.\n');
  data.level        = 'State';
  data.entityFormat = 'State of %s';
  [~, i1]           = intersect(data.names0, stateData.Name0);
  data.names0       = data.names0(i1);
  data.cumCases     = cumCases(:,i1);
  data.newCases     = newCases(:,i1);
  data.newTests     = newTests(:,i1);
  data.numNames     = length(data.names0);
  [~, i2]           = intersect(stateData.Name0, data.names0);
  data.names        = stateData.Name(i2);
  data.population   = stateData.Population(i2);
  data.density      = stateData.Density(i2);
  if debug
    [data.newCases(end-28:end,7) data.newTests(end-28:end,7)]
  end
end

%=== if we are doing US ... sum data over all states and territories
if isempty(stateData)
  fprintf('Processing data for US by summing over all state and territories.\n');
  data.level        = 'Country';
  data.entityFormat = '%s';
  data.names0       = {'US'};
  data.names        = {'United States'};
  data.numNames     = 1;
  data.cumCases     = nansum(cumCases, 2);
  data.newCases     = nansum(newCases, 2);
  data.newTests     = nansum(newTests, 2);
  data.names        = {'United States'};
  data.population   = 331002651;
  if debug
    [data.newCases(end-28:end,1) data.newTests(end-28:end,1)]
  end
end

%=== compute test positivity
data.testPositive   = data.newCases ./ data.newTests; 

%=== no deaths or hospitalization data
data.newDeaths    = NaN(data.numDates, data.numNames);
data.hospitalized = NaN(data.numDates, data.numNames);
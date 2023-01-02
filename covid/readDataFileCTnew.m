function  data1 = readDataFileCT(data0, dataFile, townData)
%
% read updated covid data files as of 6/27/2022
%
global parameters;
fprintf('\n--> readDataFileCTnew\n');

%=== read file as a table
dataTable = readtable(dataFile);
head(dataTable,8);

%=== figure out the level (state, county, town)
fields     = dataTable.Properties.VariableNames;
firstField = char(fields(2));
if strcmp(firstField, 'cumulative_cases')
  data.level = 'StateCT';
  data.entityFormat  = 'State of %s';
  dates      = dataTable.report_date;
elseif strcmp(firstField, 'county')
  data.level = 'County';
  data.entityFormat  = '%s County';
  dates      = dataTable.report_date;
elseif strcmp(firstField, 'city')
  data.level = 'Town';
  data.entityFormat  = 'Town of %s';
  dates      = dataTable.report_date;
end

%=== summary
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dates);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows, dataFile);

%=== get names
all           = 1:numRows;
if strcmp(data.level, 'StateCT')
  names0(all,1) = {'Connecticut'};
elseif strcmp(data.level, 'County')
  names0        = dataTable.county;
elseif strcmp(data.level, 'Town')
  names0        = dataTable.city;
end

%=== convert dates to cell strings
datenums   = datenum(dates);
dates      = cellstr(datestr(datenums, 'mm/dd/yyyy'));

%=== shift dates to reflect previous date convention
d           = find(datenums >= datenum('05/10/2021'));
datenums(d) = datenums(d) - parameters.stateDateOffset;
dates       = cellstr(datestr(datenums, 'mm/dd/yyyy'));

%=== only keep data within specific date range
datenum1   = datenum(parameters.startDate);
datenum2   = datenum(parameters.endDate);
range      = datenum1 : datenum2;
logical    = ismember(datenums, range);
index      = find(logical);

%=== remove not_available
i = find(strcmp(names0, 'Not_available'));
index = setdiff(index,i);
i = find(strcmp(names0, 'not_available'));
index = setdiff(index,i);

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
data.names    = data.names0;

%=== get full data as 2D arrays (numDates x numNames)
if strcmp(data.level, 'StateCT')
  cumCases        = reshape(dataTable.cumulative_cases(index),            data.numDates, data.numNames);
  cumTests        = reshape(dataTable.cumulative_tests_reportable(index), data.numDates, data.numNames);
  cumPositives    = cumCases;
  cumDeaths       = reshape(dataTable.cumulative_deaths(index),           data.numDates, data.numNames);
  hospitalized    = reshape(dataTable.census_today(index),                data.numDates, data.numNames);
elseif strcmp(data.level, 'County')
  cumCases        = reshape(dataTable.cumulative_cases(index),            data.numDates, data.numNames);
  cumTests        = reshape(dataTable.cumulative_tests_reportable(index), data.numDates, data.numNames);
  cumPositives    = cumCases;
  cumDeaths       = reshape(dataTable.cumulative_deaths(index),           data.numDates, data.numNames);
  hospitalized    = reshape(dataTable.census_today(index),                data.numDates, data.numNames);
  population      = reshape(dataTable.county_population(index),           data.numDates, data.numNames);
elseif strcmp(data.level, 'Town')
  cumCases        = reshape(dataTable.cumulative_cases(index),            data.numDates, data.numNames);
  cumTests        = reshape(dataTable.cumulative_tests_reportable(index), data.numDates, data.numNames);
  cumPositives    = cumCases;
  cumDeaths       = reshape(dataTable.cumulative_deaths(index),           data.numDates, data.numNames);
  hospitalized    = NaN(data.numDates, data.numNames);
  population      = reshape(dataTable.city_population(index),             data.numDates, data.numNames);
end

%=== fix NaNs in county hospitalized
if strcmp(data.level, 'County')
  for d=1:data.numDates
    if isnan(hospitalized(d,1))
      hospitalized(d,:) = hospitalized(d-1,:);
    end
  end
end

%=== get population  
if strcmp(data.level, 'StateCT')
  data.population  = 3565287;
elseif strcmp(data.level, 'County')
  data.population  = population(end,:)';
elseif strcmp(data.level, 'Town')
  data.population  = population(end,:)';
end

%=== if this is CT town data, get the county and population for each town
if strcmp(data.level, 'Town')
  data.countyNames = cell(data.numNames,1);
  for t=1:data.numNames
    i = find(strcmp(data.names(t), townData.Name));
    data.countyNames(t) = townData.CountyName(i);
    data.population(t)  = townData.Population(i);  % replace town populations with populations read from townData
 end
end

%=== save data as new cases etc
data.cumCases      = cumCases;
data.newCases      = computeNewCases(cumCases);
data.newTests      = computeNewCases(cumTests);
data.newPositives  = computeNewCases(cumPositives);
data.newDeaths     = computeNewCases(cumDeaths);
data.hospitalized  = hospitalized;                   % this is currently hospitalized ... no need to difference
data.testPositive  = data.newCases ./ data.newTests;
data.reportDates   = data.dates;

%------------------------------------------------------------------------------------------------------------
%=== merge new data with archived data -- set date to switch from archived to new data
switchDate                = data0.dates(end);                 % 06/23/2022
d1                        = find(strcmp(data0.dates, switchDate));
i1                        = find(data.datenums  >  datenum(switchDate));
i2                        = [d1+1 : d1+length(i1)]';
fprintf('Switching from archived data to new data on %s\n', char(switchDate));

%=== start with archived data and concatenate new data starting at switchDate
data1 = data0; 
%i1 = [];                  % check than we can replicate previous results
if ~isempty(i1)
  data1.dates(i2)           = data.dates(i1);
  data1.cumCases(i2,:)      = data.cumCases(i1,:);
  data1.newCases(i2,:)      = data.newCases(i1,:);
  data1.newTests(i2,:)      = data.newTests(i1,:);
  data1.newPositives(i2,:)  = data.newPositives(i1,:);
  data1.newDeaths(i2,:)     = data.newDeaths(i1,:);
  data1.hospitalized(i2,:)  = data.hospitalized (i1,:);
  data1.testPositive(i2,:)  = data.testPositive(i1,:);
  data1.lastDate            = char(data1.dates(end));
  data1.datenums            = datenum(data1.dates);
  data1.numDates            = length(data1.dates);

  %=== add report dates
  d1                        = find(strcmp(data0.reportDates, switchDate));
  i1                        = find(data.datenums  >  datenum(switchDate));
  i2                        = [d1+1 : d1+length(i1)]';
  data1.reportDates(i2)     = data.reportDates(i1);
end

%=== check
if strcmp(data.level, 'Town')
  t = find(strcmp(data.names, 'Ridgefield'));
  data.newCases(:,t);
  data.population(t);
end


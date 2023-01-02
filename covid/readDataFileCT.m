function  data = readDataFileCT(dataFile, townData)
%
% read covid data files from 
% https://data.ct.gov/stories/s/COVID-19-data/wa3g-tfvc/#data-library
%
global parameters;
fprintf('\n--> readDataFileCT\n');

%=== read file as a table
dataTable = readtable(dataFile);
head(dataTable,8);

%=== figure out the level (state, county, town)
fields     = dataTable.Properties.VariableNames;
firstField = char(fields(2));
if strcmp(firstField, 'State')
  data.level = 'StateCT';
  data.entityFormat  = 'State of %s';
  dates      = dataTable.Date;
elseif strcmp(firstField, 'CountyCode')
  data.level = 'County';
  data.entityFormat  = '%s County';
  dates      = dataTable.DateUpdated;
elseif strcmp(firstField, 'TownNumber')
  data.level = 'Town';
  data.entityFormat  = 'Town of %s';
  dates      = dataTable.LastUpdateDate;
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
  names0        = dataTable.County;
elseif strcmp(data.level, 'Town')
  names0        = dataTable.Town;
end

%=== convert dates to cell strings
datenums   = datenum(dates);
dates      = cellstr(datestr(datenums, 'mm/dd/yyyy'));

%=== on 5/10/2021, the State shifted the final date in the file to the creation date (it had been one day earlier)
d           = find(datenums >= datenum('05/10/2021'));
datenums(d) = datenums(d) - 1;
dates       = cellstr(datestr(datenums, 'mm/dd/yyyy'));

%=== on 6/22/2022, the State county dates started lagging the state and town dates by 1 day -- shift them forward
%=== THEY FIXED THIS
%if strcmp(data.level, 'County')
%  datenums = datenums + 1;
%  dates    = cellstr(datestr(datenums, 'mm/dd/yyyy'));
%  fprintf('Corrected County dates.\n');
%end

%=== only keep data within specific date range
datenum1   = datenum(parameters.startDate);
datenum2   = datenum(parameters.endDate);
%datenum2   = max(datenums);                  % OVERRIDE END DATA FOR CT DATA
range      = datenum1 : datenum2;
logical    = ismember(datenums, range);
index      = find(logical);

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
  cumCases        = reshape(dataTable.TotalCases(index),            data.numDates, data.numNames);
  cumTests        = reshape(dataTable.COVID_19TestsReported(index), data.numDates, data.numNames);
  cumPositives    = cumCases;
  cumDeaths       = reshape(dataTable.TotalDeaths(index),           data.numDates, data.numNames);
  hospitalized    = reshape(dataTable.HospitalizedCases(index),     data.numDates, data.numNames);
  caseRates       = NaN(data.numDates, data.numNames);
elseif strcmp(data.level, 'County')
  cumCases        = reshape(dataTable.TotalCases(index),            data.numDates, data.numNames);
  cumTests        = NaN(data.numDates, data.numNames);
  cumPositives    = cumCases;
  cumDeaths       = reshape(dataTable.TotalDeaths(index),           data.numDates, data.numNames);
  hospitalized    = reshape(dataTable.HospitalizedCases(index),     data.numDates, data.numNames);
  caseRates       = reshape(dataTable.TotalCaseRate(index),         data.numDates, data.numNames);
elseif strcmp(data.level, 'Town')
  cumCases        = reshape(dataTable.TotalCases(index),            data.numDates, data.numNames);
  cumTests        = reshape(dataTable.NumberOfTests(index),         data.numDates, data.numNames);
  cumPositives    = reshape(dataTable.NumberOfPositives(index),     data.numDates, data.numNames); % different than cum cases
  cumDeaths       = reshape(dataTable.TotalDeaths(index),           data.numDates, data.numNames);
  hospitalized    = NaN(data.numDates, data.numNames);
  caseRates       = reshape(dataTable.CaseRate(index),              data.numDates, data.numNames);
end

%=== infer population from CaseRates and ConfirmedCases  
if strcmp(data.level, 'StateCT')
  data.population  = 3565287;
elseif strcmp(data.level, 'County')
  population       = round(100000*cumCases ./ caseRates);
  data.population  = population(end,:)';
elseif strcmp(data.level, 'Town')
  population       = round(100000*cumCases ./ caseRates);
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
data.cumCases     = cumCases;
data.newCases     = computeNewCases(cumCases);
data.newTests     = computeNewCases(cumTests);
data.newPositives = computeNewCases(cumPositives);
data.newDeaths    = computeNewCases(cumDeaths);
data.hospitalized = hospitalized;                   % this is currently hospitalized ... no need to difference
data.testPositive = data.newCases ./ data.newTests;

%---------------------------------------------------------------------------------------------
% DEAL WITH MISSING DATES IN CT DATA FILES

%=== first save the original report dates
data.reportDates = data.dates;

%=== check that there are no missing dates
fileDatenums    = data.datenums(:,1);
allDatenums     = [fileDatenums(1) : fileDatenums(end)]';
missingDates    = setdiff(allDatenums, fileDatenums);
numMissingDates = length(missingDates);
fprintf('Found %d missing dates.\n', numMissingDates);
if numMissingDates == 0
  return
end

%=== build index that copies cumulative data from previous day into missing days
numDates = length(allDatenums);
index    = zeros(numDates,1);
for d=1:numDates
  j = find(allDatenums(d) == fileDatenums);
  if ~isempty(j)
    index(d) = j;            % existing date -- take existing value
  else
    index(d) = index(d-1);   % missing date -- take previous value
  end
end

%=== copy all data -- note that we map the cumulative values, so need to compute difference again
data.numDates     = length(allDatenums);
data.datenums     = allDatenums;
data.dates        = cellstr(datestr(data.datenums, 'mm/dd/yyyy'));
data.cumCases     = cumCases(index,:);
data.newCases     = computeNewCases(cumCases(index,:));
data.newTests     = computeNewCases(cumTests(index,:));
data.newPositives = computeNewCases(cumPositives(index,:));   % NOT USED
data.newDeaths    = computeNewCases(cumDeaths(index,:));
data.hospitalized = data.hospitalized(index,:);               % this is currently hospitalized
data.testPositive = data.newCases ./ data.newTests;
data.testPositive1= data.newPositives ./ data.newTests;       % NOT USED

%---------------------------------------------------------------------------------------------
% FIX ONGOING PROBLEMS WITH DPH DATA

%=== FIX PROBLEM WITH TOWN TEST DATA FOR SUNDAY 1/24/2021
%=== replace new tests on this day 3 times the MA up to previous day
if strcmp(data.level, 'Town')
  date0     = '01/24/2021';
  d         = find(strcmp(date0, data.dates));
  t         = find(strcmp('Ridgefield', data.names));
  newTests0 = data.newTests;
  MA        = movingAverage(newTests0, parameters.maWindow);
  newTests  = 3*MA(d-1,:);                              % 3 because it is Sunday covering 3 days
  data.newTests(d,:) = round(newTests);
  data.testPositive  = data.newCases ./ data.newTests;  % recompute test positivity
  fprintf('*** Fixed test data problem on %s.  Ridgefield new tests changed from %d to %d.\n', ...
           date0, newTests0(d,t), data.newTests(d,t));
end

%=== ON SUNDAY 4/3/2022, DPH NO LONGER REQUIRES REPORTING OF NEGATIVE ANTIGEN TESTS
%=== THIS DRAMATICALLY REDUCED DAILY NUMBER OF TESTS ON THIS DAY
if strcmp(data.level, 'StateCT')
  date0     = '04/03/2022';
  d         = find(strcmp(date0, data.dates));
  t         = find(strcmp('Connecticut', data.names));
  newTests0 = data.newTests;
  MA        = movingAverage(newTests0, parameters.maWindow);
  newTests  = 3*MA(d-1,:);                              % 3 because it is Sunday covering 3 days
  data.newTests(d,:) = round(newTests);
  data.testPositive  = data.newCases ./ data.newTests;  % recompute test positivity
  fprintf('*** DPH test definition changed on %s.  Connecticut new tests changed from %d to %d.\n', ...
           date0, newTests0(d,t), data.newTests(d,t));
end

%=== check
if strcmp(data.level, 'Town')
  t = find(strcmp(data.names, 'Ridgefield'));
  data.newCases(:,t);
  data.population(t);
end

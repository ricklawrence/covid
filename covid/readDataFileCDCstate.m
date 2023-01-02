 function  data = readDataFileCDCstate(dataFile, stateData)
%
% read state-level cases and deaths from CDC file
%
global parameters;
fprintf('\n--> readDataFileCDCstate\n');
debug = 0;

%=== read file as a table
dataTable = readtable(dataFile);
head(dataTable,8);

%=== summary
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dataTable.submission_date);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows, dataFile);

%=== get dates
dates0     = dataTable.submission_date;
datenums   = datenum(dates0);
dates      = cellstr(datestr(datenums, 'mm/dd/yyyy'));

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
cumCases      = reshape(dataTable.tot_cases(index), data.numDates, data.numNames);
cumDeaths     = reshape(dataTable.tot_death(index), data.numDates, data.numNames);

%=== get new cases and new deaths
newCases      = computeNewCases(cumCases);
newDeaths     = computeNewCases(cumDeaths);

%=== add NYC to NY and zero out NYC to preserve sum over entities
nyc              = find(strcmp(data.names0, 'NYC'));
ny               = find(strcmp(data.names0, 'NY'));
cumCases(:,ny)   = cumCases(:,ny)  + cumCases(:,nyc);
newCases(:,ny)   = newCases(:,ny)  + newCases(:,nyc);
newDeaths(:,ny)  = newDeaths(:,ny) + newDeaths(:,nyc);
cumCases(:,nyc)  = 0;
newCases(:,nyc)  = 0;
newDeaths(:,nyc) = 0;

%=== we are doing states ... save only the actual states + DC
if ~isempty(stateData)
  fprintf('Processing data for all states.\n');
  data.level        = 'State';
  data.entityFormat = 'State of %s';
  [~, i1]           = intersect(data.names0, stateData.Name0);
  data.names0       = data.names0(i1);
  data.cumCases     = cumCases(:,i1);
  data.newCases     = newCases(:,i1);
  data.newDeaths    = newDeaths(:,i1);
  data.numNames     = length(data.names0);
  [~, i2]           = intersect(stateData.Name0, data.names0);
  data.names        = stateData.Name(i2);
  data.population   = stateData.Population(i2);
  data.density      = stateData.Density(i2);
  if debug
    [data.newCases(end-28:end,7) data.newDeaths(end-28:end,7)]
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
  data.newDeaths    = nansum(newDeaths, 2);
  data.names        = {'United States'};
  data.population   = 331002651;
  if debug
    [data.newCases(end-28:end,1) data.newTests(end-28:end,1)]
  end
end

%=== no tests or hospitalization data
data.newTests     = NaN(data.numDates, data.numNames);
data.hospitalized = NaN(data.numDates, data.numNames);
data.testPositive = NaN(data.numDates, data.numNames);

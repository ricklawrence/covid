function  data = readMobilityData(dataFile, stateData)
%
% read google mobility data from 
% https://www.google.com/covid19/mobility/
%
% run script makeUSMobilityFile.bash to save only US data (avoids problem with reading county name)
%
global parameters;
parameters.endDateMobility = '12/31/2021';              % last data for Google mobility data
fprintf('\n--> readMobilityData\n');

%=== read file as a table -- need format because 3rd and 4th columns get read as floats, not strings (no idea why)
dataTable = readtable(dataFile, 'format', '%s%s%s%s%s%s%s%s%s%f%f%f%f%f%f'); 
head(dataTable,10);

%=== summary
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dataTable.country_region_code);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows, dataFile);

%=== parse 2020-02-15 into cellstr dates ... use unique values to speed it up
dates0         = dataTable.date;
[~,i1,i2]      = unique(dates0);
uniqueDatenums = datenum(dates0(i1));
uniqueDates    = cellstr(datestr(uniqueDatenums, 'mm/dd/yyyy'));
dates          = uniqueDates(i2);
datenums       = uniqueDatenums(i2);

%=== sort by date
[sortValues, sortIndex] = sort(datenums);

%=== only keep data before parameters.endDateMobility ... allows us to roll back data
datenum2  = datenum(parameters.endDateMobility);
datenums2 = datenums(sortIndex);
index2    = find(datenums2 <= datenum2);
sortIndex = sortIndex(index2);

%=== this is sorted index
index    = sortIndex;

%=== save first and last date in file
data.numDates  = length(unique(dates(index)));
data.firstDate = char(dates(index(1)));
data.lastDate  = char(dates(index(end)));
fprintf('Start Date = %s\n', data.firstDate);
fprintf('Last  Date = %s\n', data.lastDate);

%=== save data
data.level         = 'Mobility';
data.Number        = length(index);
data.Date          = dates(index);
data.Datenum       = datenums(index);
data.countryName   = dataTable.country_region(index);
data.stateName     = dataTable.sub_region_1(index);
data.countyName    = dataTable.sub_region_2(index);
data.countyName1   = erase(data.countyName, ' County'); % remove trailing County so these names match covid data
data.fips          = dataTable.fips(index);
data.mobility(:,1) = dataTable.retail_and_recreation_percent_change_from_baseline(index);
data.mobility(:,2) = dataTable.grocery_and_pharmacy_percent_change_from_baseline(index);
data.mobility(:,3) = dataTable.parks_percent_change_from_baseline(index);
data.mobility(:,4) = dataTable.transit_stations_percent_change_from_baseline(index);
data.mobility(:,5) = dataTable.workplaces_percent_change_from_baseline(index);
data.mobility(:,6) = dataTable.residential_percent_change_from_baseline(index);
data.labels        = cell(6,1);
data.labels(1)     = {'Retail and Recreation'};
data.labels(2)     = {'Grocery and Pharmacy'};
data.labels(3)     = {'Parks'};
data.labels(4)     = {'Transit Stations'};
data.labels(5)     = {'Workplaces'};
data.labels(6)     = {'Residential'};

%=== if the state is missing, the data is for the entire US
index1 = ismissing(data.stateName);
data.stateName(index1) = {'MISSING'};

%=== if the county is missing, the data is for the entire state
index2 = ismissing(data.countyName);
data.countyName(index2) = {'MISSING'};
data.countyName1        = erase(data.countyName, ' County'); % remove trailing County so these names match covid data

%=== save unique county,state names and unique fips (used to join covid and mobility features)
space                  = cell(data.Number,1); space(1:end) = {' County, '};
data.Name              = strcat(data.countyName1(1:end), space, data.stateName(1:end));
[~, i0]                = unique(data.Name);
data.numUniqueNames    = length(i0);
data.uniqueNames       = data.Name(i0);
data.uniqueFips        = data.fips(i0);

%=== get unique state names (remove MISSING)
uniqueNames            = unique(data.stateName);
uniqueNames            = setdiff(uniqueNames, 'MISSING');
data.uniqueStateNames0 = uniqueNames; % initialize state abbreviations
data.uniqueStateNames  = uniqueNames;
data.numStates         = length(uniqueNames);

%=== add state abbreviations from stateData
for s=1:data.numStates
  i = find(strcmp(data.uniqueStateNames(s), stateData.Name));
  data.uniqueStateNames0(s) = stateData.Name0(i);
end

%=== check that all states have same number of dates
numDatesByState = zeros(data.numStates,1);
for s=1:length(data.uniqueStateNames)
  index3             = find(strcmp(data.uniqueStateNames(s), data.stateName) & strcmp(data.countyName, 'MISSING'));
  numDatesByState(s) = length(index3);
end
minNumDates = min(numDatesByState);
maxNumDates = max(numDatesByState);
if minNumDates ~= maxNumDates
  error(sprintf('Inconsistency in number of dates over states: min = %d max = %d \n', ...
                 minNumDates, maxNumDates));
end
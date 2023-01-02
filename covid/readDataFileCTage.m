function  data = readDataFileCTage(dataFile)
%
% read CT age file
%
global parameters;
fprintf('\n--> readDataFileCTAge\n');

%=== read file as a table
dataTable = readtable(dataFile);
head(dataTable,18);

%===  get dates
data.level = 'StateAge';
dates      = dataTable.DateUpdated;

%=== summary
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dates);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows, dataFile);

%=== convert dates to cell strings
dates      = dataTable.DateUpdated;
datenums   = datenum(dates);
dates      = cellstr(datestr(datenums, 'mm/dd/yyyy'));

%=== on 5/10/2021, the State shifted the final date in the file to the creation date (it had been one day earlier)
d           = find(datenums >= datenum('05/10/2021'));
datenums(d) = datenums(d) - 1;
dates       = cellstr(datestr(datenums, 'mm/dd/yyyy'));

%=== only keep data within specific date range
datenum1   = datenum(parameters.startDate);
datenum2   = datenum(parameters.endDate);
%datenum2   = max(datenums);                  % OVERRIDE END DATA FOR CT DATA
range      = datenum1 : datenum2;
logical    = ismember(datenums, range);
index      = find(logical);

%=== sort all data by date retaining index into FULL DATA
[~, sortIndex] = sort(datenums(index));
index          = index(sortIndex);

%=== save first and last date in file
data.firstDate = char(dates(index(1)));
data.lastDate  = char(dates(index(end)));
fprintf('Start Date = %s\n', data.firstDate);
fprintf('Last  Date = %s\n', data.lastDate);

%=== create 2D arrays as numDates x numLabels (need to transpose)
data.numDates     = length(unique(dates(index)));
data.numAgeLabels = 9;                             % always 9 age groups
datenums2D        = reshape(datenums(index), data.numAgeLabels, data.numDates);
dates2D           = reshape(dates(index),    data.numAgeLabels, data.numDates);
datenums2D        = datenums2D';
dates2D           = dates2D';
data.datenums     = datenums2D(:,1);
data.dates        = dates2D(:,1);

%=== get full data as numDates x numLabels (need to transpose)
cumCases  = reshape(dataTable.TotalCases(index),  data.numAgeLabels, data.numDates);
cumDeaths = reshape(dataTable.TotalDeaths(index), data.numAgeLabels, data.numDates);
cumCases  = cumCases';
cumDeaths = cumDeaths';

%=== save data
data.cumCasesByAgeGroup  = cumCases;
data.cumDeathsByAgeGroup = cumDeaths;
data.newCasesByAgeGroup  = computeNewCases(cumCases);
data.newDeathsByAgeGroup = computeNewCases(cumDeaths);
data.AgeGroupLabels      = {'0-9'; '10-19'; '20-29'; '30-39'; '40-49'; '50-59'; '60-69'; '70-79'; '80 and older'};

%---------------------------------------------------------------------------------------------
% DEAL WITH MISSING DATES

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
data.numDates            = length(allDatenums);
data.datenums            = allDatenums;
data.dates               = cellstr(datestr(data.datenums, 'mm/dd/yyyy'));
data.cumCasesByAgeGroup  = cumCases(index,:);
data.cumDeathsByAgeGroup = cumDeaths(index,:);
data.newCasesByAgeGroup  = computeNewCases(cumCases(index,:));
data.newDeathsByAgeGroup = computeNewCases(cumDeaths(index,:));

%=== check
data.newCasesByAgeGroup(end,:);
data.newDeathsByAgeGroup(end,:);
function tract  = readVaccineDataTract(dataFile, town)
%
% read Connecticut census-tract vaccination data
%
fprintf('\n--> readVaccineDataTract\n');

%=== read file as a table
dataTable  = readtable(dataFile);
head(dataTable, 10);
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dataTable.Town);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows, dataFile);

%---------------------------------------------------------
%=== get dates and fips codes
dates      = dataTable.DateUpdate;
datenums   = datenum(dates);
dates      = cellstr(datestr(datenums, 'mm/dd/yyyy'));
fips0      = dataTable.GEOID10;
townNames0 = dataTable.Town;

%=== only keep dates after 5/20
filter     = find(datenums >= datenum('05/20/2021'));

%=== sort all data by date and then fips, retaining index into full data
[~, sortIndex] = sort(datenums(filter));
index          = filter(sortIndex);
[~, sortIndex] = sort(fips0(index));
index          = index(sortIndex);
fprintf('Most recent date = %s\n', datestr(max(datenum(dataTable.DateUpdate(index))), 'mm/dd/yyyy'));

%=== create 2D arrays as numDates x numNames
numDates    = length(unique(dates(index)));
numNames    = length(unique(fips0(index)));
dates2D     = reshape(dates(index), numDates, numNames);
fips2D      = reshape(fips0(index), numDates, numNames);
townNames2D = reshape(townNames0(index), numDates, numNames);
dates       = dates2D(:,1);
fips        = fips2D(1,:)';
townNames   = townNames2D(1,:)';

%=== save dates etc
tract.level          = 'Census Tract';
tract.stateName      = 'Connecticut';
tract.vaxDates       = dates;
tract.numNames       = length(townNames);
tract.townNames      = townNames;
tract.countyNames    = cell(tract.numNames, 1);
tract.fips           = fips;

%=== get county names from town structure
for t=1:tract.numNames
  tt = find(strcmp(tract.townNames(t), town.names));
  if ~isempty(tt)
    tract.countyNames(t) = town.countyNames(tt);
  else
    tract.countyNames(t) = {'MISSING'};
  end
end

%=== allocate arrays to hold 2D data (numDates x numNames)
numMetrics = 4;
vaxDataN   = NaN(numDates, numNames, numMetrics);

%=== save full data 2D arrays for all ages
vaxDataN(:,:,1)   = reshape(dataTable.PercentOfIndividualsWhoInitiatedVaccination_Ages16_(index),   numDates, numNames);
vaxDataN(:,:,2)   = reshape(dataTable.PercentOfIndividualsWhoInitiatedVaccination_Ages16_44(index), numDates, numNames);
vaxDataN(:,:,3)   = reshape(dataTable.PercentOfIndividualsWhoInitiatedVaccination_Ages45_64(index), numDates, numNames);
vaxDataN(:,:,4)   = reshape(dataTable.PercentOfIndividualsWhoInitiatedVaccination_Ages65_(index),   numDates, numNames);
tract.vaxDataN    = vaxDataN;

%=== save labels
tract.vaxLabels = {'Initiated Vaccination: Ages 16+'; ...
                   'Initiated Vaccination: Age 16-44'; ...
                   'Initiated Vaccination: Age 45-64'; ...
                   'Initiated Vaccination: Age 65+';};
                 
%=== debug
t = find(strcmp(tract.townNames, 'Ridgefield'));
tract.townNames(t);
num2str(tract.fips(t));
tract.vaxDataN(end,t,:);

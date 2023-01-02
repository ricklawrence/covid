function town1  = readVaccineDataTown(dataFile, dataFileAge, town)
%
% read town-level vaccination data
%
global parameters;
fprintf('\n--> readVaccineDataTown\n');

%=== read total-population file as a table
dataTable1  = readtable(dataFile);
head(dataTable1, 10);
numColumns = length(dataTable1.Properties.VariableNames);
numRows    = length(dataTable1.Town);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows,   dataFile);

%=== read age file as a table
dataTable2 = readtable(dataFileAge);
head(dataTable2, 10);
numColumns = length(dataTable2.Properties.VariableNames);
numRows    = length(dataTable2.Town);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows,   dataFileAge);

%=== read missing town-age records
missingRecords = sprintf('%s/%s', parameters.INPUT_PATH, 'missingTownVaccinationRecords.csv');
dataTable3 = readtable(missingRecords);
head(dataTable3, 10);
numColumns = length(dataTable3.Properties.VariableNames);
numRows    = length(dataTable3.Town);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows,   missingRecords);

%=== add missing records to town-age table
dataTable2 = [dataTable2; dataTable3];
fprintf('Added %d missing town-age records to %s\n', numRows, dataFileAge);

%---------------------------------------------------------
% PROCESS TABLE 1 WITH TOTAL POPULATION

%=== get dates and town names
dates      = dataTable1.DateUpdated;
datenums   = datenum(dates);
dates      = cellstr(datestr(datenums, 'mm/dd/yyyy'));
names0     = dataTable1.Town;

%=== 4-18-2022: eliminate 'Resident out of state' records
index      = [1:length(names0)]';
index      = find(~strcmp(names0, 'Resident out of state'));

%=== sort all data by date and then name, retaining index into full data
[~, sortIndex] = sort(datenums(index));
index          = index(sortIndex);
[~, sortIndex] = sort(names0(index));
index          = index(sortIndex);
fprintf('Most recent date = %s\n', datestr(max(datenum(dataTable1.DateUpdated(index))), 'mm/dd/yyyy'));

%=== create 2D arrays as numDates x numNames
numDates   = length(unique(dates(index)));
numNames   = length(unique(names0(index)));
if numDates*numNames ~= length(index)
  [values, counts] = getUniqueCounts(names0(index));
  error('length(index) = %d numDates*numNames = %d numDates = %d numNames = %d', ...
          length(index), numDates*numNames, numDates, numNames);
end

dates2D    = reshape(dates(index),  numDates, numNames);
names2D    = reshape(names0(index), numDates, numNames);
dates      = dates2D(:,1);
names      = names2D(1,:)';

%=== save dates
town1                = town;
town1.vaxDataVersion = 2;
town1.vaxDates       = dates;

%=== allocate arrays to hold 2D data (numDates x numNames) for TOTAL POPULATION
vaxDataT    = NaN(numDates, numNames, 3);  % 1 = initialized; 2 = completed 3 = boosted
populationT = NaN(numNames, 1);

%=== save full data 2D arrays for all ages
vaxDataT(:,:,1)   = reshape(dataTable1.InitiatedVaccinationCount(index),    numDates, numNames);
vaxDataT(:,:,2)   = reshape(dataTable1.FullyVaccinatedCount(index),         numDates, numNames);
vaxDataT(:,:,3)   = reshape(dataTable1.AdditionalDose1ReceivedCount(index), numDates, numNames);
population2D      = reshape(dataTable1.Population(index),                   numDates, numNames); 
populationT(:,1)  = population2D(end,:,1)';  

%---------------------------------------------------------
% PROCESS TABLE 2 WITH AGE BINS

%=== change '15-44' to '16-44'
index = find(strcmp(dataTable2.AgeGroup, '15-44'));
dataTable2.AgeGroup(index) = {'16-44'};

%=== get unique age groups -- they changed on 8/12/2021
ageGroupLabels = unique(dataTable2.AgeGroup);
ageGroupLabels = setdiff(ageGroupLabels, '0');         % remove 0 that occurs in non-town entry
ageGroupLabels = setdiff(ageGroupLabels, '');          % remove blank that occurs in non-town entry
ageGroupLabels = setdiff(ageGroupLabels, 'Unknown');   % remove Unknwn that occurs in non-town entry
numAgeGroups   = length(ageGroupLabels);               % this is 7 as of 8/12/2021
  
%=== allocate arrays to hold age-dependent data
vaxData    = NaN(numDates, numNames, numAgeGroups, 3);  % 1 = initialized; 2 = completed; 3 = boosted
population = NaN(numNames, numAgeGroups);

%=== get dates and town names
dates      = dataTable2.DateUpdated;
datenums   = datenum(dates);
dates      = cellstr(datestr(datenums, 'mm/dd/yyyy'));
names0     = dataTable2.Town;

%=== 4-18-2022: eliminate 'Resident out of state' records
index      = [1:length(names0)]';
index      = find(~strcmp(names0, 'Resident out of state'));

%=== sort all data by date and then name, retaining index into full data
[~, sortIndex] = sort(datenums(index));
index          = index(sortIndex);
[~, sortIndex] = sort(names0(index));
index          = index(sortIndex);

%=== loop over all age groups 
for ageIndex=1:numAgeGroups
  ageGroup                = ageGroupLabels(ageIndex);
  index1                  = find(strcmp(dataTable2.AgeGroup(index), ageGroup));
  index1                  = index(index1);
  dates1                  = unique(dates(index1)); 
  d                       = find(ismember(town1.vaxDates, dates1));
  numDates1               = length(d);
  if length(index1) == numDates1*numNames
    vaxData(d,:,ageIndex,1) = reshape(dataTable2.InitiatedVaccinationCount(index1),    numDates1, numNames);
    vaxData(d,:,ageIndex,2) = reshape(dataTable2.FullyVaccinatedCount(index1),         numDates1, numNames);
    vaxData(d,:,ageIndex,3) = reshape(dataTable2.AdditionalDose1ReceivedCount(index1), numDates1, numNames);
    population2D            = reshape(dataTable2.Population(index1),                   numDates1, numNames); 
    population(:,ageIndex)  = population2D(end,:,1)';  
  else
    %=== Union missing age 5-11 records on 12/1 and 12/8
    [length(index1) numDates1 numNames] 
    names1              = dataTable2.Town(index1);
    [uniqueNames1,~,i2] = unique(names1);
    counts              = histcounts(i2,'BinMethod','integers');
    counts              = numDates1 - counts;
    problemIndex        = find(counts > 0);
    [values, counts]    = getUniqueCounts(names1);
    setdiff(names,names1)
    for i=problemIndex
      fprintf('Town %s is missing %d entries for Ages %s.\n', char(uniqueNames1(i)), counts(i), char(ageGroup));
    end
    error('Ages %s: length(index1) = %d numDates1*numNames = %d numDates1 = %d numNames = %d', ...
          char(ageGroup), length(index1), numDates1*numNames, numDates1, numNames);
  end
end

%=== insert data for full population after 8 age bins
ageIndex                 = numAgeGroups + 1;
ageGroupLabels(ageIndex) = {'All Ages'};
vaxData(:,:,ageIndex,1)  = vaxDataT(:,:,1);
vaxData(:,:,ageIndex,2)  = vaxDataT(:,:,2);  
vaxData(:,:,ageIndex,3)  = vaxDataT(:,:,3);  
population(:,ageIndex)   = populationT(:,1);

%=== set indices to the active age bins (age 5+) before and after 8/12/2021
ageIndex1 = [1,3,6,7,8];   % before 8/12
ageIndex2 = [2,4,5,6,7,8]; % after  8/12 ages 
ageIndex2 = ageIndex2 + 1; % added age 0-4 on 7/28/2022 in slot 1

%=== set date indices before and after the change in age groups
changeDate = '08/12/2021';
dateIndex1 = find(datenum(town1.vaxDates) <  datenum(changeDate));  % before 8/12
dateIndex2 = find(datenum(town1.vaxDates) >= datenum(changeDate));  % after  8/12

%=== compute data for eligible population (age 5+) and insert at end -- need to deal with age groups changing 8/12
ageIndex                 = numAgeGroups + 2;
ageGroupLabels(ageIndex) = {'Eligible Ages'};
vaxData(dateIndex1,:,ageIndex,1) = nansum(vaxData(dateIndex1,:,ageIndex1,1),  3);
vaxData(dateIndex1,:,ageIndex,2) = nansum(vaxData(dateIndex1,:,ageIndex1,2),  3);
vaxData(dateIndex1,:,ageIndex,3) = nansum(vaxData(dateIndex1,:,ageIndex1,3),  3);
vaxData(dateIndex2,:,ageIndex,1) = nansum(vaxData(dateIndex2,:,ageIndex2,1),  3);
vaxData(dateIndex2,:,ageIndex,2) = nansum(vaxData(dateIndex2,:,ageIndex2,2),  3);
vaxData(dateIndex2,:,ageIndex,3) = nansum(vaxData(dateIndex2,:,ageIndex2,3),  3);
population(:,ageIndex)           = nansum(population(:,ageIndex2),2);

%--------------------------------------------------------------------------------------------
%=== join this data into town data
numAgeGroups              = length(ageGroupLabels);
numNames                  = length(town.names);
[~,i1,i2]                 = intersect(town.names, names);
town1.vaxData(:,i1,:,:)   = vaxData(:,i2,:,:);
town1.populationAge(i1,:) = population(i2,:);

%=== connecticut is the final 'town' -- sum over ALL towns
%=== NOTE: this sum differs from CDC
s                        = find(strcmp(town.names, 'Connecticut'));
townIndex                = find(~strcmp(names, 'Address pending validation'));  % skip    'Address pending validation'
townIndex                = [1:length(names)]';                                  % include 'Address pending validation'
town1.vaxData(:,s,:,:)   = nansum(vaxData(:,townIndex,:,:), 2);
town1.populationAge(s,:) = nansum(population, 1);
i                        = find(strcmp(ageGroupLabels, 'All Ages'));
town1.vaxData(:,s,i,:)   = nansum(vaxDataT(:,townIndex,:), 2);

%=== compute vaccination fractions 
town1.vaxDataN = NaN(numDates, numNames, numAgeGroups, 2);
for age=1:numAgeGroups
  for dose=1:3
    town1.vaxDataN(:,:,age,dose) = town1.vaxData(:,:,age,dose)  ./ repmat(town1.populationAge(:,age)', numDates, 1);
  end
end

%=== insure that non-Nan vaccination fractions are not greater than 1.0
i                 = find(~isnan(town1.vaxDataN));
town1.vaxDataN(i) = min(town1.vaxDataN(i),1);

%=== save age group labels
town1.vaxLabels   = ageGroupLabels;

%=== make all dates Wednesdays
i                 = find(strcmp(town1.vaxDates,'08/12/2021'));
town1.vaxDates(i) = {'08/11/2021'};
i                 = find(strcmp(town1.vaxDates,'02/17/2022'));
town1.vaxDates(i) = {'02/16/2022'};

%=== debug
t = find(strcmp(town1.names, 'Ridgefield'));
t = find(strcmp(town1.names, 'Union'));
town1.vaxLabels;
town1.vaxData(end,t,:,1:2);

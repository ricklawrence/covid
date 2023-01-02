function state1 = readCDCallocations(dataFile1, dataFile2, dataFile3, state)
%
% read CDC vaccine allocation files (Pfizer and Moderna)
%
global parameters;
fprintf('\n--> readCDCallocations\n');
state1 = state;

%=== read pfizer allocation file
dataTable1 = readtable(dataFile1);
head(dataTable1,10);
numColumns = length(dataTable1.Properties.VariableNames);
numRows    = length(dataTable1.Jurisdiction);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows, dataFile1);

%=== read moderna allocation file
dataTable2 = readtable(dataFile2);
head(dataTable2,10);
numColumns = length(dataTable2.Properties.VariableNames);
numRows    = length(dataTable2.Jurisdiction);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows, dataFile2);

%=== read j&j allocation file
dataTable3 = readtable(dataFile3);
head(dataTable3,10);
numColumns = length(dataTable3.Properties.VariableNames);
numRows    = length(dataTable3.Jurisdiction);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows, dataFile3);

%=== remove annoying * and , from state names
bad = {'*', ','};
dataTable1.Jurisdiction = erase(dataTable1.Jurisdiction, bad);
dataTable2.Jurisdiction = erase(dataTable2.Jurisdiction, bad);
dataTable3.Jurisdiction = erase(dataTable3.Jurisdiction, bad);

%=== filter dates in pfizer & moderna files so they have same number of dates (pfizer has more dates)
date1  = '02/01/2021';
index1  = find(datenum(dataTable1.WeekOfAllocations) >= datenum(date1));
index2  = find(datenum(dataTable2.WeekOfAllocations) >= datenum(date1));
index3  = find(datenum(dataTable3.WeekOfAllocations) >= datenum(date1));

%=== sort files by week (ie date)
weeks1          = cellstr(dataTable1.WeekOfAllocations);
weeks2          = cellstr(dataTable2.WeekOfAllocations);
weeks3          = cellstr(dataTable3.WeekOfAllocations);
[~, sortIndex1] = sort(datenum(weeks1(index1)));
index1          = index1(sortIndex1);
[~, sortIndex2] = sort(datenum(weeks2(index2)));
index2          = index2(sortIndex2);
[~, sortIndex3] = sort(datenum(weeks3(index3)));
index3          = index3(sortIndex3);

%=== now sort files by name
[~, sortIndex1] = sort(dataTable1.Jurisdiction(index1));
index1          = index1(sortIndex1);
[~, sortIndex2] = sort(dataTable2.Jurisdiction(index2));
index2          = index2(sortIndex2);
[~, sortIndex3] = sort(dataTable3.Jurisdiction(index3));
index3          = index3(sortIndex3);

%=== get unique dates (insuring they retain ordering)
dates    = unique(weeks1(index1), 'stable');
numWeeks = length(dates);

%=== J&J has fewer allocation weeks 
weeksJJ    = unique(weeks3(index3), 'stable');
numWeeksJJ = length(weeksJJ);

%=== get unique names (insuring they retain ordering)
names    = unique(dataTable1.Jurisdiction, 'stable');
numNames = length(names);

%=== create 2D arrays
weeks2D  = reshape(dataTable1.WeekOfAllocations(index1),   numWeeks,   numNames);
names2D  = reshape(dataTable1.Jurisdiction(index1),        numWeeks,   numNames);
pfizer1  = reshape(dataTable1.x1stDoseAllocations(index1), numWeeks,   numNames);
pfizer2  = reshape(dataTable1.x2ndDoseAllocations(index1), numWeeks,   numNames);
moderna1 = reshape(dataTable2.x1stDoseAllocations(index2), numWeeks,   numNames);
moderna2 = reshape(dataTable2.x2ndDoseAllocations(index2), numWeeks,   numNames);
JandJ0   = reshape(dataTable3.x1stDoseAllocations(index3), numWeeksJJ, numNames);
weeks    = weeks2D(:,1);
names    = names2D(1,:)';

%=== align J&J with pfizer and moderna
[~,i1,i2]    = intersect(weeks, weeksJJ);
JandJ1       = NaN(numWeeks, numNames);
JandJ1(i1,:) = JandJ0(i2,:);

%=== create array for allocations
numStates          = state.numNames;
numDoses           = 2;   % first dose, second dose
numManuf           = 3;   % pfizer,     moderna,     JandJ
cdcAllocations     = NaN(numWeeks, numStates, numDoses, numManuf);

%=== save data for each state
for s=1:numStates
  s1 = find(strcmp(state.names(s), names));

  %=== save data for each state in our state structure
  if ~isempty(s1)
    cdcAllocations(:,s,1,1) = pfizer1(:,s1);
    cdcAllocations(:,s,2,1) = pfizer2(:,s1);
    cdcAllocations(:,s,1,2) = moderna1(:,s1);
    cdcAllocations(:,s,2,2) = moderna2(:,s1);
    cdcAllocations(:,s,1,3) = JandJ1(:,s1);
  end

  %=== US total is sum over all names
  if strcmp(state.names(s), 'United States')
    cdcAllocations(:,s,1,1) = nansum(pfizer1,2);
    cdcAllocations(:,s,2,1) = nansum(pfizer2,2);
    cdcAllocations(:,s,1,2) = nansum(moderna1,2);
    cdcAllocations(:,s,2,2) = nansum(moderna2,2);
    cdcAllocations(:,s,1,3) = nansum(JandJ1,2);
  end

  %=== add NYC to NYS
  if strcmp(state.names(s), 'New York')
    nys  = find(strcmp('New York',      names));
    nyc  = find(strcmp('New York City', names));
    cdcAllocations(:,s,1,1) = pfizer1(:,nys)  + pfizer1(:,nyc);
    cdcAllocations(:,s,2,1) = pfizer2(:,nys)  + pfizer2(:,nyc);
    cdcAllocations(:,s,1,2) = moderna1(:,nys) + moderna1(:,nyc);
    cdcAllocations(:,s,2,2) = moderna2(:,nys) + moderna2(:,nyc);
    cdcAllocations(:,s,1,3) = JandJ1(:,nys)   + JandJ1(:,nyc);
  end      
end

%=== save data
state1.cdcAllocations     = cdcAllocations;
state1.cdcAllocationDates = cellstr(weeks);
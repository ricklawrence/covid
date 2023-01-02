function state1 = readVaccineDataState(dataFile, state)
%
% read state-level CDC vaccination data from data.cdc.gov
%
global parameters;
fprintf('\n--> readVaccineDataState\n');

%=== read cdc file
dataTable  = readtable(dataFile);
head(dataTable,10);
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dataTable.Date);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows, dataFile);

%=== get dates and state abbreviations
dates      = dataTable.Date;
datenums   = datenum(dates);
dates      = cellstr(datestr(datenums, 'mm/dd/yyyy'));
names0     = dataTable.Location;

%=== filter on dates
date1  = '01/30/2022';        % after huge CDC data swings in early March
index  = find(datenum(dates) >= datenum(date1));

%=== remove location LTC which first appears on 10/27/2021 (LTC does NOT appear for all dates)
index0 = find(strcmp(names0, 'LTC'));
index  = setdiff(index,index0);

%=== sort all data by date and then name, retaining index into full data
[~, sortIndex] = sort(datenums(index));
index          = index(sortIndex);
[~, sortIndex] = sort(names0(index));
index          = index(sortIndex);
fprintf('Most recent date = %s\n', datestr(max(datenum(dataTable.Date(index))), 'mm/dd/yyyy'));

%=== truncate
index = index(1:30);
dates(index)
names0(index)

%=== get unique dates and names
uniqueDates  = unique(dates(index))
uniqueNames0 = unique(names0(index))
[~,i1,i2]    = intersect(dates(index),  uniqueDates);
[~,j1,j2]    = intersect(names0(index), uniqueNames0);
[i1 i2]
[j1 j2]

return;

%=== create 2D arrays as numDates x numNames
numDates   = length(unique(dates(index)));
numNames   = length(unique(names0(index)));
if numDates*numNames ~= length(index)
  [values, counts] = getUniqueCounts(names0(index));
end
dates2D    = reshape(dates(index),  numDates, numNames);
names2D    = reshape(names0(index), numDates, numNames);
dates      = dates2D(:,1);
names      = names2D(1,:)';

%=== save dates
state1 = state;
state1.vaxDates = dates;

%=== allocate array for metrics
numDates   = length(state1.vaxDates);
numStates  = state.numNames;
numMetrics = 18;  
vaxData    = NaN(numDates, numStates, numMetrics);

%=== join on state short names
[~, i1, i2] = intersect(state.names0, names);

%=== extract data
data1 = reshape(dataTable.Distributed(index),                            numDates, numNames);  vaxData(:,i1, 1) = data1(:,i2);
data1 = reshape(dataTable.Administered(index),                           numDates, numNames);  vaxData(:,i1, 2) = data1(:,i2);
data1 = reshape(dataTable.Administered_Dose1_Recip(index),               numDates, numNames);  vaxData(:,i1, 3) = data1(:,i2);
data1 = reshape(dataTable.Series_Complete_Yes(index),                    numDates, numNames);  vaxData(:,i1, 4) = data1(:,i2);
data1 = reshape(dataTable.Distributed_Janssen(index),                    numDates, numNames);  vaxData(:,i1, 5) = data1(:,i2);
data1 = reshape(dataTable.Administered_Janssen(index),                   numDates, numNames);  vaxData(:,i1, 6) = data1(:,i2);
data1 = reshape(dataTable.Administered_Janssen(index),                   numDates, numNames);  vaxData(:,i1, 7) = data1(:,i2);
data1 = reshape(dataTable.Series_Complete_Janssen(index),                numDates, numNames);  vaxData(:,i1, 8) = data1(:,i2);
data1 = reshape(dataTable.Series_Complete_Pop_Pct(index),                numDates, numNames);  vaxData(:,i1, 9) = data1(:,i2);
data1 = reshape(dataTable.Series_Complete_65PlusPop_Pct(index),          numDates, numNames);  vaxData(:,i1,10) = data1(:,i2);
data1 = reshape(dataTable.Administered_Dose1_Recip_18PlusPop_Pct(index), numDates, numNames);  vaxData(:,i1,11) = data1(:,i2);
data1 = reshape(dataTable.Administered_Moderna(index),                   numDates, numNames);  vaxData(:,i1,12) = data1(:,i2);
data1 = reshape(dataTable.Administered_Pfizer(index),                    numDates, numNames);  vaxData(:,i1,13) = data1(:,i2);
data1 = reshape(dataTable.Series_Complete_Moderna(index),                numDates, numNames);  vaxData(:,i1,14) = data1(:,i2);
data1 = reshape(dataTable.Series_Complete_Pfizer(index),                 numDates, numNames);  vaxData(:,i1,15) = data1(:,i2);
data1 = reshape(dataTable.Series_Complete_18PlusPop_Pct(index),          numDates, numNames);  vaxData(:,i1,16) = data1(:,i2);
data1 = reshape(dataTable.Administered_Dose1_Recip_12PlusPop_Pct(index), numDates, numNames);  vaxData(:,i1,17) = data1(:,i2);
data1 = reshape(dataTable.Series_Complete_12PlusPop_Pct(index),          numDates, numNames);  vaxData(:,i1,18) = data1(:,i2);
data1 = reshape(dataTable.Additional_Doses(index),                       numDates, numNames);  vaxData(:,i1,19) = data1(:,i2);
data1 = reshape(dataTable.Additional_Doses_18Plus_Vax_Pct(index),        numDates, numNames);  vaxData(:,i1,20) = data1(:,i2);
data1 = reshape(dataTable.Administered_Dose1_Recip_12Plus(index),        numDates, numNames);  vaxData(:,i1,21) = data1(:,i2);
data1 = reshape(dataTable.Series_Complete_12Plus(index),                 numDates, numNames);  vaxData(:,i1,22) = data1(:,i2);
data1 = reshape(dataTable.Administered_Dose1_Recip_5Plus(index),         numDates, numNames);  vaxData(:,i1,23) = data1(:,i2);
data1 = reshape(dataTable.Series_Complete_5Plus(index),                  numDates, numNames);  vaxData(:,i1,24) = data1(:,i2);
data1 = reshape(dataTable.Administered_Dose1_Recip_5PlusPop_Pct(index),  numDates, numNames);  vaxData(:,i1,25) = data1(:,i2);
data1 = reshape(dataTable.Series_Complete_5PlusPop_Pct(index),           numDates, numNames);  vaxData(:,i1,26) = data1(:,i2);

%=== save data
state1.vaxData = vaxData;

%=== normalize to population, compute daily cases, and MA of daily cases
[~, ~, numMetrics] = size(state1.vaxData);
for m=1:numMetrics
  state1.vaxDataN(:,:,m)  = state1.vaxData(:,:,m) ./ repmat(state1.population', numDates, 1);
  state1.vaxDataD(:,:,m)  = computeNewCases(state1.vaxData(:,:,m));
  state1.vaxDataMA(:,:,m) = movingAverage(state1.vaxDataD(:,:,m), parameters.maWindow);
end

%=== set vaccination field names
state1.vaxLabels  = {'Doses Delivered'; ...
                     'Doses Administered'; ...
                     'People With At Least One Dose'; ...
                     'People Fully Vaccinated'; ...
                     'Doses Delivered (J&J)'; ...
                     'Doses Administered (J&J)'; ...
                     'People With One Dose (J&J)'; ...
                     'People Fully Vaccinated (J&J)';
                     'Percent of Total Population Fully Vaccinated'; ...
                     'Percent of 65+ Population Fully Vaccinated'; ...
                     'Percent of 18+ Population With One+ Dose';...
                     'Administered_Moderna'; ...
                     'Administered_Pfizer'; ... 
                     'Series_Complete_Moderna'; ...
                     'Series_Complete_Pfizer';...
                     'Percent of 18+ Population Fully Vaccinated'; ...
                     'Percent of 12+ Population With One+ Dose';...
                     'Percent of 12+ Population Fully Vaccinated'; ...
                     'People with Additional Dose'; ...
                     'Percent of 18+ Population with Additional Dose'; ...
                     'People 12+ with With One+ Dose';...
                     'People 12+ Fully Vaccinated'; ...
                     'People 5+ with With One+ Dose';...
                     'People 5+ Fully Vaccinated';...
                     'Percent of 5+ Population With One+ Dose'; ...
                     'Percent of 5+ Population Fully Vaccinated'; ...
                    };

                   
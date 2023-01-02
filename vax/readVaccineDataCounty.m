  function county1 = readVaccineDataCounty(dataFile, county)
%
% read CDC county-level vaccination data from cdc file
%
global parameters;
fprintf('\n--> readVaccineDataCounty\n');

%=== read cdc file
dataTable  = readtable(dataFile);
head(dataTable,10);
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dataTable.Date);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows, dataFile);

%=== get dates and FIPS 
dates      = dataTable.Date;
datenums   = datenum(dates);
dates      = cellstr(datestr(datenums, 'mm/dd/yyyy'));
fips0      = dataTable.FIPS;

%=== filter on dates and valid fips
date1  = '03/08/2021';        % after huge CDC data swings in early March
index1 = find(datenum(dates) >= datenum(date1));
index2 = find(~isnan(fips0));
index  = intersect(index1, index2);
fprintf('Removed %d records with unknown FIPS code.\n', length(index1) - length(index));


%=== CDC changed alaska fips code from 2270 to 2158 on july 14, 2021 -- 2158 is used in CountyData.csv
%=== 11-15-2021: no longer any 2270 codes
i = find(fips0(index) == 2270);
fips0(index(i)) = 2158;
fprintf('Changed %d occurrences of Alaska FIPS=2270 to FIPS=2158.\n',length(i));  

%=== 11-13-2021 contains duplicate records -- eliminate them
date0  = '11/13/2021';
index0 = find(datenum(dates(index)) == datenum(date0));  
index0 = index(index0);                                  % all records with this date
[~,i1] = unique(fips0(index0));
index1 = index0(i1);                                     % these are unique records
index0 = setdiff(index0,index1);                         % these are duplicate records
index  = setdiff(index, index0);                         % removed duplicate records
fprintf('Removed %d duplicate records for %s\n', length(index0), date0);

%=== sort all data by date and then fips, retaining index into full data
[~, sortIndex] = sort(datenums(index));
index          = index(sortIndex);
[~, sortIndex] = sort(fips0(index));
index          = index(sortIndex);
fprintf('Most recent date = %s\n', datestr(max(datenum(dataTable.Date(index))), 'mm/dd/yyyy'));

%=== insure that we can create 2D arrays as numDates x numNames
numDates   = length(unique(dates(index)));
numNames   = length(unique(fips0(index)));
if numDates*numNames ~= length(index)                  % this will cause the reshape below to fail
  [numDates numNames numDates*numNames length(index)]
  %getUniqueCounts(fips0(index));
  getUniqueCounts(dates(index));
  error('Cannot reshape data into 2D arrays.');
end

%=== create 2D arrays as numDates x numNames
dates2D    = reshape(dates(index),  numDates, numNames);
fips2D     = reshape(fips0(index),  numDates, numNames);
dates      = dates2D(:,1);
fips       = fips2D(1,:)';

%=== save dates
county1 = county;
county1.vaxDates = dates;

%=== allocate array for metrics
numDates     = length(county1.vaxDates);
numCounties  = county.numNames;
numMetrics   = 6;  
vaxData      = NaN(numDates, numCounties, numMetrics);

%=== join on county fips
[~, i1, i2] = intersect(county.fips, fips);

%=== extract data
data1 = reshape(dataTable.Completeness_pct(index),                       numDates, numNames);  vaxData(:,i1, 1) = data1(:,i2);
data1 = reshape(dataTable.Series_Complete_Yes(index),                    numDates, numNames);  vaxData(:,i1, 2) = data1(:,i2);
data1 = reshape(dataTable.Series_Complete_Pop_Pct(index),                numDates, numNames);  vaxData(:,i1, 3) = data1(:,i2);
data1 = reshape(dataTable.Series_Complete_18PlusPop_Pct(index),          numDates, numNames);  vaxData(:,i1, 4) = data1(:,i2);
data1 = reshape(dataTable.Administered_Dose1_Recip_12PlusPop_Pct(index), numDates, numNames);  vaxData(:,i1, 5) = data1(:,i2);
data1 = reshape(dataTable.Series_Complete_18PlusPop_Pct(index),          numDates, numNames);  vaxData(:,i1, 6) = data1(:,i2);

%=== save data
county1.vaxDataN = vaxData;

%=== debug
c = find(county1.fips == 9001);     % fairfield county
county1.vaxDataN(end,c,:);

%=== set vaccination field names
county1.vaxLabels  = {'Percent of People with Valid County'; ...
                      'People Fully Vaccinated'; ...
                      'Percent of People Fully Vaccinated'; ...
                      'Percent of People 18+ Fully Vaccinated'; ...
                      'Percent of 12+ Population With One+ Dose';...
                      'Percent of 12+ Population Fully Vaccinated'};

function county1 = readCountyElectionData(countyElectionData, county)
%
% read US county election data and join it with existing US county data
%
global parameters;
fprintf('\n--> readCountyElectionData\n');
   
%=== read county election data
dataTable = readtable(countyElectionData);
head(dataTable,10);
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dataTable.county_fips);
fprintf('Read %2d columns and %d rows from %s.\n', numColumns, numRows, countyElectionData);

%=== join data on fips
county1 = county;
[~,i1,i2] = intersect(county1.fips, dataTable.county_fips);
county1.republicanVote     = NaN(county.numNames,1);
county1.republicanVote(i1) = dataTable.per_gop(i2);

%=== check
missing = find(isnan(county1.republicanVote));
fprintf('%d counties are missing election data.\n', length(missing));
county1.names(missing);  % 29 missing counties in Alaska, 1 in Hawaii

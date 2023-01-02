function town1 = readTownElectionData(townElectionData, town)
%
% read election data at town
%
global parameters;
fprintf('\n--> readTownElectionData\n');
town1 = town;

%=== read town file with election results
dataTable = readtable(townElectionData);
head(dataTable,10);
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dataTable.TownName);
fprintf('Read %2d columns and %d rows from %s.\n', numColumns, numRows, townElectionData);

%=== join data on town name
[~,i1,i2] = intersect(town.names, dataTable.TownName);
town1.republicanVote     = NaN(length(town.names),1);
town1.republicanVote(i1) = dataTable.TrumpFraction(i2);

%=== connecticut is last 'town' in town structure
i = length(town.names);
town1.republicanVote(i) = 0.392;   % from hartford courant site

%=== check
missing = find(isnan(town1.republicanVote));
fprintf('%d towns are missing election data.\n', length(missing));
town.names(missing);

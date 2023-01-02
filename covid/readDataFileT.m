function townData = readDataFileT(dataFile)
%
% read simple town data (abbreviations, population)
%
%
global parameters;
fprintf('\n--> readDataFileT\n');

%=== read file as a table
dataTable = readtable(dataFile);
head(dataTable,8);

%=== summary
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dataTable.TownName);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows, dataFile);

%=== sort towns by NAME so we have same ordering as in Covid data
[sortValues, sortIndex] = sort(dataTable.TownName);

%=== save data
townData.Name       = dataTable.TownName(sortIndex);
townData.CountyName = dataTable.CountyName(sortIndex);
townData.Population = dataTable.Population(sortIndex);

%=== add CT as final record
i                      = length(townData.Name) + 1;
townData.Name(i)       = {'Connecticut'};
townData.CountyName(i) = {'None'};
townData.Population(i) = 3565287;


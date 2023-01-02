function stateData = readDataFileS(dataFile)
%
% read simple state data (abbreviations, population)
%
%
global parameters;
fprintf('\n--> readDataFileS\n');

%=== read file as a table
dataTable = readtable(dataFile);
head(dataTable,8);

%=== summary
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dataTable.State);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows, dataFile);

%=== sort states by ABBREVIATION so we have same ordering as in Covid data
[sortValues, sortIndex] = sort(dataTable.Abbreviation);

%=== save data
stateData.Name          = dataTable.State(sortIndex);
stateData.Name0         = dataTable.Abbreviation(sortIndex);
stateData.Population    = dataTable.Population(sortIndex);
stateData.Density       = dataTable.Density(sortIndex);
stateData.RepublicanGov = dataTable.RepublicanGovernor(sortIndex);
stateData.TrumpWon      = dataTable.TrumpWon(sortIndex);

%=== OVERWRITE governor party with whether Trump won
overwrite = 0;
if overwrite
  stateData.RepublicanGov  = stateData.TrumpWon;
  fprintf('OVERWROTE RepublicanGov with TrumpWon.\n')
end

%=== first date mask required
stateData.MaskDatenum    = datenum(dataTable.MaskDate(sortIndex));
stateData.MaskDate       = cellstr(datestr(stateData.MaskDatenum, 'mm/dd/yyyy'));
none                     = find(strcmp(stateData.MaskDate, 'NaN/NaN/NaN'));
stateData.MaskDate(none) = {'None'};

%=== set party based on governor
stateData.Party         = cell(length(stateData.Name),1);
mask                    = find(stateData.RepublicanGov == 1);
stateData.Party(mask)   = {'R'};
mask                    = find(stateData.RepublicanGov == 0);
stateData.Party(mask)   = {'D'};

%=== add US as final record
i = length(stateData.Name) + 1;
stateData.Name(i)          = {'United States'};
stateData.Name0(i)         = {'US'};
stateData.Population(i)    = 331002651;
stateData.Density(i)       = NaN;
stateData.RepublicanGov(i) = -1;
stateData.TrumpWon(i)      = -1;
stateData.Party(i)         = {''};
stateData.MaskDatenum(i)   = NaN;
stateData.MaskDate(i)      = {'None'};
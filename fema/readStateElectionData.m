function state1 = readStateElectionData(stateElectionData, state)
%
% read election data at state
%
global parameters;
fprintf('\n--> readStateElectionData\n');
state1 = state;

%=== read state file with election results
dataTable = readtable(stateElectionData);
head(dataTable,10);
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dataTable.state);
fprintf('Read %2d columns and %d rows from %s.\n', numColumns, numRows, stateElectionData);

%=== join data on state name
[~,i1,i2] = intersect(state.names0, dataTable.stateid);
state1.republicanVote     = NaN(length(state.names),1);
state1.republicanVote(i1) = dataTable.rep_fraction(i2);

%=== check
missing = find(isnan(state1.republicanVote));
fprintf('%d states are missing election data.\n', length(missing));
state.names(missing);

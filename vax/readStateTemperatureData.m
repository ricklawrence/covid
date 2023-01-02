function state1 = readStateTemperatureData(stateTemperatureData, state)
%
% read mean state temperature data
%
global parameters;
fprintf('\n--> readStateTemperatureData\n');
state1 = state;

%=== read state file with state temperatures
dataTable = readtable(stateTemperatureData);
head(dataTable,10);
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dataTable.State);
fprintf('Read %2d columns and %d rows from %s.\n', numColumns, numRows, stateTemperatureData);

%=== join data on state name
[~,i1,i2] = intersect(state.names, dataTable.State);
state1.temperature     = NaN(length(state.names),1);
state1.temperature(i1) = dataTable.FallTemperature(i2);

%=== us temperature is simply the mean
us = find(strcmp(state.names0, 'US'));
state1.temperature(us) = mean(dataTable.FallTemperature);

%=== check
missing = find(isnan(state1.temperature));
fprintf('%d states are missing temperature data.\n', length(missing));
state.names(missing);

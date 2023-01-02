function town1 = mergeStateTown(town, state)
%
% add connecticut as final record in town data
%
global parameters;
fprintf('\n--> mergeStateTown\n');

%=== start with existing state structure
town1 = town;

%=== add connecticut scalar data
i                        = town.numNames + 1; 
j                        = find(strcmp('Connecticut', state.names));
town1.numNames           = i;
town1.names(i)           = {'Connecticut'};
town1.names0(i)          = {'CT'};
town1.countyNames(i)     = {'State'};
town1.population(i)      = state.population(j);

%=== add connecticut time series
town1.cumCases(:,i)     = state.cumCases(:,j);
town1.newCases(:,i)     = state.newCases(:,j);
town1.newTests(:,i)     = state.newTests(:,j);
town1.newDeaths(:,i)    = state.newDeaths(:,j);
town1.hospitalized(:,i) = state.hospitalized(:,j);
town1.testPositive(:,i) = state.testPositive(:,j);
fprintf('Added Connecticut data as final records in Town data structure.\n');
function state1 = mergeCountryState(state, country)
%
% add US data as final record in state data
%
global parameters;
fprintf('\n--> mergeCountryState\n');

%=== start with existing state structure
state1 = state;

%=== add US scalar data
i                         = state.numNames + 1; 
state1.numNames           = i;
state1.names(i)           = {'United States'};
state1.names0(i)          = {'US'};
state1.population(i)      = 331002651;

%=== add US time series
state1.cumCases(:,i)     = country.cumCases;
state1.newCases(:,i)     = country.newCases;
state1.newTests(:,i)     = country.newTests;
state1.newDeaths(:,i)    = country.newDeaths;
state1.hospitalized(:,i) = country.hospitalized;
state1.testPositive(:,i) = country.testPositive;
fprintf('Added US data as final records in State data structure.\n');
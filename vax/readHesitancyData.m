function [county1, state1] = readHesitancyData(dataFile, county, state)
%
% read county-level CDC hesitancy data and map to states
%
global parameters;
fprintf('\n--> readHesitancyData\n');
state1  = state;
county1 = county;

%=== read CDC hesitancy file
dataTable  = readtable(dataFile);
head(dataTable,10);
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dataTable.FIPSCode);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows, dataFile);

%=== join county data on FIPS code
[~,i1,i2] = intersect(county.fips, dataTable.FIPSCode);
county1.hesitancy       = NaN(county.numNames,3);
county1.hesitancy(i1,1) = dataTable.EstimatedHesitantOrUnsure(i2);
county1.hesitancy(i1,2) = dataTable.EstimatedHesitant(i2);
county1.hesitancy(i1,3) = dataTable.EstimatedStronglyHesitant(i2);
county1.hesitancyLabels = {'Estimated Hesitant or Unsure'; 'Estimated Hesitant'; 'Estimated Strongly Hesitant'};

%=== get state-level data by population-weighting the county data
state1.hesitancy = NaN(state.numNames,3);
for s=1:state.numNames
  index                 = find(contains(county.names0, state.names0(s)));
  populations           = county.population(index);
  weights               = populations ./ nansum(populations);
  state1.hesitancy(s,:) = nansum(weights .* county1.hesitancy(index,:));
end
state1.hesitancyLabels  = county1.hesitancyLabels;

%=== no data for DC
dc = find(strcmp(state.names0, 'DC'));
state1.hesitancy(dc,1:3) = NaN;

%=== get US data by population weighting the state data
us                     = find( strcmp(state.names, 'United States'));
index                  = find(~strcmp(state.names, 'United States'));
populations            = state.population(index);
weights                = populations ./ nansum(populations);
state1.hesitancy(us,:) = nansum(weights .* state1.hesitancy(index,:));

%=== check
debug = 0;
if debug
  c = find(county1.fips == 9001);
  s = find(strcmp(state1.names0, 'CT'));
  county1.hesitancy(c,:)
  state1.hesitancy(s,:)
  state1.hesitancy(us,:)
end


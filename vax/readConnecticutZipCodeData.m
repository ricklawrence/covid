function demoFeatures = readConnecticutZipCodeData(zipCodeDataFile)
%
% read connecticut zip code data and compute demographic features
%
global parameters;
fprintf('\n--> readConnecticutZipCodeData\n');

%------------------------------------------------------------------------
%=== read zip code data file
dataTable = readtable(zipCodeDataFile);
head(dataTable,25);

%=== summary
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dataTable.ZipCode);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows, zipCodeDataFile);

%=== get unique town names
townNames     = unique(dataTable.City);
numTowns      = length(townNames);

%=== compute features
population    = NaN(numTowns,1);
income        = NaN(numTowns,1);
whiteFraction = NaN(numTowns,1);
popDensity    = NaN(numTowns,1);
for t=1:numTowns
  index        = find(strcmp(townNames(t), dataTable.City));  % index to multiple zip codes within single town
  
  %=== population weight the fields within a town
  if ~isempty(index)
    populations      = dataTable.Population(index);
    population(t)    = nansum(populations);
    income(t)        = nansum(populations .* dataTable.IncomePerHousehold(index)) / nansum(populations);
    whiteFraction(t) = nansum(dataTable.WhitePopulation(index)) / population(t);
    popDensity(t)    = nansum(dataTable.Population(index)) / nansum(dataTable.LandArea(index));
  end

  %=== save town name as intial caps so it matchs data.ct.gov town names
  townNames(t) = initialCaps(townNames(t));
end

%=== save data
demoFeatures.numNames      = numTowns;
demoFeatures.names         = townNames;
demoFeatures.features(:,1) = population;
demoFeatures.features(:,2) = income;
demoFeatures.features(:,3) = whiteFraction;
demoFeatures.features(:,4) = popDensity;
demoFeatures.featureLabels = {'Population'; 'Household Income'; 'White Fraction'; 'Population Density'};
demoFeatures.numFeatures   = length(demoFeatures.featureLabels);

%=== check Ridgefield and Danbury (multiple zip codes)
debug = 0;
if debug
  r = find(strcmp('Ridgefield', demoFeatures.names));
  fprintf('Ridgefield Population     = %3.0f\n', demoFeatures.features(r,1));
  fprintf('Ridgefield Income         = %3.0f\n', demoFeatures.features(r,2));
  fprintf('Ridgefield White Fraction = %3.3f\n', demoFeatures.features(r,3));
  fprintf('Ridgefield Pop Density    = %3.3f\n', demoFeatures.features(r,4));
  r = find(strcmp('Danbury', demoFeatures.names));
  fprintf('Danbury Population        = %3.0f\n', demoFeatures.features(r,1));
  fprintf('Danbury Income            = %3.0f\n', demoFeatures.features(r,2));
  fprintf('Danbury White Fraction    = %3.3f\n', demoFeatures.features(r,3));
  fprintf('Danbury Pop Density       = %3.3f\n', demoFeatures.features(r,4));
end
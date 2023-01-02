function [sviData, town] = readSviDataAnyState(sviDataFile, tract2zip, state)
%
% read CDC SVI data at census-tract level and join with tract to town mapping
%
fprintf('\n--> readSviDataAnyState\n');

%=== read svi data file
sviTable  = readtable(sviDataFile);
head(sviTable, 10);
numColumns = length(sviTable.Properties.VariableNames);
numRows    = length(sviTable.FIPS);
fprintf('Read %3d columns and %d rows from %s.\n', numColumns, numRows, sviDataFile);

%=== read tract to zip file
zipTable = readtable(tract2zip, 'Format','%s%f%s%s%f%f%f%f');
head(zipTable, 10);
numColumns = length(zipTable.Properties.VariableNames);
numRows    = length(zipTable.ZIP);
fprintf('Read %3d columns and %d rows from %s.\n', numColumns, numRows, tract2zip);

%=== get overlap between the files
N = length(intersect(zipTable.TRACT, sviTable.FIPS));
fprintf('Found zip codes for %d (out of %d) census tracts.\n', N, length(sviTable.FIPS));

%=== get state name from file name
stateName = 'MISSING';
for s=1:state.numNames
  if contains(sviDataFile, state.names(s))
    stateName = char(state.names(s));
    stateName0 = char(state.names0(s));
  end
end

%=== sort svi data by FIPS
[~, sortIndex]         = sort(sviTable.FIPS);
sviData.level          = 'Census Tract';
sviData.stateName      = stateName;
sviData.stateName0     = stateName0;
sviData.numTracts      = length(sviTable.FIPS);
sviData.tractFIPS      = sviTable.FIPS(sortIndex); 
sviData.location       = sviTable.LOCATION(sortIndex); 
sviData.townNames      = sviTable.LOCATION(sortIndex);  % filled in with zip-tract file data
sviData.countyNames    = sviTable.COUNTY(sortIndex);
sviData.zipCodes       = cell(sviData.numTracts,1);     % filled in with zip-tract file data
sviData.population     = sviTable.E_TOTPOP(sortIndex);

%=== get town name and zip code from zip code mapping file
for c=1:sviData.numTracts
  index     = find(sviData.tractFIPS(c) == zipTable.TRACT);  % all zip codes in this tract
  townNames = zipTable.USPS_ZIP_PREF_CITY(index);            % town names for zip codes in this tract
  zipCodes  = zipTable.ZIP(index);
  ratio     = zipTable.TOT_RATIO(index);                     % fraction of tract in the zip code 
  [~,i]     = max(ratio);                                    % pick zipCode with largest ratio
  if ~isempty(i)
    sviData.townNames(c) = initialCaps(townNames(i));
    sviData.zipCodes(c)  = zipCodes(i);
  end
end

%=== save SVI themes
sviData.sviThemes      = NaN(sviData.numTracts, 5);
sviData.sviThemes(:,1) = sviTable.RPL_THEME1(sortIndex);
sviData.sviThemes(:,2) = sviTable.RPL_THEME2(sortIndex);
sviData.sviThemes(:,3) = sviTable.RPL_THEME3(sortIndex);
sviData.sviThemes(:,4) = sviTable.RPL_THEME4(sortIndex);
sviData.sviThemes(:,5) = sviTable.RPL_THEMES(sortIndex);

%=== save SVI values
sviData.sviValues       = NaN(sviData.numTracts, 15);
sviData.sviValues(:,1)  = sviTable.EPL_POV(sortIndex);
sviData.sviValues(:,2)  = sviTable.EPL_UNEMP(sortIndex);
sviData.sviValues(:,3)  = sviTable.EPL_PCI(sortIndex);
sviData.sviValues(:,4)  = sviTable.EPL_NOHSDP(sortIndex);
sviData.sviValues(:,5)  = sviTable.EPL_AGE65(sortIndex);
sviData.sviValues(:,6)  = sviTable.EPL_AGE17(sortIndex);
sviData.sviValues(:,7)  = sviTable.EPL_DISABL(sortIndex);
sviData.sviValues(:,8)  = sviTable.EPL_SNGPNT(sortIndex);
sviData.sviValues(:,9)  = sviTable.EPL_MINRTY(sortIndex);
sviData.sviValues(:,10) = sviTable.EPL_LIMENG(sortIndex);
sviData.sviValues(:,11) = sviTable.EPL_MUNIT(sortIndex);
sviData.sviValues(:,12) = sviTable.EPL_MOBILE(sortIndex);
sviData.sviValues(:,13) = sviTable.EPL_CROWD(sortIndex);
sviData.sviValues(:,14) = sviTable.EPL_NOVEH(sortIndex);
sviData.sviValues(:,15) = sviTable.EPL_GROUPQ(sortIndex);

%=== missing are marked with -999 ... change to NaN
sviData.sviThemes(sviData.sviThemes == -999) = NaN;
sviData.sviValues(sviData.sviValues == -999) = NaN;

%=== save names for applying linear model
sviData.names         = sviData.location;

%=== assign names to the SVI themes
sviData.sviThemeLabels = {'SVI Theme 1 (Socioeconomic Status) Rank'; ...
                          'SVI Theme 2 (Household Composition and Disability) Rank'; ...
                          'SVI Theme 3 (Minority Status and Language) Rank'; ...
                          'SVI Theme 4 (Housing Type and Transportation) Rank'; ...
                          'Overall SVI Rank';};

%=== assign names to the SVI values
sviData.sviValueLabels = {'SVI Below Poverty'; ...
                          'SVI Unemployed'; ...
                          'SVI Income'; ...
                          'SVI No High School Diploma'; ...
                          'SVI Age 65 or Older'; ...
                          'SVI Age 17 or Younger'; ...
                          'SVI Older than Age 5 with a Disability'; ...
                          'SVI Single-Parent Households'; ...
                          'SVI Minority'; ...
                          'SVI Speaks English Less Than Well'; ...
                          'SVI Multi-Unit Structures'; ...
                          'SVI Mobile Homes'; ...
                          'SVI Crowding'; ...
                          'SVI No Vehicle'; ...
                          'SVI Group Quarters';};

%--------------------------------------------------------------------
%=== PROCESS ZIP CODE MAPPING DATA AND COMPUTE SVI DATA AT TOWN LEVEL

%=== save all the zip code mapping data
sviData.zipCode1   = zipTable.ZIP;
sviData.tract1     = zipTable.TRACT;
sviData.townName1  = zipTable.USPS_ZIP_PREF_CITY;
sviData.stateName1 = zipTable.USPS_ZIP_PREF_STATE;
sviData.ratio1     = zipTable.TOT_RATIO;
                        
%=== compute SVI values for special town structure with town names taken from the zip code mapping file
i0                 = find(strcmp(sviData.stateName1, stateName0));  % specific state
town.level         = 'Town';
town.names         = unique(sviData.townName1(i0));
town.numNames      = length(town.names);
town.countyNames   = town.names;
town.population    = NaN(town.numNames,1);
town.sviPopulation = NaN(town.numNames,1);
town.sviValues     = NaN(town.numNames,15);
ratioCutoff        = 0.05;
for t=1:town.numNames
  i1                  = find(strcmp(town.names(t), sviData.townName1));
  
  %=== get tracts in this town ... eliminate any with small contribution (ratioCutoff)
  tracts              = sviData.tract1(i1);
  ratios              = sviData.ratio1(i1);
  tracts              = tracts(ratios > ratioCutoff );
  i2                  = find(ismember(sviData.tractFIPS, tracts));
  
  %=== town values are population-weighted over census tracts
  weights             = sviData.population(i2) ./ sum(sviData.population(i2));
  weights             = repmat(weights,1,15);
  sviValues           = sviData.sviValues(i2,:);
  town.sviValues(t,:) = nansum(weights .* sviValues, 1);
  town.population(t)  = nansum(sviData.population(i2));   % estimate town population as sum over census tracts
  town.countyNames(t) = sviData.countyNames(i2(1));       % get county name from first tract (arbitrary)
  
  %=== get disadvantaged population based on income
  sviIncome             = sviData.sviValues(i2,3); % income
  sviIncomeCutoff       = 0.9;
  filter                = sviIncome > sviIncomeCutoff;
  i3                    = i2(filter);
  town.sviPopulation(t) = nansum(sviData.population(i3)); 
end

%=== renormalize summed sviValues
numValues = 15;
for v=1:numValues
  sumValues                      = town.sviValues(:,v);
  [~, sortIndex]                 = sort(sumValues);
  i                              = find(~isnan(sumValues(sortIndex)));
  j                              = find( isnan(sumValues(sortIndex)));
  ranks                          = [0:length(i)-1];                  % 0 to N-1 only for nonNaN entries
  ranks                          = ranks ./ max(ranks);              % 0 to 1   only for nonNaN entries
  town.sviValues(sortIndex(i),v) = ranks;
  town.sviValues(sortIndex(j),v) = NaN;
end

%=== sort on vulnerable population
sviPopulation = town.sviPopulation;
[~,sortIndex] = sort(sviPopulation, 'descend');
townNames     = town.names(sortIndex);
countyNames   = town.countyNames(sortIndex);
population    = town.population(sortIndex);
sviPopulation = town.sviPopulation(sortIndex);
ranks         = [1:length(sortIndex)]';
filter        = population > 0;
townNames     = townNames(filter);
countyNames   = countyNames(filter);
population    = population(filter);
sviPopulation = sviPopulation(filter);
ranks         = ranks(filter);

%=== write disadvantaged towns to stdout
writeTowns = 0;
if writeTowns
  fid      = 1;                    % stdout = 1
  strTowns = sprintf('Rank (%d Towns)', length(sortIndex));
  fprintf(fid,'\n');
  fprintf(fid,'%s\t%s\t%s\t%s\t%s\n', 'Town', 'County', 'Total Population', 'SVI Vulnerable Population', strTowns);
  for t=1:10
      fprintf(fid,'%s\t%s\t%d\t%d\t%d\n', char(initialCaps(townNames(t))), char(countyNames(t)), population(t), ...
                                             sviPopulation(t), ranks(t));
  end
end

%=== debug
t = find(strcmp(town.names, 'RIDGEFIELD'));
town.names(t);
[town.sviValues(t,:) num2str(town.population(t))];

%--------------------------------------------------------------------
%=== maximus request
if strcmp(sviData.stateName, 'Idaho')
  zipCode  = '83252';
elseif strcmp(sviData.stateName, 'Louisiana')
  zipCode  = '71295';
elseif strcmp(sviData.stateName, 'Connecticut')
  zipCode  = '06877';
else
  return;
end
zipCode;
i1       = find(strcmp(zipCode, sviData.zipCode1));
townName = sviData.townName1(i1);
tract    = sviData.tract1(i1);
num2str(tract);
i2       = find(ismember(sviData.tractFIPS, tract));
num2str(sviData.tractFIPS(i2));
sviData.townNames(i2);
sviData.sviValues(i2,:);

%--------------------------------------------------------------------
%=== check data
debug = 0;
if ~debug
  return
end
index = find(strcmp(sviData.townNames, 'Ridgefield'));
for i=index
  fprintf('%d\n', sviData.tractFIPS(i));
end
sviData.sviThemes(index,:)

index = find(strcmp(sviData.townNames, 'Ridgefield'));
num2str(sviData.tractFIPS(index))
sviData.zipCodes(index)


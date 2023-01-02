function tract = readSviDataTract(sviDataFile, tract2townDataFile, tract0)
%
% read CDC Connecticut SVI data at census-tract level and join with tract to town mapping
%
fprintf('\n--> readSviDataTract\n');

%=== copy existing Connecticut tract-level vaccination data
tract = tract0;

%=== read svi data file
sviTable  = readtable(sviDataFile);
head(sviTable, 10);
numColumns = length(sviTable.Properties.VariableNames);
numRows    = length(sviTable.FIPS);
fprintf('Read %3d columns and %d rows from %s.\n', numColumns, numRows, sviDataFile);

%=== read tract to town mapping file
mappingTable  = readtable(tract2townDataFile);
head(mappingTable, 10);
numColumns = length(mappingTable.Properties.VariableNames);
numRows    = length(mappingTable.tract_fips);
fprintf('Read %3d columns and %d rows from %s.\n', numColumns, numRows, tract2townDataFile);

%=== sort svi data by FIPS
[~, sortIndex]       = sort(sviTable.FIPS);
tract.level          = 'Census Tract';
tract.stateName      = 'Connecticut';
tract.numTracts      = length(sviTable.FIPS);
tract.tractFIPS      = sviTable.FIPS(sortIndex); 
tract.location       = sviTable.LOCATION(sortIndex); 
tract.countyNames    = sviTable.COUNTY(sortIndex);
tract.population     = sviTable.E_TOTPOP(sortIndex);

%=== save SVI themes
tract.sviThemes      = NaN(tract.numTracts, 5);
tract.sviThemes(:,1) = sviTable.RPL_THEME1(sortIndex);
tract.sviThemes(:,2) = sviTable.RPL_THEME2(sortIndex);
tract.sviThemes(:,3) = sviTable.RPL_THEME3(sortIndex);
tract.sviThemes(:,4) = sviTable.RPL_THEME4(sortIndex);
tract.sviThemes(:,5) = sviTable.RPL_THEMES(sortIndex);

%=== save SVI values
tract.sviValues       = NaN(tract.numTracts, 15);
tract.sviValues(:,1)  = sviTable.EPL_POV(sortIndex);
tract.sviValues(:,2)  = sviTable.EPL_UNEMP(sortIndex);
tract.sviValues(:,3)  = sviTable.EPL_PCI(sortIndex);
tract.sviValues(:,4)  = sviTable.EPL_NOHSDP(sortIndex);
tract.sviValues(:,5)  = sviTable.EPL_AGE65(sortIndex);
tract.sviValues(:,6)  = sviTable.EPL_AGE17(sortIndex);
tract.sviValues(:,7)  = sviTable.EPL_DISABL(sortIndex);
tract.sviValues(:,8)  = sviTable.EPL_SNGPNT(sortIndex);
tract.sviValues(:,9)  = sviTable.EPL_MINRTY(sortIndex);
tract.sviValues(:,10) = sviTable.EPL_LIMENG(sortIndex);
tract.sviValues(:,11) = sviTable.EPL_MUNIT(sortIndex);
tract.sviValues(:,12) = sviTable.EPL_MOBILE(sortIndex);
tract.sviValues(:,13) = sviTable.EPL_CROWD(sortIndex);
tract.sviValues(:,14) = sviTable.EPL_NOVEH(sortIndex);
tract.sviValues(:,15) = sviTable.EPL_GROUPQ(sortIndex);

%=== missing are marked with -999 ... change to NaN
tract.sviThemes(tract.sviThemes == -999) = NaN;
tract.sviValues(tract.sviValues == -999) = NaN;

%=== join town names from mapping file
[~,i1,i2]             = intersect(mappingTable.tract_fips, tract.tractFIPS);
tract.townNames     = cell(tract.numTracts,1);
tract.townNames(:)  = {'MISSING'};
tract.townNames(i2) = mappingTable.town(i1);

%=== create census-tract names
tractNames            = cell(tract.numTracts,1);
tractNames(i2)        = mappingTable.tract_name(i1);
space                 = cell(tract.numTracts,1); space(1:end) = {' '};
tract.tractNames    = strcat(tract.townNames, space, tractNames);

%=== save names for applying linear model
tract.names         = tract.tractNames;

%=== assign names to the SVI themes
tract.sviThemeLabels = {'SVI Theme 1 (Socioeconomic Status) Rank'; ...
                          'SVI Theme 2 (Household Composition and Disability) Rank'; ...
                          'SVI Theme 3 (Minority Status and Language) Rank'; ...
                          'SVI Theme 4 (Housing Type and Transportation) Rank'; ...
                          'Overall SVI Rank';};

%=== assign names to the SVI values
tract.sviValueLabels = {'SVI Below Poverty'; ...
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
%=== check data
debug = 0;
if ~debug
  return
end
index = find(strcmp(tract.townNames, 'Ridgefield'));
num2str(tract.tractFIPS(index))
tract.sviValues(index,:)

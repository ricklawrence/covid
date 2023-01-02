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
[~, sortIndex]         = sort(sviTable.FIPS);
sviData.level          = 'Census Tract';
sviData.stateName      = 'Connecticut';
sviData.numTracts      = length(sviTable.FIPS);
sviData.tractFIPS      = sviTable.FIPS(sortIndex); 
sviData.location       = sviTable.LOCATION(sortIndex); 
sviData.countyNames    = sviTable.COUNTY(sortIndex);
sviData.population     = sviTable.E_TOTPOP(sortIndex);

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

%=== join town names from mapping file
[~,i1,i2]             = intersect(mappingTable.tract_fips, sviData.tractFIPS);
sviData.townNames     = cell(sviData.numTracts,1);
sviData.townNames(:)  = {'MISSING'};
sviData.townNames(i2) = mappingTable.town(i1);

%=== create census-tract names
tractNames            = cell(sviData.numTracts,1);
tractNames(i2)        = mappingTable.tract_name(i1);
space                 = cell(sviData.numTracts,1); space(1:end) = {' '};
sviData.tractNames    = strcat(sviData.townNames, space, tractNames);

%=== save names for applying linear model
sviData.names         = sviData.tractNames;

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
%=== check data
debug = 0;
if ~debug
  return
end
index = find(strcmp(sviData.townNames, 'Ridgefield'));
num2str(sviData.tractFIPS(index))
sviData.sviValues(index,:)

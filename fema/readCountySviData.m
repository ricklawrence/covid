function county1 = readCountySviData(sviDataFile, county)
%
% read CDC SVI data at county level
%
global parameters;
fprintf('\n--> readCountySviData\n');

%=== read svi data file
sviTable  = readtable(sviDataFile);
head(sviTable, 10);
numColumns = length(sviTable.Properties.VariableNames);
numRows    = length(sviTable.FIPS);
fprintf('Read %3d columns and %d rows from %s.\n', numColumns, numRows, sviDataFile);

%=== join data on fips
[~,i1,i2] = intersect(county.fips, sviTable.FIPS);

%=== save SVI Themes
county1                 = county;
county1.sviThemes       = NaN(county1.numNames,5);
county1.sviThemes(i1,1) = sviTable.RPL_THEME1(i2);
county1.sviThemes(i1,2) = sviTable.RPL_THEME2(i2);
county1.sviThemes(i1,3) = sviTable.RPL_THEME3(i2);
county1.sviThemes(i1,4) = sviTable.RPL_THEME4(i2);
county1.sviThemes(i1,5) = sviTable.RPL_THEMES(i2);

%=== save SVI values
county1.sviValues        = NaN(county.numNames,15);
county1.sviValues(i1,1)  = sviTable.EPL_POV(i2);
county1.sviValues(i1,2)  = sviTable.EPL_UNEMP(i2);
county1.sviValues(i1,3)  = sviTable.EPL_PCI(i2);
county1.sviValues(i1,4)  = sviTable.EPL_NOHSDP(i2);
county1.sviValues(i1,5)  = sviTable.EPL_AGE65(i2);
county1.sviValues(i1,6)  = sviTable.EPL_AGE17(i2);
county1.sviValues(i1,7)  = sviTable.EPL_DISABL(i2);
county1.sviValues(i1,8)  = sviTable.EPL_SNGPNT(i2);
county1.sviValues(i1,9)  = sviTable.EPL_MINRTY(i2);
county1.sviValues(i1,10) = sviTable.EPL_LIMENG(i2);
county1.sviValues(i1,11) = sviTable.EPL_MUNIT(i2);
county1.sviValues(i1,12) = sviTable.EPL_MOBILE(i2);
county1.sviValues(i1,13) = sviTable.EPL_CROWD(i2);
county1.sviValues(i1,14) = sviTable.EPL_NOVEH(i2);
county1.sviValues(i1,15) = sviTable.EPL_GROUPQ(i2);

%=== missing are marked with -999 ... change to NaN
county1.sviThemes(county1.sviThemes == -999) = NaN;
county1.sviValues(county1.sviValues == -999) = NaN;

%=== check for counties missing SVI data
missing = find(isnan(county1.sviThemes(:,5)));
fprintf('%d counties are missing SVI data.\n', length(missing));
county1.names(missing);

%=== assign names to the SVI themes
county1.sviThemeLabels = {'SVI Theme 1 (Socioeconomic Status) Rank'; ...
                          'SVI Theme 2 (Household Composition and Disability) Rank'; ...
                          'SVI Theme 3 (Minority Status and Language) Rank'; ...
                          'SVI Theme 4 (Housing Type and Transportation) Rank'; ...
                          'Overall SVI Rank';};

%=== assign names to the SVI values
county1.sviValueLabels = {'SVI Below Poverty'; ...
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
                        
%--------------------------------------------------------------------------------------------
%=== debug
if parameters.DEBUG
  c = find(county1.fips == 9001);                    % fairfield county 
  fprintf('\nDEBUG:\n');
  fprintf('%s\n',   char(county1.names(c)));
  fprintf('%3.1f\n',     county1.vaxData(c,1));
  fprintf('%d\n',        county1.vaxData(c,2));
  fprintf('%3.1f\n', 100*county1.vaxData(c,3));      % agrees exactly with CDC site on 4/18
  fprintf('%7.6f\n',     county1.republicanVote(c)); % = 0.357384
  fprintf('%7.6f\n',     county1.sviThemes(c,5));    % = 0.4497
  fprintf('%7.6f\n',     county1.sviValues(c,1));    % = 0.121
end
                                                  
                                                  
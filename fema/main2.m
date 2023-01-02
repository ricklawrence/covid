%----------------------------------------------------------------------------------------------------------------
% main2: analysis related to FEMA Project
%
% Rick Lawrence
%
% 4/10/2021
%
%----------------------------------------------------------------------------------------------------------------
%=== clear workspace and close figures
clc;
%clear all;   % DO NOT clear workspace -- need COVID main and main1 loaded
close all;    % close all existing figures
warning off;

%----------------------------------------------------------------------------------------------------------------
%=== SET PARAMETERS
global parameters;

parameters.INPUT_PATH1        = 'C:\Users\rdl00\Dropbox\COVID\dataFEMA';         % input data files
parameters.DEBUG              = 0;
parameters.tract2town         = 'Data Source: https://github.com/CT-Data-Collaborative/ct-census-tract-to-town';

%----------------------------------------------------------------------------------------------------------------
%=== SET INPUT FILE NAMES

%=== census-tract-level SVI data for Connecticut
%=== https://www.atsdr.cdc.gov/placeandhealth/svi/data_documentation_download.html
tractSviData         = sprintf('%s/%s', parameters.INPUT_PATH1 , 'ConnecticutSviData.csv');

%=== census-tract-level SVI data for any state
%=== https://www.atsdr.cdc.gov/placeandhealth/svi/data_documentation_download.html
tractSviData1        = sprintf('%s/%s', parameters.INPUT_PATH1 , 'Massachusetts.csv');
tractSviData1        = sprintf('%s/%s', parameters.INPUT_PATH1 , 'Illinois.csv');
tractSviData1        = sprintf('%s/%s', parameters.INPUT_PATH1 , 'Connecticut.csv');
tractSviData1        = sprintf('%s/%s', parameters.INPUT_PATH1 , 'Idaho.csv');
tractSviData1        = sprintf('%s/%s', parameters.INPUT_PATH1 , 'Louisiana.csv');
tractSviData1        = sprintf('%s/%s', parameters.INPUT_PATH1 , 'Florida.csv');
tractSviData1        = sprintf('%s/%s', parameters.INPUT_PATH1 , 'Texas.csv');

%=== census tract to town mapping for Connecticut
%=== https://www.ctdata.org/geospatial-data-tools-gis
%=== https://github.com/CT-Data-Collaborative/ct-census-tract-to-town
tract2town = sprintf('%s/%s', parameters.INPUT_PATH1 , 'tract2town.csv');

%=== county-level SVI data for all US counties
%=== https://www.atsdr.cdc.gov/placeandhealth/svi/data_documentation_download.html
countySviData = sprintf('%s/%s', parameters.INPUT_PATH1, 'SVI2018_US_COUNTY.csv');   

%=== census tract to zip code maping for all US tracts
%=== https://www.huduser.gov/portal/datasets/usps_crosswalk.html
tract2zip = sprintf('%s/%s', parameters.INPUT_PATH1 , 'ZipCode2CensusTract.csv');   % all census tracts


%----------------------------------------------------------------------------------------------------------------
%=== TOWN LEVEL
doTown = 0;
if doTown

  %=== read connecticut census-tract SVI data and tract-to-town mapping data
  tractCT2 = readSviDataTract(tractSviData, tract2town, tractCT1);

  %=== map census-tract SVI data to the town level
  town2 = town1;
  town2 = mapSviDataTown(town2, tractCT2);

  %=== build linear model to predict vaccination rates at town level
  modelT = buildTownModels(town2, 101, 0, []);
  
  %=== build linear model to predict vaccination rates at CT census-tract level
  modelC = buildTownModels(tractCT2, -103, 0, []);
  
  %=== apply town model to vaccination rates at town level and census-tract level
  applyTownModels(modelT, town2,    -104, 0);
  applyTownModels(modelT, tractCT2, -106, 0);

  %=== build linear model to predict new cases at town level
  buildTownModelCaseRate(town2, 111, 0);
  
  %=== apply town model to tract-level data from another state (state determined by tractSviData1)
  skip = 1;
  if ~skip
    [tract1, town3] = readSviDataAnyState(tractSviData1, tract2zip, state);
    modelT1         = buildTownModels(town2, 121, 0, []);
    applyTownModels(modelT1, tract1, 122, 0);
  end
end

%----------------------------------------------------------------------------------------------------------------
%=== COUNTY LEVEL
doCounty = 0;
if doCounty

  %=== read county-level SVI data
  countyUS2 = countyUS1;
  countyUS2 = readCountySviData(countySviData, countyUS2);
  
  %=== build linear model to predict vaccination rates at county level
  modelC = buildTownModels(countyUS2, 201, 0, 'Florida');
    
  %=== build linear model to predict new cases at county level
  buildTownModelCaseRate(countyUS2, 211, 0);

  %=== write county prioritized list
  writeCountyList(countyUS2, 221);

end
    
%----------------------------------------------------------------------------------------------------------------
%=== STATE LEVEL
doState = 1;
if doState

  %=== read county-level SVI data
  countyUS2 = readCountySviData(countySviData, countyUS1);

  %=== map county-level SVI data to the state level
  state2 = state1;
  state2 = mapSviDataState(state2, countyUS2);
  
  %=== build linear model to predict vaccination rates at state level
  modelS = buildTownModels(state2, 301, 0, []);
  
  %=== apply model to vaccination rates at state level
  applyTownModels(modelS, state2, -303, 0);

  %=== build linear model to predict new cases at state level
  buildTownModelCaseRate(state2, 311, 0);
  
end

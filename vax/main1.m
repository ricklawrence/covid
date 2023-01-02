%----------------------------------------------------------------------------------------------------------------
% main1: vaccination analysis
%
% Rick Lawrence
%
%----------------------------------------------------------------------------------------------------------------

close all; 
clc;

%=== set file names for weekly CDC allocation files
CDCallocationFile1 = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Vaccine_Distribution_Allocations_by_Jurisdiction_-_Pfizer.csv');
CDCallocationFile2 = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Vaccine_Distribution_Allocations_by_Jurisdiction_-_Moderna.csv');
CDCallocationFile3 = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Vaccine_Distribution_Allocations_by_Jurisdiction_-_Janssen.csv');

%=== set cdc vaccination files (started 6/1/2021 -- eliminated json extracted files)
%=== https://data.cdc.gov/Vaccinations/COVID-19-Vaccinations-in-the-United-States-Jurisdi/unsk-b7fc
%=== 	
cdcVaccinationFileState   = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Vaccinations_in_the_United_States_Jurisdiction.csv');  
cdcVaccinationFileCounty  = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Vaccinations_in_the_United_States_County.csv');  

%=== set CT town-level vaccination files (updated Thursdays)
dataFileCTVax       = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Vaccinations_by_Town.csv');                 % after 4/23
dataFileCTVaxAge    = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Vaccinations_by_Town_and_Age_Group.csv');   % after 4/23

%=== set DPH incidence data files (transcribed from DPH pdf updated Thursdays)
dphIncidenceData    = sprintf('%s/%s', parameters.INPUT_PATH, 'DPH Incidence Data.csv');                 

%=== set CT census-tract-level vaccination file (updated Thursdays)
dataFileCTTract     = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Vaccinations_by_Census_Tract.csv');            

%=== set CDC vaccination hesitancy survey data
%=== https://data.cdc.gov/Vaccinations/COVID-19-County-Hesitancy/c4bi-8ytd
hesitancyDataFile   = sprintf('%s/%s', parameters.INPUT_PATH, 'Vaccine_Hesitancy_for_COVID-19__County_and_local_estimates.csv');

%=== town-level election data (Connecticut)
%=== https://www.courant.com/politics/elections/2020-results/
townElectionData = sprintf('%s/%s', parameters.INPUT_PATH1, 'townElectionData.csv');

%=== county-level election data
%=== https://github.com/tonmcg/US_County_Level_Election_Results_08-20/blob/master/2020_US_County_Level_Presidential_Results.csv
countyElectionData = sprintf('%s/%s', parameters.INPUT_PATH1, '2020_US_County_Level_Presidential_Results.csv');  

%=== state-level election data
stateElectionData = sprintf('%s/%s', parameters.INPUT_PATH1, 'stateElectionData.csv');

%=== state temperture data (from https://www.currentresults.com/Weather/US/average-state-temperatures-in-fall.php)
stateTemperatureData = sprintf('%s/%s', parameters.INPUT_PATH, 'stateTemperatureData.csv');

%----------------------------------------------------------------------------------------------------------------
%=== read CDC weekly allocation files
state1 = readCDCallocations(CDCallocationFile1, CDCallocationFile2, CDCallocationFile3, state);

%=== read CDC state-level vaccination data
state1 = readVaccineDataState(cdcVaccinationFileState, state1);

%=== add computed fields (eg age 5-11 vaccination rates) to state-level vaccination data
state1 = addComputedVaxData(state1);

%=== read CDC county-level vaccination data (this is a BIG file)
skipRead = 1;
if ~exist('countyUS1')
  if skipRead
    countyUS1 = countyUS;
  else
    countyUS1 = readVaccineDataCounty(cdcVaccinationFileCounty, countyUS);
  end
end

%=== read Connecticut town-level vaccination data
town1  = readVaccineDataTown(dataFileCTVax, dataFileCTVaxAge, town);

%=== read Connecticut tract-level vaccination data
tractCT1 = readVaccineDataTract(dataFileCTTract, town1);

%=== read CDC hesitancy data at county level and map to state level
[countyUS1, state1] = readHesitancyData(hesitancyDataFile, countyUS1, state1);
  
%=== read town election results
town1 = readTownElectionData(townElectionData, town1);

%=== read county election data
countyUS1 = readCountyElectionData(countyElectionData, countyUS1);

%=== read state election results
state1 = readStateElectionData(stateElectionData, state1);

%=== read state temperatures
state1 = readStateTemperatureData(stateTemperatureData, state1);

%----------------------------------------------------------------------------------------------------------------
%=== plot hesitancy data
plotHesitancyData(countyUS1, state1, -501);

%=== do state vaccine plots
plotVaccineStateData(state1, -505);

%=== do state vaccine plots over time
plotVaccineStateDataTime(state1, -511);

%=== plot connecticut town vaccination data (updated Thursdays)
todaysDate           = char(state1.vaxDates(end)); 
[~, todaysDayOfWeek] = weekday(todaysDate, 'long');
if strcmp(todaysDayOfWeek, 'Thursday1')
  plotVaccineTownData(town1, state1, 'Fairfield', 531, 1);  % Fairfield County
  plotVaccineTownData(town1, state1, [],          541, 1);  % worst CT towns
end

%=== plot vaccination demand
plotVaccinationDemand(town1, state1, countyUS1, 'Connecticut',   -561);

%=== make figures for 30 Minutes deck
plotFiguresFor30Minutes(town1, state1, county, countyUS1, -571);

%=== linear model to explain new case rates using vaccination rates and cumulative new cases
linearModelImmunity(state1, -581);

%=== analysis of kansas mask mandate
plotKansasMaskData(countyUS, -610);

%=== write vaccine summary to stdout for paste into Excel
writeSummaryVax(state1, town1);

%----------------------------------------------------------------------------------------------------------------


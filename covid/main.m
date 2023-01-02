%----------------------------------------------------------------------------------------------------------------
% COVID-19 Analysis
%
% Rick Lawrence
%
% 11/27/2020 -- complete rewrite to simplify data structures as 2D (date x entityName) arrays 
% 12/05/2020 -- eliminated recomputing of case rates etc for plots -- always using features computed in computeCovidFeatures
% 12/05/2020 -- added fix to problem dates due to mid-week holidays where we can have 8 days worth of data over 7 days
% 12/05/2020 -- copy data.ct.gov data to covidTracking data for CT to insure agreement
% 12/06/2020 -- added computeCountyTesting to compute testing for CT counties by summing over town testing
% 12/06/2020 -- added writeSummary to print text to go directly on powerpoint summary slide
% 12/07/2020 -- read and plot distribution of cases and deaths over age group for state of connecticut
% 12/09/2020 -- created video (makeVideo) of ridgefield vs fairfield county
% 12/10/2020 -- generated summary table for daily covid summary page
% 12/13/2020 -- generalized the town plot functions and clarified dates in writeSummary
% 12/17/2020 -- computed number of unexplained cases using kNN prediction of expected cases
% 12/19/2020 -- fixed copying of hospitalization to missing dates -- no need to correct its moving average for thanksgiving
% 12/19/2020 -- added computation of unexplained new cases using linear regression ... not as compelling as kNN approach
% 12/22/2020 -- added plots of vaccine data from JHU github
% 12/23/2020 -- automated process of determining factors to fix moving average in presence of mid-week holidays
% 12/24/2020 -- resurrected reading and plotting of google mobility data
% 01/02/2021 -- added reading of data.cdc.gov allocation files -- largely worthless
% 01/03/2021 -- still trying to find api to access CDC vaccine data
% 01/04/2021 -- created computeMaCorrections that uses actual CT report dates to compute MA corrections in computeCovidFeatures
% 01/09/2021 -- now processing downloaded CDC distribution and administration file by state
% 01/15/2021 -- herd immunity model
% 01/17/2021 -- added simulation model for connecticut
% 01/20/2021 -- focus on people vaccinated more than doses administered
% 01/27/2021 -- returned to reading CDC allocation files
% 01/28/2021 -- added J&J to simulation of herd immunity (sent to gov office)
% 01/29/2021 -- added plot showing vax rates vs new case rate (ie vax impact)
% 02/05/2021 -- added town-level vax data, with plots, and linear demographic model
% 02/21/2021 -- now adding US record to daily CDC file so it exactly replicates what is on CDC site
% 02/23/2021 -- CDC dropped 1dose and 2dose data; switched to youyanggu github archived CDC file
% 02/24/2021 -- added capability to also read archived CDC data from OWID github file
% 02/27/2021 -- added linear model to explain change in state cases in terms of cum cases and vaccination rates
% 02/28/2021 -- added capability to read cases and deaths from CDC file, since covidTracking is going away
% 03/07/2021 -- removed capability to read covid tracking and youyang vaccination data
% 03/07/2021 -- changed focus of simulation model from connecticut to US
% 03/10/2021 -- cleaned up vaxData by eliminate lots of unused fields
% 03/12/2021 -- extracted J&J data by reading txt file of daily json strings
% 03/13/2021 -- corrected extraction of US J&J data and rewrote simulation to greatly simplify it
% 03/14/2021 -- CDC corrected CT second dose data; added plot of ridgefield vaccinations as time series
% 03/18/2021 -- switched to reading cases and tests from JHU github (insteand of cases from CDC and tests from HHS)
%
%----------------------------------------------------------------------------------------------------------------
%=== clear workspace and close figures
clc;
clear all;       % clear workspace
close all;       % close all existing figures
rng('default');  % so we get same random number sequence every time
warning off;
t0 = tic;    % start clock

%----------------------------------------------------------------------------------------------------------------
%=== SET PARAMETERS
global parameters;

parameters.INPUT_PATH         = '../data';              % input data files
parameters.INPUT_PATH1        = 'C:\Users\rdl00\Dropbox\COVID\dataFEMA';         % input data files
parameters.OUTPUT_PATH        = '../results';           % output files

parameters.bkgdColor          = [1 1 0.8];              % background color for plots
parameters.orange             = [0.9290 0.6940 0.1250]; % orange

parameters.maWindow           = 7;                      % moving average window
parameters.shortWindow        = 7*8;                    % window for near term plots (0 means do all dates in basic plots)
parameters.trendWindow        = 7;                      % window for computing all trends
parameters.startDate          = '03/25/2020';           % first date for ALL covid data (this is start date for CT data)
parameters.endDate            = '07/23/2023';           % last date for covidtracking data ONLY -- used to recover historical data

parameters.covidTrackingSource = 'Data Source: Johns Hopkins Coronavirus Resource Center';
parameters.ctDataSource        = 'Data Source: https://data.ct.gov';
parameters.jhuDataSource       = 'Data Source: Johns Hopkins University CSSE GitHub Site';
parameters.umnDataSource       = 'Data Source: UnivMN COVID-19 Hospitalization Tracking Project';
parameters.vaxDataSource       = 'Data Source: http://civicimpact.jhu.edu';
parameters.vaxDataSourceCDC    = 'Data Source: https://data.cdc.gov';
parameters.vaxDataSourceCDCa   = 'Data Source: https://data.cdc.gov/browse?category=Vaccinations';
parameters.vaxDataSourceCDCv   = 'Data Source: https://covid.cdc.gov/covid-data-tracker/#vaccinations';
parameters.rickAnalysis        = 'Analysis: Rick Lawrence (Ridgefield COVID Task Force)';
parameters.doExtraPlots       = 0;                % do plots including hospitalized and deaths
parameters.resetStateTesting  = 0;                % use pos+neg for state testing rather than TotalTestingResults
parameters.fixProblemDates    = 1;                % fix features at problem dates caused by mid-week holidays (eg Thanksgiving)
parameters.maxTestRate        = 1000;             % some towns have very high test rates -- clip them for plotting only
parameters.stateDateOffset    = 1;                % shift CT dates so they agree with CDC 

%----------------------------------------------------------------------------------------------------------------
%=== SET INPUT FILE NAMES

%=== simple files with state, town, and county popultions etc
dataFileS   = sprintf('%s/%s', parameters.INPUT_PATH, 'StateData.csv');
dataFileT   = sprintf('%s/%s', parameters.INPUT_PATH, 'TownData.csv');
dataFileC   = sprintf('%s/%s', parameters.INPUT_PATH, 'CountyData.csv');   % US county data with population

%=== from JHU ... state-level cases and tests as replacement for covidtracking.com ... no hospitalizations or deaths here
%=== https://github.com/govex/COVID-19/blob/master/data_tables/testing_data/time_series_covid19_US.csv
dataFileJHUstate = sprintf('%s/%s', parameters.INPUT_PATH, 'time_series_covid19_US.csv');           % cases and tests

%=== from JHU ... county-level cases and deaths in separate files
%=== https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series
dataFileJHUcountyCases  = sprintf('%s/%s', parameters.INPUT_PATH, 'time_series_covid19_confirmed_US.csv');  % cases
dataFileJHUcountyDeaths = sprintf('%s/%s', parameters.INPUT_PATH, 'time_series_covid19_deaths_US.csv');     % deaths

%=== from CDC ... state-level cases and deaths -- overwrites Florida and US cases read from JHU state-level file
%=== https://data.cdc.gov/Case-Surveillance/United-States-COVID-19-Cases-and-Deaths-by-State-o/9mfq-cb36
dataFileCDCstate = sprintf('%s/%s', parameters.INPUT_PATH, 'United_States_COVID-19_Cases_and_Deaths_by_State_over_Time.csv');           % cases and tests

%=== connecticut data from data.ct.gov
%=== https://data.ct.gov/Health-and-Human-Services/COVID-19-Tests-Cases-and-Deaths-By-Town-/28fr-iqnx
%=== archived files
dataFileCTState0  = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Tests__Cases__Hospitalizations__and_Deaths__Statewide__-_ARCHIVE.csv');
dataFileCTCounty0 = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Cases__Hospitalizations__and_Deaths__By_County__-_ARCHIVE.csv');
dataFileCTTown0   = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Tests__Cases__and_Deaths__By_Town__-ARCHIVE.csv');
%=== new files as of 6/27/2022
dataFileCTState   = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_State_Level_Data.csv');
dataFileCTCounty  = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_County_Level_Data.csv');
dataFileCTTown    = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Town_Level_Data.csv');

%=== set file names for weekly CDC allocation files
CDCallocationFile1 = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Vaccine_Distribution_Allocations_by_Jurisdiction_-_Pfizer.csv');
CDCallocationFile2 = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Vaccine_Distribution_Allocations_by_Jurisdiction_-_Moderna.csv');
CDCallocationFile3 = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Vaccine_Distribution_Allocations_by_Jurisdiction_-_Janssen.csv');

%=== set cdc vaccination files (started 6/1/2021 -- eliminated json extracted files)
%=== https://data.cdc.gov/Vaccinations/COVID-19-Vaccinations-in-the-United-States-Jurisdi/unsk-b7fc
%=== https://data.cdc.gov/Vaccinations/COVID-19-Vaccinations-in-the-United-States-County/8xkx-amqh
cdcVaccinationFileState   = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Vaccinations_in_the_United_States_Jurisdiction.csv');  
cdcVaccinationFileCounty  = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Vaccinations_in_the_United_States_County.csv');  

%=== set CT town-level vaccination files
dataFileCTVax       = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Vaccinations_by_Town.csv');                 % after 4/23
dataFileCTVaxAge    = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Vaccinations_by_Town_and_Age_Group.csv');   % after 4/23

%=== set hospitalization file from UMN
stateHospitalizationDataFile = sprintf('%s/%s', parameters.INPUT_PATH, 'hospitalizations.csv');

%=== set CT census-tract-level vaccination file
dataFileCTTract     = sprintf('%s/%s', parameters.INPUT_PATH, 'COVID-19_Vaccinations_by_Census_Tract.csv');            

%=== set hospitalization file from UMN
%=== https://carlsonschool.umn.edu/mili-misrc-covid19-tracking-project/download-data
stateHospitalizationDataFile = sprintf('%s/%s', parameters.INPUT_PATH, 'hospitalizations.csv');

%=== set seroprevalence data from CDC
%=== https://covid.cdc.gov/covid-data-tracker/#national-lab
seroprevalenceData = sprintf('%s/%s', parameters.INPUT_PATH, 'SeroprevalenceData.csv');

%=== set CDC vaccination hesitancy survey data
%=== https://data.cdc.gov/Vaccinations/COVID-19-County-Hesitancy/c4bi-8ytd
hesitancyDataFile   = sprintf('%s/%s', parameters.INPUT_PATH, 'Vaccine_Hesitancy_for_COVID-19__County_and_local_estimates.csv');

%=== from google mobility (need to run bash script to remove non-US records)
%=== https://www.google.com/covid19/mobility/
mobilityDataFile = sprintf('%s/%s', parameters.INPUT_PATH, 'US_Mobility_Report.csv'); % US mobility data (from bash script)

%=== zip code demographic data
zipCodeDataFile = sprintf('%s/%s', parameters.INPUT_PATH, 'ConnecticutZipCodeData.csv');

%=== Facebook survey data from CMU site
dataFileFBstate  = sprintf('%s/%s', parameters.INPUT_PATH, 'covidcast-fb-survey-smoothed_wearing_maskState.csv');
dataFileFBcounty = sprintf('%s/%s', parameters.INPUT_PATH, 'covidcast-fb-survey-smoothed_wearing_maskCounty.csv');

%----------------------------------------------------------------------------------------------------------------
%=== READ DATA FILES

%=== read simple state data (state name, state 2-letter abbreviations, state population, etc)
stateData = readDataFileS(dataFileS);

%=== read simple CT town data (town name, county name)
townData = readDataFileT(dataFileT);

%=== read JHU cases and tests for US then state
countryJHU = readDataFileJHUstate(dataFileJHUstate, []);
stateJHU   = readDataFileJHUstate(dataFileJHUstate, stateData);

%=== read JHU county data files
countyUS = readDataFileJHUcounty(dataFileJHUcountyCases, dataFileJHUcountyDeaths, dataFileC);

%=== read CDC cases and deaths for US and then state
countryCDC = readDataFileCDCstate(dataFileCDCstate, []);
stateCDC   = readDataFileCDCstate(dataFileCDCstate, stateData);

%=== merge JHU and CDC state and country data
[state, country] = mergeJHUandCDCdata(stateJHU, stateCDC, countryJHU, countryCDC);
clear stateJHU;
clear stateCDC;
clear countryJHU;
clear countryCDC;

%=== read state-level hospitalization data from UMinn
[state, country] = readHospitalizationData(stateHospitalizationDataFile, state, country);

%=== read archived CT data
stateCT  = readDataFileCT(dataFileCTState0,  []);
county   = readDataFileCT(dataFileCTCounty0, []);
town     = readDataFileCT(dataFileCTTown0, townData);

%=== read new data format as of 6/27/2022 (starts with 6/16/2022)
stateCT  = readDataFileCTnew(stateCT, dataFileCTState,  []);
county   = readDataFileCTnew(county,  dataFileCTCounty, []);
town     = readDataFileCTnew(town,    dataFileCTTown,   townData);

%=== fix batch of new tests on 3/30/2022 that created 185 new cases
%=== GaryA says these tests go back over January and February so distribute them accordingly
town = fixRidgefieldData(town, '03/30/2022', '01/01/2022', '02/28/2022');

%=== read connecticut zip code data
demographicFeatures = readConnecticutZipCodeData(zipCodeDataFile);

%=== compute factors to correct moving averages for missing reports due to holidays
computeMaCorrections(town,0);  % added to parameters

%=== add US data to state structure
state = mergeCountryState(state, country);

%=== add CT data to town structure
town = mergeStateTown(town, stateCT);

%=== compute testing and positivity at CT county level (this data is not provided by CT state)
county = computeCountyTesting(county, town);

%=== read state-level seroprevalance data from CDC
[state, country] = readSeroprevalenceData(seroprevalenceData, state, country);

%----------------------------------------------------------------------------------------------------------------
%=== COMPUTE COVID FEATURES

country  = computeCovidFeatures(country);
state    = computeCovidFeatures(state);
stateCT  = computeCovidFeatures(stateCT);
county   = computeCovidFeatures(county);
town     = computeCovidFeatures(town);
countyUS = computeCovidFeatures(countyUS);

%=== copy CT data and features from data.ct.gov to state data to insure agreement between CT and CDC
state = copyCtData(stateCT, state);

%=== all relevant plots are in mainPlot
return;

%----------------------------------------------------------------------------------------------------------------
%=== PLOT RAW DATA

%=== cases, deaths, hospitalized
plotBasicData(country,   'United States',   101); % from covidtracking.com
plotBasicData(stateCT,   'Connecticut',     102); % from CT.gov 
plotBasicData(county,    'Fairfield',       103); % from CT.gov 
plotBasicData(town,      'Ridgefield',      104); % from CT.gov 

%=== cases, tests, positive rate
plotTestingData(country , 'United States',  111); % from covidtracking.com
plotTestingData(stateCT,  'Connecticut',    112); % from CT.gov
plotTestingData(county,   'Fairfield',      113); % from CT.gov 
plotTestingData(town,     'Ridgefield',     114); % from CT.gov  
plotTestingData(state,    'Florida',        115); 

%----------------------------------------------------------------------------------------------------------------
%=== PLOT COVID FEATURES

if parameters.doExtraPlots
  plotCovidFeatures(1, state,    201); % trend(cases)
  plotCovidFeatures(2, state,    202); % mean(cases)
  plotCovidFeatures(4, state,    203); % mean(tests)
  plotCovidFeatures(5, state,    204); % test positivity
  plotCovidFeatures(2, town,     205); % mean(cases)  
  plotCovidFeatures(2, county,   206); % mean(cases)
  plotCovidFeatures(5, town,     207); % test positivity
  plotCovidFeatures(4, town,     208); % mean(tests)
  plotCovidFeatures(6, state,    209); % hospitalized
  plotCovidFeatures(7, state,    210); % deaths
  plotCovidFeatures(2, countyUS, 211); % mean(cases)
  plotCovidFeatures(7, countyUS, 212); % deaths
end

%----------------------------------------------------------------------------------------------------------------
%=== PLOT STATE DATA

%=== plot new cases vs mask wearing
if parameters.doExtraPlots
  plotCaseVsMask(dataFileFBstate, 2, state, 302); % mean(cases)
  plotCaseVsMask(dataFileFBstate, 6, state, 303); % hospitalized
  plotCaseVsMask(dataFileFBstate, 7, state, 304); % deaths
end

%----------------------------------------------------------------------------------------------------------------
%=== CREATE FIGURES FOR DAILY TASK FORCE REPORT

%=== line chart of new case rates for town, county, state
plotTownLineChart('Ridgefield', 'Fairfield', town, county, stateCT, 401); 

%=== plot cases, tests, positivity for town
plotTestingData(town, 'Ridgefield', 402); 

%=== plot currently hospitalized in CT counties
plotHospitalized(county, state, 403); 

%=== horizontal bar chart of new case rates for all towns in county
plotTownBarChart(2, town, 'Fairfield', 405);

%=== heatmap of new case rates for all towns in county
plotHeatmap(2, town, 'Fairfield', 405);                             

%=== plot new cases vs new tests at state level
plotCaseVsTestState(state, 407);

%=== plot new cases vs new tests at town level
plotCaseVsTestTown(town, 408);

%=== compute unexplained cases using knn model
computeUnexplainedCases('Ridgefield', town, demographicFeatures, 409);

%=== make video of temporal trace in test-case space
figureOnly = 1;
makeVideo('Ridgefield', town, 'Fairfield', county, -411, figureOnly);

%=== write summary to stdout for paste into Excel
writeSummary(town, county);

%=== plot US states and counties (to get Fairfield County rank)
plotCovidFeatures(2, state,    202); % mean(cases)
plotCovidFeatures(2, countyUS, 211); % mean(cases)

%=== done
fclose('all');
getElapsedTime1(t0);

%----------------------------------------------------------------------------------------------------------------
%=== PROCESS VACCINE DATA (use main1)
%main1;

%----------------------------------------------------------------------------------------------------------------
%=== PROCESS GOOGLE MOBILITY DATA
doMobility = 0;
if doMobility
  close all; clc;
  mobilityData = readMobilityData(mobilityDataFile, stateData);
  plotMobilityData('Connecticut', 'Fairfield', mobilityData, county, 600);
end

%----------------------------------------------------------------------------------------------------------------
%=== MISCELLANOUS ANALYSIS

if parameters.doExtraPlots

  %=== linear model to explain town case rates in terms of demographic variables
  linearModelTown(demographicFeatures, town, 418)
  
  %=== risk analysis at town level
  computeRisk('Ridgefield', town, 451);
  computeRisk('Danbury',    town, 452);

  %=== compute covid lags
  computeCovidLags(country, 453);
    
end

%----------------------------------------------------------------------------------------------------------------
%=== PLOT US COUNTY DATA

if parameters.doExtraPlots

  %=== plot county mask data
  plotCaseVsMask(dataFileFBcounty, 2, countyUS, 701); % mean(cases)
  
  %== westchester county
  plotBasicData(countyUS, 'Westchester County, New York', 702);

  %=== plot county data (check against he county data we get from data.ct.gov
  plotBasicData(countyUS, 'Fairfield County, Connecticut', 703);

  %=== plot population living in counties with increasing case rates
  plotCountyPopulationFractions(countyUS, 704);

  %=== quick experimental scatter plots
  figure(711)
  plot(state.features(end,:,2), state.features(end,:,7), 'ro');           % cases vs deaths at state level
  figure(712)
  plot(countyUS.features(end,:,2), countyUS.features(end,:,7), 'b.');     % cases vs deaths at county level

end

%----------------------------------------------------------------------------------------------------------------
% mainPlot: create all figures for either task force or west conn talk
%
% Rick Lawrence
%
%----------------------------------------------------------------------------------------------------------------

%=== close all previous figures 
close all; 
clc;

%=== set flag
doTaskForce = 1;   %  1 = task force.  2 = May 2022 plots.  3 = schools.  

if doTaskForce == 1
  
  %---------------------------------------------------------------------------------------------------------------
  %=== TASK FORCE FIGURES

  %=== line chart of new case rates for town, county, state
  figureNum = 101;
  plotTownLineChart('Ridgefield', 'Fairfield', town1, county, stateCT, figureNum); 
  figureNum = figureNum + 1;

  %=== plot cases, tests, positivity for town
  plotTestingData(town, 'Ridgefield', figureNum); 
  figureNum = figureNum + 1;

  %=== plot cases & currently hospitalized & deaths in Fairfield County
  plotHospitalized(county, state, figureNum); 
  figureNum = figureNum + 4;
  
  %=== plot omicron peak analysis
  plotOmicronPeak(state, county,  town, -figureNum);
  figureNum = figureNum + 0;
  
  %=== remaining 2 plots
  plotTaskForce1(town1, state1, county, figureNum)
  figureNum = figureNum + 2;
  
  %=== town vaccination data (new data only on thursdays)
  todaysDate           = cellstr(datestr(town.datenums(end)+1, 'mm/dd/yyyy'));  % todays date is the download date plus date of our report
  [~, latestDayOfWeek] = weekday(todaysDate, 'long');
  if strcmp(latestDayOfWeek, 'Friday')
    plotVaccineTownData(town1, state1, 'Fairfield', figureNum, 1);
    figureNum = figureNum + 4;
  end

  %=== DPH incidence data (from DPH pdf released every Thursday) -- NO LONGER UPDATED
  if strcmp(latestDayOfWeek, 'Thursday1')
    plotDphIncidenceData(dphIncidenceData, state1, figureNum);
    figureNum = figureNum + 1;
  end
  
  %=== US case rates
  plotMay2022_2(town1, state1, county, countyUS1, figureNum);
  figureNum = figureNum + 1;
  
  %=== write summary to stdout for paste into Excel
  writeSummary(town, county);

  %=== write vaccine summary to stdout for paste into Excel
  writeSummaryVax(state1, town1);

elseif doTaskForce == 2
  
  %---------------------------------------------------------------------------------------------------------------
  %=== MAY 2022 FIGURES
  
  %=== main figures
  figureNum = 201;
  plotMay2022_1(town1, state1, county, countyUS1, figureNum);
  
  %=== optional detailed scatter plots
  figureNum = 211;
  plotMay2022_2(town1, state1, county, countyUS1, figureNum);
  
elseif doTaskForce == 3
  
  %---------------------------------------------------------------------------------------------------------------
  %=== RPS DATA ANALYSIS
  
  %=== set data files
  dataFileRPS1 = sprintf('%s/%s', parameters.INPUT_PATH, 'RPS School Data.csv');   % school names and enrollments
  dataFileRPS2 = sprintf('%s/%s', parameters.INPUT_PATH, 'RPS Case Data 2022.txt'); % raw data from RPS COVID-19 Tracker
  dataFileRPS3 = sprintf('%s/%s', parameters.INPUT_PATH, 'RPS Case Data 2023.txt'); % raw data from RPS COVID-19 Tracker
  
  %=== read data files
  rpsData = readRpsData(dataFileRPS1, dataFileRPS2, dataFileRPS3);
  
  %=== plot data
  plotRpsData(rpsData, town1, 301);

end

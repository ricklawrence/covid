function [state, country] = mergeJHUandCDCdata(stateJHU, stateCDC, countryJHU, countryCDC)
%
% merge JHU and CDC data
% get cases and deaths from CDC, testing from JHU, no hospitalization data from either
%
global parameters;
fprintf('\n--> mergeJHUandCDCdata\n');

%=== make sure we have same dates for JHU and CDC data
fprintf('stateJHU.lastDate = %s  countryJHU.lastDate   = %s\n', stateJHU.lastDate,  countryJHU.lastDate);
fprintf('stateCDC.lastDate = %s  countryCDC.lastDate   = %s\n', stateCDC.lastDate,  countryCDC.lastDate);
misMatch = 0;
if ~strcmp(stateJHU.lastDate, stateCDC.lastDate)
  %error('Date mis-match between JHU and CDC state-level files ... using JHU data.');
  misMatch = 1;
end
if ~strcmp(countryJHU.lastDate, countryCDC.lastDate)
  %error('Date mis-match between JHU and CDC country-level files ... using JHU data.');
  misMatch = 1;
end

%=== use CDC data if there is a mismatch in dates ... this means we have no testing data
if misMatch
  state   = stateCDC;
  country = countryCDC;
  fprintf('Dates disagree: using CDC data (without test data from JHU).\n');
  return;
else
  fprintf('Dates agree: merging CDC cases and deaths into JHU data.\n');
end

%=== start with JHU data (so we get testing from JHU)
state   = stateJHU;
country = countryJHU;

%=== STATE: All States: use CDC cases and deaths
state.cumCases  = stateCDC.cumCases;
state.newCases  = stateCDC.newCases;     % 7-23-2021: using CDC cases to get agreement with WaPo cases
state.newDeaths = stateCDC.newDeaths;

%=== STATE: Florida: use CDC cases
fl                   = find(strcmp(state.names0, 'FL'));
state.cumCases(:,fl) = stateCDC.cumCases(:,fl);
state.newCases(:,fl) = stateCDC.newCases(:,fl);

%=== COUNTRY: use CDC cases and deaths
country.cumCases  = countryCDC.cumCases;
country.newCases  = countryCDC.newCases;
country.newDeaths = countryCDC.newDeaths;

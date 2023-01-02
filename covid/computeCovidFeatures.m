function data1 = computeCovidFeatures(data)
%
% compute covid features and return them in data structure
%
global parameters;
fprintf('\n--> computeCovidFeatures\n');
fprintf('  Level = %s\n', data.level);

%=== copy data structure
data1             = data;
data1.numFeatures = 10;
data1.features    = NaN(data1.numDates, data1.numNames, data1.numFeatures);

%=== set labels
data1.featureLabels           = {'7-Day Trend in New Cases'; ...
                                 'New Case Rate'; ...
                                 '7-Day Trend in New Tests'; ...
                                 'New Test Rate'; ...
                                 'Test Positivity'; ... 
                                 'Currently Hospitalized'; ...
                                 'Death Rate'; ... 
                                 'Cumulative Case Rate'; ...
                                 'Case Hospitalization Rate'}; 

                               
data1.featureTitles           = {'7-Day Trend in New Cases (%)'; ...
                                 'New Case Rate (Per 100,000 Residents)'; ...
                                 '7-Day Trend in New Tests (%)'; ...
                                 'New Test Rate (Per 100,000 Residents)'; ...
                                 'Test Positivity (%)'; ...
                                 'Currently Hospitalized (Per 100,000 Residents)'; ...
                                 'Death Rate (Per 100,000 Residents)'; ...
                                 'Cumulative Case Rate (Per 100,000 Residents)'; ...
                                 'Ratio of Hospitalizations to New Case Rate'};

%=== compute case features
newCases               = data.newCases;
newCasesMA             = movingAverage(newCases, parameters.maWindow);
data1.features(:,:,1)  = computeTrends(newCasesMA, parameters.trendWindow);
data1.features(:,:,2)  = computeCaseRates(newCasesMA, data.population); 

%=== compute test features
newTests               = data.newTests;
newTestsMA             = movingAverage(newTests, parameters.maWindow);
data1.features(:,:,3)  = computeTrends(newTestsMA, parameters.trendWindow);
data1.features(:,:,4)  = computeCaseRates(newTestsMA, data.population);   

%=== compute test positivity
data1.features(:,:,5)  = 100*newCasesMA ./ newTestsMA;

%=== compute hospitalized features
hospitalized           = data.hospitalized;
MA                     = movingAverage(hospitalized, parameters.maWindow);
data1.features(:,:,6)  = computeCaseRates(MA, data.population);   

%=== compute death features
newDeaths              = data.newDeaths;
MA                     = movingAverage(newDeaths, parameters.maWindow);
data1.features(:,:,7)  = computeCaseRates(MA, data.population);   

%=== compute cumulative cases
cumCases               = data.cumCases;
data1.features(:,:,8)  = computeCaseRates(cumCases, data.population);   

%=== compute ratio of hospitalizations to new cases
parameters.hospitalizationLag = 14;
lag = parameters.hospitalizationLag;
i2  = lag+1:data1.numDates;
i1  = i2 - lag;
meanHospitalizations   = data1.features(i2,:,6);     % average of currently hospitalized over 1 week
totalNewCases          = 7*data1.features(i1,:,2);   % total number of new cases over 1 week, lagged by 14 days
data1.features(i2,:,9) = meanHospitalizations ./ totalNewCases;

%=== compute hospitalized trend
hospitalized           = data.hospitalized;
MA                     = movingAverage(hospitalized, parameters.maWindow);
data1.features(:,:,10) = computeTrends(MA, parameters.trendWindow);

%-------------------------------------------------------------------------------------------
% FIX PROBLEM DATES IN CONNECTICUT DATA

%=== we fix all Connecticut data: town, county, state
ctData = strcmp(data1.level, 'StateX')  || strcmp(data1.level, 'StateCT') ...
      || strcmp(data1.level, 'County') || strcmp(data1.level, 'Town');
if ~parameters.fixProblemDates || ~ctData
  return;
end

%=== we apply MA correction factors features, except test positivity since it is a ratio
problemDates = parameters.problemDates;
for d=1:length(problemDates)
  factor     = parameters.problemFactors(d);
  fixDatenum = datenum(problemDates(d)); 
  fixDate    = cellstr(datestr(fixDatenum, 'mm/dd/yyyy'));
  dateIndex  = find(strcmp(fixDate, data1.dates));  % single problem date
  if ~isempty(dateIndex)
    if strcmp(data1.level, 'State')
      nameIndex = find(strcmp(data1.names, 'Connecticut'));  % only fix Connecticut in the state data
    else
      nameIndex = [1:data1.numNames];                        % fix all entities in CT state, CT county, CT town data
    end

    %=== fix means
    data1.features(dateIndex,nameIndex,2) = factor*data1.features(dateIndex,nameIndex,2);  % mean(cases)
    data1.features(dateIndex,nameIndex,4) = factor*data1.features(dateIndex,nameIndex,4);  % mean(tests)
    data1.features(dateIndex,nameIndex,6) = factor*data1.features(dateIndex,nameIndex,6);  % mean(hospitalizations)
    data1.features(dateIndex,nameIndex,7) = factor*data1.features(dateIndex,nameIndex,7);  % mean(deaths)

    %=== recompute trends with corrected means
    caseTrends = computeTrends(data1.features(:,:,2), parameters.trendWindow);             % using corrected data
    data1.features(dateIndex,nameIndex,1) = caseTrends(dateIndex,nameIndex);               % trend(cases)
    testTrends = computeTrends(data1.features(:,:,4), parameters.trendWindow);             % using corrected data
    data1.features(dateIndex,nameIndex,3) = testTrends(dateIndex,nameIndex);               % trend(tests)
    hospTrends = computeTrends(data1.features(:,:,6), parameters.trendWindow);             % using corrected data
    data1.features(dateIndex,nameIndex,10)= hospTrends(dateIndex,nameIndex);               % trend(tests)

    %fprintf('  Applied factor = %4.3f to moving average at %s\n', factor, char(problemDates(d)));
  end
end
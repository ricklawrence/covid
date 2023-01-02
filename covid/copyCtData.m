function state1 = copyCtData(stateCT, state)
%
% copy data from CT data (stateCT) to state data (state)
%
global parameters;
fprintf('\n--> copyCtData\n');
state1 = state;

option = 2;
if option == 1
  
  %=== option 1: align dates
  fprintf('Copied CT data to state data by aligning dates. \n');
  [~,dateIndex1, dateIndex2] = intersect(state.datenums, stateCT.datenums);
  [dateIndex1 dateIndex2];
else

  %=== option 2: always copy final CT data
  fprintf('Copied most recent CT data to state data. \n');
  numDates   = min(state.numDates, stateCT.numDates);
  d1         = state.numDates   - numDates + 1;
  d2         = stateCT.numDates - numDates + 1;
  dateIndex1 = d1:state.numDates;
  dateIndex2 = d2:stateCT.numDates;
end

%=== copy main data fields from CT data to state data
ct                                 = find(strcmp(state.names, 'Connecticut'));
state1.cumCases(dateIndex1,ct)     = stateCT.cumCases(dateIndex2,1);
state1.newCases(dateIndex1,ct)     = stateCT.newCases(dateIndex2,1);
state1.newTests(dateIndex1,ct)     = stateCT.newTests(dateIndex2,1);
state1.newDeaths(dateIndex1,ct)    = stateCT.newDeaths(dateIndex2,1);
state1.hospitalized(dateIndex1,ct) = stateCT.hospitalized(dateIndex2,1);
state1.testPositive(dateIndex1,ct) = stateCT.testPositive(dateIndex2,1);
state1.datesCT                     = stateCT.dates;
state1.datesCT(dateIndex1)         = stateCT.dates(dateIndex2);

%=== copy features
state1.features(dateIndex1,ct,:)   = stateCT.features(dateIndex2,:);

%=== missing final date in CT data
all                             = [1:length(state.dates)]';
missing                         = setdiff(all, dateIndex1);
state1.cumCases(missing,ct)     = NaN;
state1.newCases(missing,ct)     = NaN;
state1.newTests(missing,ct)     = NaN;
state1.newDeaths(missing,ct)    = NaN;
state1.hospitalized(missing,ct) = NaN;
state1.testPositive(missing,ct) = NaN;


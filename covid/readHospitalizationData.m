 function  [state1, country1] = readHospitalizationData(dataFile, state, country)
%
% read state-level hospitalization data from Univ Minn COVID hospitalization tracking project
%
global parameters;
fprintf('\n--> readHospitalizationData\n');

%== copy structures
state1   = state;
country1 = country;

%=== read file as a table
dataTable = readtable(dataFile);
head(dataTable,8);

%=== summary
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dataTable.Date);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows, dataFile);

%=== get dates
dates0     = dataTable.Date;
datenums   = datenum(dates0);
fprintf('Start Date = %s\n', datestr(min(datenums), 'mm/dd/yyyy'));
fprintf('Last  Date = %s\n', datestr(max(datenums), 'mm/dd/yyyy'));

%=== get all short names
names0     = dataTable.StateAbbreviation;

%=== get data
hospitalized = dataTable.CurrentHospitalizations;

%=== this data has different dates for each state, so we join data for each state separately
state1.hospitalized         = NaN(state1.numDates, state1.numNames);
for s=1:state1.numNames
  stateName0                = state1.names0(s);
  i0                        = find(strcmp(stateName0, names0));
  stateDatenums             = datenums(i0);
  [~,i1,i2]                 = intersect(stateDatenums, state1.datenums);
  state1.hospitalized(i2,s) = hospitalized(i0(i1));
end

%=== compute US as sum over states
country1.hospitalized         = nansum(state1.hospitalized,2);
filter                        = find(country1.hospitalized == 0);
country1.hospitalized(filter) = NaN;

%=== debug
debug = 0;
if debug
  ct = 7;
  d1 = state1.numDates - 5;
  d2 = state1.numDates;
  for d=d1:d2
    fprintf('%s\t%d\n', char(state1.dates(d)), state1.hospitalized(d,ct));
  end
  for d=d1:d2
    fprintf('%s\t%d\n', char(state1.dates(d)), country1.hospitalized(d));
  end
end

 function  [state1, country1] = readSeroprevalenceData(dataFile, state, country)
%
% read state-level seroprevalence data from CDC (extracted manually from CDC tracking page)
%
global parameters;
fprintf('\n--> readSeroprevalenceData\n');

%== copy structures
state1   = state;
country1 = country;

%=== read file as a table
dataTable = readtable(dataFile);
head(dataTable,8);

%=== summary
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dataTable.Abbreviation);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows, dataFile);

%=== get all short names
names0     = dataTable.Abbreviation;

%=== get data and join into existing structure
numDates                      = 7;
infectedFraction(:,1)         = dataTable.Feb22;
infectedFraction(:,2)         = dataTable.Jan22;
infectedFraction(:,3)         = dataTable.Dec21;
infectedFraction(:,4)         = dataTable.Nov21;
infectedFraction(:,5)         = dataTable.Oct21;
infectedFraction(:,6)         = dataTable.Sept21;
infectedFraction(:,7)         = dataTable.July21;
[~,i1,i2]                     = intersect(names0, state1.names0);
state1.infectedFraction       = NaN(state1.numNames,numDates);
state1.infectedFraction(i2,:) = infectedFraction(i1,:);
state1.infectedFractionDates  = {'02/28/2022'; '01/31/2022'; '12/31/2021'; '11/30/2021'; '10/31/2021'; '09/30/2021'; '07/31/2021'};
state1.infectedDateLabels    = {'Feb 2022'; 'Jan 2022'; 'Dec 2021'; 'Nov 2021'; 'Oct 2021'; 'Sept 2021'; 'July 2021'};

%=== save US data
s = find(strcmp(names0, 'US'));
country1.infectedFraction = infectedFraction(s);

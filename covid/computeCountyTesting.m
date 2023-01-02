function county1 = computeCountyTesting(county, town)
%
% testing does not exist at CT county level -- compute it using town testing data
%
global parameters;
fprintf('\n--> computeCountyTesting\n');
fprintf('Computing testing at CT County level.\n')

%=== allocate array
county1   = county;
newCases1 = county1.newCases;
[~,i1,i2] = intersect(town.dates, county.dates);

%=== compute new cases and testing at CT county level
for c=1:length(county.names)
  index    = find(strcmp(county.names(c), town.countyNames));
  newCases = nansum(town.newCases(:,index), 2);
  newTests = nansum(town.newTests(:,index), 2);
  newCases1(i1,c)       = newCases(i2,:);
  county1.newTests(:,c) = newTests;
  county1.newCases(:,c) = newCases;  % added 4/1/2022 after ridgefield data fix
end

%=== compute test positivity
county1.testPositive = county1.newCases ./ county1.newTests;

%=== compare new cases computed via town to state-reported county numbers
diff      = abs(county1.newCases - newCases1);
numWeeks  = 16;
dateIndex = county.numDates+1-numWeeks*7 : county.numDates;
numDiff   = sum(sum(diff(dateIndex,:)));
fprintf('There are %d disagreements between computed cases and state-reported cases over past %d weeks.\n', numDiff, numWeeks);

function town1 = fixRidgefieldData(town, date, date1, date2)
%
% fix batch of new tests on 3/30/2022 that created 185 new cases
% GaryA says these tests go back over January and February so distribute them accordingly
%
% Generalized to accommodate any dates:
%   date  = date when batch of tests were reported
%   date1 = initial date in period when test actualy occurred
%   date2 = final   date in period when test actualy occurred
%
global parameters;
fprintf('\n--> fixRidgefieldData\n');

%=== copy full structure
town1 = town;

%=== get ridgefield data for the anomolous date
t         = find(strcmp(town.names, 'Ridgefield'));
d         = find(strcmp(town.dates, date));
newCases0 = town.newCases(d,t);
newTests0 = town.newTests(d,t);

%=== compute 7-day moving average up to day before and make them integers
period     = d-7:d-1;
newCasesMA = round(mean(town.newCases(period,t)));
newTestsMA = round(mean(town.newTests(period,t)));

%=== replace anomolous data with 7-day moving average
town1.newCases(d,t) = newCasesMA;
town1.newTests(d,t) = newTestsMA;
fprintf('  Replaced %d Ridgefield New Cases on %s with 7-day moving average = %d.\n', newCases0, date, town1.newCases(d,t));

%=== apply multiplier to increase new cases during period when the tests were done
d1         = find(strcmp(town.dates, date1));
d2         = find(strcmp(town.dates, date2));
period     = d1:d2;
index      = find(town.newCases(period,t) > 0);  % only modify days with actual cases
index      = period(index);
deltaCases = newCases0 - newCasesMA;
deltaTests = newTests0 - newTestsMA;
newCases0  = sum(town.newCases(index,t));
newTests0  = sum(town.newTests(index,t));
ratioCases = (newCases0 + deltaCases) ./ newCases0;
ratioTests = (newTests0 + deltaTests) ./ newTests0;
town1.newCases(index,t) = round(town1.newCases(index,t) .* ratioCases);
town1.newTests(index,t) = round(town1.newTests(index,t) .* ratioTests);
fprintf('  Added %d new cases between %s and %s.\n', deltaCases, date1, date2);

%=== preserve sum of daily new cases by modifying entries for last N days
addedCases = sum(town1.newCases(index,t)) - sum(town.newCases(index,t));
addedTests = sum(town1.newTests(index,t)) - sum(town.newTests(index,t));
diffCases  = deltaCases - addedCases;
diffTests  = deltaTests - addedTests;
index1     = index(end-abs(diffCases)+1:end);
index2     = index(end-abs(diffTests)+1:end);
town1.newCases(index1,t) = town1.newCases(index1,t) + sign(diffCases);
town1.newTests(index2,t) = town1.newTests(index2,t) + sign(diffTests);

%=== check results -- these numbers should agree
addedCases = sum(town1.newCases(index,t)) - sum(town.newCases(index,t));
if deltaCases ~= addedCases
  [town.newCases(index,t) town1.newCases(index,t)];
  error('addedCases = %d  deltaCases = %d\n', addedCases, deltaCases);
end

%=== recompute test positivity
town1.testPositive(:,t) = town1.newCases(:,t) ./ town1.newTests(:,t);

%=== recompute cumulative cases during this period
for dd=2:length(index)
  d2 = index(dd);
  d1 = index(dd-1);
  town1.cumCases(d2,t) = town1.cumCases(d1,t) + town1.newCases(d2,t);
end
[town.cumCases(index,t) town1.cumCases(index,t)];

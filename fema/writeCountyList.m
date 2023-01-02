function writeCountyList(county, figureNum)
%
% build a prioritized list of US counties
%
global parameters;
if figureNum < 0
  return;
end
fprintf('\n--> writeCountyList\n');

%=== get county names
names       = county.names0;
stateNames  = county.stateNames;
numCounties = county.numNames;
ranks       = NaN(numCounties,5);

%=== set cutoff on completeness (fraction of state vax records that get mapped to FIPS in that state)
completenessCutoff  = 90;
fprintf('Completeness cutoff = %d\n', completenessCutoff);

%=== 1. fraction fully vaccinated
vaxRates            = county.vaxDataN(end,:,3)'; % fully vaccinated, all ages
completeness        = county.vaxDataN(end,:,1)'; 
filter              = find(~isnan(vaxRates) & completeness > completenessCutoff);  
[values,sortIndex]  = sort(vaxRates(filter), 'ascend');
sortIndex1          = filter(sortIndex);
ranks(sortIndex1,1) = [1:length(sortIndex1)]';

%=== 2. number of cases in last N days
N                   = 30;
newCases            = nansum(county.newCases(end-N+1:end, :), 1)';
newCases            = 100000 * newCases ./ county.population;
newCases            = newCases ./ N; 
filter              = find(~isnan(newCases));
[values,sortIndex]  = sort(newCases(filter), 'descend');
sortIndex2          = filter(sortIndex);
ranks(sortIndex2,2) = [1:length(sortIndex2)]';

%=== 3. SVI income
sviIncome           = county.sviValues(:,3);
filter              = find(~isnan(sviIncome));
[values,sortIndex]  = sort(sviIncome(filter), 'descend');
sortIndex3          = filter(sortIndex);
ranks(sortIndex3,3) = [1:length(sortIndex3)]';

%=== 4. 2020 biden vote
bidenVote           = 1 - county.republicanVote;
filter              = find(~isnan(bidenVote));
[values,sortIndex]  = sort(bidenVote(filter), 'descend');
sortIndex4          = filter(sortIndex);
ranks(sortIndex4,4) = [1:length(sortIndex4)]';

%=== 5. population
population          = county.population;
filter              = find(~isnan(population));
[values,sortIndex]  = sort(population(filter), 'descend');
sortIndex5          = filter(sortIndex);
ranks(sortIndex5,5) = [1:length(sortIndex5)]';

%=== get unvaccinated population
unvaccinated        = (1 - 0.01*vaxRates) .* population;

%=== 6. weighted ranks
weights             = [2 2 1 1 1]; 
weights             = weights ./ sum(weights);
weights             = repmat(weights, numCounties, 1);
weightedRanks       = sum(ranks .* weights, 2);
filter              = find(~isnan(weightedRanks));
[values,sortIndex]  = sort(weightedRanks(filter), 'ascend');
sortIndex6          = filter(sortIndex);
ranks(sortIndex6,6) = [1:length(sortIndex6)]';

%=== set file name
fileName = sprintf('%s/%s', parameters.INPUT_PATH1, 'CountyList.txt');
fid      = fopen(fileName, 'w');
%fid      = 1;

%=== write header
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', ...
            'County', 'State',      ...
            'Overall US Rank (3142 Counties)', 'Overall Score', ...
            'Fully Vaccinated Rank',           'Fully Vaccinated (%)', ...
            'New Case Rank',                   'New Case Rate (per 100K)', ...
            'SVI Income Rank',                 'SVI Income Percentile', ...
            '2020 Biden Vote Rank',            '2020 Biden Vote (%)', ...
            'Population Rank',                 'Population', ...
            'Unvaccinated Population');

%=== write data sorted by overall rank
if fid ~= 1
  numPrint = length(sortIndex6);
else
  numPrint = 50;
end
for i=1:numPrint
  c = sortIndex6(i);
  fprintf(fid,'%s\t%s\t%d\t%2.0f\t%d\t%3.4f\t%d\t%3.2f\t%d\t%5.4f\t%d\t%3.4f\t%d\t%2.0f\t%2.0f\n', ...
    char(names(c)), char(stateNames(c)), ...
    ranks(c,6), weightedRanks(c), ...
    ranks(c,1), 0.01*vaxRates(c),  ranks(c,2), newCases(c),  ranks(c,3), sviIncome(c), ...
    ranks(c,4), bidenVote(c), ranks(c,5), population(c),...
    unvaccinated(c));
end

%=== close file
if fid ~= 1
  fprintf('Wrote %d town records to %s\n', numPrint, fileName);
  fclose('all');
end

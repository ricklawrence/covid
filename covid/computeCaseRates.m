function caseRates = computeCaseRates(cases, populations)
%
% compute case rates per 100,000 population
%
[numDates, numNames] = size(cases);
numNames1            = length(populations);
if numNames ~= numNames1
  error('computeCaseRates: dimension mismatch.');
end
caseRates = cases ./ repmat(populations', numDates, 1);
caseRates = 100000*caseRates;   % express per 100,000
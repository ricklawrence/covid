function newCases = computeNewCases(cases)
%
% compute new cases as daily difference of cumulative cases
% works for any variable
% 9/29/2020: any NaN in cases causes a NaN in new cases
%
global parameters;

[numDates, numSeries]  = size(cases);
newCases               = NaN(numDates, numSeries);
newCases(2:numDates,:) = cases(2:numDates,:) - cases(1:numDates-1,:);


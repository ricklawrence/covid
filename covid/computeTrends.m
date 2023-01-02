function trends = computeTrends(casesMA, trendWindow)
%
% compute trends for any time series (expected to have already been averaged)
%
[numDates, numSeries] = size(casesMA);
trends       = NaN(numDates, numSeries);
w1           = 1 : numDates-trendWindow;
w2           = trendWindow+1 : numDates;
trends(w2,:) = casesMA(w2,:) ./ casesMA(w1,:) - 1;
trends       = 100*trends;  % express as percent
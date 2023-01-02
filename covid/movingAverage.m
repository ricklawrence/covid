function y1 = movingAverage(y, moveAvgWindow)
%
% return moving average of time series y
%
%=== return if window is zero
y1 = y;
if moveAvgWindow == 0
  return;
end

%=== initialize to NaN
[numPoints, numSeries] = size(y); 
if numPoints == 1
  y = y';
  [numPoints, numSeries] = size(y); 
end
y1 = NaN(numPoints, numSeries);

%=== compute moving average over nonNan values
for i2=1:numPoints
  i1 = max(1, i2-moveAvgWindow+1);  % use as many values as available
  x  = i1:i2;
  y1(i2,:) = nanmean(y(x,:));
end
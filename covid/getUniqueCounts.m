function [values, counts] = getUniqueCounts(A, printFlag)
%
% returns unique values and their counts
%
% test examples:
% A = [2 2 1 4 4 4 4 3 3 3];
% B = {'b' 'b' 'a' 'd' 'd' 'd' 'd' 'c' 'c' 'c'};

%=== default printFlag is 1
if nargin == 1
  printFlag = 1;
end

%=== get unique values and counts
if isfloat(A)
  %=== input array is numeric
  values = unique(A);
  counts = histcounts(A, 'BinMethod','integers');
else
  %=== input array is character
  [values,~,i2] = unique(A);
  counts        = histcounts(i2,'BinMethod','integers');
end

%=== sort the results
[~,sortIndex] = sort(counts, 'descend');
counts        = counts(sortIndex);
values        = values(sortIndex);

%=== print the results
if ~printFlag 
  return;
end
if isfloat(A)
  for i=1:length(counts)
    fprintf('%d\t%d\n', values(i), counts(i));
  end
else
  for i=1:length(counts)
    fprintf('%s\t%d\n', char(values(i)), counts(i));
  end
end


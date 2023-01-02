function numOut = addComma(numIn)
%
% format number with commas
%
jf     = java.text.DecimalFormat;
numOut = char(jf.format(numIn));
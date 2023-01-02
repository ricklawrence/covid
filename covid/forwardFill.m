function fullSequence = forwardFill(sequence)
%
% expand a sparse sequence to the full sequence by forward filling
%
fullSequence = sequence;
for d=1:length(sequence)
  if isnan(fullSequence(d)) & d == 1
    fullSequence(d) = 0;
  elseif isnan(fullSequence(d)) & d > 1
    fullSequence(d) = fullSequence(d-1);
  end
end


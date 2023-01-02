function state = mapSviDataTown(state, county)
%
% map SVI data to town level
%
fprintf('\n--> mapSviDataTown\n');

%=== map county-level data to state by population-weighting the county data
[~, numThemes] = size(county.sviThemes);
[~, numValues] = size(county.sviValues);
state.sviThemes = NaN(length(state.names), numThemes, 3);
state.sviValues = NaN(length(state.names), numValues, 3);
for s=1:length(state.names)
  name0 = state.names0(s);
  index = find(contains(county.names0, name0));
  if ~isempty(index)
    sviThemes              = county.sviThemes(index,:);
    weights                = county.population(index) ./ sum(county.population(index));
    weights                = repmat(weights,1,numThemes);
    state.sviThemes(s,:,1) = nansum(weights .* sviThemes, 1);  % population-weighted mean in this town
    state.sviThemes(s,:,2) = max(sviThemes,[],1);              % max in this town
    state.sviThemes(s,:,3) = min(sviThemes,[],1);              % min in this town
    sviValues              = county.sviValues(index,:);
    weights                = county.population(index) ./ sum(county.population(index));
    weights                = repmat(weights,1,numValues);
    state.sviValues(s,:,1) = nansum(weights .* sviValues, 1);  % population-weighted mean in this town
    state.sviValues(s,:,2) = max(sviValues,[],1);              % max in this town
    state.sviValues(s,:,3) = min(sviValues,[],1);              % min in this town
  end
end

%=== renormalize summed sviThemes
for v=1:numThemes
  sumThemes                        = state.sviThemes(:,v,1);
  [~, sortIndex]                   = sort(sumThemes);
  i                                = find(~isnan(sumThemes(sortIndex)));
  j                                = find( isnan(sumThemes(sortIndex)));
  ranks                            = [0:length(i)-1];                  % 0 to N-1 only for nonNaN entries
  ranks                            = ranks ./ max(ranks);              % 0 to 1   only for nonNaN entries
  state.sviThemes(sortIndex(i),v,1) = ranks;
  state.sviThemes(sortIndex(j),v,1) = NaN;
end

%=== renormalize summed sviValues
for v=1:numValues
  sumValues                        = state.sviValues(:,v,1);
  [~, sortIndex]                   = sort(sumValues);
  i                                = find(~isnan(sumValues(sortIndex)));
  j                                = find( isnan(sumValues(sortIndex)));
  ranks                            = [0:length(i)-1];                  % 0 to N-1 only for nonNaN entries
  ranks                            = ranks ./ max(ranks);              % 0 to 1   only for nonNaN entries
  state.sviValues(sortIndex(i),v,1) = ranks;
  state.sviValues(sortIndex(j),v,1) = NaN;
end

%=== save names of SVI themes
state.sviThemeLabels = county.sviThemeLabels;
state.sviValueLabels = county.sviValueLabels;

%=== print summary
numTowns = length(find(~isnan(state.sviThemes(:,5,1))));
fprintf('Mapped census-tract SVI data to %d states.\n', numTowns);

%--------------------------------------------------------------------
%=== check data
debug = 0;
if ~debug
  return;
end
[~,sortIndex] = sort(state.sviValues(:,3,1));
state.names(sortIndex)
  






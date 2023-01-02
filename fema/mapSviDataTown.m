function town = mapSviDataTown(town, sviData)
%
% map connecticut SVI data to town level
%
fprintf('\n--> mapSviDataTown\n');

%=== map census tracks to towns by population-weighting the census-tract data
[~, numThemes] = size(sviData.sviThemes);
[~, numValues] = size(sviData.sviValues);
town.sviThemes = NaN(length(town.names), numThemes, 3);
town.sviValues = NaN(length(town.names), numValues, 3);
for t=1:length(town.names)
  index = find(strcmp(town.names(t), sviData.townNames));
  if ~isempty(index)
    sviThemes             = sviData.sviThemes(index,:);
    weights               = sviData.population(index) ./ sum(sviData.population(index));
    weights               = repmat(weights,1,numThemes);
    town.sviThemes(t,:,1) = nansum(weights .* sviThemes, 1);  % population-weighted mean in this town
    town.sviThemes(t,:,2) = max(sviThemes,[],1);              % max in this town
    town.sviThemes(t,:,3) = min(sviThemes,[],1);              % min in this town
    sviValues             = sviData.sviValues(index,:);
    weights               = sviData.population(index) ./ sum(sviData.population(index));
    weights               = repmat(weights,1,numValues);
    town.sviValues(t,:,1) = nansum(weights .* sviValues, 1);  % population-weighted mean in this town
    town.sviValues(t,:,2) = max(sviValues,[],1);              % max in this town
    town.sviValues(t,:,3) = min(sviValues,[],1);              % min in this town
  end
end

%=== renormalize summed sviThemes
for v=1:numThemes
  sumThemes                        = town.sviThemes(:,v,1);
  [~, sortIndex]                   = sort(sumThemes);
  i                                = find(~isnan(sumThemes(sortIndex)));
  j                                = find( isnan(sumThemes(sortIndex)));
  ranks                            = [0:length(i)-1];                  % 0 to N-1 only for nonNaN entries
  ranks                            = ranks ./ max(ranks);              % 0 to 1   only for nonNaN entries
  town.sviThemes(sortIndex(i),v,1) = ranks;
  town.sviThemes(sortIndex(j),v,1) = NaN;
end

%=== renormalize summed sviValues
for v=1:numValues
  sumValues                        = town.sviValues(:,v,1);
  [~, sortIndex]                   = sort(sumValues);
  i                                = find(~isnan(sumValues(sortIndex)));
  j                                = find( isnan(sumValues(sortIndex)));
  ranks                            = [0:length(i)-1];                  % 0 to N-1 only for nonNaN entries
  ranks                            = ranks ./ max(ranks);              % 0 to 1   only for nonNaN entries
  town.sviValues(sortIndex(i),v,1) = ranks;
  town.sviValues(sortIndex(j),v,1) = NaN;
end

%=== save names of SVI themes
town.sviThemeLabels = sviData.sviThemeLabels;
town.sviValueLabels = sviData.sviValueLabels;

%=== print summary
numTowns = length(find(~isnan(town.sviThemes(:,5,1))));
fprintf('Mapped census-tract SVI data to %d towns.\n', numTowns);

%--------------------------------------------------------------------
%=== check data
debug = 0;
if ~debug
  return;
end
t = find(strcmp(town.names, 'Ridgefield'));
town.sviThemes(t,5,:)
i = find(town.sviThemes(:,5,2) > 0.75);
j = find(strcmp(town.sviFlag, 'Yes'));
fprintf('sviFlag - sviTheme > 0.75:\n');
setdiff(town.names(j), town.names(i))
fprintf('sviTheme > 0.75 - sviFlag:\n');
setdiff(town.names(i), town.names(j))

  






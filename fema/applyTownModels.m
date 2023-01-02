function applyTownModels(model, town, figureNum, printFlag)
%
% apply model to predict town vaccination rates using SVI data as explanatory features
% also works at state level
% 'town' must contain sviValues and sviThemes
%
global parameters;
if figureNum < 0
  return;
end
fprintf('\n--> applyTownModels\n');
fprintf('Level = %s\n', town.level);

%=== construct features based on svi data in town structure
%=== add all SVI values as features
f             = 1:15;
X             = town.sviValues(:,f,1);       % weighted sum for each of 15 values
featureLabels = town.sviValueLabels;

%=== add the single SVI theme (used by State to prioritize towns)
f                = 16;
X(:,f)           = town.sviThemes(:,5,1);     
featureLabels(f) = {'Overall SVI Theme'}; 

%=== add republican vote
f                = 17;
if isfield(town,'republicanVote')
  X(:,f)           = town.republicanVote;
  featureLabels(f) = {sprintf('2020 Republican Presidential Vote')};
else
  X(:,f)           = zeros(length(town.names), 1);
  featureLabels(f) = {sprintf('MISSING')};
end

%=== add hesitancy
if model.numFeatures == 18
  f                = 18;
  X(:,f)           = town.hesitancy(:,1);  % strongly hesitant + hesitant + unsure
  featureLabels(f) = {sprintf('CDC Estimated Vaccine Hesitancy')};
end

%=== remove any NaNs
filter    = find(~isnan(sum(X,2)));
X         = X(filter,:);
townNames = town.names(filter);

%=== if this CountyUS, filter to specified state
if strcmp(town.level, 'CountyUS')
  stateName  = 'Louisiana';
  filter     = find(contains(townNames, stateName));
  X          = X(filter,:);
  townNames  = townNames(filter);
end
 
%=== normalize data using training-set mean and std
[numRecords, numFeatures] = size(X);
meanX = repmat(model.meanX, numRecords, 1);
stdX  = repmat(model.stdX,  numRecords, 1);
X     = (X - meanX) ./ stdX;

%=== zero features normalize to NaN ... zero them out before applying model
c           = find(strcmp(featureLabels,'MISSING'));
X(:,c)      = 0;

%=== apply model
yfit = X * model.B + model.B0;

%=== compute feature contributions
B              = repmat(model.B', numRecords, 1);
yContributions = X .* B;

%=== sort by model score
[~, sortIndex] = sort(yfit, 'ascend');
yfit           = yfit(sortIndex);
yContributions = yContributions(sortIndex,:);
sortIndex      = filter(sortIndex);     % index into town structure for printing below
rank           = [1:length(sortIndex)];
names          = town.names(sortIndex);

%=== print results
if printFlag
  fileName = sprintf('%s/%s', parameters.INPUT_PATH1, 'Model_Output.txt');
  fid      = fopen(fileName, 'w');
  fid      = 1;                    % stdout = 1

  %=== write header and data
  if strcmp(town.level, 'Town') || strcmp(town.level, 'Census Tract')
    fprintf(fid,'%s\t%s\t%s\t%s\t%s\n', 'Town', 'County', 'Population', 'Model Score', 'Rank (169 Towns)');
    for tt=1:numRecords
      t = sortIndex(tt);
        fprintf(fid,'%s\t%s\t%d\t%6.4f\t%d\n', char(town.names(t)), char(town.countyNames(t)), town.population(t,1), ...
                                               yfit(tt), rank(tt));
    end
  elseif strcmp(town.level, 'CountyUS')
    fprintf(fid,'%s\t%s\t%s\n', 'County', 'Model Score', 'Rank (3142 US Counties)');
    for tt=1:numRecords
      t = sortIndex(tt);
        fprintf(fid,'%s\t%6.4f\t%d\n', char(town.names(t)), yfit(tt), rank(tt));
    end
  elseif strcmp(town.level, 'State')
    fprintf(fid,'%s\t%s\t%s\n', 'State', 'Model Score', 'Rank (51 States + DC)');
    for tt=1:numRecords
      t = sortIndex(tt);
        fprintf(fid,'%s\t%6.4f\t%d\n', char(town.names(t)), yfit(tt), rank(tt));
    end
  end
  fprintf('Wrote %d town records to %s\n', numRecords, fileName);
  fclose('all');
end

if figureNum < 0
  return;
end

%-----------------------------------------------------------------------------
%=== 1. HORIZONTAL BAR PLOTS OF FEATURE CONTRIBUTIONS

%=== first pass is top 10, second pass is bottom 10
numPlot = 10;
for pass=1:2
  if pass == 1
    r              = 1:numPlot;
    strTitle       = sprintf('%d %ss with Low Vaccination Rates: Contribution of Lasso-Selected Features', numPlot, town.level);
    legendPosition = 'SouthWest';
  else
    figureNum = figureNum + 1;
    
    r              = numRecords-numPlot+1:numRecords;
    strTitle       = sprintf('%d %ss with High Vaccination Rates: Contribution of Model-Selected Features', numPlot, town.level);
    legendPosition = 'NorthEast';
  end
  figure(figureNum); fprintf('Figure %d.\n', figureNum);

  %=== get contributions
  c       = find(yContributions(1,:) ~= 0);
  yValues = yContributions(r,c);
  yLabels = names(r);
  y       = 1:length(yLabels);

  %=== flip data so top town is at top
  yValues        = flip(yValues);
  yLabels        = flip(yLabels);

  %=== bar plot
  barh(yValues, 'grouped');

  %=== labels
  xLabel     = 'Feature Contribution to Model-Estimated Vaccination Rate (standard deviations from mean)';
  strLegends = model.featureLabels(model.B ~= 0);

  %=== axis labels and everything else
  hold off;
  grid on;
  set(gca,'Color',parameters.bkgdColor);
  set(gca,'FontSize',12);
  set(gca,'YTick',y);
  set(gca,'YTickLabel',yLabels);
  xtickformat('%3.2f');
  xlabel(sprintf('%s', xLabel), 'FontSize', 14);
  title(sprintf('%s', strTitle), 'FontSize', 14);
  legend(strLegends, 'Location', legendPosition, 'Fontsize', 10);
end
function plotVaccineTownData(town, state, countyName, figureNum, showPrevious)
%
% plot connecticut town-level vaccination data
%
global parameters;

%=== optional return
if figureNum <= 0
  return;
end
fprintf('\n--> plotVaccineTownData\n');

%=== set pointer to eligible
m = 10;

%=== compute fraction of eligible unvaccinated people initiating vaccination each day for all towns
index         = 1:town.numNames;
townNames     = town.names(index);
numDates      = length(town.vaxDates);
d1            = 2;
d2            = numDates;
newPeople     = town.vaxData(d1:d2,index,m,1) - town.vaxData(d1-1:d2-1,index,m,1); % weekly new people with at least one dose
newPeople     = newPeople / 7;                                                     % daily new people with at least one dose
peopleElig    = town.populationAge(index,m)';                                      % 12+ population
peopleElig    = repmat(peopleElig, length(d1:d2), 1);                              % number of eligible people replicated over time
peopleInit    = town.vaxData(d1:d2,index,m,1);                                     % number of people who have initiated over time                                      
peopleUnvax   = peopleElig - peopleInit;                                           % unvaccinated people over time
newPeopleN    = 100 * newPeople ./ peopleUnvax;                                    % new people as percent of unvaxed 12+ residents

%=== sort by percent daily initiation
[~,sortIndex]  = sort(newPeopleN(end,:));
townNames      = townNames(sortIndex);
ridgefieldRank = find(strcmp(townNames, 'Ridgefield'));

%------------------------------------------------------------------------
%=== 1. SCATTER PLOT OF VACCINATION FRACTIONS
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get data
townNames = town.names;
date2     = char(town.vaxDates(end));

%=== set age group to be plotted
m1        = find(strcmp(town.vaxLabels, '0-4'));    ageLabel1  = sprintf('Age %s', char(town.vaxLabels(m1)));
m2        = find(strcmp(town.vaxLabels, '5-11'));   ageLabel2  = sprintf('Age %s', char(town.vaxLabels(m2)));

%=== first dose fractions: 5+ on x-axis, 5-11 on y-axis
x2        = 100 * squeeze(town.vaxDataN(end,:,m1,2))';  
y2        = 100 * squeeze(town.vaxDataN(end,:,m2,2))'; 

%=== get previous data if showing it
showPrevious = 1;
if showPrevious
  date1     = char(town.vaxDates(end-1));
  x1        = 100 * town.vaxDataN(end-1,:,m1,2);
  y1        = 100 * town.vaxDataN(end-1,:,m2,2);
else
  date1     = date2;
  x1        = x2;
  y1        = y2;
end

%=== only do selected county or worst towns
if ~isempty(countyName)
  filter    = find(strcmp(town.countyNames, countyName) | strcmp(town.countyNames, 'State'));
  strTitle  = sprintf('%s County: %s vs %s Vaccination Rates', countyName, ageLabel1, ageLabel2);
else
  numKeep        = 30;
  [~, sortIndex] = sort(x2,'ascend');
  filter         = sortIndex(1:numKeep);
  strTitle       = sprintf('%d Connecticut Towns with Lowest Vaccination Rates', numKeep);
end
townNames   = townNames(filter);
x1          = x1(filter);
y1          = y1(filter);
x2          = x2(filter);
y2          = y2(filter);

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); 
strLegend(1) = {sprintf('Data as of %s', date2)}; subset(1) = h1;

%=== add town names inside circles
for i=1:length(x2)
  h = text(x2(i),y2(i), char(townNames(i))); hold on;
  set(h,'HorizontalAlignment','Center'); 
  set(h,'FontWeight', 'bold');
  if strcmp(townNames(i), 'Ridgefield') || strcmp(townNames(i), 'Connecticut')
    set(h,'Color','b'); 
    set(h,'FontSize', 8);
  else
    set(h,'Color','k'); 
    set(h,'FontSize', 8);
  end
end

%=== plot small dots for each each previous point
N = 1;
if showPrevious
  h2 = plot(x1, y1, '.', 'Color', 'k', 'MarkerSize', 10); 
  N  = 2;
  strLegend(2) = {sprintf('Data as of %s', date1)}; subset(N) = h2;

  %=== plot lines connecting current data to previous data
  colormap(jet(length(x2)));
  for i=1:length(x2)
    plot([x1(i), x2(i)], [y1(i), y2(i)], ':', 'LineWidth', 1); hold on;
  end
end

%=== set labels
xTitle    = sprintf('Percent of %s Population Fully Vaccinated', ageLabel1);
yTitle    = sprintf('Percent of %s Population Fully Vaccinated', ageLabel2);
strText1  = sprintf('The Connecticut vaccination rates shown here are inferred from DPH data.  They are lower than reported by the CDC.');
strText2  = sprintf('The dashed lines (''jet plumes'') show the trajectory for each town over the past 7 days');
strSource = sprintf('%s\n%s', parameters.ctDataSource, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
%xlim([15,70]);
xmin = ax.XLim(1);
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add explanatory text -- explaining CT rates
x0 = xmin + 0.99*(xmax - xmin);
y0 = ymin + 0.01*(ymax - ymin);
h  = text(x0, y0, strText1); 
set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
set(h,'HorizontalAlignment','Right'); set(h,'VerticalAlignment','Bottom');

%=== add explanatory text -- jet plumes
x0 = xmin + 0.01*(xmax - xmin);
y0 = ymin + 0.90*(ymax - ymin);
h  = text(x0, y0, strText2); 
set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
set(h,'HorizontalAlignment','Left'); set(h,'VerticalAlignment','Top');

%=== add data source
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.085*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== finish plot
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 1);
set(gca,'FontSize',14);
xlabel(xTitle);
ylabel(yTitle);
xtickformat('%1.0f%%');
ytickformat('%1.0f%%');
legend(strLegend, 'Location', 'NorthWest', 'Fontsize', 12);
title(strTitle, 'Fontsize', 16);

if isempty(countyName)
  return;
end

%---------------------------------------------------------------------------------------------
%=== 2. VERTICAL BAR CHART OF RIDGEFIELD INITIATED AND COMPLETED VACCINATION FRACTIONS BY AGE GROUP

figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get cumulative and weekly vaccinations for Ridgefield
d         = length(town.vaxDates);
date      = char(town.vaxDates(d));
townName  = 'Ridgefield';
t         = find(strcmp(townName, town.names));
ageIndex  = [10,1,8,3,5,6,7,9];  % DANGEROUS if age groups change in state vax file
initiated = 100 * squeeze(town.vaxDataN(d,t,ageIndex,1));
completed = 100 * squeeze(town.vaxDataN(d,t,ageIndex,2));
boosted   = 100 * squeeze(town.vaxDataN(d,t,ageIndex,3));
boosted(isnan(boosted)) = 0;
xLabels = {'All Ages'; 'Ages 0-4'; 'Ages 5-11'; 'Ages 12-17'; 'Ages 18-24'; 'Ages 25-44'; 'Ages 45-64'; 'Ages 65+'};

%=== bar chart
y  = [boosted completed-boosted initiated-completed];
%y  = [boosted completed-boosted];
h  = bar(y, 0.8, 'stacked'); hold on;
set(h(1), 'FaceColor', 'k'); 
set(h(2), 'FaceColor', 'r'); 
set(h(3), 'FaceColor', 'b'); 
strLegend(1) = {sprintf('Received Booster Shot')};
strLegend(2) = {sprintf('Fully Vaccinated')};
strLegend(3) = {sprintf('Initiated Vaccination')};

%=== add values above bars
for p=1:3
  X = get(h(p), 'XEndPoints');
  Y = get(h(p), 'YEndPoints');
  for i=1:length(Y)
    T(i) = {sprintf('%2.1f%%', Y(i))};
  end
  if p == 1
    text(X,Y,T, 'vert','bottom', 'horiz','center', 'FontWeight','bold', 'FontSize',12, 'color','k', 'BackgroundColor','w');
  elseif p == 2
    text(X,Y,T, 'vert','bottom', 'horiz','center', 'FontWeight','bold', 'FontSize',12, 'color','r', 'BackgroundColor','w');
  else
    text(X,Y,T, 'vert','bottom', 'horiz','center', 'FontWeight','bold', 'FontSize',12, 'color','b', 'BackgroundColor','w');
  end
end

%=== increase y axis
ylim([0,120]);

%=== get labels for plot
strTitle  = sprintf('Percent of %s Residents Vaccinated (as of %s)', townName,date);
yTitle    = sprintf('Percent of %s Residents in the Respective Age Group', townName');
strSource = sprintf('%s\n%s', parameters.ctDataSource, parameters.rickAnalysis);
strText   = sprintf('The Initiated Vaccination numbers may be over-estimated because some Booster shots are mis-classified as First Doses.');

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add data source
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.085*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 2);
set(gca,'FontSize',  14);
set(gca,'XTick',[1:8]);  
set(gca,'XTickLabel',xLabels);
ylabel(yTitle,    'FontSize', 14);
ytickformat('%1.0f%%');
legend(strLegend, 'Location', 'NorthWest', 'Fontsize', 12);
title(strTitle,   'FontSize', 16);
function computeRisk(townName, town, figureNum)
%
% compute risk using georgia tech methodology
%
global parameters;
fprintf('\n--> computeRisk\n');

%=== set custom colors
or = parameters.orange;

%=== get data
index          = find(strcmp(town.names, townName));
newCases       = town.newCases(:,index);
incidence      = nansum(newCases(end-9:end));
population     = town.population(index);
date           = town.lastDate;

%== compute probabilities
multiple    = [1 1.4 8];
people      = [10 50 100];
probability = NaN(length(people), length(multiple));
for m=1:length(multiple)
  labels(m) = {sprintf('%2.1f', multiple(m))};
  for p=1:length(people)
    legends(p) = {sprintf('Number of People at Gathering = %d', people(p))};
    probPositive     = multiple(m) * incidence / population;
    probNegative     = 1 - probPositive;
    probPeople       = 1 - probNegative ^people(p);
    probability(p,m) = probPeople;
  end
end

%=== plot data
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== bar graph
y = 100*probability';
h = bar(y); hold on;
set(h(1), 'FaceColor', 'b');
set(h(2), 'FaceColor',  or);
set(h(3), 'FaceColor', 'r');

%=== add values above bars
for p=1:3
  X = get(h(p), 'XEndPoints');
  Y = get(h(p), 'YEndPoints');
  T = {sprintf('%2.1f%%', Y(1)), sprintf('%2.1f%%', Y(2)), sprintf('%2.1f%%', Y(3))};
  text(X, Y, T, 'vert','bottom','horiz','center', 'FontSize', 14);
end
if strcmp(townName, 'Danbury')
  t = plot(0,110,'k.'); hold on;   % force y-axis to be 100%
else
  t = plot(0,100,'k.'); hold on;   % force y-axis to be 100%
end

%=== add explanatory text
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = xmin + 0.02*(xmax - xmin);
y0   = ymin + 0.80*(ymax - ymin);
strText1 = sprintf('A multiplier of 1.0 assumes that the number of true cases is simply the number of observed cases.');
strText2 = sprintf('A multiplier of 1.4 assumes that the number of true cases is 40%% higher than observed cases due to asymptomatic cases.');
strText3 = sprintf('A multiplier of 8.0 assumes that the number of cases could be 8 times higher than reported (CDC 11/27/2020).');
strText  = sprintf('%s\n%s\n%s', strText1, strText2, strText3);
h = text(x0, y0, strText); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontWeight', 'normal'); set(h,'FontSize', 12);
set(h, 'BackgroundColor', 'c');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 2);
set(gca,'FontSize',14);
set(gca,'XTick',     1:length(labels));
set(gca,'XTickLabel',labels);
xlabel('Multiplier (Actual Cases in Last 10 Days --> Estimated Cases)', 'FontSize', 14);
ylabel('Probability (in %) That At Least One Person is COVID Positive','FontSize', 14);
strTitle = sprintf('Probability That At Least One Person is COVID Positive at a Gathering in %s (%s)', townName, date);
legend(legends,'Location', 'NorthWest', 'FontSize', 14);
title(strTitle, 'FontSize', 16);
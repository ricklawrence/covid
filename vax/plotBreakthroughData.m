function plotBreakthroughData(town, county, state, stateAge, figureNum)
%
% plot breakthrough data from CT Department Public Health
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> plotBreakthroughData\n');

%=== data from state DPH pdf
date         = 'November 18, 2021';
ageCases     = [266, 1882, 2628, 2845, 2971, 3097, 2063, 1812];
ageLabels    = {'12-15';'16-24';'25-34';'35-44';'45-54';'55-64';'65-74';'75 and older'};

%=== total cases and deaths since 2-9-2021 (ala DPH analysis)
date1  = '02/09/2021';
date2  = '11/23/2021'; 
ct     = find(strcmp(state.names0, 'CT'));
d1     = find(strcmp(state.dates, date1));
d2     = find(strcmp(state.dates, date2));
cases  = sum(state.newCases(d1:d2,ct));
deaths = sum(state.newDeaths(d1:d2,ct));
fprintf('%s to %s\n', date1, date2);
fprintf('Number of cases  = %d\n', cases);
fprintf('Number of deaths = %d\n', deaths);

%----------------------------------------------------------------------------------------
%=== 1. PLOT BREAKTHROUGH AGE DISTRIBUTIONS
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== plot data
y = ageCases' ./ sum(ageCases);
y = ageCases';
h = bar(y, 0.8, 'grouped'); hold on;
set(h(1),'FaceColor', 'g');

%=== set labels
strTitle  = sprintf('State of Connecticut: Distribution of Breakthrough Cases over Age Group');
xLabels   = ageLabels;
strLegend = {sprintf('Total Number of Breakthrough Cases = %d (as of %s)', sum(ageCases), date)};

%=== extend y axis
ylim([0, 1.1*max(y,[],'all')]);

%=== add data source
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = 0;
x0   = xmin - 0.07*(xmax - xmin);
y0   = ymin - 0.10*(ymax - ymin);
strText = sprintf('%s\n%s', 'Data Source: CT Department of Public Health', parameters.rickAnalysis);
h = text(x0, y0, strText); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== finish plot
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',14);
set(gca,'XTickLabel',xLabels);
xlabel('Age Group', 'FontSize', 16);
ylabel('Fraction of New Cases','FontSize', 16);
ylabel('New Cases','FontSize', 16);
legend(strLegend, 'Location', 'NorthWest', 'Fontsize', 16, 'FontName', 'FixedWidth', 'FontWeight', 'bold');
title(strTitle, 'FontSize', 16);

return;
%-----------------------------------------------------------------------------
%===  3. HORIZONTAL BAR CHART of VACCINATED VS UNVACCINATED CASES
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);
         
%=== bar chart
y  = cases';
h  = bar(y, 0.8, 'grouped'); hold on;
set(h(1), 'FaceColor', 'r'); 
set(h(2), 'FaceColor', 'b'); 
strLegend(1) = {sprintf('Unvaccinated (per 100,000 Unvaccinated Residents)')};
strLegend(2) = {sprintf('Vaccinated   (per 100,000 Vaccinated Residents)')};

%=== add values above bars
for p=1:2
  X = get(h(p), 'XEndPoints');
  Y = get(h(p), 'YEndPoints');
  for i=1:length(Y)
    T(i) = {sprintf('%3.2f', Y(i))};
  end
  text(X,Y,T, 'vert','bottom', 'horiz','center', 'FontWeight','bold', 'FontSize',12, 'color','k');
end

%=== get labels for plot
ratio     = y(end,1) / y(end,2);
strTitle  = sprintf('Monthly Cases For Vaccinated and Unvaccinated Connecticut Residents (as of %s)', date);
xTitle    = sprintf('Month of Specimen Collection');
yTitle    = sprintf('Monthly Cases (per 100,000 Residents)');
strText1  = sprintf('%s %2.1f %s\n %s', 'In July, Unvaccinated Residents were', ratio, ...
                   'times more', 'likely to test positive than Vaccinated Residents.');
strText2  = sprintf('%s\n%s', 'The unvaccinated population includes partially vaccinated residents.', ...
                              'The Blue Bars represent Breakthrough Cases.'); 
strSource = sprintf('Data Source: %s\nGraphics: %s', ...
                    'CT Department of Public Health', 'Rick Lawrence (Ridgefield COVID Task Force)');

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add explanatory text
x0 = xmin + 0.99*(xmax - xmin);
y0 = ymin + 0.25*(ymax - ymin);
h  = text(x0, y0, strText1); 
set(h,'Color','k'); set(h, 'BackgroundColor', 'y');  set(h,'FontWeight', 'bold'); set(h,'FontSize', 10);
set(h,'HorizontalAlignment','Right'); set(h,'VerticalAlignment','Bottom');
x0 = xmin + 0.99*(xmax - xmin);
y0 = ymin + 0.35*(ymax - ymin);
h  = text(x0, y0, strText2); 
set(h,'Color','b');  set(h,'FontWeight', 'bold'); set(h,'FontSize', 12);
set(h,'HorizontalAlignment','Right'); set(h,'VerticalAlignment','Bottom');

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
set(gca,'XTick',[1:numMonths]);  
set(gca,'XTickLabel',months);
xlabel(xTitle,    'FontSize', 14);
ylabel(yTitle,    'FontSize', 14);
ytickformat('%2.0f');
legend(strLegend, 'Location', 'NorthEast', 'Fontsize', 12, 'FontName', 'FixedWidth', 'FontWeight', 'bold');
title(strTitle,   'FontSize', 16);

%-----------------------------------------------------------------------------
%===  4. HORIZONTAL BAR CHART of VACCINATED VS UNVACCINATED HOSPITALIZATIONS
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);
         
%=== bar chart
y  = hospitalized';
h  = bar(y, 0.8, 'grouped'); hold on;
set(h(1), 'FaceColor', 'r'); 
set(h(2), 'FaceColor', 'b'); 
strLegend(1) = {sprintf('Unvaccinated (per 100,000 Unvaccinated Residents)')};
strLegend(2) = {sprintf('Vaccinated   (per 100,000 Vaccinated Residents)')};

%=== add values above bars
for p=1:2
  X = get(h(p), 'XEndPoints');
  Y = get(h(p), 'YEndPoints');
  for i=1:length(Y)
    T(i) = {sprintf('%3.2f', Y(i))};
  end
  text(X,Y,T, 'vert','bottom', 'horiz','center', 'FontWeight','bold', 'FontSize',12, 'color','k');
end

%=== get labels for plot
ratio     = y(end,1) / y(end,2);
strTitle  = sprintf('Monthly Hospitalizations For Vaccinated and Unvaccinated Connecticut Residents (as of %s)', date);
yTitle    = sprintf('Monthly Hospitalizations (per 100,000 Residents)');
strText1  = sprintf('%s %2.1f %s\n %s', 'In July, Unvaccinated Residents were', ratio, ...
                   'times more', 'likely to be hospitalized than Vaccinated Residents.');
strText2  = sprintf('%s\n%s\n%s', 'The unvaccinated population includes partially vaccinated residents.', ...
                              'The Blue Bars represent Breakthrough Hospitalizations.', ...
                              'This data is for Middlesex and New Haven Counties only.'); 
strSource = sprintf('Data Source: %s\nGraphics: %s', ...
                    'CT Department of Public Health', 'Rick Lawrence (Ridgefield COVID Task Force)');

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add explanatory text
x0 = xmin + 0.99*(xmax - xmin);
y0 = ymin + 0.25*(ymax - ymin);
h  = text(x0, y0, strText1); 
set(h,'Color','k'); set(h, 'BackgroundColor', 'y');  set(h,'FontWeight', 'bold'); set(h,'FontSize', 10);
set(h,'HorizontalAlignment','Right'); set(h,'VerticalAlignment','Bottom');
x0 = xmin + 0.99*(xmax - xmin);
y0 = ymin + 0.35*(ymax - ymin);
h  = text(x0, y0, strText2); 
set(h,'Color','b');  set(h,'FontWeight', 'bold'); set(h,'FontSize', 12);
set(h,'HorizontalAlignment','Right'); set(h,'VerticalAlignment','Bottom');

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
set(gca,'XTick',[1:numMonths]);  
set(gca,'XTickLabel',months);
xlabel(xTitle,    'FontSize', 14);
ylabel(yTitle,    'FontSize', 14);
ytickformat('%2.0f');
legend(strLegend, 'Location', 'NorthEast', 'Fontsize', 12, 'FontName', 'FixedWidth', 'FontWeight', 'bold');
title(strTitle,   'FontSize', 16);

%-----------------------------------------------------------------------------
%===  5. HORIZONTAL BAR CHART of VACCINATED VS UNVACCINATED DEATHS
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);
         
%=== bar chart
y  = deaths';
h  = bar(y, 0.8, 'grouped'); hold on;
set(h(1), 'FaceColor', 'r'); 
set(h(2), 'FaceColor', 'b'); 
strLegend(1) = {sprintf('Unvaccinated (per 100,000 Unvaccinated Residents)')};
strLegend(2) = {sprintf('Vaccinated   (per 100,000 Vaccinated Residents)')};

%=== add values above bars
for p=1:2
  X = get(h(p), 'XEndPoints');
  Y = get(h(p), 'YEndPoints');
  for i=1:length(Y)
    T(i) = {sprintf('%3.2f', Y(i))};
  end
  text(X,Y,T, 'vert','bottom', 'horiz','center', 'FontWeight','bold', 'FontSize',12, 'color','k');
end

%=== get labels for plot
ratio     = y(end,1) / y(end,2);
strTitle  = sprintf('Monthly Deaths For Vaccinated and Unvaccinated Connecticut Residents (as of %s)', date);
yTitle    = sprintf('Monthly Deaths (per 100,000 Residents)');
strText1  = sprintf('There were no deaths in July among the vaccinated population.');
strText2  = sprintf('%s\n%s', 'The unvaccinated population includes partially vaccinated residents.', ...
                              'The Blue Bars represent Breakthrough Deaths.'); 
strSource = sprintf('Data Source: %s\nGraphics: %s', ...
                    'CT Department of Public Health', 'Rick Lawrence (Ridgefield COVID Task Force)');
                  
%=== set y axis
ymax = 1.1*max(y(:,1));
ylim([0,ymax]);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add explanatory text
x0 = xmin + 0.99*(xmax - xmin);
y0 = ymin + 0.15*(ymax - ymin);
h  = text(x0, y0, strText1); 
set(h,'Color','k'); set(h, 'BackgroundColor', 'y');  set(h,'FontWeight', 'bold'); set(h,'FontSize', 10);
set(h,'HorizontalAlignment','Right'); set(h,'VerticalAlignment','Bottom');
x0 = xmin + 0.99*(xmax - xmin);
y0 = ymin + 0.45*(ymax - ymin);
h  = text(x0, y0, strText2); 
set(h,'Color','b');  set(h,'FontWeight', 'bold'); set(h,'FontSize', 12);
set(h,'HorizontalAlignment','Right'); set(h,'VerticalAlignment','Bottom');

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
set(gca,'XTick',[1:numMonths]);  
set(gca,'XTickLabel',months);
xlabel(xTitle,    'FontSize', 14);
ylabel(yTitle,    'FontSize', 14);
ytickformat('%2.0f');
legend(strLegend, 'Location', 'NorthEast', 'Fontsize', 12, 'FontName', 'FixedWidth', 'FontWeight', 'bold');
title(strTitle,   'FontSize', 16);
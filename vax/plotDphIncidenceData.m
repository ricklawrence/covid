 function  plotDphIncidenceData(dataFile, state, figureNum)
%
% read DPH incidence data and plot results
%
global parameters;
fprintf('\n--> plotDphIncidenceData\n');

%=== read file as a table
dataTable = readtable(dataFile);
head(dataTable,8);

%=== summary
numColumns = length(dataTable.Properties.VariableNames);
numRows    = length(dataTable.Date);
fprintf('Read %d columns and %d rows from %s.\n', numColumns, numRows, dataFile);

%=== get dates
dates0     = dataTable.Date;
datenums   = datenum(dates0);
%fprintf('Start Date = %s\n', datestr(min(datenums), 'mm/dd/yyyy'));
%fprintf('Last  Date = %s\n', datestr(max(datenums), 'mm/dd/yyyy'));

%=== dates are begining of week ... convert to end of week
dates    = cellstr(datestr(datenum(dates0)+7, 'mm/dd/yyyy'));
numDates = length(dates);

%=== date labels
interval    = 2; % every second week
xTicks      = [1:interval:numDates]';
xTicks      = xTicks + numDates - max(xTicks); % insure last tick is latest date
xLabels     = dates;

%=== save data
clear y;
y(:,1,1) = dataTable.CasesUV;
y(:,1,2) = dataTable.CasesFV;
y(:,1,3) = dataTable.CasesB;
y(:,2,1) = dataTable.HospitalizationsUV;
y(:,2,2) = dataTable.HospitalizationsFV;
y(:,2,3) = dataTable.HospitalizationsB;
y(:,3,1) = dataTable.DeathsUV;
y(:,3,2) = dataTable.DeathsFV;
y(:,3,3) = dataTable.DeathsB;

%=== convert weekly to daily rates and compute ratios
y        = y ./ 7;
y(:,:,4) = y(:,:,1) ./ y(:,:,2);    % unvaccinated to fully vaccinated
y(:,:,5) = y(:,:,1) ./ y(:,:,3);    % unvaccinated to boosed

%=== print data for universe powerpoint slide
skip = 1;
if ~skip
ctVaxRate = state.vaxData(end,7,26);
fprintf('Vaccinated:   %2.1f%% of Age 5+ Population .\n', ctVaxRate);
fprintf('Unvaccinated: %2.1f%% of Age 5+ Population.\n', 100 - ctVaxRate);
fprintf('Vaccinated:   New Case Rate = %2.1f\n', y(end,1,2));
fprintf('Unvaccinated: New Case Rate = %2.1f\n', y(end,1,1));
fprintf('Relative to vaccinated people, vaccinated people are \n' );
fprintf('  %4.1f times more likely to get COVID-19\n',      y(end,1,4));
fprintf('  %4.1f times more likely to be hospitalized\n',   y(end-1,2,4));
fprintf('  %4.1f times more likely to die from COVID-19\n', y(end,3,4));
fprintf('Week ending, %s\n', char(dates(end)));
end

if figureNum < 0
  return;
end

%-----------------------------------------------------------------------------------------------------
%=== 1. LINE CHART OF INCIDENCE RATIOS
figure(figureNum); fprintf('Figure %d.\n', figureNum);
barWidth = 0.8;

%------------------------------------------------------------------------------------------------------
%=== UNVACCINATED TO FULLY VACCINATED
subplot(2,1,1);
r = 4;      % use ratio wrt fully vaccinated
h = plot(y(:,1,r), 'k-', 'LineWidth', 2); hold on;
h = plot(y(:,2,r), 'b-', 'LineWidth', 2); hold on;
h = plot(y(:,3,r), 'r-', 'LineWidth', 2); hold on;

%=== labels
clear strLegend;
strTitle     = sprintf('Connecticut: Ratio of Incidence Rates for Unvaccinated vs Fully Vaccinated Populations Over Time');
xLabel       = sprintf('Week Ending Date');
yLabel       = sprintf('Incident Rate Ratio: \nUnvaccinated to Fully Vaccinated');
strLegend(1) = {sprintf('New Cases        (Latest Ratio = %4.1f)', y(end,1,r))};
strLegend(2) = {sprintf('Hospitalizations (Latest Ratio = %4.1f)', y(end-1,2,r))};
strLegend(3) = {sprintf('Deaths           (Latest Ratio = %4.1f)', y(end,3,r))};

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
ylim([0,ymax]);


%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 1);
set(gca,'FontSize',12);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(xLabel, 'FontSize', 14);
ylabel(yLabel,'FontSize', 14);
legend(strLegend,'Location', 'NorthEast', 'FontSize', 12, 'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

%------------------------------------------------------------------------------------------------------
%=== UNVACCINATED TO BOOSTED
subplot(2,1,2);
r = 5;      % use ratio wrt boosted
h = plot(y(:,1,r), 'k-', 'LineWidth', 2); hold on;
h = plot(y(:,2,r), 'b-', 'LineWidth', 2); hold on;
h = plot(y(:,3,r), 'r-', 'LineWidth', 2); hold on;

%=== labels
clear strLegend;
strTitle     = sprintf('Connecticut: Ratio of Incidence Rates for Unvaccinated vs Boosted Populations Over Time');
xLabel       = sprintf('Week Ending Date');
yLabel       = sprintf('Incident Rate Ratio: \nUnvaccinated to Boosted');
strLegend(1) = {sprintf('New Cases        (Latest Ratio = %4.1f)', y(end,1,r))};
strLegend(2) = {sprintf('Hospitalizations (Latest Ratio = %4.1f)', y(end-1,2,r))};
strLegend(3) = {sprintf('Deaths           (Latest Ratio = %4.1f)', y(end,3,r))};
strSource    = sprintf('%s\n%s', 'Data Source: CT DPH Weekly COVID-19 Update', parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add data source
x0   = xmin - 0.15*(xmax - xmin);
y0   = ymin - 0.20*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 1);
set(gca,'FontSize',12);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(xLabel, 'FontSize', 14);
ylabel(yLabel,'FontSize', 14);
legend(strLegend,'Location', 'NorthEast', 'FontSize', 12, 'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);
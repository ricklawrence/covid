function plotRpsData(data, town, figureNum)
%
% plot RPS data
%
global parameters;
fprintf('\n--> plotRpsData\n');

%=== set text notes
strNote1 = sprintf('This analysis does not include cases reported during the February 19-27 and April 9-17 school breaks.');
strNote1 = sprintf('');

%---------------------------------------------------------------------------------------------
%=== 1. LINE PLOT OF SCHOOL-AGE VACCINATION RATES
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== set date indices for vaccination plots
interval = 16;
d1       = find(strcmp(town.vaxDates, '08/11/2021'));  % first date with age 12-17 vax data
d2       = length(town.vaxDates);
d0       = mod(d2-d1,interval) + 1;
xLabels  = town.vaxDates(d1:d2);
xTicks   = [d0:interval:length(xLabels)]';

%=== get vax data
t        = find(strcmp(town.names, 'Ridgefield'));
vaxRate1 = 100*town.vaxDataN(:,t,3,2); % 12-17 fully vaxed
vaxRate2 = 100*town.vaxDataN(:,t,8,2); % 5-11  fully vaxed
vaxRate3 = 100*town.vaxDataN(:,t,1,2); % 0-4   fully vaxed
vaxRate4 = 100*town.vaxDataN(:,t,1,1); % 0-4   initiated
vaxRate5 = 100*town.vaxDataN(:,t,3,3); % 12-17 boosted
vaxRate6 = 100*town.vaxDataN(:,t,8,3); % 5-11  boosted
plot(vaxRate1(d1:d2), 'r:',  'LineWidth', 2); hold on;
plot(vaxRate2(d1:d2), 'b:',  'LineWidth', 2); hold on;
plot(vaxRate3(d1:d2), 'k:',  'LineWidth', 2); hold on;
plot(vaxRate4(d1:d2), 'k--', 'LineWidth', 2); hold on;
plot(vaxRate5(d1:d2), 'r-',  'LineWidth', 2); hold on;
plot(vaxRate6(d1:d2), 'b-',  'LineWidth', 2); hold on;

%=== title and legends
strTitle   = sprintf('Vaccination Rates for Ridgefield Children (%s to %s)', char(xLabels(1)), char(xLabels(end)));
xLabel     = sprintf('Connecticut DPH Reporting Date');
yLabel     = sprintf('Vaccination Rate (as Percent of Age Group)');
strSource  = sprintf('Data Source: http://data.ct.gov\n%s', parameters.rickAnalysis);
clear strLegends;
strLegends(1) = {sprintf('Ages 12-17 Fully Vaccinated      (Latest = %4.1f%%', vaxRate1(end))};
strLegends(2) = {sprintf('Ages 5-11  Fully Vaccinated      (Latest = %4.1f%%', vaxRate2(end))};
strLegends(3) = {sprintf('Ages 0-4   Fully Vaccinated      (Latest = %4.1f%%', vaxRate3(end))};
strLegends(4) = {sprintf('Ages 0-4   Initiated Vaccination (Latest = %4.1f%%', vaxRate4(end))};
strLegends(5) = {sprintf('Ages 12-17 Boosted               (Latest = %4.1f%%', vaxRate5(end))};
strLegends(6) = {sprintf('Ages 5-11  Boosted               (Latest = %4.1f%%', vaxRate6(end))};

%=== get axis limits
ax   = gca; 
ylim([0,109]);
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add data source
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.095*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== finish plot
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',14);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(xLabel, 'FontSize', 16);
ylabel(yLabel, 'FontSize', 16);
ytickformat('%1.0f%%');
legend(strLegends,'Location', 'NorthWest', 'FontSize', 12,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

%---------------------------------------------------------------------------------------------
%=== 2. BAR PLOT OF RPS VS TOWN NEW CASES
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== set date indices for remaining plots
interval = 56;
d1       = find(strcmp(data.dates, '01/03/2022'));
d2       = length(data.dates);
d0       = mod(d2-d1,interval) + 1;
xLabels  = data.dates(d1:d2);
xTicks   = [d0:interval:length(xLabels)]';

%=== get data for all schools
schoolName0  = 'RPS';
s            = find(strcmp(data.schoolNames0, schoolName0));
schoolName   = char(data.schoolNames(s));
newCases     = data.newCases(:,s);
MA1          = movingAverage(newCases,7);

%=== get town data and align with RPS data
t                  = find(strcmp(town.names, 'Ridgefield'));
[~,i1,i2]          = intersect(data.dates, town.dates);
MA2                = NaN(length(data.dates),1);
MA2(i1)            = movingAverage(town.newCases(i2,t), 7);
end2               = max(find(~isnan(MA2)));   % last town value could be NaN if last RPS date is previous day

%=== bar plot with MA
y = newCases;
h = bar(y(d1:d2), 0.8, 'FaceColor','b'); hold on;
plot(MA1(d1:d2), 'r-', 'LineWidth', 2);    hold on;
plot(MA2(d1:d2), 'k-', 'LineWidth', 2); hold on;

%=== title and legends
strTitle      = sprintf('Daily New Cases for %s (%s to %s)', schoolName, char(xLabels(1)), char(xLabels(end)));
xLabel        = sprintf('RPS Reporting Date');
yLabel        = sprintf('Daily New Cases');
strLegends(1) = {sprintf('Ridgefield Public Schools                        (Latest = %d)',    y(end))};
strLegends(2) = {sprintf('Ridgefield Public Schools (7-Day Moving Average) (Latest = %3.1f)', MA1(end))};
strLegends(3) = {sprintf('Town of Ridgefield        (7-Day Moving Average) (Latest = %3.1f)', MA2(end2))};
strSource     = sprintf('Data Source: RPS COVID-19 Tracker\n%s', parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add data source
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.095*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== add note
x0   = xmin + 0.50*(xmax - xmin);
y0   = ymin + 0.85*(ymax - ymin);
h    = text(x0, y0, strNote1); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Center'); set(h,'Vert','Middle');

%=== finish plot
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',12);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(xLabel, 'FontSize', 16);
ylabel(yLabel, 'FontSize', 16);
legend(strLegends,'Location', 'North', 'FontSize', 12,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

%---------------------------------------------------------------------------------------------
%=== 3. HEAT MAP FOR ALL SCHOOLS AS PERCENT OF ENROLLED STUDENTS
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== heat map
i  = [1,2,4,5,7,9,3,8,6];             % elementary then middle then high school
MA = 100 * movingAverage(data.newCases, 7) ./ repmat(data.enrollment', length(data.dates), 1);
z  = MA(d1:d2,i);
imagesc(z');
colormap jet;
h = colorbar;
set(get(h,'label'),'string','Daily New Cases (as Percent of Enrolled Students)', 'FontSize', 14);
hold on;

%=== school labels on y axis
yLabels     = data.schoolNames(i);
y           = 1:length(yLabels);

%=== title
strTitle      = sprintf('Daily New Cases (as Percent of Enrolled Students) for Ridgefield Public Schools (%s to %s)', ...
                char(xLabels(1)), char(xLabels(end)));
xLabel        = sprintf('RPS Reporting Date');
strSource     = sprintf('Data Source: RPS COVID-19 Tracker\n%s', parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== horizontal separators
X = [-xmin,xmax];
plot(X,[0.5,0.5], 'w-', 'LineWidth', 3); hold on;
plot(X,[6.5,6.5], 'w-', 'LineWidth', 3); hold on;
plot(X,[8.5,8.5], 'w-', 'LineWidth', 3); hold on;
plot(X,[9.5,9.5], 'w-', 'LineWidth', 3); hold on;

%=== add school labels
x0   = xmin + 0.50*(xmax - xmin);
y0   = 3.5;
h    = text(x0, y0, 'Elementary Schools'); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'w'); set(h,'Horiz','Center'); set(h,'Vert','Middle'); set(h, 'FontWeight','bold');
y0   = 7.5;
h    = text(x0, y0, 'Middle Schools'); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'w'); set(h,'Horiz','Center'); set(h,'Vert','Middle'); set(h, 'FontWeight','bold');
y0   = 9.0;
h    = text(x0, y0, 'High School'); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'w'); set(h,'Horiz','Center'); set(h,'Vert','Middle'); set(h, 'FontWeight','bold');

%=== add data source
x0   = xmin - 0.25*(xmax - xmin);
y0   = ymin + 1.1*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== finish plot
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',12);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
set(gca,'YTick',y);
set(gca,'YTickLabel',yLabels(y));
xlabel(xLabel, 'FontSize', 16);
%legend(strLegends,'Location', 'North', 'FontSize', 14,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

%---------------------------------------------------------------------------------------------
%=== 4. LINE PLOT OF NEW CASES AS PERCENT OF ENROLLED STUDENTS IN ELEMENTARY, MIDDLE, AND HIGH SCHOOLS
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== partition schools
clear strLegends; clear MA;
index1        = find(contains(data.schoolNames, 'Elementary'));
index2        = find(contains(data.schoolNames, 'Middle'));
index3        = find(contains(data.schoolNames, 'High'));
index4        = find(contains(data.schoolNames, 'Public'));
newCases1     = nansum(data.newCases(:,index1),2);
newCases2     = nansum(data.newCases(:,index2),2);
newCases3     = nansum(data.newCases(:,index3),2);
newCases4     = nansum(data.newCases(:,index4),2);
enrollment1   = nansum(data.enrollment(index1));
enrollment2   = nansum(data.enrollment(index2));
enrollment3   = nansum(data.enrollment(index3));
enrollment4   = nansum(data.enrollment(index4));
enrollment4   = enrollment1 + enrollment2 + enrollment3;

%=== line plot of new case rates per 100K enrolled students
clear MA;
MA(:,1) = 100 * movingAverage(newCases1, 7) ./ repmat(enrollment1', length(data.dates), 1);
MA(:,2) = 100 * movingAverage(newCases2, 7) ./ repmat(enrollment2', length(data.dates), 1);
MA(:,3) = 100 * movingAverage(newCases3, 7) ./ repmat(enrollment3', length(data.dates), 1);
MA(:,4) = 100 * movingAverage(newCases4, 7) ./ repmat(enrollment4', length(data.dates), 1);
plot(MA(d1:d2,1), 'r', 'LineWidth', 2); hold on;
plot(MA(d1:d2,2), 'b', 'LineWidth', 2); hold on;
plot(MA(d1:d2,3), 'c', 'LineWidth', 2); hold on;
plot(MA(d1:d2,4), 'k', 'LineWidth', 2); hold on;

%=== get peak dates
d0    = find(strcmp(data.dates,'02/01/2022'));            % avoid BA1 peak in January
dates = data.dates(d0:d2);
[~,p] = max(MA(d0:d2,1)); dp1 = dates(p); str1 = sprintf('  Elementary Schools Peak Date = %s', char(dp1));
[~,p] = max(MA(d0:d2,2)); dp2 = dates(p); str2 = sprintf('  Middle Schools     Peak Date = %s', char(dp2));
[~,p] = max(MA(d0:d2,3)); dp3 = dates(p); str3 = sprintf('  High School        Peak Date = %s', char(dp3));
[~,p] = max(MA(d0:d2,4)); dp4 = dates(p); str4 = sprintf('  All RPS            Peak Date = %s', char(dp4));
strPeak = sprintf('%s\n%s\n%s\n%s', str1, str2, str3, str4);
strPeak = sprintf('');

%=== title and legends
strTitle      = sprintf('Daily New Cases (as Percent of Enrolled Students) for Ridgefield Public Schools (%s to %s)', ...
                char(xLabels(1)), char(xLabels(end)));
xLabel        = sprintf('RPS Reporting Date');
yLabel        = sprintf('Daily New Cases as Percent of Enrolled Students');
strSource     = sprintf('Data Source: RPS COVID-19 Tracker\n%s', parameters.rickAnalysis);
strLegends(1) = {sprintf('%4d students in %d Elementary Schools      (Latest = %4.3f%%)', enrollment1, length(index1), MA(end,1))};
strLegends(2) = {sprintf('%4d students in %d Middle Schools          (Latest = %4.3f%%)', enrollment2, length(index2), MA(end,2))};
strLegends(3) = {sprintf('%4d students in %d High School             (Latest = %4.3f%%)', enrollment3, length(index3), MA(end,3))};
strLegends(4) = {sprintf('%4d students in Ridgefield Public Schools (Latest = %4.3f%%)',  enrollment4,                 MA(end,4))};

%=== get axis limits
ax   = gca; 
ylim([0,1.45]);
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add note
x0   = xmin + 0.50*(xmax - xmin);
y0   = ymin + 0.84*(ymax - ymin);
h    = text(x0, y0, strNote1); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Center'); set(h,'Vert','Middle');

%=== add peak dates
x0   = xmin + 0.50*(xmax - xmin);
y0   = ymin + 0.80*(ymax - ymin);
h    = text(x0, y0, strPeak); 
set(h,'FontSize', 10); set(h,'Color','k');    set(h, 'BackgroundColor', 'y'); 
set(h,'Horiz','Center'); set(h,'Vert','Top'); 
set(h, 'FontName','FixedWidth');  set(h, 'FontWeight','bold');

%=== add data source
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.095*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== finish plot
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',12);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(xLabel, 'FontSize', 16);
ylabel(yLabel, 'FontSize', 16);
ytickformat('%2.1f%%');
legend(strLegends,'Location', 'North', 'FontSize', 12,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

%---------------------------------------------------------------------------------------------
%=== 5. LINE PLOT OF CUMULATIVE CASES AS PERCENT OF SCHOOL POPULATION IN ELEMENTARY, MIDDLE, AND HIGH SCHOOLS
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== partition schools
clear strLegends; clear MA;
index1        = find(contains(data.schoolNames, 'Elementary'));
index2        = find(contains(data.schoolNames, 'Middle'));
index3        = find(contains(data.schoolNames, 'High'));
index4        = find(contains(data.schoolNames, 'Public'));
cumCases1     = cumsum(sum(data.newCases(:,index1),2));
cumCases2     = cumsum(sum(data.newCases(:,index2),2));
cumCases3     = cumsum(sum(data.newCases(:,index3),2));
cumCases4     = cumsum(sum(data.newCases(:,index4),2));
population1   = data.staffRatio * nansum(data.enrollment(index1));  % this is all students, faculty, staff
population2   = data.staffRatio * nansum(data.enrollment(index2));
population3   = data.staffRatio * nansum(data.enrollment(index3));
population4   = data.staffRatio * nansum(data.enrollment(index4));
population4   = population1 + population2 + population3;

%=== line plot of cum sum of cases as percent of total school population
MA(:,1) = 100 * cumCases1 ./ repmat(population1', length(data.dates), 1);
MA(:,2) = 100 * cumCases2 ./ repmat(population2', length(data.dates), 1);
MA(:,3) = 100 * cumCases3 ./ repmat(population3', length(data.dates), 1);
MA(:,4) = 100 * cumCases4 ./ repmat(population4', length(data.dates), 1);
plot(MA(d1:d2,1), 'r', 'LineWidth', 2); hold on;
plot(MA(d1:d2,2), 'b', 'LineWidth', 2); hold on;
plot(MA(d1:d2,3), 'c', 'LineWidth', 2); hold on;
plot(MA(d1:d2,4), 'k', 'LineWidth', 2); hold on;

%=== title and legends
strTitle      = sprintf('Cumulative Cases as Percent of Total School Populations for Ridgefield Public Schools (%s to %s)', ...
                char(xLabels(1)), char(xLabels(end)));
xLabel        = sprintf('RPS Reporting Date');
yLabel        = sprintf('Cumulative Cases as Percent of Total School Population');
strSource     = sprintf('Data Source: RPS COVID-19 Tracker\n%s', parameters.rickAnalysis);
strLegends(1) = {sprintf('%d Elementary Schools      (Latest = %4.1f%%)', length(index1), MA(end,1))};
strLegends(2) = {sprintf('%d Middle Schools          (Latest = %4.1f%%)', length(index2), MA(end,2))};
strLegends(3) = {sprintf('%d High School             (Latest = %4.1f%%)', length(index3), MA(end,3))};
strLegends(4) = {sprintf('Ridgefield Public Schools (Latest = %4.1f%%)',                  MA(end,4))};

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add note
x0   = xmin + 0.50*(xmax - xmin);
y0   = ymin + 0.84*(ymax - ymin);
h    = text(x0, y0, strNote1); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Center'); set(h,'Vert','Middle');

%=== add data source
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.095*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== finish plot
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',12);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(xLabel, 'FontSize', 16);
ylabel(yLabel, 'FontSize', 16);
ytickformat('%1.0f%%');
legend(strLegends,'Location', 'NorthWest', 'FontSize', 12,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

return;

%---------------------------------------------------------------------------------------------
%=== 6. LINE PLOT OF MOVING AVERAGES FOR ALL SCHOOLS
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== line plot of new cases
MA       = movingAverage(data.newCases, 7);
plot(MA(d1:d2,:), 'LineWidth', 2);

%=== title and legends
strTitle   = sprintf('Daily New Cases for Ridgefield Public Schools (since %s)', char(xLabels(1)));
xLabel     = sprintf('RPS Reporting Date');
yLabel     = sprintf('Daily New Cases (7-Day Moving Average)');
strSource  = sprintf('Data Source: RPS COVID-19 Tracker\n%s', parameters.rickAnalysis);
strLegends = data.schoolNames;
for i=1:length(data.schoolNames)
  strLegends(i) = {sprintf('%34s (Latest = %2.1f)', char(data.schoolNames(i)), MA(end,i))};
end

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== add data source
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.095*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== finish plot
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',14);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(xLabel, 'FontSize', 16);
ylabel(yLabel, 'FontSize', 16);
legend(strLegends,'Location', 'North', 'FontSize', 12,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

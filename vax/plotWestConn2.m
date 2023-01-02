function plotWestConn2(town, state, county, countyUS, figureNum)
%
% figures for west conn Q2: will US reach herd immunity
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> plotWestConn2\n');

%=== do Connecticut and US
figureNum = figureNum - 1;
for p=1:2

%=== set state
if p ==1 
  stateName = 'Connecticut';
else
  stateName = 'United States';
end
s         = find(strcmp(stateName, state.names));

%=== get CDC dates
date1        = '11/01/2021';
d1           = find(strcmp(date1, state.vaxDates));  % ages 5+ eligible
d2           = length(state.vaxDates);
dates        = state.vaxDates(d1:d2);

%=== get rates
completed5   = state.vaxData(d1:d2,:,26); % age 5+
completed511 = state.vaxData(d1:d2,:,28); % age 5-11
boosted18    = state.vaxData(d1:d2,:,20); % boosted age 18+

%---------------------------------------------------------------------------------------------
%=== 1. DAILY PLOT OF INITIATED AND COMPLETED 5+ VACCINATIONS
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get dates for plots
numDates = length(dates);
interval = 14;
d6       = numDates;
d5       = mod(numDates,interval);    % so last date is final tick mark
if d5 == 0
  d5     = interval;
end
x        = d5:interval:d6;            % show only these dates
xLabels  = dates;

%=== plots
y1 = completed5(:,s);
y2 = boosted18(:,s);
y3 = completed511(:,s);
plot(y1,'r-',     'LineWidth', 2); hold on;
plot(y2,'b-',     'LineWidth', 2); hold on;
plot(y3,'k-',     'LineWidth', 2); hold on;

%=== get labels for plot
strLegends(1) = {sprintf('Age 5+   Fully Vaccinated (Latest = %2.1f%%)', y1(end))};
strLegends(2) = {sprintf('Age 18+  Boosted          (Latest = %2.1f%%)', y2(end))};
strLegends(3) = {sprintf('Age 5-11 Fully Vaccinated (Latest = %2.1f%%)', y3(end))};
strTitle      = sprintf('%s Vaccination Rates (Since %s)', char(stateName), char(dates(1)));
xTitle        = sprintf('Report Date');
yTitle        = sprintf('Percent of Age Population');
strSource     = sprintf('%s\n%s','Data Source: CDC and http://data.ct.gov', parameters.rickAnalysis);

%=== get axis limits
ylim([0,100]);
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
set(gca,'XTick',x);  
set(gca,'XTickLabel',xLabels(x));
xlabel(xTitle, 'FontSize', 14);
ylabel(yTitle, 'FontSize', 14);
ytickformat('%2.0f%%');
legend(strLegends,'FontSize', 14, 'Location','NorthWest', 'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle,   'FontSize', 16);
end
return

%-----------------------------------------------------------------------------
%===  2. HORIZONTAL BAR CHART OF STATE 5+ POPULATION COMPLETED AND INITATED VACCINATIONS
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get data
stateNames = state.names;
initiated  = initiated5(end,:)';  % age 5+
completed  = completed5(end,:)';  % age 5+

%=== get data for plots
yValues        = [completed initiated-completed];
yLabels        = stateNames;
sortValues     = completed;
[~, sortIndex] = sort(sortValues, 'descend');
yValues        = yValues(sortIndex,:);
yLabels        = yLabels(sortIndex);
yValues        = flip(yValues);     % reverse so biggest is at top of bar chart
yLabels        = flip(yLabels);     % reverse so biggest is at top of bar chart
y              = 1:length(yLabels);

%=== horizontal bar chart
h = barh(y, yValues, 'stacked'); 
set(h(1), 'FaceColor', 'r'); hold on;
set(h(2), 'FaceColor', 'b'); hold on;

%=== labels
strTitle     = sprintf('Percent of Eligible (Age 5+) Populations Vaccinated (as of %s)', char(state.vaxDates(end)));
clear strLegend;
strLegend(1) = {sprintf('Completed Vaccination')}; 
strLegend(2) = {sprintf('Initiated Vaccination')};
xLabel       = sprintf('Percent of Age 5+ Population Vaccinated');
strSource    = sprintf('%s', parameters.vaxDataSourceCDCa);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at herd immunity
Reff         = 8;
herdImmunity = 100*(1 - 1/Reff);
x0           = herdImmunity;
h3 = plot([x0,x0], [ymin,ymax], 'k-', 'LineWidth', 2); hold on;
strLegend(3) = {sprintf('Herd Immunity at %2.1f%% of Eligible Population Completing Vaccination \n(Based on Delta Variant)', ...
                herdImmunity)};

%=== add value next to US and CT
stateName = 'Connecticut';
s  = find(strcmp(stateName, yLabels));
x0 = sum(yValues(s,:),2);
y0 = y(s);
t0 = yValues(s,1);
h1 = text(x0,y0,sprintf(' %s = %2.1f%%', stateName, t0));
s  = find(strcmp('United States', yLabels));
x0 = sum(yValues(s,:),2);
y0 = y(s);
t0 = yValues(s,1);
h2 = text(x0,y0,sprintf(' United States = %2.1f%%',t0));
set(h1,'Color','r'); set(h1,'Horiz','Left'); set(h1, 'Vert', 'middle'); set(h1,'FontSize', 12); set(h1,'FontWeight', 'bold');
set(h2,'Color','r'); set(h2,'Horiz','Left'); set(h2, 'Vert', 'middle'); set(h2,'FontSize', 12); set(h2,'FontWeight', 'bold');

%=== add data source
x0   = xmin - 0.150*(xmax - xmin);
y0   = ymin - 0.095*(ymax - ymin);
h = text(x0, y0, strSource); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== axis labels and everything else
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'FontSize',10);
set(gca,'YTick',y);
set(gca,'YTickLabel',yLabels(y));
xtickformat('%1.0f%%');
xlabel(sprintf('%s', xLabel), 'FontSize', 14);
title(sprintf('%s', strTitle), 'FontSize', 16);
legend(strLegend, 'location', 'NorthWest', 'Fontsize', 12, 'FontWeight','normal');

%---------------------------------------------------------------------------------------------
%=== 3. SCATTER PLOT OF BOOSTERS VS ELIGIBLE VACCINATION
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get latest data
date2       = char(state.vaxDates(end));
x2          = completed5(end,:)';    % completed 5+ percent
y2          = boosters(end,:)';      % boosted percent
stateNames0 = state.names0;

%=== get previous data if showing it
showPrevious = 1;
numDays      = 7;
if showPrevious
  date1     = char(state.vaxDates(end-numDays));
  x1        = completed5(end-numDays,:)';    % completed 5+ percent
  y1        = boosters(end-numDays,:)';      % boosted percent
else
  date1     = date2;
  x1        = x2;
  y1        = y2;
end

%=== eliminate ID with zero 12+ vax data
filter      = x1 > 0 & x2 > 0 & y1 > 0 & y2 > 0;
x1          = x1(filter); 
x2          = x2(filter);
y1          = y1(filter); 
y2          = y2(filter);
stateNames0 = stateNames0(filter);

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); 
strLegend(1) = {sprintf('Data as of %s', date2)}; subset(1) = h1;

%=== add state short names inside circles
for i=1:length(x2)
  h = text(x2(i),y2(i), char(stateNames0(i))); hold on;
  set(h,'HorizontalAlignment','Center'); 
  set(h,'FontWeight', 'bold');
  if strcmp(stateNames0(i), 'CT') || strcmp(stateNames0(i), 'US')
    set(h,'Color','b'); 
    set(h,'FontSize', 14);
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
strTitle  = sprintf('Percent of Population Boosted vs Percent of Population Fully Vaccinated');
xTitle    = sprintf('Percent of Age 5+ Population Fully Vaccinated');
yTitle    = sprintf('Percent of Age 18+ Population with Booster Shot');
strText   = sprintf('The dashed lines (''jet plumes'') show the trajectory for each state over the past %d days', numDays);
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ylim([0,1.2*max(y2)]);
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at US competed
us = find(strcmp('US', stateNames0));
x3 = x2(us);
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Age 5+ Fully Vaccinated = %2.1f%%', x3)}; subset(N) = h2;

%=== horizontal line at US booster rate
y3 = y2(us);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Age 18+ Boosted = %2.1f%%', y3)}; subset(N) = h3;

%=== compute correlation
R    = corrcoef(x2,y2);
corr = R(1,2);
h4   = plot([xmin,xmin], [ymin,ymin], '.');
N    = N + 1;
strLegend(N) = {sprintf('Correlation = %4.3f', corr)}; subset(N) = h4;

%=== add counts in each quadrant
us       = find(strcmp('US', stateNames0));
xx       = x2(us);       % quadrant defined by us vax rate
yy       = y2(us);       % quadrant definded by US case rate
x2       = x2(1:end-1);  % omit US
y2       = y2(1:end-1);  % omit US
count(1) = length(find(x2 <= xx & y2 <= yy));  xpos(1) = (xmin+xx)/2; ypos(1) = (ymin+yy)/2; 
count(2) = length(find(x2 >  xx & y2 <= yy));  xpos(2) = (xmax+xx)/2; ypos(2) = (ymin+yy)/2;
count(3) = length(find(x2 <= xx & y2 >  yy));  xpos(3) = (xmin+xx)/2; ypos(3) = (ymax+yy)/2;
count(4) = length(find(x2 >  xx & y2 >  yy));  xpos(4) = (xmax+xx)/2; ypos(4) = (ymax+yy)/2;
for i=1:4
  h = text(xpos(i), ypos(i), sprintf('%d states', count(i)));
  set(h,'Color','k'); set(h, 'BackgroundColor', 'y');  set(h,'FontWeight', 'bold'); set(h,'FontSize', 14);
  set(h,'HorizontalAlignment','Center'); set(h,'VerticalAlignment','Middle');
end

%=== add explanatory text
if showPrevious
  x0 = xmin + 0.99*(xmax - xmin);
  y0 = ymin + 0.99*(ymax - ymin);
  h  = text(x0, y0, strText); 
  set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
  set(h,'HorizontalAlignment','Right'); set(h,'VerticalAlignment','Top');
end

%=== add data source
x0   = xmin - 0.150*(xmax - xmin);
y0   = ymin - 0.100*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== finish plot
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 1);
set(gca,'FontSize',16);
xlabel(xTitle);
ylabel(yTitle);
xtickformat('%1.0f%%');
ytickformat('%1.0f%%');
legend(subset, strLegend, 'Location', 'NorthWest', 'Fontsize', 12);
title(strTitle, 'Fontsize', 16);

%---------------------------------------------------------------------------------------------
%=== 4. SCATTER PLOT OF AGES 5-11 VS ELIGIBLE VACCINATION
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get latest data
date2       = char(state.vaxDates(end));
x2          = completed5(end,:)';      % completed 5+ percent
y2          = initiated511(end,:)';    % initiated 5-11 percent
stateNames0 = state.names0;

%=== get previous data if showing it
showPrevious = 1;
numDays      = 7;
if showPrevious
  date1     = char(state.vaxDates(end-numDays));
  x1        = completed5(end-numDays,:)';      % completed 5+ percent
  y1        = initiated511(end-numDays,:)';    % initiated 5-11 percent
else
  date1     = date2;
  x1        = x2;
  y1        = y2;
end

%=== eliminate ID with zero 12+ vax data
filter      = x1 > 0 & x2 > 0 & y1 > 0 & y2 > 0;
x1          = x1(filter); 
x2          = x2(filter);
y1          = y1(filter); 
y2          = y2(filter);
stateNames0 = stateNames0(filter);

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); 
strLegend(1) = {sprintf('Data as of %s', date2)}; subset(1) = h1;

%=== add state short names inside circles
for i=1:length(x2)
  h = text(x2(i),y2(i), char(stateNames0(i))); hold on;
  set(h,'HorizontalAlignment','Center'); 
  set(h,'FontWeight', 'bold');
  if strcmp(stateNames0(i), 'CT') || strcmp(stateNames0(i), 'US')
    set(h,'Color','b'); 
    set(h,'FontSize', 14);
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
strTitle  = sprintf('Percent of Ages 5-11 Initiated vs Percent of Population Fully Vaccinated');
xTitle    = sprintf('Percent of Age 5+ Population Fully Vaccinated');
yTitle    = sprintf('Percent of Age 5-11 Population Initiated Vaccination');
strText   = sprintf('The dashed lines (''jet plumes'') show the trajectory for each state over the past %d days', numDays);
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ylim([0,1.2*max(y2)]);
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at US competed
us = find(strcmp('US', stateNames0));
x3 = x2(us);
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Age 5+ Fully Vaccinated = %2.1f%%', x3)}; subset(N) = h2;

%=== horizontal line at US booster rate
y3 = y2(us);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Age 5-11 Initiated Vaccination = %2.1f%%', y3)}; subset(N) = h3;

%=== compute correlation
R    = corrcoef(x2,y2);
corr = R(1,2);
h4   = plot([xmin,xmin], [ymin,ymin], '.');
N    = N + 1;
strLegend(N) = {sprintf('Correlation = %4.3f', corr)}; subset(N) = h4;

%=== add counts in each quadrant
us       = find(strcmp('US', stateNames0));
xx       = x2(us);       % quadrant defined by us vax rate
yy       = y2(us);       % quadrant definded by US case rate
x2       = x2(1:end-1);  % omit US
y2       = y2(1:end-1);  % omit US
count(1) = length(find(x2 <= xx & y2 <= yy));  xpos(1) = (xmin+xx)/2; ypos(1) = (ymin+yy)/2; 
count(2) = length(find(x2 >  xx & y2 <= yy));  xpos(2) = (xmax+xx)/2; ypos(2) = (ymin+yy)/2;
count(3) = length(find(x2 <= xx & y2 >  yy));  xpos(3) = (xmin+xx)/2; ypos(3) = (ymax+yy)/2;
count(4) = length(find(x2 >  xx & y2 >  yy));  xpos(4) = (xmax+xx)/2; ypos(4) = (ymax+yy)/2;
for i=1:4
  h = text(xpos(i), ypos(i), sprintf('%d states', count(i)));
  set(h,'Color','k'); set(h, 'BackgroundColor', 'y');  set(h,'FontWeight', 'bold'); set(h,'FontSize', 14);
  set(h,'HorizontalAlignment','Center'); set(h,'VerticalAlignment','Middle');
end

%=== add explanatory text
if showPrevious
  x0 = xmin + 0.99*(xmax - xmin);
  y0 = ymin + 0.99*(ymax - ymin);
  h  = text(x0, y0, strText); 
  set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
  set(h,'HorizontalAlignment','Right'); set(h,'VerticalAlignment','Top');
end

%=== add data source
x0   = xmin - 0.150*(xmax - xmin);
y0   = ymin - 0.100*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== finish plot
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 1);
set(gca,'FontSize',16);
xlabel(xTitle);
ylabel(yTitle);
xtickformat('%1.0f%%');
ytickformat('%1.0f%%');
legend(subset, strLegend, 'Location', 'NorthWest', 'Fontsize', 16);
title(strTitle, 'Fontsize', 16);


return

%------------------------------------------------------------------------
%=== 5. PLOT LINE CHART OF PEOPLE INITIATING VACCINATION
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get dates
dates       = state.vaxDates;
numDates    = length(dates);

%=== set date limits
numWeeks    = 16;
window      = numWeeks*7;
d2          = numDates;
d1          = numDates - window;
interval    = window / 10;             % ~10 date labels
interval    = 7 * ceil(interval/7);    % round up to integer number of weeks
numWeeks    = round(window/7);
xLabels     = dates(d1:d2);
xTicks      = [d1:interval:d2]';
xTicks      = xTicks - d1 + 1;
clear y;
clear strLegends;

%=== compute fraction of eligible unvaccinated people initiating vaccination each day
index         = 1:state.numNames;
newPeople     = state.vaxData(d1:d2,index,3) - state.vaxData(d1-7:d2-7,index,3);     % weekly new people with at least one dose
newPeople     = newPeople / 7;                                                       % daily new people with at least one dose
fraction12    = state.vaxData(end,index,9) ./ state.vaxData(end,index,18);           % frac pop 12+ inferred from percents
peopleElig    = fraction12 .* state.population(index)';                              % number of eligible people
peopleElig    = repmat(peopleElig, length(d1:d2), 1);                                % number of eligible people replicated over time
peopleInit    = state.vaxData(d1:d2,index,3);                                        % number of people who have initiated over time                                      
peopleUnvax   = peopleElig - peopleInit;                                             % unvaccinated people over time
newPeopleN    = 100 * newPeople ./ peopleUnvax;                                      % new people as percent of unvaxed 12+ residents

%=== debug
debug = 0;
if debug
  s = 7;
  peopleElig(end,s)  / 1
  peopleInit(end,s)  / 1
  peopleUnvax(end,s) / 1
  newPeople(end,s)   / 1
end

%=== set states to be plotted
stateNames = {'United States'; 'Connecticut'; 'Pennsylvania'; 'New Hampshire'; 'Massachusetts'; 'Rhode Island'};
stateNames = {'United States'; 'Connecticut'};
colors     = {'r'; 'b'; 'k'; 'g'; 'c'; 'm'};
for s=1:length(stateNames)
  stateName = char(stateNames(s));

  %=== plot data for each state
  index         = find(strcmp(stateName, state.names));
  y(:,s)        = newPeopleN(:,index);        
  color         = sprintf('%s-', char(colors(s)));
  h             = plot(y(:,s), color);  set(h, 'LineWidth', 2); hold on;
  strLegends(s) = {sprintf('%s (7-Day Moving Average)', stateName)};
end

%=== add values next to lines
for s=1:length(stateNames)
  x0 = 1.005*length(y(:,s));
  y0 = y(end,s);
  t0 = sprintf('%2.2f%%', y0);
  text(x0,y0,t0, 'vert','middle', 'horiz','left', 'FontWeight','bold', 'FontSize',12, 'color',char(colors(s)));
end

%=== set labels
strTitle  = sprintf('Percent of Eligible Unvaccinated People Initiating Vaccination Each Day (as of %s)', char(xLabels(end)));
xLabel    = sprintf('CDC Reporting Date (Last %d Weeks)', numWeeks);
yLabel    = sprintf('Percent of Eligible Unvaccinated People Initiating Vaccination');
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at Biden vaccine mandate
date0 = '09/09/2021';
x0    = find(strcmp(date0, xLabels));
h2    = plot([x0,x0], [ymin,ymax], 'k:', 'LineWidth', 2);
N     = length(stateNames) + 1;
strLegends(N) = {sprintf('President Biden vaccination mandate announcement(%s)', date0)};

%=== add data source
x0   = xmin - 0.100*(xmax - xmin);
y0   = ymin - 0.095*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== add axis labels
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',14);
set(gca,'XTick',xTicks);  
set(gca,'XTickLabel',xLabels(xTicks));
xlabel(xLabel, 'FontSize', 16);
ylabel(yLabel, 'FontSize', 16);
ytickformat('%2.1f%%');
legend(strLegends,'Location', 'NorthWest', 'FontSize', 12,'FontName','FixedWidth', 'FontWeight','bold');
title(strTitle, 'FontSize', 16);

%---------------------------------------------------------------------------------------------
%=== 6. SCATTER PLOT OF VACCINATION RATE VS VACCINATION INITIATION AT STATE LEVEL
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== compute fraction of eligible unvaccinated people initiating vaccination each day
d1            = 8;
d2            = length(state.vaxDates);
index         = 1:state.numNames;
newPeople     = state.vaxData(d1:d2,index,3) - state.vaxData(d1-7:d2-7,index,3);     % weekly new people with at least one dose
newPeople     = newPeople / 7;                                                       % daily new people with at least one dose
fraction12    = state.vaxData(end,index,9) ./ state.vaxData(end,index,18);           % frac pop 12+ inferred from percents
peopleElig    = fraction12 .* state.population(index)';                              % number of eligible people
peopleElig    = repmat(peopleElig, length(d1:d2), 1);                                % number of eligible people replicated over time
peopleInit    = state.vaxData(d1:d2,index,3);                                        % number of people who have initiated over time                                      
peopleUnvax   = peopleElig - peopleInit;                                             % unvaccinated people over time
newPeopleN    = 100 * newPeople ./ peopleUnvax;                                      % new people as percent of unvaxed 12+ residents

%=== get latest data
m           = 18;                         % use completed 12+ vaccination rate
date2       = char(state.vaxDates(end));
x2          = state.vaxData(end,:,m)';    % completed 12+
y2          = newPeopleN(end,:)';         % new initiation rate
stateNames0 = state.names0;

%=== get previous data if showing it
showPrevious = 0;
numDays      = 7;
if showPrevious
  date1     = char(state.vaxDates(end-numDays));
  x1        = state.vaxData(end-numDays,:,m)';   % completed 12+
  y1        = state.features(end-numDays,:,2)';  % new case rate
  y1        = newPeopleN(end-numDays,:)';        % new initiation rate
else
  date1     = date2;
  x1        = x2;
  y1        = y2;
end

%=== eliminate ID with zero 12+ vax data
filter      = x1 > 0 & x2 > 0 & y1 > 0 & y2 > 0;
x1          = x1(filter); 
x2          = x2(filter);
y1          = y1(filter); 
y2          = y2(filter);
stateNames0 = stateNames0(filter);

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); 
strLegend(1) = {sprintf('Data as of %s', date2)}; subset(1) = h1;

%=== add state short names inside circles
for i=1:length(x2)
  h = text(x2(i),y2(i), char(stateNames0(i))); hold on;
  set(h,'HorizontalAlignment','Center'); 
  set(h,'FontWeight', 'bold');
  if strcmp(stateNames0(i), 'CT') || strcmp(stateNames0(i), 'US')
    set(h,'Color','b'); 
    set(h,'FontSize', 14);
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
strTitle  = sprintf('Rate of DAILY Vaccination Initiation vs Percent of Eligible (Age 12+) Population Fully Vaccinated');
xTitle    = sprintf('Percent of Eligible Population Fully Vaccinated');
yTitle    = sprintf('Percent of Eligible Unvaccinated People Initiating Vaccination Each Day');
strText   = sprintf('The dashed lines (''jet plumes'') show the trajectory for each state over the past %d days', numDays);
strSource = sprintf('%s\n%s', parameters.vaxDataSourceCDCa, parameters.rickAnalysis);

%=== get axis limits
ylim([0,1.2*max(y2)]);
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at US initiated
us = find(strcmp('US', stateNames0));
x3 = x2(us);
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Fully Vaccinated Rate = %2.1f%%', x3)}; subset(N) = h2;

%=== horizontal line at US case rate
y3 = y2(us);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Vaccination Initiation Rate = %3.2f%%', y3)}; subset(N) = h3;

%=== add counts in each quadrant
us       = find(strcmp('US', stateNames0));
xx       = x2(us);       % quadrant defined by us vax rate
yy       = y2(us);       % quadrant definded by US case rate
x2       = x2(1:end-1);  % omit US
y2       = y2(1:end-1);  % omit US
count(1) = length(find(x2 <= xx & y2 <= yy));  xpos(1) = (xmin+xx)/2; ypos(1) = (ymin+yy)/2; 
count(2) = length(find(x2 >  xx & y2 <= yy));  xpos(2) = (xmax+xx)/2; ypos(2) = (ymin+yy)/2;
count(3) = length(find(x2 <= xx & y2 >  yy));  xpos(3) = (xmin+xx)/2; ypos(3) = (ymax+yy)/2;
count(4) = length(find(x2 >  xx & y2 >  yy));  xpos(4) = (xmax+xx)/2; ypos(4) = (ymax+yy)/2;
for i=1:4
  h = text(xpos(i), ypos(i), sprintf('%d states', count(i)));
  set(h,'Color','k'); set(h, 'BackgroundColor', 'y');  set(h,'FontWeight', 'bold'); set(h,'FontSize', 14);
  set(h,'HorizontalAlignment','Center'); set(h,'VerticalAlignment','Middle');
end

%=== add explanatory text
if showPrevious
  x0 = xmin + 0.99*(xmax - xmin);
  y0 = ymin + 0.99*(ymax - ymin);
  h  = text(x0, y0, strText); 
  set(h,'Color','k'); set(h, 'BackgroundColor', 'c');  set(h,'FontWeight', 'normal'); set(h,'FontSize', 10);
  set(h,'HorizontalAlignment','Right'); set(h,'VerticalAlignment','Top');
end

%=== add data source
x0   = xmin - 0.150*(xmax - xmin);
y0   = ymin - 0.100*(ymax - ymin);
h    = text(x0, y0, strSource); 
set(h,'FontSize', 10); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
set(h,'Horiz','Left'); set(h,'Vert','Middle');

%=== finish plot
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca,'LineWidth', 1);
set(gca,'FontSize',16);
xlabel(xTitle);
ylabel(yTitle);
xtickformat('%1.0f%%');
ytickformat('%2.1f%%');
legend(subset, strLegend, 'Location', 'NorthWest', 'Fontsize', 16);
title(strTitle, 'Fontsize', 16);


function plotMay2022_1(town, state, county, countyUS, figureNum)
%
% main figures for 30 minutes show in May 2022
%
global parameters;
if figureNum <= 0
  return;
end
fprintf('\n--> plotMay2022_1\n');

%---------------------------------------------------------------------------------------------
%=== 1 & 2. CT AND US VACCINATION RATES

%=== do Connecticut and US
figureNum = figureNum - 1;
for p=1:2
  figureNum = figureNum + 1;
  figure(figureNum); fprintf('Figure %d.\n', figureNum);
  
  %=== set CT or US
  if p ==1 
    stateName = 'Connecticut';
  else
    stateName = 'United States';
  end
  s         = find(strcmp(stateName, state.names));

  %=== get CDC dates
  date1        = char(state.vaxDates(end-365));
  d1           = find(strcmp(date1, state.vaxDates));
  d2           = length(state.vaxDates);
  dates        = state.vaxDates(d1:d2);

  %=== get rates
  completedAll = state.vaxData(d1:d2,:,9);  % all ages
  completed5   = state.vaxData(d1:d2,:,26); % age 5+
  completed511 = state.vaxData(d1:d2,:,28); % age 5-11
  boosted18    = state.vaxData(d1:d2,:,20); % boosted age 18+
  boostedAll   = state.vaxData(d1:d2,:,27); % all ages

  %=== get dates for plots
  numDates = length(dates);
  interval = 8*7;
  d6       = numDates;
  d5       = mod(numDates,interval);    % so last date is final tick mark
  if d5 == 0
    d5     = interval;
  end
  x        = d5:interval:d6;            % show only these dates
  xLabels  = dates;

  %=== plots
  y1 = completed5(:,s);
  y1 = completedAll(:,s);
  y2 = boosted18(:,s);
  y2 = boostedAll(:,s);
  y3 = completed511(:,s);
  plot(y1,'r-',     'LineWidth', 2); hold on;
  plot(y2,'b-',     'LineWidth', 2); hold on;
  plot(y3,'k-',     'LineWidth', 2); hold on;

  %=== get labels for plot
  strLegends(1) = {sprintf('Age 5+   Fully Vaccinated (Latest = %2.1f%%)', y1(end))};
  strLegends(1) = {sprintf('All Ages Fully Vaccinated (Latest = %2.1f%%)', y1(end))};
  strLegends(2) = {sprintf('Age 18+  Boosted          (Latest = %2.1f%%)', y2(end))};
  strLegends(2) = {sprintf('All Ages Boosted          (Latest = %2.1f%%)', y2(end))};
  strLegends(3) = {sprintf('Age 5-11 Fully Vaccinated (Latest = %2.1f%%)', y3(end))};
  strTitle      = sprintf('%s Vaccination Rates (%s to %s)', char(stateName), char(dates(1)), char(dates(end)));
  xTitle        = sprintf('Report Date');
  yTitle        = sprintf('Percent of Age Population');
  strSource     = sprintf('%s\n%s','Data Source: https://data.cdc.gov/', parameters.rickAnalysis);

  %=== get axis limits
  ylim([0,80]);
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

%---------------------------------------------------------------------------------------------
%=== 3 & 4. CT AND US NATURAL IMMUNITY RATES

%=== do Connecticut and US
for p=1:2
  figureNum = figureNum + 1;
  figure(figureNum); fprintf('Figure %d.\n', figureNum);
  
  %=== set CT or US
  if p ==1 
    stateName = 'Connecticut';
  else
    stateName = 'United States';
  end
  s         = find(strcmp(stateName, state.names));

  %=== get CDC dates
  %date1        = '07/01/2021';
  d1           = find(strcmp(date1, state.vaxDates));  % ages 5+ eligible
  d2           = length(state.vaxDates);
  dates        = state.vaxDates(d1:d2);
  
  %=== get natural immunity
  naturalImmunity = zeros(length(d1:d2),1);
  for dd=1:length(state.infectedFractionDates)
    d                  = find(strcmp(state.infectedFractionDates(dd), dates));
    naturalImmunity(d) = 100*state.infectedFraction(s,dd);
  end

  %=== get dates for plots
  numDates = length(dates);
  interval = 8*7;
  d6       = numDates;
  d5       = mod(numDates,interval);    % so last date is final tick mark
  if d5 == 0
    d5     = interval;
  end
  x        = d5:interval:d6;            % show only these dates
  xLabels  = dates;
  
  %=== bar plot of natural immunity
  barWidth = 3;
  h = bar(naturalImmunity, barWidth, 'FaceColor', 'r'); hold on;

  %=== add values above bars
  dateLabels = flip(state.infectedDateLabels);
  for p=1:1
    X = get(h(p), 'XEndPoints');
    Y = get(h(p), 'YEndPoints');
    X = X(Y>0);
    Y = Y(Y>0);
    for i=1:length(Y)
      T(i) = {sprintf('%2.1f%%\n%s', Y(i), char(dateLabels(i)))};
    end
    text(X,Y,T, 'vert','bottom', 'horiz','center', 'FontWeight','bold', 'FontSize',12, 'color','k', 'BackgroundColor','w');
  end

  %=== get labels for plot
  strTitle      = sprintf('%s: CDC Estimated Percent of Population Previously Infected', char(stateName));
  xTitle        = sprintf('CDC Seroprevalence Report Date');
  yTitle        = sprintf('Estimated Percent of Population Previously Infected');
  strSource     = sprintf('%s\n%s','Data Source: https://covid.cdc.gov/covid-data-tracker', ...
                                   'Figure created by Rick Lawrence (Ridgefield COVID Task Force)');
  strLegends(1) = {sprintf('Percent of Population Previously Infected (Latest = %2.1f%%)', 100*state.infectedFraction(s,1))};
  strNote       = sprintf('%s\n%s','The CDC estimates that 94.7%% of the Age 16+ US population have COVID-19 antibodies', ...
                                       '(from either vaccination or previous infection)');
                                       %'https://covid.cdc.gov/covid-data-tracker/#nationwide-blood-donor-seroprevalence');

  %=== get axis limits
  ylim([0,80]);
  ax   = gca; 
  xmin = ax.XLim(1); 
  xmax = ax.XLim(2);
  ymin = ax.YLim(1); 
  ymax = ax.YLim(2);

  %=== add note
  x0   = xmin + 0.50*(xmax - xmin);
  y0   = ymin + 0.90*(ymax - ymin);
  h    = text(x0, y0, strNote); 
  set(h,'FontSize', 14); set(h,'FontWeight', 'bold'); set(h,'Color','k'); set(h, 'BackgroundColor', 'c'); 
  set(h,'Horiz','Center'); set(h,'Vert','Middle');
  
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
  %legend(strLegends,'FontSize', 14, 'Location','NorthWest', 'FontName','FixedWidth', 'FontWeight','bold');
  title(strTitle,   'FontSize', 16);
end

%----------------------------------------------------------------------------------------
%=== 5. PLOT CDC NATURAL IMMUNITY DATA
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== plot data
y(:,1) = [33.5, 44.2, 45.6, 36.5, 28.8, 19.1]';  % December 2021
y(:,2) = [57.7, 75.2, 74.2, 63.7, 49.8, 33.2]';  % February 2022
h      = bar(y, 1.0, 'grouped'); hold on;
set(h(1),'FaceColor', 'b');
set(h(2),'FaceColor', 'r');

%=== add values above bars
clear T;
for p=1:2
  X = get(h(p), 'XEndPoints');
  Y = get(h(p), 'YEndPoints');
  for i=1:length(Y)
    T(i) = {sprintf('%2.1f%%', Y(i))};
  end
  text(X,Y,T, 'vert','bottom', 'horiz','center', 'FontWeight','bold', 'FontSize',12, 'color','k', 'BackgroundColor','w');
end

%=== set labels
strTitle      = sprintf('Seroprevalence of infection-induced COVID antibodies');
strLegends(1) = {sprintf('December 2021')};
strLegends(2) = {sprintf('February 2022')};
xLabels       = {'Overall US'; 'Age 0-11'; 'Age 12-17'; 'Age 18-49'; 'Age 50-65'; 'Age 65+'};
yLabel        = sprintf('Infection-induced seroprevalence (as percent of population)');

%=== add data source
ax   = gca; 
ymin = ax.YLim(1); 
ymax = ax.YLim(2);
x0   = -0.10;
y0   = ymin - 0.10*(ymax - ymin);
strText = sprintf('%s\n%s', 'Data Source: CDC Morbidity and Mortality Weekly Report, April 26, 2022', ...
                            'Figure created by Rick Lawrence (Ridgefield COVID Task Force)');
h = text(x0, y0, strText); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); set(h,'FontSize', 10);
set(h, 'BackgroundColor', 'c');

%=== finish plot
hold off;
grid on;
set(gca,'Color',parameters.bkgdColor);
set(gca, 'LineWidth', 2);
set(gca,'FontSize',14);
set(gca,'XTickLabel',xLabels);
%xlabel('Age Group', 'FontSize', 14);
ylabel(yLabel,'FontSize', 14);
ytickformat('%1.0f%%');
legend(strLegends,'Location', 'NorthEast', 'FontSize', 14);
title(strTitle, 'FontSize', 16);

%---------------------------------------------------------------------------------------------
%=== 6. SCATTER PLOT OF VACCINATION RATE VS PREVIOUS INFECTION RATE
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== get vax data
date1       = '03/01/2022';
date2       = char(state.vaxDates(end));
d2v         = find(strcmp(date2, state.vaxDates));
x2          = state.vaxData(d2v,:,9)';           % completed all ages

%=== get previous infection data
y2          = 100*state.infectedFraction(:,1);

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); 
strLegend(1) = {sprintf('State-Level Data')}; subset(1) = h1;

%=== add state short names inside circles
stateNames0 = state.names0;
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

%=== set labels
strTitle  = sprintf('Previous Infection Rates vs Vaccination Rates');
xTitle    = sprintf('Percent of US Population Fully Vaccinated');
yTitle    = sprintf('Estimated Percent of Population Previously Infected');
strSource = sprintf('%s\n%s','Data Source: https://data.cdc.gov/', parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
ylim([20,100]);
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at US 
N  = 1;
us = find(strcmp('US', stateNames0));
x3 = x2(us);
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Fully Vaccinated Rate = %2.1f%%', x3)}; subset(N) = h2;

%=== horizontal line at US
y3 = y2(us);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Previously Infected Percent = %2.1f%%', y3)}; subset(N) = h3;

%=== compute correlation
filter = find(~isnan(y2));
R      = corrcoef(x2(filter),y2(filter));
corr   = R(1,2);
h4     = plot([xmin,xmin], [ymin,ymin], '.');
N      = N + 1;
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
%=== 7. SCATTER PLOT OF VACCINATION RATE VS BA2 CASES AT STATE LEVEL
figureNum = figureNum + 1;
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== set date window for BA2
date1       = '03/01/2022';
date2       = char(state.dates(end));
d1          = find(strcmp(date1, state.dates));
d2          = find(strcmp(date2, state.dates));

%=== get vax data
d2v         = find(strcmp(date2, state.vaxDates));
d2v         = length(state.vaxDates);
x2          = state.vaxData(d2v,:,9)';            % fully vaccinated all ages
%x2          = state.vaxData(d2v,:,27)';           % boosted all ages

%===- get BA2 case rate
y2          = nansum(state.newCases(d1:d2,:),1)' ./ length(d1:d2);  % daily death rate
y2          = 100000 * y2 ./ state.population;

%=== plot big circles for each point
h1 = plot(x2, y2, 'o', 'Color','k', 'Markersize', 20); 
strLegend(1) = {sprintf('State-Level Data')}; subset(1) = h1;

%=== add state short names inside circles
stateNames0 = state.names0;
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

%=== set labels
strTitle  = sprintf('Daily Case Rate During BA.2 Phase (%s to %s) vs Vaccination Rates', date1, date2);
xTitle    = sprintf('Percent of US Population Fully Vaccinated');
yTitle    = sprintf('Daily Case Rate During BA.2 Phase');
strSource = sprintf('%s\n%s','Data Source: https://data.cdc.gov/', parameters.rickAnalysis);

%=== get axis limits
ax   = gca; 
xmin = ax.XLim(1); 
xmax = ax.XLim(2);
ymin = ax.YLim(1); 
ymax = ax.YLim(2);

%=== vertical line at US 
N  = 1;
us = find(strcmp('US', stateNames0));
x3 = x2(us);
h2 = plot([x3,x3], [ymin,ymax], 'r:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US Fully Vaccinated Rate = %2.1f%%', x3)}; subset(N) = h2;

%=== horizontal line at US
y3 = y2(us);
h3 = plot([xmin,xmax], [y3,y3], 'k:', 'LineWidth', 2);
N  = N + 1;
strLegend(N) = {sprintf('US New Case Rate During BA.2 Phase = %2.1f', y3)}; subset(N) = h3;

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
legend(subset, strLegend, 'Location', 'NorthWest', 'Fontsize', 12);
title(strTitle, 'Fontsize', 16);

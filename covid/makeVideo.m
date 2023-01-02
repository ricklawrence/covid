function makeVideo(townName, town, countyName, county, figureNum, figureOnly)
%
% make video of townName vs fairfield county over time
%
global parameters;
if figureNum <= 0
  return;
end
or = parameters.orange;
fprintf('\n--> makeVideo\n');

%=== need to close figure if it exists
close(findobj('type','figure','number',figureNum));
figure(figureNum); fprintf('Figure %d.\n', figureNum);

%=== if we only care about the figure, make everything bigger
if figureOnly
  sizeMultiplier = 2.0;
else
  sizeMultiplier = 1.0;
end

%=== set name of video file
videoFile = sprintf('../video/%s vs Fairfield County.mp4', townName);

%=== set date limits
d1        = find(strcmp(town.dates, '12/17/2020'));   % initial date
d1        = town.numDates-7;                          % initial date
d2        = town.numDates;                            % use final date in data
date1     = char(town.dates(d1));
date2     = char(town.dates(d2));

%=== get data for town and county
t                 = find(strcmp(town.names,   townName));
c                 = find(strcmp(county.names, countyName));
newCaseRates(:,1) = town.features(:,t,2);
newCaseRates(:,2) = county.features(:,c,2);
newTestRates(:,1) = town.features(:,t,4);
newTestRates(:,2) = county.features(:,c,4);
longNames(1)      = town.names(t);
longNames(2)      = {sprintf('%s County', char(county.names(c)))};
shortName1        = char(longNames(1)); shortName1 = shortName1(1);
shortName2        = sprintf('%sC', countyName(1));                  % fairfield county is FC
if strcmp(county.level, 'Town')  % in case county is actually a town
  longNames(2)      = county.names(c);
  shortName2         = char(longNames(2)); shortName2 = shortName2(1); % first initial of town
end
shortNames        = {shortName1, shortName2};
countyName        = char(longNames(2));

%=== compute max positivity for number of positivity lines to plot
positivity    = newCaseRates(d1:d2,:) ./ newTestRates(d1:d2,:);
maxPositivity = max(positivity,[],'all');
maxPositivity = ceil(maxPositivity*100)/100;

%=== set axis limits
xmin0 = min(newTestRates(d1:d2,:),[],'all');
xmax0 = max(newTestRates(d1:d2,:),[],'all');
ymin0 = min(newCaseRates(d1:d2,:),[],'all');
ymax0 = max(newCaseRates(d1:d2,:),[],'all');
xmin  = 100*floor(xmin0/100);     % min tests
xmax  = 100*ceil(xmax0/100);      % max tests
ymin  = 10*floor(ymin0/10);       % min cases
ymax  = 10*ceil(ymax0/10);        % max cases
ymin  = 0;                        % cases always start at 0
ymax  = ymax + 10;                % need room at top of notes

%----------------------------------------------------------------------------------------------------------------
%=== loop over dates -- each date is a video frame
hold on; 
for d=d1:d2 
  frame = d - d1 + 1;
  day   = sprintf('%d',frame);
            
  %=== set axis limits
  xlim([xmin xmax]);
  ylim([ymin ymax]);

  %=== linearly increase the size of the markers
  size1 = 6;    % smallest circle
  size2 = 50;   % largest  circle
  frac  = (d - d1) / (d2 - d1);
  size  = size1 + frac*(size2 - size1);
  size  = size*sizeMultiplier;
  
  %=== plot single point at each date
  if d < d2
    
    %=== plot each date with increasing marker size.  optionally add day number inside the marker
    h = plot(newTestRates(d,1), newCaseRates(d,1), '.');           set(h,'Color', 'y'); set(h,'MarkerS', size);
    h = plot(newTestRates(d,2), newCaseRates(d,2), '.');           set(h,'Color',  or); set(h,'MarkerS', size);
    if figureOnly < 0
      h = text(newTestRates(d,1), newCaseRates(d,1), day);           set(h,'Color', 'k'); set(h,'Horiz', 'center'); set(h,'FontSize', 6*sizeMultiplier); set(h,'FontWeight', 'normal');
      h = text(newTestRates(d,2), newCaseRates(d,2), day);           set(h,'Color', 'k'); set(h,'Horiz', 'center'); set(h,'FontSize', 6*sizeMultiplier); set(h,'FontWeight', 'normal');
    end
  else
    
    %=== final date always gets blue circle with abbreviation inside.
    h = plot(newTestRates(d,:), newCaseRates(d,:), '.');           set(h,'Color', 'b'); set(h,'MarkerS', size); 
    h = text(newTestRates(d,1), newCaseRates(d,1), shortNames(1)); set(h,'Color', 'y'); set(h,'Horiz', 'center'); set(h,'FontSize', 6*sizeMultiplier); set(h,'FontWeight', 'bold');
    h = text(newTestRates(d,2), newCaseRates(d,2), shortNames(2)); set(h,'Color',  or); set(h,'Horiz', 'center'); set(h,'FontSize', 6*sizeMultiplier); set(h,'FontWeight', 'bold');
  end

  %=== first date only
  if d == d1
    
    %=== print town name next to first point
    x0 = 1.005*newTestRates(d1,:);
    y0 = newCaseRates(d1,:);
    h  = text(x0(1), y0(1), longNames(1)); set(h, 'FontSize', 8*sizeMultiplier); set(h,'Color', 'y'); set(h,'Horiz', 'left');
    h  = text(x0(2), y0(2), longNames(2)); set(h, 'FontSize', 8*sizeMultiplier); set(h,'Color',  or); set(h,'Horiz', 'left');

    %=== add explanatory text
    x0   = xmin + 0.01*(xmax - xmin);
    y0   = ymin + 0.98*(ymax - ymin);
    strText1 = sprintf('The circles show the New Test Rate and New Case Rate at each date from %s to %s.', date1, date2);
    strText2 = sprintf('The size of the circles increases with time. The Blue circle is the final date %s.', date2);
    strText3 = sprintf('The White lines show constant Test Positivity Rates.');
    strText4 = sprintf('The New Case Rate and the New Test Rate are averaged over %d days.', parameters.maWindow);
    strText  = sprintf('%s\n%s\n%s\n%s', strText1, strText2, strText3, strText4);
    h = text(x0, y0, strText); set(h,'Color','k'); set(h,'HorizontalAlignment','Left'); 
    set(h,'FontWeight', 'normal');  set(h,'FontSize', 6*sizeMultiplier);
    set(h, 'BackgroundColor', 'c'); set(h,'VerticalAlignment','Top');
    
    %=== plot lines for constant positive test rates
    positiveRates1 = 0.01 : 0.01 : maxPositivity;
    xfit(1) = xmin;
    xfit(2) = xmax;
    for i=1:length(positiveRates1)
      positiveRate = positiveRates1(i);
      yfit         = positiveRate .* xfit;
      if yfit(2) > ymax
        xfit(2) = ymax / positiveRate;
        yfit(2) = ymax;
      end
      h            = plot(xfit,yfit,'w-');  set(h, 'LineWidth', 1); hold on;
      strText      = sprintf(' %1.0f%%', 100*positiveRate);
      x0           = xfit(2);
      y0           = yfit(2);
      h            = text([x0,x0],[y0,y0], strText); 
      set(h,'Color','r', 'HorizontalAlignment','Left', 'FontWeight','bold', 'FontSize',10); hold on;
    end
  end

  %=== add labels
  grid on;
  set(gca,'Color','k');
  set(gca,'LineWidth', 2);
  set(gca,'GridColor', 'c');
  set(gca,'FontSize',14);
  xlabel('New Test Rate (per 100,000 Residents)','FontSize', 14);
  ylabel('New Case Rate (per 100,000 Residents)','FontSize', 14);
  if ~figureOnly
    strTitle = sprintf('%s', char(town.dates(d)));  % title for video
    F(frame) = getframe(gcf);                       % capture the frame
  else
    strTitle = sprintf('%s vs %s: %s to %s', townName, countyName, date1, date2);  % title for figure
  end
  title(strTitle);
  
end

if figureOnly
  return;
end

%----------------------------------------------------------------------------------------------------------------
%=== make the video
v = VideoWriter(videoFile, 'MPEG-4');
v.FrameRate = 1;
open(v);
writeVideo(v,F);
close(v);
fprintf('Wrote video to %s.\n', videoFile);

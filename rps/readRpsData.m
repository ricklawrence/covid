function data = readRpsData(dataFile1, dataFile2, dataFile3)
%
% read raw RPS data
%
global parameters;
fprintf('\n--> readRpsData\n');

%---------------------------------------------------------------------------------------------
%=== read school data as a table
dataTable1 = readtable(dataFile1);
head(dataTable1,8);
numRows    = length(dataTable1.School);
fprintf('Read      %3d rows from %s.\n', numRows, dataFile1);

%=== save school names and enrollments
data.schoolNames0 = dataTable1.School;
data.schoolNames  = dataTable1.SchoolName;
data.enrollment   = dataTable1.Enrollment;

%=== add total RPS data at end 
%=== (there are records tagged with RPS ... these are cases not specific to a school)
s                    = length(data.schoolNames) + 1;
i                    = [1:length(data.schoolNames)];
data.schoolNames(s)  = {'Ridgefield Public Schools'};
data.schoolNames0(s) = {'RPS'};
data.enrollment(s)   = 4164 + 750;   % total RPS students+faculty+staff from Aaron

%=== compute average ratio of {total RPS students+faculty+staff} to {total RPS students}
data.staffRatio = data.enrollment(end) / sum(data.enrollment(1:end-1));

%---------------------------------------------------------------------------------------------
%=== read each line of the 2022 unstructured case data file
fid       = fopen(dataFile2, 'r');
dates0    = cell(10,1);
newCases0 = NaN(10,1);
names0    = cell(10,1);
r         = 0;
r0        = 0; % count all lines
line      = fgetl(fid);
while ischar(line)
  r0 = r0 + 1;
  
  if contains(line, '/')     
    
    %=== this line is a date
    date      = cellstr(datestr(datenum(line), 'mm/dd/yyyy'));
    r         = r + 1;
    dates0(r) = date;
  elseif contains(line,'case') 
    
    %=== this line has cases for a specified school for the date on previous line
    [num, rem]   = strtok(line);
    [tok,rem1]   = strtok(rem);
    cases        = str2double(num);
    name         = {strtrim(rem1)};   % remove blanks
    name         = strtok(name,'.');  % remove '.'
    name         = strtok(name,',');  % remove ','
    newCases0(r) = cases;
    names0(r)    = cellstr(name);
    
    %=== if name = 'RPSbreak, these are cases reported during breaks
    if strcmp(names0(r), 'RPSbreak')
      fprintf('  Ignoring %2d cases during break on %s\n', newCases0(r), char(dates0(r)));
    end
    
  else
    
    %=== make sure we didn't miss anything
    if length(line) ~= 0
      fprintf('  Record %3d with length %d: %s\n', r0, length(line), line);
    end
  end
  line = fgetl(fid);
end
fclose(fid);
fprintf('  Extracted %3d dates and %3d (%d unique) school names from %s.\n', ...
         length(dates0), length(names0), length(unique(names0)), dataFile2);

%---------------------------------------------------------------------------------------------
%=== read each line of the 2023 unstructured case data file
fid       = fopen(dataFile3, 'r');
line      = fgetl(fid);
r1        = 0;
r2        = 0;
r2023     = r + 1;
while ischar(line)
  r0 = r0 + 1;
  
  if contains(line, '/')    
    
    %=== this line is a date
    r1   = r1 + 1;
    date = cellstr(datestr(datenum(line), 'mm/dd/yyyy'));
    
  elseif length(line) > 0  
    
    %=== this line has case data (e.g. RHS - 3, FES - 2, SES - 1)
    rem = line;
    while length(rem) > 0
      r            = r + 1;
      r2           = r2 + 1;
      [name, rem]  = strtok(rem);
      [dash, rem]  = strtok(rem);
      [num,  rem]  = strtok(rem);
      %[name, rem]  = strtok(rem,'-');
      %[num,  rem]  = strtok(rem);
      %num          = abs(num);
      dates0(r)    = date;
      names0(r)    = cellstr(name);
      newCases0(r) = str2double(num);
    end

  end
  line = fgetl(fid);
end
fclose(fid);
fprintf('  Extracted %3d dates and %d school records from %s.\n', r1, r2, dataFile3);

%---------------------------------------------------------------------------------------------
%=== save data in array format
datenum1      = datenum('01/01/2022');
datenum2      = max(datenum(dates0));
data.dates    = cellstr(datestr([datenum1:datenum2]', 'mm/dd/yyyy'));
data.newCases = zeros(length(data.dates), length(data.schoolNames));
fprintf('  Most recent date = %s\n', char(data.dates(end)));
for r=1:length(dates0)
  i = find(strcmp(dates0(r), data.dates));
  j = find(strcmp(names0(r), data.schoolNames0));
  if isempty(i)
    fprintf('    Did not find %s (for %s) in the list of dates.\n', char(dates0(r)), char(names0(r)));
  end
  if isempty(j) && ~strcmp(names0(r), 'RPSbreak')
    fprintf('    Did not find %s (for %s) in the list of schools.\n', char(names0(r)), char(dates0(r)));
  end
  data.newCases(i,j) = newCases0(r);
end

%=== add school totals to RPS data
s                    = find(strcmp(data.schoolNames0, 'RPS'));
i                    = 1:length(data.schoolNames)-1;
data.newCases(:,s)   = data.newCases(:,s) + nansum(data.newCases(:,i), 2);

%=== 1/1/2022 and 1/2/2022 are not available
data.newCases(1:2,:) = 0;

%=== compute new case rates
[numDates, ~]     = size(data.newCases);
data.newCaseRates = 100000 * movingAverage(data.newCases,7) ./ repmat(data.enrollment', numDates, 1);

%---------------------------------------------------------------------------------------------
%=== check 2023 data
debug = 0;
if debug
  for r=r2023:length(dates0)
    fprintf('%s\t%s\t%d\n', char(dates0(r)), char(names0(r)), newCases0(r));
  end
  data.dates(241:end)
  data.schoolNames0'
  data.newCases(241:end,:)
end

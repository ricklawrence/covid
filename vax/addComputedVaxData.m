function state1 = addComputedVaxData(state)
%
% add new fields (e.g. percent of ages 5-11 initiated and completed) to state-level vaccination data
%
global parameters;
fprintf('\n--> addComputedVaxData\n');

%=== get 12+ and 5+ percents (used to compute populations below)
initiated12  = state.vaxData(:,:,17);
completed12  = state.vaxData(:,:,18);
initiated5   = state.vaxData(:,:,25);
completed5   = state.vaxData(:,:,26);

%=== get 12+ and 5+ people (p is for people, not percent :-)
initiated12p = state.vaxData(:,:,21);
completed12p = state.vaxData(:,:,22);
initiated5p  = state.vaxData(:,:,23);
completed5p  = state.vaxData(:,:,24);

%=== compute 5-11 people
initiated511p  = initiated5p - initiated12p;
completed511p  = completed5p - completed12p;

%=== compute 5-11 population (based on both inititated and completed data)
population5    = initiated5p  ./ (0.01*initiated5);
population12   = initiated12p ./ (0.01*initiated12);
population511i = population5 - population12;
population5    = completed5p  ./ (0.01*completed5);
population12   = completed12p ./ (0.01*completed12);
population511c = population5 - population12;

%=== use population based on completed (CT value from initiated is WRONG)
population511  = population511c;

%=== compute 5-11 percents
initiated511 = 100*(initiated511p ./ population511);
completed511 = 100*(completed511p ./ population511);

%=== save data in existing structure
state1                  = state;
numDates                = length(state1.vaxDates);
i                       = length(state1.vaxLabels);
state1.vaxLabels(i+1)   = {'Percent of Age 5-11 Population With One+ Dose'};
state1.vaxLabels(i+2)   = {'Percent of Age 5-11 Population Fully Vaccinated'};
state1.vaxData(:,:,i+1) = initiated511;
state1.vaxData(:,:,i+2) = completed511;
for m=i+1:i+2
  state1.vaxDataN(:,:,m)  = state1.vaxData(:,:,m) ./ repmat(state1.population', numDates, 1);
  state1.vaxDataD(:,:,m)  = computeNewCases(state1.vaxData(:,:,m));
  state1.vaxDataMA(:,:,m) = movingAverage(state1.vaxDataD(:,:,m), parameters.maWindow);
end

%=== debug
debug = 0;
[population511(end-10:end,7) initiated511p(end-10:end,7) completed511p(end-10:end,7)];
if debug
  [population511i(end-10:end,7)  population511c(end-10:end,7)]
  [population511i(end-10:end,52) population511c(end-10:end,52)]
  state1.vaxData(end, 7,27:28)
  state1.vaxData(end,52,27:28)
end


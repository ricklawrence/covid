function writeDatamapperData(fid, names, data, dataLabel, fileName0)
%
% write data in csv format for import into data wrapper
%
global parameters;
fprintf('\n--> writeDatamapperData\n');

%=== strip NaNs for datawrapper
index = find(~isnan(data));
data  = data(index);
names = names(index);

if fid ~= 1
  fileName = fileName0;
  fid      = fopen(fileName, 'w');
end 
fprintf(fid,'%s,%s\n', 'Name', char(dataLabel));
for r=1:length(data)
  fprintf(fid,'%s,%6.4f\n', char(names(r)), data(r));
end
if fid ~= 1
  fclose(fid);
  fclose('all');
  fprintf('Wrote data for %s to %s\n', char(dataLabel), fileName);
end
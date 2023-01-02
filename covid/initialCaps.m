function name1 = initialCaps(name)
%
% convert town name to initial caps
%
name   = char(name);
name1  = [];
remain = name;

%=== convert each token in name to inital caps
while (remain ~= "")
  [token,remain] = strtok(remain);
  name1 = [name1, upper(token(1)),lower(token(2:end)), ' '];
end

%=== strip final blank and return as cell
name1 = {name1(1:end-1)};

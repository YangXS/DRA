function findAppend(filename, tabs)
lines = {};
fid = fopen(filename,'r');
n = 0;
while 1
    line = fgetl(fid);
    if ~ischar(line)
        break;
    end
    n = n + 1;
    lines{n} = line;
end
fclose(fid);

k = 1;
replaceNum = length(tabs);
for i = 1:n
    line = lines{i};
    pattern = tabs{k}{1};
    str_tgt = tabs{k}{2};
    idxs = strfind(line, pattern);
    if ~isempty(idxs)
        lines{i} = [line str_tgt];
        k = k + 1;
        if k > replaceNum
            break;
        end
    end
end

fid = fopen(filename,'w');
for i = 1:n
    fprintf(fid, '%s\n', lines{i});
end
fclose(fid);
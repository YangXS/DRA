function findAppend(filename, tabs)
% 找到tabs中的每个str，并在后面添加参数
% 要求：原来的filename中必须是参数：后面没有字符，直接换行了，
% 先把filename文件中的所有行都读进来
lines = {};
fid = fopen(filename,'r');
n = 0; % 保存总的行数
while 1
    line = fgetl(fid); % fgetl函数把换行省略了，
    if ~ischar(line)
        break;
    end
    n = n + 1;
    lines{n} = line;
end
fclose(fid);

% 然后在每行的字符串中查找和替换
k = 1; % 指示在table中第k行的替换
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

% 最后再把所有行写回到文件，
fid = fopen(filename,'w');
for i = 1:n
    fprintf(fid, '%s\n', lines{i});
end
fclose(fid);
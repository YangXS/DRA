function findAppend(filename, tabs)
% �ҵ�tabs�е�ÿ��str�����ں�����Ӳ���
% Ҫ��ԭ����filename�б����ǲ���������û���ַ���ֱ�ӻ����ˣ�
% �Ȱ�filename�ļ��е������ж�������
lines = {};
fid = fopen(filename,'r');
n = 0; % �����ܵ�����
while 1
    line = fgetl(fid); % fgetl�����ѻ���ʡ���ˣ�
    if ~ischar(line)
        break;
    end
    n = n + 1;
    lines{n} = line;
end
fclose(fid);

% Ȼ����ÿ�е��ַ����в��Һ��滻
k = 1; % ָʾ��table�е�k�е��滻
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

% ����ٰ�������д�ص��ļ���
fid = fopen(filename,'w');
for i = 1:n
    fprintf(fid, '%s\n', lines{i});
end
fclose(fid);
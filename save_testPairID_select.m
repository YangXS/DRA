function save_testPairID_select(datasetName, version, n_s, data_root)

saveRoot = ['data/pairsID/' datasetName '_te/v' num2str(version) '/' ];
if ~exist(saveRoot, 'dir')
    mkdir(saveRoot);
end

load(data_root);
n = length(class_labels);
fid = fopen(['data/' datasetName '_list.txt']);
img_list = textscan(fid,'%s%d', n);
img_list = img_list{1};
fclose(fid);
if ~checkName(im_names, img_list')
    error('names no match');
end

idx_te = find( used_for_training ~= 1 );
class_labels_te = class_labels(idx_te);

O_S_array_te = pairsForLearnRank_select(...
    class_labels_te, relative_ordering, n_s);

O_S_array_te = randSetRows(O_S_array_te);

for i = 1:length(O_S_array_te)
    dlmwrite([saveRoot num2str(i) '.txt'], O_S_array_te{i}, ' ');
    relatives = relative_ordering(i,:)';
    relatives_te = relatives(class_labels_te);
	fid = fopen([saveRoot datasetName '_list' num2str(i) '.txt'], 'w');
    for j = 1:length(relatives_te)
        fprintf(fid, '%s %d\n', img_list{idx_te(j)}, relatives_te(j));  % ����ʹ�õ��±������idx_te(j)��дΪj,һ��Ҫע�������
    end
    fclose(fid);
end

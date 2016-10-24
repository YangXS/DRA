% ��������ѵ��ranker��image��ɵ�pair
% �����Ǳ���train��Ӧ �ġ�������
% �����п�������train��pairs��ѡȡ��һ���֣�

function [idx_tr, O_S_array_tr] = save_pairID_select(datasetName, version, n_s, data_root)
% n_s = 50; ����O��S�е�pairsѡȡn_s����
% version = 1; 
% dataType = 'osr';
% ���������ݵĵı���λ��
% load(['D:\data\attribute\relative_attributes_v2\relative_attributes\' ...
%     dataType '\data.mat']);
% ��ʼ������
saveRoot = ['data/pairsID/' datasetName '_tr/v' num2str(version) '/'];
if ~exist(saveRoot, 'dir')
    mkdir(saveRoot);
end

load(data_root);
n = length(class_labels);
['data/' datasetName '_list.txt']
fid = fopen(['data/' datasetName '_list.txt']);
img_list = textscan(fid,'%s%d', n);
img_list = img_list{1};
fclose(fid);
% �������ȡ��������Ӧ��ͼ�����
% ԭ����������Ӧ��ͼ�����Ƿ���ͬ
if ~checkName(im_names, img_list')
    error('names no match');
end

% �ҵ�����ѵ�������±�, 
idx_tr = find( used_for_training == 1 );
class_labels_tr = class_labels(idx_tr);% ѵ���������

%��ȡpairs��id
O_S_array_tr = pairsForLearnRank_select(...
    class_labels_tr, relative_ordering, n_s);

% ��idx_tr, ��O��S(û�д��ҵ�O_S_array_tr)Ҳ����������
save([saveRoot 'idxs_tr.mat'], 'idx_tr', 'O_S_array_tr');

% ����ѵ��ReNet�����ǵ�����ݶ��½��㷨����O_S�����ң�
O_S_array_tr = randSetRows(O_S_array_tr);

for i = 1:length(O_S_array_tr)
    dlmwrite([saveRoot num2str(i) '.txt'], O_S_array_tr{i}, ' ');
    relatives = relative_ordering(i,:)';
    relatives_tr = relatives(class_labels_tr);
	fid = fopen([saveRoot datasetName '_list' num2str(i) '.txt'], 'w');
    for j = 1:length(relatives_tr)
        fprintf(fid, '%s %d\n', img_list{idx_tr(j)}, relatives_tr(j));  % ����ʹ�õ��±������idx_te(j)��дΪj,һ��Ҫע�������
    end
    fclose(fid);
end


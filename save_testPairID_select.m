% ��������ѵ��ranker�õ���te��image��ɵ�pair
% �����п����õ�pairs��ѡȡ��һ���֣�

% clear all;

function save_testPairID_select(datasetName, version, n_s, data_root)

%ָ��seen������label��ʣ�µ�Ϊunseen
% seen_labels = [1;2;3;4;5;6];
% version = 1; 

% dataType = 'osr';
% ���������ݵĵı���λ��
% load(['D:\data\attribute\relative_attributes_v2\relative_attributes\' ...
%     dataType '\data.mat']);
% ��ʼ������
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
% �������ȡ��������Ӧ��ͼ�����
% ԭ����������Ӧ��ͼ�����Ƿ���ͬ
if ~checkName(im_names, img_list')
    error('names no match');
end


% �ҵ�����ѵ���õ�te���±�, 
% ����������te���±꣬����Ҫ����seen��class
idx_te = find( used_for_training ~= 1 );
class_labels_te = class_labels(idx_te);% �����

%��ȡpairs��id
O_S_array_te = pairsForLearnRank_select(...
    class_labels_te, relative_ordering, n_s);

% ����ѵ��ReNet�����ǵ�����ݶ��½��㷨����O_S�����ң�
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

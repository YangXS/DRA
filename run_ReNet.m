% ѵ��model����ȡfeat���������۽��

clear all;
close all;
clc;


%ָʾ��������ĸ���ݼ���
datasetName = 'osr';
% ָʾ��ǰ�Ĵ�����ǵڼ���attribute
N_att = 6;% osr: 6, pubfig: 11
version = 100;
n_tr_pairs = 500
% ָʾ��ǰ�����г���İ汾
version = version + 1


pathRoot = '/mnt/pan_sdd1/D_windows/data/attribute/relative_attributes_v2/relative_attributes/';
imagesRoot = [pathRoot datasetName '/images/'];
data_root = [pathRoot datasetName '/data.mat'];


createImageList(pathRoot, datasetName);
createImagePath(pathRoot, datasetName);

n_te_pairs = 20;% this is used for validation for training cnn model,
if n_tr_pairs < 100;
    batch_size = 10;% Ĭ��64
else
    batch_size = 32;
end
iterN = 4000;% Ĭ��5000��ָ��ѵ��������
batchN_te = 27; % ͼ�񼯵�ʵ�ʴ�С < batchN_te * batch_size���ɣ�


train_ReNet(datasetName, imagesRoot, ...
    data_root, N_att, version, n_tr_pairs,...
    n_te_pairs, batch_size, iterN, batchN_te);

%% ����feat
evaluation_ReNet(data_root, N_att, version, iterN, datasetName);

% osr res:
%     0.9770
% pubfig res:
%     0.9057





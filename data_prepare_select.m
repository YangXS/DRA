
% clear all;
% close all;
function data_prepare_select(datasetName, version, imagesRoot, N_attr)
% ���������Ϊzero-shot learning �� ׼�����

%ָʾ��������ĸ���ݼ���
% datasetName = 'osr';
% version = 1;
% ����ͼ�� ���ļ���
% ROOT = ['D:\data\attribute\relative_attributes_v2\relative_attributes\' datasetName '\images\'];
ROOT = imagesRoot;



% ָʾattribute������
% N_attr = 6;

for k_attr = 1:N_attr
    % % ָʾ��ǰ�Ĵ�����ǵڼ���attribute
    % k_attr = 1;
    
    % ������������
    nn = [datasetName '_v' num2str(version) '_attr' num2str(k_attr) ];
    
    %�м���ɵ��ļ����ļ���ǰ׺
    prefixData = ['./data/'];
    BIN_root = './caffe_20160725/build/tools/';
    BIN_cvt = [BIN_root, 'convert_imageset_siamese_data'];
    BIN_cvt_ = [BIN_root, 'convert_imageset'];
    BIN_mean = [BIN_root, 'compute_image_mean'];
    
    
    
    %% train data pair
    trData = [prefixData nn '_train_leveldb'];
    trList = [prefixData '/pairsID/' datasetName '_tr/v' num2str(version) ...
        '/'  datasetName '_list' ...
        num2str(k_attr) '.txt'];
    trPairs = [prefixData '/pairsID/' datasetName '_tr/v' num2str(version) ...
        '/'  num2str(k_attr) '.txt'];
    system('echo Creating training leveldb...');
    if exist(trData,'file')
        system(['rm -rf ', trData]);
    end
    sysCMD = [BIN_cvt ' ' ROOT ' ' trList ' ' ...
        trData ' ' trPairs ' -resize_height 227 -resize_width 227 -backend leveldb']
    system(sysCMD);
    system('echo Done.');
    
    %% test data pair
    teData = [prefixData nn '_test_leveldb'];
    teList = [prefixData '/pairsID/' datasetName '_te/v' num2str(version)...
        '/'  datasetName '_list' ...
        num2str(k_attr) '.txt'];
    tePairs = [prefixData '/pairsID/' datasetName  '_te/v' num2str(version)...
        '/'  num2str(k_attr) '.txt'];
    system('echo Creating test leveldb...');
    if exist(teData,'file')
        system([ 'rm -rf ' teData]);
    end
    sysCMD = [BIN_cvt ' ' ROOT ' ' teList ' ' ...
        teData ' ' tePairs ' -resize_height 227 -resize_width 227 -backend leveldb']
    system(sysCMD);
    system('echo Done.');
    
    
    %% mean of train data pair
    meanData = [prefixData nn '_train_leveldb_mean'];
    system('echo Creating leveldb for mean ...');
    sysCMD = [BIN_mean ' -backend leveldb ' trData ' ' meanData]
    system(sysCMD);
    system('echo Done.');
    
    %% train images
    trImg = [prefixData nn '_trImg_leveldb'];
    system('echo Creating train image leveldb...');
    if exist(trImg,'file')
        system(['rm -rf ', trImg]);
    end
    sysCMD = [BIN_cvt_ ' ' ROOT ' ' trList ' ' ...
        trImg ' -resize_height 227 -resize_width 227 -backend leveldb']
    system(sysCMD);
    system('echo Done.');    
     
    
    %% mean of train images
    meanImg = [prefixData nn '_trImg_leveldb_mean'];
    system('echo Creating leveldb for mean of images ...');
    sysCMD = [BIN_mean ' -backend leveldb ' trImg ' ' meanImg]
    system(sysCMD);
    system('echo Done.');
end

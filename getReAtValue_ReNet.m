function rt_predictions = getReAtValue_ReNet(data_root, ...
    datasetName, N_att, iterN, version)
% �������ȼ����������relative attributeֵ,
% ʹ��relative net ��feat���
load(data_root);
n = length(class_labels);
rt_predictions = [];
for k_attr = 1:N_att
    
    % ������������
    nn = [datasetName '_v' num2str(version) '_attr' num2str(k_attr) ];    
    feat_txt_name = ['features/' nn '_feat_iter' num2str(iterN) '.txt'];
   
     
    % ��ȡ������
    fea_new =  dlmread(feat_txt_name);
    fea_new = fea_new(1:n);
    fid = fopen(['data/' datasetName '_list.txt']);
    img_list = textscan(fid,'%s%d', n);
    fclose(fid);
    % �������ȡ��������Ӧ��ͼ�����
    % ԭ����������Ӧ��ͼ�����Ƿ���ͬ
    if ~checkName(im_names, img_list{1}')
        error('names no match');
    end
    display('read new feature done');
    
    % ���������滻ԭ��������
    feat = fea_new; % featֱ�Ӿ���attribute��relative ֵ��
    rt_predictions = [rt_predictions feat];
end
function rt_predictions = getReAtValue_ReNet(data_root, ...
    datasetName, N_att, iterN, version)
load(data_root);
n = length(class_labels);
rt_predictions = [];
for k_attr = 1:N_att
    nn = [datasetName '_v' num2str(version) '_attr' num2str(k_attr) ];    
    feat_txt_name = ['features/' nn '_feat_iter' num2str(iterN) '.txt'];
   
    fea_new =  dlmread(feat_txt_name);
    fea_new = fea_new(1:n);
    fid = fopen(['data/' datasetName '_list.txt']);
    img_list = textscan(fid,'%s%d', n);
    fclose(fid);
    if ~checkName(im_names, img_list{1}')
        error('names no match');
    end
    display('read new feature done');

    feat = fea_new; % featֱ denotes the attribute value
    rt_predictions = [rt_predictions feat];
end
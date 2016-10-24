function [idx_tr, O_S_array_tr] = train_ReNet(datasetName, ...
    imagesRoot, data_root, N_att, version, n_tr_pairs, ...
    n_te_pairs, batch_size, iterN, batchN_te)


[idx_tr, O_S_array_tr] = save_pairID_select(datasetName, ...
    version, n_tr_pairs, data_root);
% generate test image pairs
save_testPairID_select(datasetName, version, n_te_pairs, data_root);
% generate leveldb 
data_prepare_select(datasetName, version, imagesRoot, N_att);

for k_attr = 1:N_att
    
    create_prototxt(datasetName, k_attr, version, ...
        iterN, batch_size);    
    
    nn = [datasetName '_v' num2str(version) '_attr' num2str(k_attr) ]
    
    %% use ref model to train the attribute model
    BIN_dir = './caffe_20160725/build/tools/';
    BIN_caffe = 'caffe';
    solverProto = ['./prototxt/' nn '_solver.prototxt'];
    refModel = './Models/bvlc_reference_caffenet.caffemodel';
    
    sysComand = [BIN_dir BIN_caffe ' train ' '--solver=' solverProto ...
        ' --weights=' refModel]
    system(sysComand);
    

    %% extract attribute results for test images
    featType = 'feat';
    BIN_fea = 'extract_features_txt';
    out_fea = ['features/' nn '_' featType '_iter' num2str(iterN) '.txt'];
    trModel = ['Models/' nn '_iter_' num2str(iterN) '.caffemodel'];
    NetProto = ['prototxt/' nn '.prototxt'];
    sysComand = [BIN_dir BIN_fea ' ' trModel ' ' NetProto ' ' ...
        featType ' ' out_fea ' ' num2str(batchN_te) ' GPU 0']
    system(sysComand);    
end




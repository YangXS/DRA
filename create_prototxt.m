function create_prototxt(dataType, k_attr, version, ...
    iterN, batch_size)


prototxt_Root = './prototxt/';


nn = [dataType '_v' num2str(version) '_attr' num2str(k_attr) ]


% template_net_name
tnn = 'template_net';
tnpn = [prototxt_Root tnn '.prototxt'];
tnspn = [prototxt_Root tnn '_solver.prototxt'];
tntpn = [prototxt_Root tnn '_train.prototxt'];


% net_name : nn;
% net_prototxt_name
npn = [prototxt_Root nn '.prototxt'];
copyfile(tnpn, npn);
% net_solver_prototxt_name
nspn = [prototxt_Root nn '_solver.prototxt'];
copyfile(tnspn, nspn);
% net_train_prototxt_name
ntpn = [prototxt_Root nn '_train.prototxt'];
copyfile(tntpn, ntpn);



% net_prototxt_name
replace_tab1 = {
    {'source: ', ['"./data/'...
    dataType '_path.txt"']},
    {'mean_file: ', ['"./data/'...
    nn '_trImg_leveldb_mean"']}
};
findAppend(npn, replace_tab1);


replace_tab2 = {
    {'net: ', ['"' ntpn '"']},
    {'max_iter: ', num2str(iterN)}, 
    {'snapshot_prefix: ', ['"./Models/'...
    nn '"']}
};
findAppend(nspn, replace_tab2);


replace_tab3 = {
    {'source: ', ['"./data/'...
    nn '_train_leveldb"']},
    {'batch_size: ', num2str(batch_size)}, 
    {'mean_file: ', ['"./data/'...
    nn '_train_leveldb_mean"']}
    {'source: ', ['"./data/'...
    nn '_test_leveldb"']}, 
    {'mean_file: ', ['"./data/'...
    nn '_train_leveldb_mean"']}
};
findAppend(ntpn, replace_tab3);
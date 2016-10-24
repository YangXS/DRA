function create_prototxt(dataType, k_attr, version, ...
    iterN, batch_size)

% dataType = 'osr';
% k_attr = 1;
% version = 1;
% iterN = 2000;% ѵ���ĵ�����
% batch_size = 30;% ѵ����batch size
prototxt_Root = './prototxt/';

% ������������
nn = [dataType '_v' num2str(version) '_attr' num2str(k_attr) ]


%% ���prototxtģ���ļ��ı���λ��
% template_net_name
tnn = 'template_net';
% template_net_prototxt_name
tnpn = [prototxt_Root tnn '.prototxt'];
% template_net_solver_prototxt_name
tnspn = [prototxt_Root tnn '_solver.prototxt'];
% template_net_train_prototxt_name
tntpn = [prototxt_Root tnn '_train.prototxt'];


%% ���prototxt�ļ��ı���λ�ã�
% net_name : nn;
% net_prototxt_name����������ṹ��������ȡ������
npn = [prototxt_Root nn '.prototxt'];
copyfile(tnpn, npn);
% net_solver_prototxt_name������solver������Ҫ�Ĳ���
nspn = [prototxt_Root nn '_solver.prototxt'];
copyfile(tnspn, nspn);
% net_train_prototxt_name����������ѵ��������ṹ
ntpn = [prototxt_Root nn '_train.prototxt'];
copyfile(tntpn, ntpn);



%% �����prototxt�ļ��ж������

% net_prototxt_name����������ṹ��������ȡ������
replace_tab1 = { %����Ӳ�����б?
    {'source: ', ['"./data/'...
    dataType '_path.txt"']},
    {'mean_file: ', ['"./data/'...
    nn '_trImg_leveldb_mean"']} % ������ȡ������ͼ��ľ�ֵ�����Զ�Ӧ����Щͼ�ľ�ֵ���ƣ�
};
findAppend(npn, replace_tab1);

% net_solver_prototxt_name������solver������Ҫ�Ĳ���
replace_tab2 = { %����Ӳ�����б?
    {'net: ', ['"' ntpn '"']},
    {'max_iter: ', num2str(iterN)}, 
    {'snapshot_prefix: ', ['"./Models/'...
    nn '"']}
};
findAppend(nspn, replace_tab2);

% net_train_prototxt_name����������ѵ��������ṹ
replace_tab3 = { %����Ӳ�����б?
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
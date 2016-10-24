%  run evaluation

function evaluation_ReNet(data_root, N_att, version, iterN, datasetName)

res_root = ['./res/' datasetName '_v' num2str(version) '/ReNet/'];
load(data_root);
n = length(class_labels);
idx_te = find(used_for_training == 0);
class_labels_te = class_labels(idx_te);

% 得到所有样本的relative attribute值，
rt_predictions = getReAtValue_ReNet(data_root, ...
    datasetName, N_att, iterN, version);

accs = [];
tags = [];
corrs = [];
for k_attr = 1:N_att
    % 每个属性的结果
    predictions_te = rt_predictions(idx_te, k_attr);    
    [acc, tag, corr] = relative_evalutation_simple_s(predictions_te, ...
        relative_ordering, class_labels_te, k_attr);
    accs = [accs acc];
    tags = [tags tag];
    corrs = [corrs corr];
end

% 保存结果
if ~exist(res_root, 'dir')
    mkdir(res_root);
end
save([res_root 'res.mat'], 'accs', 'tags', 'corrs');

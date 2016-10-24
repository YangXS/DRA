function O_S_array = pairsForLearnRank_select(...
    class_labels_tr, relative_ordering, n_sub)
% n_sub 表示 每个属性中选取的pair个数
% 简化了callRank中的采样pair的方式
% num_s = 30, 不能大于每个类别的样本数;
% 这里的变量名称和 relative作者给的.mat文件是一致的，
% idx_tr = find(used_for_training==1);% 找到用于训练的样本下标
n_tr = length(class_labels_tr);%  训练的样本个数
% fea_tr = feat(idx_tr,:);% 训练的特征
% class_labels_tr = class_labels(idx_tr);% 训练的类别标记
n_att = size(relative_ordering,1);

p = nchoosek(n_tr,2);% pair最多可能的个数 = n_tr!，
O_S_array = {};
% 下面找到用于训练的样本中每个类别对应的样本
for i = 1:n_att % 每个属性都分别来处理
    display(['attribute: ' num2str(i)]);
    O_S = zeros(p, 2);
    tag_O_S = zeros(p,1);% 1 for O, 0 for S
    tag = 0;
    for j = 1:n_tr
        for k = j+1:n_tr % pair中的样本不能相同
            tag = tag + 1;
            if relative_ordering(i,class_labels_tr(j)) > ...
                    relative_ordering(i,class_labels_tr(k)) || ...
                    relative_ordering(i,class_labels_tr(j)) < ...
                    relative_ordering(i,class_labels_tr(k))
                tag_O_S(tag) = 1;% ordered pair
            else
                tag_O_S(tag) = 0;% unordered pair
            end
            O_S(tag, 1) = j;
            O_S(tag, 2) = k;
        end
    end
    % 把O_S分成O和S
    idx_O = find(tag_O_S == 1); % order
    idx_S = find(tag_O_S == 0); % similar
    % 分成 ordered 和similar 两部分，并随机打乱,
    % 这样打乱以后，在选择一部分的时候就可以直接截取前面部分
    O = O_S(idx_O(randperm(length(idx_O))),:);
    S = O_S(idx_S(randperm(length(idx_S))),:);
    n_O = length(idx_O);
    n_S = length(idx_S);
    p_p = min(n_O, n_S); % 最后用于train的pair个数
    if p_p == 0
        error('p_p == 0');
    end
    % 手工指定O和S只选取n_sub个
    p_p = min(p_p,n_sub);
    % 截取一部分使得O和S中的样本一样多
    O = O(1:p_p,:);
    S = S(1:p_p,:);
    % 再把O和S合并, 暂时不随机打乱，因为训练ReAt或者ReMTL的时候O和S要分开，
    O_S = [O; S];
    O_S_array{i} = O_S;
end

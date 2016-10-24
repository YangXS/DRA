function [acc, tag, corr] = relative_evalutation_simple_s(predictions, ...
    relative_ordering, class_labels_te, k_att)
% 和relative_evalutation_simple，这里只是计算一个属性的准确率
% predictions只是一个列向量
n_te = length(class_labels_te);
% n_te = length(class_labels_te);
%
% 下面找到用于训练的样本中每个类别对应的样本
tag = 0;
corr = 0;
for j = 1:n_te
    for k = j+1:n_te
        % 不同的order 分开处理
        if relative_ordering(k_att, class_labels_te(j)) > ...
                relative_ordering(k_att, class_labels_te(k))
            tag = tag + 1;
            if predictions(j) > predictions(k)
                corr = corr + 1;
            end
        elseif relative_ordering(k_att,class_labels_te(j)) < ...
                relative_ordering(k_att,class_labels_te(k))
            tag = tag + 1;
            if predictions(j) < predictions(k)
                corr = corr + 1;
            end
        end
    end
end
acc = corr / tag;
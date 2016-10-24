function [acc, tag, corr] = relative_evalutation_simple_s(predictions, ...
    relative_ordering, class_labels_te, k_att)
% ��relative_evalutation_simple������ֻ�Ǽ���һ�����Ե�׼ȷ��
% predictionsֻ��һ��������
n_te = length(class_labels_te);
% n_te = length(class_labels_te);
%
% �����ҵ�����ѵ����������ÿ������Ӧ������
tag = 0;
corr = 0;
for j = 1:n_te
    for k = j+1:n_te
        % ��ͬ��order �ֿ�����
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
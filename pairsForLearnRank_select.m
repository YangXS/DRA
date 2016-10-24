function O_S_array = pairsForLearnRank_select(...
    class_labels_tr, relative_ordering, n_sub)
n_tr = length(class_labels_tr);
n_att = size(relative_ordering,1);

p = nchoosek(n_tr,2);
O_S_array = {};

for i = 1:n_att % 
    display(['attribute: ' num2str(i)]);
    O_S = zeros(p, 2);
    tag_O_S = zeros(p,1);% 1 for O, 0 for S
    tag = 0;
    for j = 1:n_tr
        for k = j+1:n_tr %
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
    idx_O = find(tag_O_S == 1); % order
    idx_S = find(tag_O_S == 0); % similar
    O = O_S(idx_O(randperm(length(idx_O))),:);
    S = O_S(idx_S(randperm(length(idx_S))),:);
    n_O = length(idx_O);
    n_S = length(idx_S);
    p_p = min(n_O, n_S);
    if p_p == 0
        error('p_p == 0');
    end
    p_p = min(p_p,n_sub);
    O = O(1:p_p,:);
    S = S(1:p_p,:);
    O_S = [O; S];
    O_S_array{i} = O_S;
end

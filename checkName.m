function res = checkName(im_names, img_list)
% 检查字符串是否完全相同，
res = true;
n1 = length(im_names);
n2 = length(img_list);
if n1 ~= n2
    res = false;
end
for i = 1:n1
    if im_names{i} ~= img_list{i}
        res = false;
        break;
    end
end
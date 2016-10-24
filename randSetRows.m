function O_S_array = randSetRows(O_S_array)
n = length(O_S_array);

for i = 1:n
    O_S = O_S_array{i};
    O_S = O_S(randperm(size(O_S,1)),:);
    O_S_array{i} = O_S;
end
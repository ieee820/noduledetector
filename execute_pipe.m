sets = {'SNUH', 'CR', 'LS', 'CW'};
for i = 1 : 4,
    extract_nodules(cell2mat(sets(i)));
end
create_trainset();
create_testset();
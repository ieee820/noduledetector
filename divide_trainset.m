addpath 'utility_funcs';
eval(global_vars);
writepath = '../noduledetectordata/test_train_sets/fold_test/';
[~, ~, ~, allnodules] = calculate_avg_nodule();
[sets, ia2, ~] = unique(extractfield(allnodules, 'dataset'), 'stable');
sets = sets';
ia2 = [ia2; length(allnodules)+1];

for i = 1 : length(sets)
    allobjects = allnodules(ia2(i) : ia2(i+1)-1); %First add the nodules
    C = strsplit(cell2mat(sets(i)), '/');
    datasetname = cell2mat(C(3));
    setname = cell2mat(C(4));
    
    fprintf(['Processing Set : ' setname ' from dataset ' datasetname]);
    
    vessels = read_vessels(datasetname, setname, dth, ex_size, dilatesiz);
    
    labels = zeros(length(allobjects) + length(vessels), 1);
    labels(1:length(allobjects), 1) = 1;% set nodules to 1
    
    allobjects = struct([allobjects vessels]);
    
    %% Write labels
    delete([writepath 'set_labels_' num2str(i) '.h5'])
    h5create([writepath 'set_labels_' num2str(i) '.h5'], '/labels', length(allobjects), 'Datatype','int16');
    h5write([writepath 'set_labels_' num2str(i) '.h5'], '/labels', int16(labels));
    
    calculate_features(allobjects, [writepath 'set_feas_' num2str(i) '.h5']);
end
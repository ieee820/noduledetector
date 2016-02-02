%% Load Files
addpath('utility_funcs');
sets = extractfield(dir('../noduledetectordata/ANODECHALLANGE/originaldata/*.h5'), 'name')';
eval(global_vars);
dataname = 'ANODECHALLANGE';

%% Calculate Features
for i=1:length(sets)
    disp(['Processing Set : ' num2str(i)]);
    [~,fn,~] = fileparts(cell2mat(sets(i)));
    original_scan = h5read(['../noduledetectordata/ANODECHALLANGE/originaldata/' fn '.h5'], '/set');
    original_scan = permute(original_scan, [2 3 1]);
    
    p_file_name = ['../noduledetectordata/ANODECHALLANGE/ilastikoutput/' fn '_Probabilities.h5'];
    ilastik_output = read_ilastik_output(p_file_name, 4, dth);
    
    objs = calculate_cc(ilastik_output, original_scan, dilatesiz, ex_size, dataname);
    
    original_scan = [];
    ilastik_output = [];
    
    %% Calculate the features
    calculate_features(objs, ['../noduledetectordata/test_train_sets/ANODECHALLANGE/test_'...
                              num2str(i) '_feas.h5']);
end
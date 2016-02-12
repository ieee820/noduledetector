addpath 'utility_funcs';
eval(global_vars);
path = '/Volumes/INTENSO/Acedemic/Datasets/CTData/luna16/subset0/';
dataname = 'LUNA16/SUBSET0';
sets = extractfield(dir([path 'originaldata/*.h5']), 'name');
load '/Volumes/INTENSO/Acedemic/Datasets/CTData/luna16/annots';

for i = 1 : length(sets)
    %% Read ilastik pred file & original files
    disp(['Processing Set : ' num2str(i)]);
    [~,fn,~] = fileparts(cell2mat(sets(i)));
    original_scan = h5read([path 'originaldata/' fn '.h5'], '/set');
    original_scan = permute(original_scan, [2 3 1]);
    
    p_file_name = [path 'ilastikoutput/' fn '_Probabilities.h5'];
    ilastik_output = read_ilastik_output(p_file_name, 4, dth);
    
    objs = calculate_cc(ilastik_output, original_scan, dilatesiz, ex_size, [dataname '/' fn]);
    labels = cell(1, length(objs));
    
    %% TODO : Somehow get the labels exactly as luna16 does.
    
    
    %% Calculate the features
    calculate_features(objs, ['../noduledetectordata/test_train_sets/test_'...
                              num2str(i) '_feas.h5']);
end
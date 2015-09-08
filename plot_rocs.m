random_forest_result_file = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/FeatureFiles/randomforest_results.h5';

file_info = h5info(random_forest_result_file);
file_info = file_info.Datasets;
roc_values = h5read(random_forest_result_file, '/roc_vals');
var_alphastep = h5readatt(random_forest_result_file, '/roc_vals', 'var_alphastep');
var_treecount = h5readatt(random_forest_result_file, '/roc_vals', 'var_treecount');
var_mult = h5readatt(random_forest_result_file, '/roc_vals', 'var_mult');

batch_results = cell(length(file_info) -1, 2);
batch_counter = 1;
for x = 1:length(file_info)
    dataSetName = file_info(x).Name;
    if strcmp(dataSetName, 'roc_vals')
        continue;
    end
    probabilities = h5read(random_forest_result_file, ['/', dataSetName]);
    batch_results{batch_counter, 1} = dataSetName;
    batch_results{batch_counter, 2} = probabilities;
    batch_counter = batch_counter + 1;
end
figure;
plot(roc_values(1,:), roc_values(2,:))
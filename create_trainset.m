%% This Script creates labels and the features for training set
%% Load Classes
addpath 'utility_funcs'
eval(global_vars);
vessels = read_vessels('SNUH', '12773', dth, ex_size, dilatesiz);
vessels2 = read_vessels('SNUH', '12777', dth, ex_size, dilatesiz);
vessels3 = read_vessels('CR', '11029', dth, ex_size, dilatesiz);
vessels4 = read_vessels('LS', '10136', dth, ex_size, dilatesiz);
[nodz, nody, nodx, nodules] = calculate_avg_nodule();
allobjects = struct([nodules vessels2 vessels vessels3 vessels4]);
labels = zeros(length(allobjects), 1);
labels(1:length(nodules), 1) = 1;% set nodules to 1

%% Write labels
paths = '../noduledetectordata/test_train_sets/';
delete([paths 'train_labels.h5'])
h5create([paths 'train_labels.h5'], '/labels', length(allobjects), 'Datatype','int16');
h5write([paths 'train_labels.h5'], '/labels', int16(labels));

%% Calculate & Save Features
calculate_features(allobjects, [paths 'train_feas.h5']);
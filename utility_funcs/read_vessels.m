function objs = read_vessels(dataset, set, dth, ex_size, dilatesiz)
% This will use lot's of nodules and vessels to train a classifier.
% Channel 1 -> Vessels
% Channel 2 -> Bones
% Channel 3 -> Background
% Channel 4 -> Nodules

predicted_nodules = read_ilastik_output(['../noduledetectordata/' dataset '/ilastikoutput/' set '_Probabilities.h5'], 4, dth);

nodules_annot = h5read(['../noduledetectordata/' dataset '/annotations/' set '.h5'], '/set');
nodules_annot = permute(nodules_annot, [2, 3, 1]);

scan_orig = h5read(['../noduledetectordata/' dataset '/originaldata/' set '.h5'], '/set');
scan_orig = permute(scan_orig, [2, 3, 1]);


%Remove probability of nodules
predicted_nodules(nodules_annot>0) = 0;

objs = calculate_cc(predicted_nodules, scan_orig, dilatesiz, ex_size, [dataset '/' set]);
end
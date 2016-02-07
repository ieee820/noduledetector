%% Analyse Set
addpath 'utility_funcs';
analyse = 2;
origf = '../noduledetectordata/ANODE/originaldata/';
eval(global_vars)

fname = ['example0' num2str(analyse)];
ofp = [origf 'example0' num2str(analyse) '.h5'];

falses = h5read('randomforest_results_wxg.h5', ['/falses_' num2str(analyse)])';
trues = h5read('randomforest_results_wxg.h5', ['/trues_' num2str(analyse)])';
negatives = h5read('randomforest_results_wxg.h5', ['/negatives_' num2str(analyse)])';

original_scan = h5read(ofp, '/set');
original_scan = permute(original_scan, [2 3 1]);
normalizedmovie = uint8(255*mat2gray(original_scan));

p_file_name = ['../noduledetectordata/ANODE/ilastikoutput/' fname '_Probabilities.h5'];
ilastik_output = read_ilastik_output(p_file_name, 4, dth);
%ex_size = [20 20 20];
objs = calculate_cc(ilastik_output, original_scan, dilatesiz, ex_size, '');

%% MARK
for i=1:length(falses)
    annots.falses(i, :) = objs(falses(i)).CC.bbx;
end
for i=1:length(trues)
    annots.trues(i, :) = objs(trues(i)).CC.bbx;
end
for i=1:length(negatives)
    annots.negatives(i, :) = objs(negatives(i)).CC.bbx;
end

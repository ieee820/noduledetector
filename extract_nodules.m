function extract_nodules(name)
%% Read From H5
addpath 'utility_funcs';
eval(global_vars);          % This will get the global variables for all sets
datasetname = ['../noduledetectordata/' name];
sets = extractfield(dir([datasetname '/originaldata/*.h5']), 'name')';
datasets = cell(length(sets), 3); % 1 for set, 1 for annotation mask
for i=1:length(sets)
    [~,fn,~] = fileparts(cell2mat(sets(i)));             %get file name
    original_file = h5read([datasetname '/originaldata/' fn '.h5'], '/set');
    original_file = permute(original_file, [2,3,1]);
    annotation_file = h5read([datasetname '/annotations/' fn '.h5'], '/set');
    annotation_file = permute(annotation_file, [2,3,1]);
    %ilastik_file = h5read([datasetname '/ilastikoutput/' fn '_Probabilities.h5'], '/exported_data');
    %ilastik_file = permute(ilastik_file, [3 4 2 1]);
    ilastik_file = read_ilastik_output([datasetname '/ilastikoutput/' fn '_Probabilities.h5'], 4, dth);
    datasets{i, 1} = original_file;
    datasets{i, 2} = annotation_file;
    datasets{i, 3} = ilastik_file;
end

%% Process Nodules
nodules = struct;

for i=1:length(sets)
    [~,fn,~] = fileparts(cell2mat(sets(i)));
    original_scan = datasets{i, 1};
    annotation = datasets{i, 2};
    annotation(annotation>0) = 1; %set all masks to 1
    ilastik_file = datasets{i, 3};
    %ilastik_file = ilastik_file(:,:,:,4); %4'Th channel are nodules
    %ilastik_log = imreconstruct(ilastik_file>dth(1), ilastik_file>dth(2)); 
    mask_mat = ilastik_file .* single(annotation);
    
    objs = calculate_cc(mask_mat, original_scan, dilatesiz, ex_size, [datasetname '/' fn]);
    if numel(nodules) <= 1 && ~isempty(fieldnames(objs))
        nodules = objs;
    elseif numel(nodules) > 1 && ~isempty(fieldnames(objs))
        nodules = struct([nodules objs]);
    end
    
end
newname = ['nodules_' lower(name)];
rename_p = [newname '= nodules;'];
eval(rename_p);
delete([datasetname '/' newname '.mat']);
save([datasetname '/' newname '.mat'], newname');
end

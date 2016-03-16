
%% Read From H5
addpath 'utility_funcs';
addpath 'parfor_progress';
name = 'CR';
patchsize = 120;
eval(global_vars);          % This will get the global variables for all sets
datasetname = ['../noduledetectordata/' name];
sets = extractfield(dir([datasetname '/originaldata/*.h5']), 'name')';
parfor_progress(length(sets));
parfor i=1:length(sets)
    parfor_progress;
    [~,fn,~] = fileparts(cell2mat(sets(i)));             %get file name
    original_file = h5read([datasetname '/originaldata/' fn '.h5'], '/set');
    original_file = permute(original_file, [2,3,1]);
    annotation_file = h5read([datasetname '/annotations/' fn '.h5'], '/set');
    annotation_file = permute(annotation_file, [2,3,1]);
    
    BW = bwconncomp(annotation_file);
    S = regionprops(BW, 'centroid');
    
    %% For each nodule
    for j=1:length(S)
        try
            voxelcoor = floor(S(j).Centroid+0.5);
            cube = original_file(voxelcoor(2)-patchsize/2:voxelcoor(2)+patchsize/2, ...
                voxelcoor(1)-patchsize/2:voxelcoor(1)+patchsize/2, ...
                voxelcoor(3)-patchsize/10:voxelcoor(3)+patchsize/10);
            %write to h5 file
            flipped = permute(cube, [3,1,2]);
            sizeFlipped = size(flipped);
            filename = ['ROIS/' name '_' fn '_' num2str(j) '_ROI.h5'];
            delete(filename);
            h5create(filename, '/set', sizeFlipped, 'Datatype', 'int16')
            h5write(filename, '/set', flipped);
        end
    end
end
parfor_progress(0);
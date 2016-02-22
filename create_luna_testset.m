addpath 'utility_funcs';
eval(global_vars);
subset = '1';
path = ['/Volumes/INTENSO/Acedemic/Datasets/CTData/luna16/subset' subset '/'];
dataname = ['LUNA16/SUBSET' subset];
sets = extractfield(dir([path 'originaldata/*.h5']), 'name');
load '/Volumes/INTENSO/Acedemic/Datasets/CTData/luna16/annots';

total_hits = 0;
total_nodules = 0;
for i = 1 : length(sets)
    %% Read ilastik pred file & original files
    disp(['Processing Set : ' num2str(i)]);
    [~,fn,~] = fileparts(cell2mat(sets(i)));
    [~, info] = read_mhd([path 'originalfiles/' fn '.mhd']);
    original_scan = h5read([path 'originaldata/' fn '.h5'], '/set');
    original_scan = permute(original_scan, [2 3 1]);
    
    p_file_name = [path 'ilastikoutput/' fn '_Probabilities.h5'];
    ilastik_output = read_ilastik_output(p_file_name, 4, dth);
    
    objs = calculate_cc(ilastik_output, original_scan, dilatesiz, ex_size, [dataname '/' fn]);
    allcentroids = [objs(:).CC];
    allcentroids = reshape([allcentroids.centroid], [] , length(objs))';
    allcentroids_w = voxel_to_worldcoords(allcentroids, info.Offset, info.PixelDimensions);
    
    %Get annotations
    IndexC = strfind(seriesuid, fn);
    Index = find(not(cellfun('isempty', IndexC)));
    coord_w = [coordX(Index), coordY(Index), coordZ(Index)];
    dia = diameter_mm(Index);
    
    dists = pdist2(coord_w, allcentroids_w);
    
    total_nodules = total_nodules + length(Index);
    
    for j = 1 : size(dists, 1)
        R = dia(j) / 2;
        D = dists(j, :);
        z = min(D);
        if length(find(D<=R)) >= 1
            total_hits = total_hits + 1;
            disp('A Hit');
        else
            disp(['Distance = ' num2str(z) ' was above = ' num2str(R)]);
        end
    end

    %% TODO : Somehow get the labels exactly as luna16 does.
    
    
    %% Calculate the features
    %calculate_features(objs, ['../noduledetectordata/test_train_sets/test_'...
    %num2str(i) '_feas.h5']);
end

    if total_nodules>0
        sensivity = total_hits / total_nodules;
        disp(['Total Nodules : ' num2str(total_nodules)]);
        disp(['Total Hits : ' num2str(total_hits)]);
        disp(['Sensivity : ' num2str(sensivity)]);
        disp('//////////////////////');
    end
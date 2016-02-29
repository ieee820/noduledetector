addpath 'utility_funcs';
eval(global_vars);
subset = '0';
path = ['/Volumes/INTENSO/Acedemic/Datasets/CTData/luna16/subset' subset '/'];
dataname = ['LUNA16/SUBSET' subset];
sets = extractfield(dir([path 'originaldata/*.h5']), 'name');
load '/Volumes/INTENSO/Acedemic/Datasets/CTData/luna16/annots';

total_hits = 0;
total_nodules = 0;
ROIS = {};
for i = 1 : length(sets)
    %% Read ilastik pred file & original files
    disp(['Processing Set : ' num2str(i)]);
    [~,fn,~] = fileparts(cell2mat(sets(i)));
    [~, info] = read_mhd([path 'originalfiles/' fn '.mhd']);
    original_scan = h5read([path 'originaldata/' fn '.h5'], '/set');
    original_scan = permute(original_scan, [2 3 1]);
    
    p_file_name = [path 'ilastikoutput/' fn '_Probabilities.h5'];
    [ilastik_output, output_prob] = read_ilastik_output(p_file_name, 4, dth);
    
    objs = calculate_cc(ilastik_output, original_scan, dilatesiz, ex_size, [dataname '/' fn], output_prob);
    allcentroids = [objs(:).CC];
    % -1 for zero indexed world coordinates
    allcentroids = reshape([allcentroids.centroid], [] , length(objs))' - repmat([1 1 1], length(objs), 1);
    allcentroids_w = voxel_to_worldcoords(allcentroids, info.Offset, info.PixelDimensions);
    
    %Get annotations
    IndexC = strfind(seriesuid, fn);
    Index = find(not(cellfun('isempty', IndexC)));
    coord_w = [coordX(Index), coordY(Index), coordZ(Index)];
    dia = diameter_mm(Index);
    
    %% Try sth else than pairwise dist
%     total_nodules = total_nodules + length(Index);
%     foundforthis = 0;
%     for ii = 1 : size(coord_w, 1)
%         found = 0;
%         rsq = power(dia(ii)/2.0, 2.0);
%         x1 = coord_w(ii, 1);
%         y1 = coord_w(ii, 2);
%         z1 = coord_w(ii, 3);
%         for j = 1 : size(allcentroids_w, 1)
%             x2 = allcentroids_w(j, 1);
%             y2 = allcentroids_w(j, 2);
%             z2 = allcentroids_w(j, 3);
%             d = power(x1-x2, 2.0) + power(y1-y2, 2.0) + power(z1-z2, 2.0);
%             if d<rsq
%                 found = 1;
%                 foundforthis = foundforthis + 1;
%                 disp(['A Hit with d = ' num2str(d) ' thold was : ' num2str(rsq)]);
%                 total_hits = total_hits + 1;
%                 break;
%             end
%         end
%         if found == 0
%             disp(['No hit for that for radius = ' dia(ii)/2]);
%             [cube, prob, mapp] = get_ROI(original_scan, output_prob, ilastik_output,coord_w(ii, :), info, 120);
%             
%             flipped = permute(cube, [3,1,2]);
%             sizeFlipped = size(flipped);
%             filename = [fn '_' num2str(ii) '_ROI.h5'];
%             h5create(filename, '/set', sizeFlipped, 'Datatype', 'int16')
%             h5write(filename, '/set', flipped);
%             %OK than save its
%         end
%     end
    %disp(['This set Has : ' num2str(length(Index)) ' Nodules, we found : ' num2str(foundforthis)]);
    
    
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
load annotations;
path = '/Volumes/INTENSO/Acedemic/Datasets/CTData/luna16';
ex_th = 5; %Extension for it
for i = 1 : 10
    %For each subset
    set_pat = [path '/subset' num2str(i-1)];
    sets = extractfield(dir([set_pat '/originalscan/*.h5']));
    %For each scan
    for j = 1: length(sets)
        disp(['Processing Subset : ' num2str(i) ' With Scan No : ' num2str(j)]);
        [~,fn,~] = fileparts(cell2mat(sets(j)));
        IndexC = strfind(seriesuid, fn);
        Index = find(not(cellfun('isempty', IndexC)));
        if isempty(Index)
            continue;
        end
        
        [~, info] = read_mhd([path '/originalfiles/' fn '.mhd']);
        original_scan = h5read([path '/originaldata/' fn '.h5'], '/set');
        original_scan = permute(original_scan, [2 3 1]);
        
        coord_w = [coordX(Index), coordY(Index), coordZ(Index)];
        coor_v = worldcoords_to_voxel(coord_w, info.Offset, info.PixelDimensions);
        dia = diameter_mm(Index);
        %for each nodule
        for k = 1 : length(dia)
            R = dia(k) / 2;
            R = R + ex_th;
            X = coord_v(k, 1);
            Y = coord_v(k, 2);
            Z = coord_v(k, 3);
            ROI = original_scan(Y-R:Y+R, X-R:X+R, Z-R:Z+R);
            %Save it
            flipped = permute(ROI, [3,1,2]);
            sizeFlipped = size(flipped);
            filename = ['elm-roi/' fn '_' num2str(k) '_ROI.h5'];
            h5create(filename, '/set', sizeFlipped, 'Datatype', 'int16')
            h5write(filename, '/set', flipped);
        end
    end
    
end
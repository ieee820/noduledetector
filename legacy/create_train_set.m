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
labels(1:length(nodules), 1) = 1;                   % set nodules to 1
%% ROOM FOR FEATURES
histbins = linspace(0,255,32);
feature_names = {'Volume','CentroidNorm','Centroid', 'Perimeter', 'PseudoRadius', 'Complexity', ...
    'BoundingBox2Volume', 'BoundingBoxAspectRatio', 'IntensityMax','IntensityMean', ...
    'IntensityMin','IntensityStd', 'CloseMassRatio','IntensityHist' ...
    'gaussianCoeffsz', 'gaussianGOFz', 'gaussianGOVz', ...
    'Gradient', 'GradientOfMag', 'ssim'};
feature_lengths = [1, 3, 3, 1, 1, 1,...
                   1, 1, 1, 1,...
                   1, 1, 1, length(histbins),...
                   7, 5, 2,...
                   50, 9*3, 1];
feature_num = length(feature_names);
features = cell(feature_num,1);
for f = 1: feature_num
    features{f} = zeros(length(allobjects),feature_lengths(f));
end

%% Calculate Features
allcentroids = [allobjects(:).CC];
allcentroids = reshape([allcentroids.centroid], [] , length(allobjects))';
allareas = [allobjects(:).CC];
allareas = reshape([allareas.area], [] , length(allobjects))';
th = magth;
for i=1:length(allobjects)
    completed = floor(i/length(allobjects)*100);
    if (mod(i,5)==0)
        fprintf('\b\b\b');
        fprintf('%3d', completed);
    end
    
    cube = allobjects(i).boxex;
    bbx = allobjects(i).CC.bbx;
    centroid = allobjects(i).CC.centroid;
    pixelidlist = allobjects(i).CC.PixelIdxList{1};
    imsize = allobjects(i).CC.ImageSize;
    base = zeros(bbx(5), bbx(4), bbx(6));           %base of bounding box
    [py,px,pz] = ind2sub(imsize, pixelidlist);      %converts the 1d point into 3d point
    lenx = bbx(4); leny = bbx(5); lenz = bbx(6);    %length of bbx
    
    %Create a new base
    newpy = py-bbx(2)+1;
    newpx = px-bbx(1)+1;
    newpz = pz-bbx(3)+1;
    newI = sub2ind(size(base), newpy, newpx, newpz);
    base(newI) = 1;
    newbase = imfill(base, 'holes');                %show_iso(newbase)
    
    %Collapse on Z, Y, Z axis
    CollapseZ = sum (cube,3);
    CollapseZ = CollapseZ /  size (cube,3); % x ve y i?in size, 2 ve 1
    CollapseZ = (CollapseZ - -1000) / 2000;% - -1000 ??nk? min = -1000
    CollapseZ(CollapseZ <0) = 0;
    CollapseZ(CollapseZ >1000) = 1000;
    CollapseY = squeeze(sum(cube, 1));
    CollapseX = squeeze(sum(cube, 2));
    
    %New Feature -> Gradient and 2nd derivative orientations
    [fea_gradient, fea_gradient_of_mag] = calculate_gradient_features(cube, th);
    
    %New Feature -> Gaussian Fitting on Z
    [fitresult, gof, val_obj] = fit_gaussian(CollapseZ, nodz);
    gaussianCoeffsz = coeffvalues(fitresult);        % Coefficient values
    gaussianGOFz = struct2array(gof);                % godness of fit
    gaussianGOVz = struct2array(val_obj);            % godness of validation
    
    %New Feature -> Structural Similarity
    [ssimz, ~] = ssim(nodz, imresize(CollapseZ, [10 10]));
    
    %Generic Features
    fea_vol = sum(newbase(:));
    fea_pseudo_rad = (3*fea_vol/4/pi)^(1/3);
    fea_perim = calculate_3d_slength(base);
    fea_perim_area = fea_perim.*fea_pseudo_rad/fea_vol;
    fea_box_to_vol = numel(base)/fea_vol;
    fea_box_aspect_ratio = max([lenx,leny, lenz])/min([lenx,leny, lenz]);
    masked_pixel_vals = double(cube(newI));
    fea_pixmax = max(masked_pixel_vals);
    fea_pixmean = mean(masked_pixel_vals);
    fea_pixmin = min(masked_pixel_vals);
    fea_pixstd = std(masked_pixel_vals);
    fea_close_mass = calculate_closemass(centroid, fea_pseudo_rad, fea_vol, i, allareas, allcentroids);
    fea_pixhist =  hist(masked_pixel_vals, histbins);
    
    features{1}(i) = fea_vol;
    features{2}(i, :) = [centroid(1)/imsize(2), centroid(2)/imsize(1),centroid(3)/imsize(3)];
    features{3}(i, :) = [centroid(1), centroid(2),centroid(3)];
    features{4}(i) = fea_perim;
    features{5}(i) =  fea_pseudo_rad;
    features{6}(i) =  fea_perim_area;
    features{7}(i) = fea_box_to_vol;
    features{8}(i) = fea_box_aspect_ratio;
    features{9}(i) = fea_pixmax;
    features{10}(i) = fea_pixmean;
    features{11}(i) = fea_pixmin;
    features{12}(i) = fea_pixstd;
    features{13}(i, :) = fea_close_mass;
    features{14}(i, :) = fea_pixhist;
    features{15}(i, :) = gaussianCoeffsz;
    features{16}(i, :) = gaussianGOFz;
    features{17}(i, :) = gaussianGOVz; 
    features{18}(i, :) = fea_gradient;
    features{19}(i, :) = fea_gradient_of_mag';
    features{20}(i) = ssimz;
end

%% Write
paths = '../noduledetectordata/test_train_sets/';
delete([paths 'train_feas.h5'])
delete([paths 'train_labels.h5'])
write_features([paths 'train_feas.h5'], length(allobjects), features, feature_names, feature_lengths)
h5create([paths 'train_labels.h5'], '/labels', length(allobjects), 'Datatype','int16');
h5write([paths 'train_labels.h5'], '/labels', int16(labels));

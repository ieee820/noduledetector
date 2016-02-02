%% This function calculates the features of the given objects strut.
% Without the labels, the labels shall be written in a different
% function/script, this is only for calculating the features and writing
% them to a h5 file
function calculate_features(allobjects, filetosave)
%% Global vars
addpath('parfor_progress');
eval(global_vars);
[nodz, ~, ~ , ~] = calculate_avg_nodule();
%% ROOM FOR FEATURES
histbins = linspace(0,255,32);
feature_names = {'Volume','CentroidNorm','Centroid', 'Perimeter', 'PseudoRadius', 'Complexity', ...
    'BoundingBox2Volume', 'BoundingBoxAspectRatio', 'IntensityMax','IntensityMean', ...
    'IntensityMin','IntensityStd', 'CloseMassRatio','IntensityHist' ...
    'gaussianCoeffsz', 'gaussianGOFz', 'gaussianGOVz', ...
    'Gradient', 'GradientOfMag', 'ssimz'};
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
fprintf(['Calculation Features For File : ' filetosave '\n']);
fprintf('Starting To Calculate Generic Features\n');
N = length(allobjects);
parfor_progress(N);
for i=1:length(allobjects)
    parfor_progress;
    
    cube = allobjects(i).boxex;
    cube2 = allobjects(i).boxex2; %more extended for gradient calc
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
    
    %New Feature -> Gradient and 2nd derivative orientations
    [fea_gradient, fea_gradient_of_mag] = calculate_gradient_features(cube2, magth);
    
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
    %features{15}(i, :) = gaussianCoeffsz;
    %features{16}(i, :) = gaussianGOFz;
    %features{17}(i, :) = gaussianGOVz; 
    features{18}(i, :) = fea_gradient;
    features{19}(i, :) = fea_gradient_of_mag';
    
    features{20}(i) = ssimz;
end
parfor_progress(0);

ps = gcp;
fprintf('Generic Features Calculation Finished.\n');
fprintf('Starting To Calculate Complex Features (Gaussian Fitting)\n');
fprintf(['Using ' num2str(ps.NumWorkers) ' Workers...' '\n']);
drawnow('update');
parfor_progress(length(allobjects));
%Temp Rooms for parfor-loop
f1 = zeros(size(features{15}));
f2 = zeros(size(features{16}));
f3 = zeros(size(features{17}));
parfor j=1:length(allobjects);
    cube = allobjects(j).boxex;
  
    CollapseZ = sum (cube,3);
    CollapseZ = CollapseZ /  size (cube,3); % x ve y i?in size, 2 ve 1
    CollapseZ = (CollapseZ - -1000) / 2000;% - -1000 ??nk? min = -1000
    CollapseZ(CollapseZ <0) = 0;
    CollapseZ(CollapseZ >1000) = 1000;
    
    %New Feature -> Gaussian Fitting on Z
    [fitresult, gof, val_obj] = fit_gaussian(CollapseZ, nodz);
    gaussianCoeffsz = coeffvalues(fitresult);        % Coefficient values
    gaussianGOFz = struct2array(gof);                % godness of fit
    gaussianGOVz = struct2array(val_obj);            % godness of validation
    
    %Assign to temp variables
    f1(j, :) = gaussianCoeffsz;
    f2(j, :) = gaussianGOFz;
    f3(j, :) = gaussianGOVz;
    
    parfor_progress;
end
parfor_progress(0);
%Assign to real containersback
features{15} = f1;
features{16} = f2;
features{17} = f3; 

fprintf('Calculation Completed... Writing Features to h5 file.\n');
%% Write features
delete(filetosave);
write_features(filetosave, length(allobjects), features, feature_names, feature_lengths)
end
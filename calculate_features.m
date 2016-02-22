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
    'gaussfit', 'gaussfitval', ...
    'Gradient', 'GradientOfMag', 'ssimz'};
feature_lengths = [1, 3, 3, 1, 1, 1,...
    1, 1, 1, 1,...
    1, 1, 1, length(histbins),...
    6, 5,...
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

ps = gcp;
fprintf('Starting To Calculate Features (Parallel)\n');
fprintf(['Using ' num2str(ps.NumWorkers) ' Workers...' '\n']);
drawnow('update');
parfor_progress(length(allobjects));
%Temp Rooms for parfor-loop
f1 = zeros(size(features{1}));
f2 = zeros(size(features{2}));
f3 = zeros(size(features{3}));
f4 = zeros(size(features{4}));
f5 = zeros(size(features{5}));
f6 = zeros(size(features{6}));
f7 = zeros(size(features{7}));
f8 = zeros(size(features{8}));
f9 = zeros(size(features{9}));
f10 = zeros(size(features{10}));
f11 = zeros(size(features{11}));
f12 = zeros(size(features{12}));
f13 = zeros(size(features{13}));
f14 = zeros(size(features{14}));
f15 = zeros(size(features{15}));
f16 = zeros(size(features{16}));
f17 = zeros(size(features{17}));
f18 = zeros(size(features{18}));
f19 = zeros(size(features{19}));
parfor i=1:length(allobjects),
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
    
    %New Feature -> Gaussian Fitting on Z
    [fitresult, gof, ~] = fit_gaussian(CollapseZ, nodz)
    gaussianCoeffsz = coeffvalues(fitresult);        % Coefficient values
    gaussianGOFz = struct2array(gof);                % godness of fit
    %gaussianGOVz = struct2array(val_obj);            % godness of validation
    
    %Assign to temp variables
    f1(i) = fea_vol;
    f2(i, :) = [centroid(1)/imsize(2), centroid(2)/imsize(1),centroid(3)/imsize(3)];
    f3(i, :) = [centroid(1), centroid(2),centroid(3)];
    f4(i) = fea_perim;
    f5(i) =  fea_pseudo_rad;
    f6(i) =  fea_perim_area;
    f7(i) = fea_box_to_vol;
    f8(i) = fea_box_aspect_ratio;
    f9(i) = fea_pixmax;
    f10(i) = fea_pixmean;
    f11(i) = fea_pixmin;
    f12(i) = fea_pixstd;
    f13(i, :) = fea_close_mass;
    f14(i, :) = fea_pixhist;
    f15(i, :) = gaussianCoeffsz;
    f16(i, :) = gaussianGOFz;
    f17(i, :) = fea_gradient;
    f18(i, :) = fea_gradient_of_mag';
    f19(i) = ssimz;
    %Progress
    parfor_progress;
end;
parfor_progress(0);
%Assign to real containersback
features{1} = f1;
features{2} = f2;
features{3} = f3;
features{4} = f4;
features{5} = f5;
features{6} = f6;
features{7} = f7;
features{8} = f8;
features{9} = f9;
features{10} = f10;
features{11} = f11;
features{12} = f12;
features{13} = f13;
features{14} = f14;
features{15} = f15;
features{16} = f16;
features{17} = f17;
features{18} = f18;
features{19} = f19;

fprintf('Calculation Completed... Writing Features to h5 file.\n');
%% Write features
delete(filetosave);
write_features(filetosave, length(allobjects), features, feature_names, feature_lengths)
end
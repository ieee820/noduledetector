function calcFeas(ds)
addpath 'utility_funcs'
eval(global_vars);          % This will get the global variables for all sets
originalFile = ['../noduledetectordata/ANODE/originaldata/example0' num2str(ds) '.h5'];
predictionFile = ['../noduledetectordata/ANODE/ilastikoutput/example0' num2str(ds) '_Probabilities.h5'];
outputFileNameAndPath = ['test_feas_' num2str(ds) '.h5'];
labelFiles = ['../noduledetectordata/ANODE/labels/example0' num2str(ds) '_labels.txt'];
dth = [0.65 0.45];


%%ROOM FOR FEATURES
histbins = linspace(0,255,32);

numObjects2 = 0;
realNumObjects = 0;
feature_names = {'Volume','CentroidNorm','Centroid', 'Perimeter', 'PseudoRadius', 'Complexity', ...
    'BoundingBox2Volume', 'BoundingBoxAspectRatio', 'IntensityMax','IntensityMean', ...
    'IntensityMin','IntensityStd', 'CloseMassRatio','IntensityHist', ...
    'gaussianCoeffsz', 'gaussianGOFz', 'gaussianGOVz', ...
    'Gradient', 'GradientOfMag', 'ssim'};
feature_lengths = [1, 3, 3, 1, 1, 1,...
                   1, 1, 1, 1,...
                   1, 1, 1, length(histbins),...
                   7, 5, 2,...
                   50, 9*3, 1];
%512 for cnn filter features
fea_label = cell(numObjects2,1);
feature_num = length(feature_names);
features = cell(feature_num,1);
for f = 1: feature_num
    features{f} = zeros(numObjects2,feature_lengths(f));
end
%%EOF ROOM FOR FEATURES

outfname = ['../noduledetectordata/test_train_sets/' outputFileNameAndPath];
labelFile = fopen(labelFiles);
labels = textscan(labelFile,'%d','delimiter','\n');
labels = labels{1};

predMatrix = h5read(predictionFile,'/exported_data'); %h5 read prediction matrix
predMatrix = permute(predMatrix, [3 4 2 1]); %permute the matrix
predMatrixTH = predMatrix(:,:,:,4); %predictiondaki
predMatrixTH = imreconstruct(predMatrixTH>dth(1), predMatrixTH>dth(2));
bigcube = h5read(originalFile, '/set');
bigcube = permute(bigcube, [2, 3, 1]);

CC = bwconncomp(predMatrixTH);
s  = regionprops(CC, 'centroid','BoundingBox','Area');
CC.centroids = cat(1, s.Centroid);
CC.bbx =  cat(1, s.BoundingBox);
CC.areas =  cat(1, s.Area);

imSize = CC.ImageSize;
numObjects = CC.NumObjects;
vec_areas= cat(1,CC.areas);
vec_centroids = cat(1,CC.centroids);

%Calculate Avg Nodule
[nodz, nody, nodx, ~] = calculate_avg_nodule();
th = 500;

%Calculate features
for o = 1 : numObjects
    realNumObjects = realNumObjects + 1;
    completed = floor(o/numObjects*100);
    if (mod(o,50)==0)
        fprintf('\b\b\b');
        fprintf('%3d', completed);
    end
    
     is_current_object_a_noldule = any(labels(:)==o); %if label file contains that label
    
    if is_current_object_a_noldule==1
        debug=0;
    end
    
    bbx = floor(CC.bbx(o,:)+0.5);   %bounding box
    graycube = extend_cube(bbx, bigcube, [10 10 4]);

    base = zeros(bbx(5), bbx(4), bbx(6));   %base of bounding box
    pix = CC.PixelIdxList{o};   %the pixel location of the cc object
    [py,px,pz] = ind2sub(imSize, pix); %converts the 1d point into 3d point
    lenx = bbx(4); leny = bbx(5); lenz = bbx(6);
    
    newpy = py-bbx(2)+1;
    newpx = px-bbx(1)+1;
    newpz = pz-bbx(3)+1;
    newI = sub2ind(size(base), newpy, newpx, newpz);
    base(newI) = 1;
    
    newbase = imfill(base, 'holes');
    
    %Collapse on Z, Y, Z axis
    CollapseZ = sum (graycube,3);
    CollapseZ = CollapseZ /  size(graycube,3); % x ve y i?in size, 2 ve 1
    CollapseZ = (CollapseZ - -1000) / 2000;% - -1000 ??nk? min = -1000
    CollapseZ(CollapseZ < 0) = 1;
    CollapseZ(CollapseZ > 1000) = 1000;
    CollapseY = squeeze(sum(graycube, 1));
    CollapseX = squeeze(sum(graycube, 2));

    %New Feature -> Gaussian Fitting on Z
    [fitresult, gof, val_obj] = fit_gaussian(CollapseZ, nodz);
    gaussianCoeffsz = coeffvalues(fitresult);        % Coefficient values
    gaussianGOFz = struct2array(gof);                % godness of fit
    gaussianGOVz = struct2array(val_obj);            % godness of validation
    
    %3D Gradient
    [fea_gradient, fea_gradient_of_mag] = calculate_gradient_features(graycube ,th);
    
    %New Feature -> Structural Similarity
    [ssimz, ~] = ssim(nodz, imresize(CollapseZ, [10 10]));
    
    fea_vol = sum(newbase(:));
    pseudorad = (3*fea_vol/4/pi)^(1/3);
    fea_perim = calculate_3d_slength(base);
    fea_pseudo_rad = pseudorad;
    fea_perim_area = fea_perim.*fea_pseudo_rad/fea_vol;
    fea_box_to_vol = numel(base)/fea_vol;
    fea_box_aspect_ratio = max([lenx,leny, lenz])/min([lenx,leny, lenz]);
    mskedPixelValues = double(graycube(newI));
    fea_pixmax = max(mskedPixelValues);
    fea_pixmean = mean(mskedPixelValues);
    fea_pixmin = min(mskedPixelValues);
    fea_pixstd = std(mskedPixelValues);
    fea_close_mass = calculate_closemass(vec_centroids(o,:), pseudorad,fea_vol,o,vec_areas, vec_centroids);
    fea_pixhist=  hist(mskedPixelValues, histbins);
    
    features{1}(realNumObjects) = fea_vol;
    features{2}(realNumObjects,:) = [vec_centroids(o,1)/imSize(2), vec_centroids(o,2)/imSize(1),vec_centroids(o,3)/imSize(3)];
    features{3}(realNumObjects,:) = [vec_centroids(o,1), vec_centroids(o,2),vec_centroids(o,3)];
    features{4}(realNumObjects) = fea_perim;
    features{5}(realNumObjects) =  fea_pseudo_rad;
    features{6}(realNumObjects) =  fea_perim_area;
    features{7}(realNumObjects) = fea_box_to_vol;
    features{8}(realNumObjects) = fea_box_aspect_ratio;
    features{9}(realNumObjects) = fea_pixmax;
    features{10}(realNumObjects) = fea_pixmean;
    features{11}(realNumObjects) = fea_pixmin;
    features{12}(realNumObjects) = fea_pixstd;
    features{13}(realNumObjects,:) = fea_close_mass;
    features{14}(realNumObjects,:) = fea_pixhist;
    features{15}(realNumObjects, :) = gaussianCoeffsz;
    features{16}(realNumObjects, :) = gaussianGOFz;
    features{17}(realNumObjects, :) = gaussianGOVz;

    features{18}(realNumObjects, :) = fea_gradient;
    features{19}(realNumObjects, :) = fea_gradient_of_mag';
    features{20}(realNumObjects) = ssimz;
    fea_label{realNumObjects} = is_current_object_a_noldule;
end
delete(outfname);
write_features(outfname, realNumObjects, features, feature_names, feature_lengths)

labelF = ['../noduledetectordata/test_train_sets/test_labels_' num2str(ds) '.h5'];
delete(labelF);
h5create(labelF, '/labels', realNumObjects, 'Datatype','int16');
h5write(labelF, '/labels', int16(cell2mat(fea_label)));
end
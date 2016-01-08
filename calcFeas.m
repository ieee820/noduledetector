function calcFeas(ds)

originalFile = ['../noduledetectordata/originaldata/example0' num2str(ds) '.h5'];
predictionFile = ['../noduledetectordata/ilastikoutput3/example0' num2str(ds) '_Probabilities.h5'];
outputFileNameAndPath = ['example_0' num2str(ds) '.h5'];
labelFiles = ['../noduledetectordata/ilastikoutput3/example0' num2str(ds) '_labels.txt'];
thold = 0.65;


%%ROOM FOR FEATURES
histbins = linspace(0,255,32);

numObjects2 = 0;
realNumObjects = 0;
feature_names = {'Volume','CentroidNorm','Centroid', 'Perimeter', 'PseudoRadius', 'Complexity',...
    'BoundingBox2Volume', 'BoundingBoxAspectRatio', 'IntensityMax','IntensityMean',...
    'IntensityMin','IntensityStd', 'CloseMassRatio','IntensityHist', 'gaussianCoefficients',...
    'gaussianBounds', 'gaussianGOF', 'gaussianGOV', 'CollapseZ', 'Gradient', 'GradientOfMag'};
feature_lengths = [1, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, length(histbins), 7, 14, 5, 2, 100, 50, 9*3];
%512 for cnn filter features
fea_label = cell(numObjects2,1);
feature_num = length(feature_names);
features = cell(feature_num,1);
for f = 1: feature_num
    features{f} = zeros(numObjects2,feature_lengths(f));
end
%%EOF ROOM FOR FEATURES

outfname = ['../noduledetectordata/ilastikoutput3/extractedfeatures/' outputFileNameAndPath];
labelFile = fopen(labelFiles);
labels = textscan(labelFile,'%d','delimiter','\n');
labels = labels{1};

originalSetName = '/set';
ThresHold = thold;
predMatrix = h5read(predictionFile,'/exported_data'); %h5 read prediction matrix
predMatrix = permute(predMatrix, [3 4 2 1]); %permute the matrix
predMatrixTH = predMatrix(:,:,:,4)>ThresHold; %predictiondaki
[width,height,deep] = size(predMatrixTH);

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
avgNod = avgNodule(CC, labels, originalFile, originalSetName, predMatrixTH);

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
    [graycube, ~] = extendCube(bbx, originalFile, originalSetName,...
        height, width, deep);
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
    
    %Sum cube at z axsis
    CollapseZ = sum(graycube, 3);                   %CollapseY = sum(graycube, 2);
    [fitresult, gof, val_obj] = fit_gaussian(CollapseZ, avgNod);
    gaussianCoeffs = coeffvalues(fitresult);        % Coefficient values
    gaussianCoeffBounds = confint(fitresult);       % Confidence Bounds on the Coefficients
    gaussianGOF = struct2array(gof);                % godness of fit
    gaussianGOV = struct2array(val_obj);            % godness of validation
    
    %3D Gradient
    [grad_hist, hist_mag] = GradientFeatureExtractor(graycube);
    
    fea_gradient = grad_hist;
    fea_vol = sum(newbase(:));
    pseudorad = (3*fea_vol/4/pi)^(1/3);
    fea_perim = calculate3DSurfaceLengthbyErosion(base);
    fea_pseudo_rad = pseudorad;
    fea_perim_area = fea_perim.*fea_pseudo_rad/fea_vol;
    fea_box_to_vol = numel(base)/fea_vol;
    fea_box_aspect_ratio = max([lenx,leny, lenz])/min([lenx,leny, lenz]);
    mskedPixelValues = double(graycube(newI));
    fea_pixmax = max(mskedPixelValues);
    fea_pixmean = mean(mskedPixelValues);
    fea_pixmin = min(mskedPixelValues);
    fea_pixstd = std(mskedPixelValues);
    fea_close_mass = calculateCloseMassGravity(vec_centroids(o,:), pseudorad,fea_vol,o,vec_areas, vec_centroids);
    fea_pixhist=  hist(mskedPixelValues, histbins);
    collapseOnZ = imresize(CollapseZ, [10 10]);
    
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
    features{15}(realNumObjects, :) = gaussianCoeffs;
    features{16}(realNumObjects, :) = gaussianCoeffBounds(:);
    features{17}(realNumObjects, :) = gaussianGOF;
    features{18}(realNumObjects, :) = gaussianGOV;
    features{19}(realNumObjects, :) = collapseOnZ(:);
    features{20}(realNumObjects, :) = fea_gradient;
    features{21}(realNumObjects, :) = hist_mag;
    fea_label{realNumObjects} = is_current_object_a_noldule;
end

writeFeatures2HDF5(outfname, realNumObjects, features, feature_names, feature_lengths)
%Write labels in a different file
%while h5 matrixes are 0 indexed, a object which is 1234'th object seems
%1233'th object in the file.
labelF = ['../noduledetectordata/ilastikoutput3/extractedlabels/labels_' outputFileNameAndPath];
h5create(labelF, '/labels', realNumObjects, 'Datatype','int16');
h5write(labelF, '/labels', int16(cell2mat(fea_label)));
end

%% Gradient Calculation for n-dimensional voxels
function [hist_3d_grads, second_mag_hist] = GradientFeatureExtractor(graycube)
%Prepare Kernels for x,y,z
kernelx = [-1,0,1];
kernely = [-1;0;1];
kernelz = zeros(3,3);
kernelz(2,2,1) = -1;
kernelz(2,2,3) = 1;

%Calculate derivatives for x,y,z using the kernels
dx = convn(graycube, kernelx, 'same');
dy = convn(graycube, kernely, 'same');
dz = convn(graycube, kernelz, 'same');

%Cut-off noises
dx = dx(2:end-1, 2:end-1, 2:end-1);
dy = dy(2:end-1, 2:end-1, 2:end-1);
dz = dz(2:end-1, 2:end-1, 2:end-1);

%Calculate Magnitude of the cube
mag = abs(dx) + abs(dy) + abs(dz);

%Calculate angles (Azimuth & Theta)
angleazimuth = zeros(size(dx));
angletetha = zeros(size(dx));
for i = 1 : size(dx, 1) * size(dy, 2) * size(dz, 3),
    angletetha(i) = acos(dz(i) / sqrt(dx(i).*dx(i)+dy(i).*dy(i)+dz(i).*dz(i)));
    angleazimuth(i) = atan2(dx(i),dy(i));
end

%Calculate histogram for the gradient angles
nbins_u = 5; 
nbins_v = 10;
th = 500;
uu = linspace(0,pi, nbins_u);                   %preparing bins for azimuth
vv = linspace(-pi,pi,nbins_v);                  %preparing bins for zenith or teta
hist_uu_vv = zeros(nbins_u, nbins_v);           %orientation histogram
for i = 1 : size(dx, 1) * size(dy, 2) * size(dz, 3),
    if mag(i)>th
    % lets find the bins that this particular azimuth and tetha belongs to
        k = 1; 
        while(angletetha(i)> uu(k)), k=k+1; end;  %assuming it is in the limits
        j = 1; 
        while(angleazimuth(i)> vv(j)), j=j+1; end;
        % k and j are the indices, transform them to 1 index
        hist_uu_vv(k,j) = hist_uu_vv(k,j)+mag(i); 
    end
end
% Normalization of the feature vector using L2-Norm
hist_uu_vv = hist_uu_vv(:);
hist_uu_vv=hist_uu_vv/sqrt(norm(hist_uu_vv)^2+.001);
hist_3d_grads = hist_uu_vv;

%% Calculate mag & orientation of the magnitude
%remember to normalize the magnitude if needed
x_s = squeeze(sum(mag, 1))/size(mag,1);
y_s = squeeze(sum(mag, 2))/size(mag,2);
z_s = sum(mag, 3)/size(mag,3);

dx_x = conv2(x_s, kernelx, 'same');
dy_x = conv2(x_s, kernely, 'same');
mag_x = abs(dx_x) + abs(dy_x);
angle_x = atan2d(dx_x, dy_x);
angle_x = angle_x + 180;

dx_y = conv2(y_s, kernelx, 'same');
dy_y = conv2(y_s, kernely, 'same');
mag_y = abs(dx_y) + abs(dy_y);
angle_y = atan2d(dx_y, dy_y);
angle_y = angle_y + 180;


dx_z = conv2(z_s, kernelx, 'same');
dy_z = conv2(z_s, kernely, 'same');
mag_z = abs(dx_z) + abs(dy_z);
angle_z = atan2d(dx_z, dy_z);
angle_z = angle_z + 180;

%investigate this threshold
th = 500;
[hist_x] = hist_mag(mag_x, angle_x, th);
[hist_y] = hist_mag(mag_y, angle_y, th);
[hist_z] = hist_mag(mag_z, angle_z, th);
second_mag_hist = [hist_x hist_y hist_z];
end

%% Calculate Close Mass Gravity
function  close_mass_ratio = calculateCloseMassGravity(thisCentroid, thisRad,thisArea,thisIndex, vecAreas, vecCentroids)
% this hyper sophisticated functions calculates big mass objects gravity
% to this object.
% this object must be close to other in order to be pulled by them
% this can be used to solve oversegmentation problems
% centroids in matlab are allways xyz order

PROXIMITY_THRESHOLD = 4*thisRad;

dist_centers = (thisCentroid(3)-vecCentroids(:,3)).*(thisCentroid(3)-vecCentroids(:,3))+...
    (thisCentroid(2)-vecCentroids(:,2)).*(thisCentroid(2)-vecCentroids(:,2))+ ...
    (thisCentroid(1)-vecCentroids(:,1)).*(thisCentroid(1)-vecCentroids(:,1));

closeenough = sqrt(dist_centers)<= PROXIMITY_THRESHOLD;%(1.5*gtr(igt));
closeind = setdiff(find(closeenough==1),thisIndex);
% found itself
if((isempty(closeind)))
    close_mass_ratio  = -1;
    return;
end

close_mass_ratio = max(vecAreas(closeind))/thisArea;

end

%% Calculate surface lenght
function [surfaceLength, surfacePixels] = calculate3DSurfaceLengthbyErosion(msk)
% this is calculated in a quick way
DEBUGG  = 0 ;

% I will calculate the surface very simply with msk -erode(msk)
cross2d = [0 1 0 ; 1 1 1; 0 1 0];
basecenters = [0 0 0; 0 1 0 ; 0 0 0];
cross3d = cat(3, basecenters, cross2d,basecenters);
sebox3d = strel(strel(cross3d));
%sebox3d = strel(strel(ones(3,3,3)));
mskopen = imopen(msk, sebox3d);
mskopen = imfill(mskopen,'Holes');
mskerode3d = imerode(mskopen, sebox3d);
% now the difference
diff_3d = mskopen-mskerode3d;
if(DEBUGG)
    sliceview(msk+diff_3d);
    pause;
end
CC = bwconncomp(diff_3d);
lenCC = CC.NumObjects;
if(DEBUGG)
    lenCC
end
if(lenCC==1)
    surfaceLength = length(CC.PixelIdxList{1});
    surfacePixels = msk;
    
    surfacePixels(CC.PixelIdxList{1}) = max(msk(:));
    return;
elseif (lenCC ==0)
    surfaceLength = 0;
    surfacePixels = zeros(size(msk));
    return;
else
    
    % if there are more than one connected component
    % I assume the largest connected component is the perimeter
    regioninfo = regionprops(CC, 'Area');
    areas = cat(1,regioninfo.Area);
    [mxval, mxarg] = max(areas);
    surfaceLength = mxval;
    if (nargout==2)
        surfacePixels = msk;
        surfacePixels(CC.PixelIdxList{mxarg}) = max(msk(:));
    end
end
end

%% Calculate Avg Nodule
function avgNodule = avgNodule(CC, labels, originalFile, originalSetName, predMatrixTH)
totalNodules = 0;
[width,height,deep] = size(predMatrixTH);
CollapseZ = zeros(10, 10);
for o = 1 : CC.NumObjects
    completed = floor(o/CC.NumObjects*100);
    if (mod(o,50)==0)
        fprintf('\b\b\b');
        fprintf('%3d', completed);
    end
    
    bbx = floor(CC.bbx(o,:)+0.5);   %bounding box
    [graycube, bbx] = extendCube(bbx, originalFile, originalSetName,...
        height, width, deep);
    
    
    is_current_object_a_noldule = any(labels(:)==o); %if label file contains that label
    
    if is_current_object_a_noldule==1
        totalNodules = totalNodules + 1;
        normalized = imresize(sum(graycube, 3), [10 10]);
        CollapseZ = CollapseZ + normalized;
    end
    
    %Sum cube at z axsis
    
end
CollapseZ = CollapseZ ./ totalNodules;
%Normalize Nodule 0-1
CollapseZ = (CollapseZ - min(CollapseZ(:))) / (max(CollapseZ(:)) - min(CollapseZ(:)));
avgNodule = CollapseZ;
end

%% Extend The Cube
function [graycube, bbx] = extendCube(bbx, file, setname, height, width, deep)
%extend the cube given;
e_z = 4;
e_x = 10;
e_y = 10;

%detected locations
z = bbx(3);
y = bbx(2);
x = bbx(1);
z_count = bbx(6);
y_count = bbx(5);
x_count = bbx(4);

x = (x-(e_x/2));
y = (y-(e_y/2));
z = (z-(e_z/2));

%if startpoints are negative or zero, set them to detected ones
%add the patch size to the count
if x<=0
    x = bbx(1);
    x_count = bbx(4) + (e_x/2);
end
if y<=0
    y = bbx(2);
    y_count = bbx(5) + (e_y/2);
end
if z<=0
    z = bbx(3);
    z_count = bbx(6) + (e_z/2);
end

x_count = x_count + (e_x);
y_count = y_count + (e_y);
z_count = z_count + (e_z);

if x_count>height || x_count+x>height
    x_count = bbx(4);
end
if y_count>width || y_count+y>width
    y_count = bbx(5);
end
if z_count>deep || z_count+z>deep
    z_count = bbx(6);
end

startix = double([z, y, x]);
counts = double([z_count, y_count, x_count]);
graycube = h5read(file, setname, startix, counts);
graycube = permute(permute(graycube, [3, 2, 1]),[2,1,3]); %this is for matlab xyz order227122
bbx = [x y z x_count y_count z_count];
%[sift_feas,~] = Create_Descriptor(graycube,1,1,x_count/2,y_count/2, z_count/2);
end

%% WRITE THE FEATURES INTO HDF5 FILE
function writeFeatures2HDF5(outfname, numObjects, features, featureNames, featureLength)

for f = 1: length(features)
    feature_data = features{f};
    if (featureLength(f)==1)
        data_size = numObjects;
    else
        data_size = fliplr([numObjects,featureLength(f)]);
        feature_data = feature_data';
    end
    
    h5create(outfname,['/',featureNames{f}],data_size,'Datatype','double');
    
    %     if(rank(feature_data)>1)
    %     feature_data = transpose(feature_data);
    %     end
    h5write(outfname, ['/',featureNames{f}], feature_data);
end
end

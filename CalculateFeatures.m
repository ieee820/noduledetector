function writeFeatures(originalFile, predictionFile, outputFileNameAndPath,labelFiles)

if (nargin==0)
   originalFile = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/example01.h5';
   predictionFile = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/NormalFeaturesSelected/example01_Probabilities.h5';
   outputFileNameAndPath = 'example_01.h5';
   labelFiles = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/LabelsForFeatures/example01labels_.txt';
   %labelFiles = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/NormalFeaturesSelected/Labels/example05labels_.txt';              
end
net = load('imagenet-vgg-f.mat');
run('matconvnet/matlab/vl_setupnn.m');
%%ROOM FOR FEATURES
histbins = linspace(0,255,32);
granbins = linspace(50, 10000,5);
numObjects2 = 0;
realNumObjects = 0;
fileCount = 1;
feature_names = {'Volume', 'CentroidNorm','Centroid', 'Perimeter', 'PseudoRadius', 'Complexity',...
    'BoundingBox2Volume', 'BoundingBoxAspectRatio', 'IntensityMax','IntensityMean',...
    'IntensityMin','IntensityStd', 'CloseMassRatio', 'CNN'}; %,'IntensityHist', 'Granulometry'
feature_lengths = [1, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 512]; %, length(histbins), length(granbins)
%512 for cnn filter features
fea_label = cell(numObjects2,1);
feature_num = length(feature_names);
features = cell(feature_num,1);
for f = 1: feature_num
    features{f} = zeros(numObjects2,feature_lengths(f));
end
%%EOF ROOM FOR FEATURES

for flx = 1:fileCount
  
outfname = strcat('FeatureFiles2/',outputFileNameAndPath);
labelFile = fopen(labelFiles(flx,:));
labels = textscan(labelFile,'%d','delimiter','\n');
labels = labels{1};

originalSetName = '/set';
ThresHold = 0.4;
predMatrix = h5read(predictionFile(flx,:),'/exported_data'); %h5 read prediction matrix
predMatrix = permute(predMatrix, [3 4 2 1]); %permute the matrix
predMatrixTH = predMatrix(:,:,:,1)>ThresHold; %predictiondaki

CC = bwconncomp(predMatrixTH);
s  = regionprops(CC, 'centroid','BoundingBox','Area');
CC.centroids = cat(1, s.Centroid);
CC.bbx =  cat(1, s.BoundingBox);
CC.areas =  cat(1, s.Area);

imSize = CC.ImageSize;
numObjects = CC.NumObjects;
vec_areas= cat(1,CC.areas);
vec_centroids = cat(1,CC.centroids);

for o = 1 : numObjects
    realNumObjects = realNumObjects + 1;
    completed = floor(o/numObjects*100);
    if (mod(o,50)==0)
        fprintf('\b\b\b');
        fprintf('%3d', completed);
    end
    
    is_current_object_a_noldule = any(labels(:)==o); %if label file contains that label
    
    bbx = floor(CC.bbx(o,:)+0.5);   %bounding box
    base = zeros(bbx(5), bbx(4),bbx (6));   %base of bounding box
    pix = CC.PixelIdxList{o};   %the pixel location of the cc object
    [py,px,pz] = ind2sub(imSize, pix); %converts the 1d point into 3d point
    lenx  =bbx(4); leny = bbx(5); lenz = bbx(6);
    
    startix = double([bbx(3), bbx(2), bbx(1)]);
    counts = double([bbx(6),bbx(5), bbx(4)]);
    graycube = h5read(originalFile(flx,:), originalSetName, startix, counts);
    graycube = permute(permute(graycube, [3, 2, 1]),[2,1,3]); %this is for matlab xyz order227122
    
    newpy = py-bbx(2)+1;
    newpx = px-bbx(1)+1;
    newpz = pz-bbx(3)+1;
    newI = sub2ind(size(base), newpy, newpx, newpz);
    base(newI) = 1;
    
    newbase = imfill(base,'holes');
    
    %%START OF FEATURE CALCULATION
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
    %fea_pixhist=  hist(mskedPixelValues, histbins);
    %fea_gran = calculate3DVolumeGranulometry(graycube, base, granbins);
    %%END OF FEATURE CALCULATION
    
    %%WRITE FEATURES INTO CELL
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
    %CNNFEATURES
    features{14}(realNumObjects, :) = extract_cnn_features(graycube, net);
    fea_label{realNumObjects} = is_current_object_a_noldule;
    %features{14}(o,:) = fea_pixhist;
    %features{15}(o,:) = fea_gran;
    %%EOF WRITING FEATURES
end
fprintf('\n');
end

writeFeatures2HDF5(outfname, realNumObjects, features, feature_names, feature_lengths)
%Write labels in a different file
%while h5 matrixes are 0 indexed, a object which is 1234'th object seems
%1233'th object in the file.
h5create(strcat('labels_',outputFileNameAndPath), '/labels', realNumObjects, 'Datatype','int16');
h5write(strcat('labels_',outputFileNameAndPath), '/labels', int16(cell2mat(fea_label)));
end

%%WRITE THE FEATURES INTO HDF5 FILE
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

%%FEATURE CALCULATION LOCAL FUNCTION BELOW
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

function granulo = calculate3DVolumeGranulometry(greyData,msk, granulobins)

% calculates volume granulometry just for the pixels of msk
greyData(~msk) = 0;
granulo = maxtree_granulo3d(greyData, 0, 2, granulobins);
% this is not the best way of doing it but I will for now

end

function calcFeas(originalFile, predictionFile, outputFileNameAndPath, labelFiles, thold)

if (nargin==0)
    originalFile = '../noduledetectordata/originaldata/example02.h5';
    predictionFile = '../noduledetectordata/ilastikoutput3/example02_Probabilities.h5';
    outputFileNameAndPath = 'example_02.h5';
    labelFiles = '../noduledetectordata/ilastikoutput3/example02_labels.txt';
    thold = 0.65;
end

%%ROOM FOR FEATURES
histbins = linspace(0,255,32);

numObjects2 = 0;
realNumObjects = 0;
feature_names = {'Volume','CentroidNorm','Centroid', 'Perimeter', 'PseudoRadius', 'Complexity',...
    'BoundingBox2Volume', 'BoundingBoxAspectRatio', 'IntensityMax','IntensityMean',...
    'IntensityMin','IntensityStd', 'CloseMassRatio','IntensityHist'};
feature_lengths = [1, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, length(histbins)];
%512 for cnn filter features
fea_label = cell(numObjects2,1);
feature_num = length(feature_names);
features = cell(feature_num,1);
for f = 1: feature_num
    features{f} = zeros(numObjects2,feature_lengths(f));
end
%%EOF ROOM FOR FEATURES

outfname = ['../noduledetectordata/FeatureFiles/' outputFileNameAndPath];
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
    [graycube, bbx] = extendCube(bbx, originalFile, originalSetName,...
        height, width, deep);
    
    %Sum cube at z axsis
    
    CollapseZ = sum(graycube, 3);
    CollapseY = sum(graycube, 2);
    
   
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

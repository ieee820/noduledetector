function objs = calculate_cc(bigcube, original_scan, dilatesiz, ex_size, dataname)
% Given thresholded cube, calculate connected components and
% return as a struct
%% 1- Apply dilation
sesize = dilatesiz;
sw=(sesize-1)/2; 
ses2=ceil(sesize/2);
[y,x,z]=meshgrid(-sw:sw,-sw:sw,-sw:sw); 
m=sqrt(x.^2 + y.^2 + z.^2); 
b=(m <= m(ses2,ses2,sesize)); 
se=strel('arbitrary',b);
mat = imclose(bigcube, se);
%mat = imopen(mat, se);

%% 2- Calculat CC
CC = bwconncomp(mat);
S = regionprops(CC,'Centroid', 'Area', 'BoundingBox');
objs = struct;
n = 1; % this is redundant
%For each Nodule
    for j=1:length(S)
        bbx = floor(S(j).BoundingBox+0.5);
        objs(n).boxex = extend_cube(bbx, original_scan, ex_size);
        objs(n).dataset = dataname;
        objs(n).CC.bbx = bbx;
        objs(n).CC.area = S(j).Area;
        objs(n).CC.centroid = S(j).Centroid;
        objs(n).CC.PixelIdxList = CC.PixelIdxList(j);
        objs(n).CC.Connectivity = CC.Connectivity;
        objs(n).CC.NumObjects = CC.NumObjects;
        objs(n).CC.ImageSize = CC.ImageSize;
        %nodules(n).label = 1; %means nodule
        n = n + 1;
    end
end


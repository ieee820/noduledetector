function objs = calculate_cc(bigcube, original_scan, dilatesiz, ex_size, dataname)
% Given thresholded cube, calculate connected components and
% return as a struct
%% 1- Apply dilation
eval(global_vars);
sesize = dilatesiz;
sw=(sesize-1)/2;
ses2=ceil(sesize/2);
[y,x,z]=meshgrid(-sw:sw,-sw:sw,-sw:sw);
m=sqrt(x.^2 + y.^2 + z.^2);
b=(m <= m(ses2,ses2,sesize));
se=strel('arbitrary',b);
%mat = bigcube;
mat = imclose(bigcube, se);
%mat = imopen(mat, se);

%% 2- Calculat CC
CC = bwconncomp(mat);
S = regionprops(CC,'Centroid', 'Area', 'BoundingBox');
objs = struct;
n = 1; % this is redundant
imsize = size(original_scan);
%For each Nodule
for j=1:length(S)
    centro = S(j).Centroid;
    if (centro(1)<(imsize(1)-contol) && centro(1)>contol &&...
       (centro(2)<(imsize(2)-contol) && centro(2)>contol) &&...
       (centro(3)<(imsize(3)-(contol/3)) && centro(3)>(contol/3)) &&...
       (S(j).Area>=areatol))
        bbx = floor(S(j).BoundingBox+0.5);
        %objs(n).actualcube = original_scan(bbx(2):bbx(2)+bbx(5), bbx(1):bbx(1)+bbx(4), bbx(3):bbx(3)+bbx(6));
        %[~,id] = max(objs(n).actualcube(:));
        %[y,x,z] = ind2sub(size(objs(n).actualcube), id);
        
        objs(n).boxex = extend_cube(bbx, original_scan, ex_size);
        objs(n).boxex2 = extend_cube(bbx, original_scan, ex_size2);
        objs(n).dataset = dataname;
        objs(n).CC.bbx = bbx;
        objs(n).CC.area = S(j).Area;
        objs(n).CC.centroid = S(j).Centroid;
        %objs(n).CC.centroid = [x-bbx(2) y-bbx(1) z-bbx(3)];
        objs(n).CC.PixelIdxList = CC.PixelIdxList(j);
        objs(n).CC.Connectivity = CC.Connectivity;
        objs(n).CC.NumObjects = CC.NumObjects;
        objs(n).CC.ImageSize = CC.ImageSize;
        %nodules(n).label = 1; %means nodule
        n = n + 1;
    end
end
end


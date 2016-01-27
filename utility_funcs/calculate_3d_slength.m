function [surfaceLength, surfacePixels] = calculate_3d_slength(msk)
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
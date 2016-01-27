function  close_mass_ratio = calculate_closemass(thisCentroid, thisRad,thisArea,thisIndex, vecAreas, vecCentroids)
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

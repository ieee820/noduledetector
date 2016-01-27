set = 'example02';
vessel_pred = read_ilastik_output(['../noduledetectordata/ilastikoutput3/' set '_Probabilities.h5'], 1, 0.50);
nodule_pred = read_ilastik_output(['../noduledetectordata/ilastikoutput3/' set '_Probabilities.h5'], 4, 0.65);

vessel_orig = h5read(['../noduledetectordata/originaldata/' set '.h5'], '/set');
vessel_orig = permute(vessel_orig, [2, 3, 1]);
imsize = size(vessel_orig);
CC = bwconncomp(vessel_pred);
S = regionprops(CC, 'Area', 'BoundingBox', 'Centroid');
n = 1;
vessels = {};
for i=1:size(S, 1)
    if S(i).Area > 50 %&& S(i).Area < 150
        pixelidlist = CC.PixelIdxList(i);
        %Exclude big vessels from detection
        nodule_pred(pixelidlist{1}) = 0;
    end
end
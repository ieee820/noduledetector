function [cube, prob, probm] = get_ROI(original_scan, pmap, map, wordcoor, info, patchsize)
voxelcoor = worldcoords_to_voxel(wordcoor, info.Offset, info.PixelDimensions);
cube = original_scan(voxelcoor(2)-patchsize/2:voxelcoor(2)+patchsize/2, ...
    voxelcoor(1)-patchsize/2:voxelcoor(1)+patchsize/2, ...
    voxelcoor(3)-patchsize/10:voxelcoor(3)+patchsize/10);
prob = pmap(voxelcoor(2)-patchsize/2:voxelcoor(2)+patchsize/2, ...
    voxelcoor(1)-patchsize/2:voxelcoor(1)+patchsize/2, ...
    voxelcoor(3)-patchsize/10:voxelcoor(3)+patchsize/10);

probm = map(voxelcoor(2)-patchsize/2:voxelcoor(2)+patchsize/2, ...
    voxelcoor(1)-patchsize/2:voxelcoor(1)+patchsize/2, ...
    voxelcoor(3)-patchsize/10:voxelcoor(3)+patchsize/10);

end


function out = voxel_to_worldcoords(voxelcoord, origin, spacing)
    C = abs(bsxfun(@times, voxelcoord, spacing));
    out = bsxfun(@plus, C, origin);
end
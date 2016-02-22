function out = worldcoords_to_voxel(worldcoord, origin, spacing)
    C = abs(bsxfun(@minus, worldcoord, origin));
    out = bsxfun(@rdivide, C, spacing);
end
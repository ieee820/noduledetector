function writeMatlabCubeToHDF5inXYZOrder(fname, dataname, data, startpos,count,mergeFunc,mergeParams)
%function writeMatlabCubeToHDF5inXYZOrder(fname, dataname, data, startpos,count)
% give data in matlab as it is y,x,z
% give startposition xyz
startpos = fliplr(startpos);
count = fliplr(count);
% changing write data to zyx
dat3 = permute(data, [3,1,2]);
if nargin<6
    mergeFunc = [];
    mergeParams = [];
end
if (~isempty(mergeFunc)) 
    read_data = h5read(fname, dataname,startpos, count);
    
                %subcube = permute(permute(subcube, [3, 2, 1]),[2,1,3]);

        if(~isempty(mergeParams))
            datmerge= feval(mergeFunc,read_data,dat3,mergeParams);
            
    else
        datmerge= feval(mergeFunc,read_data,dat3);
        end
    h5write(fname, dataname,datmerge,startpos, count);
end
h5write(fname, dataname,dat3,startpos, count);



% if (~) 
%     read_data = h5read(fname, dataname,startpos, count);
%     intersectiondata = intersect(read_data(:), dat3(:));
%     if(sum(intersectiondata(:))>0)
%         disp('overlapping write intersects');
%         dat3= max(read_data,dat3);
%         
%     else
%         dat3= read_data + dat3;
%     end
%     
% end
% h5write(fname, dataname,dat3,startpos, count);

%usage : ..(fileName, savePath, CT) -> where CT is CT object
%default set name = '/set'
function ilker_write_CT2h5(fileName, savePath, CT_obj, set)
%get the size
if varargin < 4
    set = '/set';
end
cellData = cell(CT_obj);
matrixData = cell2mat(cellData);
flipped = permute(matrixData, [3,1,2]);
sizeFlipped = size(flipped);
h5create(strcat(strcat(savePath,fileName),'.h5'), strcat('/', set), sizeFlipped, 'Datatype', 'int16');
h5write(strcat(strcat(savePath,fileName),'.h5'), strcat('/', set),flipped);
end
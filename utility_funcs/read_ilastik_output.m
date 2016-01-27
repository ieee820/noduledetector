function output = read_ilastik_output(file, channel, dth)
%This function reads an ilastik probability map an applies a threshold if
%Channel 1 -> Vessels
%Channel 2 -> Bones
%Channel 3 -> Background
%Channel 4 -> Nodules
if nargin<2
    disp('file -> ilastik probability map');
    disp('channel -> the class channel');
    disp('threshold -> if you want to threshold it');
end
ilastikprob = h5read(file, '/exported_data'); %h5 read prediction matrix
ilastikprob = permute(ilastikprob, [3 4 2 1]); %permute the matrix
output = ilastikprob(:,:,:,channel);%>dth(1);
output = imreconstruct(output>dth(1), output>dth(2));
%ThHigh = squeeze(ilastikprob(:,:,:,4))>squeeze(1.5.*max(ilastikprob(:,:,:,1:3),[],4));
%ThLow = squeeze(ilastikprob(:,:,:,4))>squeeze(1.0*max(ilastikprob(:,:,:,1:3),[],4));
%output = imreconstruct(ThLow, ThHigh);
end
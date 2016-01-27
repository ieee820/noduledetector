function [nodz, nody, nodx, allnodules] = calculate_avg_nodule()
%This function uses all datasets nodules and calculates an average nodule
%Also returns the nodules as cell array
%Using 55+170+44+57 nodules
%Avg Area is 642 pxls
%% LOAD Nodules
load('../noduledetectordata/LS/nodules_ls.mat');
load('../noduledetectordata/CR/nodules_cr.mat');
load('../noduledetectordata/CW/nodules_cw.mat');
load('../noduledetectordata/SNUH/nodules_snuh.mat');

%% Process Nodules
allnodules = struct([nodules_cr nodules_cw nodules_ls nodules_snuh]);
nod_count = length(allnodules);
nodule_arr = cell(nod_count, 1);
nodz = zeros(10, 10);
nody = zeros(10, 10);
nodx = zeros(10, 10);
avg_area = 0;
for i=1 : length(allnodules)
    nodule_box = allnodules(i).boxex;
    nodule_arr{i} = nodule_box;
    nodz = nodz + imresize(sum(smooth3(nodule_box), 3), [10 10]);
    nody = nody + imresize(squeeze(sum(smooth3(nodule_box), 1)), [10 10]);
    nodx = nodx + imresize(squeeze(sum(smooth3(nodule_box), 2)), [10 10]);
    avg_area = avg_area + allnodules(i).CC.area;
end
nodz = nodz ./ nod_count;
nody = nody ./ nod_count;
nodx = nodx ./ nod_count;
end
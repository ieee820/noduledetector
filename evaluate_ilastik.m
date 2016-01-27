%% This File is not completed yet
%% Load Files
addpath('utility_funcs');
sets = extractfield(dir('../noduledetectordata/ANODE/originaldata/*.h5'), 'name')';
annotfile = '../noduledetectordata/ANODE/originaldata/annotations.txt';
eval(global_vars);
dataname = 'ANODE';

%% Read Annotations
annot_c = cell(length(sets), 1);
annots = fopen(annotfile, 'r');
ctrs = zeros(4, 1);
while ~feof(annots)
    line = fgetl(annots);
    if ~ischar(line), break, end %break if no read a line
    line_i = textscan(line,'%s %d %d %d %d');
    cor = [line_i{:,[2 3 4]}];
    %pos = line_i{5};
    if strcmp(cell2mat(line_i{1}), 'example01')==1
        ctrs(1,1) = ctrs(1,1)+1;
        annot_c{1, ctrs(1,1)} = cor;
    elseif strcmp(cell2mat(line_i{1}), 'example02')==1
        ctrs(2,1) = ctrs(2,1)+1;
        annot_c{2, ctrs(2,1)} = cor;
    elseif strcmp(cell2mat(line_i{1}), 'example03')==1
        ctrs(3,1) = ctrs(3,1)+1;
        annot_c{3, ctrs(3,1)} = cor;
    elseif strcmp(cell2mat(line_i{1}), 'example05')==1
        ctrs(4,1) = ctrs(4,1)+1;
        annot_c{4, ctrs(4,1)} = cor;
    end
end
fclose(annots);

%% Label objects
labels = cell(4, 1);
for i=1:length(sets)
    [~,fn,~] = fileparts(cell2mat(sets(i)));
    original_scan = h5read(['../noduledetectordata/ANODE/originaldata/' fn '.h5'], '/set');
    original_scan = permute(original_scan, [2 3 1]);
    
    p_file_name = ['../noduledetectordata/ANODE/ilastikoutput/' fn '_Probabilities.h5'];
    ilastik_output = read_ilastik_output(p_file_name, 4, dth);
    
    objs = calculate_cc(ilastik_output, original_scan, dilatesiz, ex_size, dataname);
    imSize = size(original_scan);
    a = reshape([annot_c{i,:}], [3 ctrs(i,1)])'; %annotations for this sets
    
    for obj=1:length(objs)
        CC = objs(obj).CC;
        pix = CC.PixelIdxList;   %the pixel location of the cc object
        [py,px,pz] = ind2sub(imSize, pix{1}); %converts the 1d point into 3d point
        %py = [py-15;py;py+15];
        %px = [px-15;px;px+15];
        %pz = [px-15;pz;pz+15];
        labelfound = 0;
        for j=1:size(a, 1)
            y = a(j, 2); x = a(j, 1); z = a(j, 3);
            if any(find(py==y)) && any(find(px==x)) && any(find(pz==z))
                % That is a true detection label as 1
                labels{i, obj} = 1;
                %CC.centroid
                labelfound = 1; break;
            end
        end
        if labelfound == 0
            labels{i, obj} = 0;
        end
    end
end

%% Save Labels


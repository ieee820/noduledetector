function[orig, annot, overlayed] = ilker_read_with_annot(filename)
    %enter file name with out .hdr
    %operated = CT();
    addpath '/Users/ilker/Desktop/Thesis/CT';
    addpath '/Users/ilker/Desktop/Thesis/CTData/Roidata/Nodule/Orig';
    orig = read_ct_set(strcat(filename,'.hdr'),0);
    parentpath = cd(cd('..'));
    annotPath = strcat(parentpath,'/ROI/');
    annotFile = strcat(annotPath,strcat(filename,'_ROI.hdr'));
    annot = read_ct_set(annotFile,0);
    annot = int16(cell2mat(cell(annot))); % converted
    annot(annot==1) = 1023;
    annot(annot==0) = 1;
    annot = CT(annot); %convert it back
    overlayed = orig+annot;
    %0's are bg. 1 s are annotations
    % cant read uint16 so we convert the annot to int16
end
% This script iterates over the test files (anode09)
% executes function calculateEv2 that returns tp fp object counts per
% trainset and also saves the labels.
%

datadir = '../noduledetectordata/';
annotf = [datadir 'originaldata/annotations.txt'];
resultsFile = fopen([datadir 'results_all_tholds.txt'], 'w');
folder = [datadir 'ilastikoutput3/'];
files = dir([folder '*.h5']);
%thold = linspace(0.40, 0.60, 5);
thold = 0.65;
labelthreshold = 0.65; %the threshold that labels shall be extracted

resultperTh = zeros(length(thold), length(files)-1);%example_04 has no nodules

for x = 1:length(files)
    fileName = files(x).name;
    fileNameWithPath = strcat(folder, fileName);
    underindex = strfind(fileName, '_');
    onlyFileName = char(fileName(1:underindex-1));
    originalFileName = strcat(onlyFileName,'.h5');  
    
    predMatrix = h5read(fileNameWithPath,'/exported_data'); %h5 read prediction matrix
    predMatrix = permute(predMatrix, [3 4 2 1]); %permute the matrix
    if(~exist(originalFileName))
   
    else
        origMatrix = h5read(originalFileName,'/set');
        origMatrix = permute(origMatrix, [2 3 1]); 
    end
    result  = calculateEv2(onlyFileName, annotf,...
                           predMatrix, thold, labelthreshold);
    resultperTh = resultperTh+result;
    fprintf(resultsFile, '---- Results Of : %s ----\n', originalFileName);
    fprintf(resultsFile, 'nNodules\tTruePos\tFalsePos\tThresHold\n');
    fprintf(resultsFile, [repmat('%4.2f\t ', 1, 4) '\n'], result');
    fprintf(resultsFile, '---- END OF : %s ----\n\n', originalFileName);

end
    fprintf(resultsFile, '\n Total TP rates:');
    fprintf(resultsFile,'%f\n', resultperTh(:,2)./resultperTh(:,1));
    fprintf(resultsFile, '\n Total FP:');
    fprintf(resultsFile,'%f\n', resultperTh(:,3)./length(files));
    fclose('all');
    
    tpRate = resultperTh(:,2)./ resultperTh(:,1);
    fpNumber = resultperTh(:,3)./ length(files);
    z = [tpRate, fpNumber]';
    save('ilastik_results.mat', 'z');
    save('anode_results.mat', 'resultperTh');

%annotations.txt de verilen koordinatlar 0 based mi
%annotation.txt de verilen koordinatlar x,y,z mi ?yleyse
%matlabda zyx olarak mi de?erlendirmeliyiz yoksa oldu?u ?ekilde mi.
%nekadar b?y?k detection yapm??sak onu truepositive sayal?m
%overlapping le ilgili bir?ey hesaplayaca??z m?



anotationFile = fopen('../noduledetectordata/originaldata/anotations.txt','r');
resultsFile = fopen('../noduledetectordata/results_all_tholds.txt','w');
folder = '../noduledetectordata/ilastikoutput/';
files = dir(strcat(folder,'*.h5'));
%thold = [0.2, 0.3, 0.5 , 0.7 , 0.8];
thold = linspace(0.40, 0.70, 10);
%thold = [0.30 0.35 0.40 0.42 0.45 0.48 0.5 0.55 0.59 0.60 0.61 0.62 0.65];

resultperTh = zeros(length(thold),4);

for x = 1:length(files)
    fileName = files(x).name;
    fileNameWithPath = strcat(folder, fileName);
    %onlyFileName = strsplit(fileName,'_');
    underindex = strfind(fileName, '_');
    onlyFileName = char(fileName(1:underindex-1));
    %onlyFileName = onlyFileName{1}; %contains only the filename
    originalFileName = strcat(onlyFileName,'.h5');   
    predMatrix = h5read(fileNameWithPath,'/exported_data'); %h5 read prediction matrix
    predMatrix = permute(predMatrix, [3 4 2 1]); %permute the matrix
    if(~exist(originalFileName))
   
    else
        origMatrix = h5read(originalFileName,'/set');
        origMatrix = permute(origMatrix, [2 3 1]); 
    end
    result  = calculateEv2(onlyFileName, anotationFile, predMatrix, thold);
    resultperTh = resultperTh+result;
    fprintf(resultsFile, '---- Results Of : %s ----\n', originalFileName);
    fprintf(resultsFile, 'nNodules\tTruePos\tFalsePos\tThresHold\n');
    fprintf(resultsFile, [repmat('%4.2f\t ', 1, 4) '\n'], result');
    fprintf(resultsFile, '---- END OF : %s ----\n\n', originalFileName);
        %%get the coordinates
          
end
    fprintf(resultsFile, '\n Total TP rates:');
    fprintf(resultsFile,'%f\n', resultperTh(:,2)./resultperTh(:,1));
    fprintf(resultsFile, '\n Total FP:');
    fprintf(resultsFile,'%f\n', resultperTh(:,3)./5);
    fclose(resultsFile);
    
    tpRate = resultperTh(:,2)./resultperTh(:,1);
    fpNumber = resultperTh(:,3)./5;
    z = [tpRate, fpNumber]';
    save('ilastik_results.mat', 'z');
    save('anode_results.mat', 'resultperTh');

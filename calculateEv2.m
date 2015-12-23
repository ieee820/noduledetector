% This function will find the values for the given predictionfile and thresholds
% will iterate each thresholds and annotation points 
function [returnStruct] = calculateEv2(setName,predFile, predMatrix, thresHolds, labelthreshold)
    labelsFile = fopen(['../noduledetectordata/' setName '_labels.txt'], 'w');
    setInfo = getCoordinatesAndPossibilitiesFromTheFile(predFile,setName);
    distanceTolerance = 5;
    returnStruct = zeros(length(thresHolds), 4);

    for x = 1 : length(thresHolds)
    
        numberOfFalsePositive = 0;%%
        numberOfTruePositive = 0;%%
        predMatrixTH = predMatrix(:,:,:,4)>thresHolds(x); %4 is the channel

        prediction_conn_comp = bwlabeln(predMatrixTH);
        
        if (isempty(setInfo))
            numberOfFalsePositive = max(prediction_conn_comp(:));
            returnStruct(x,:) = [length(setInfo),numberOfTruePositive, numberOfFalsePositive, thresHolds(x)];
            continue;
        end
        CC = bwconncomp(predMatrixTH);
        centroids = regionprops(prediction_conn_comp, 'centroid');
        centroids = cat(1, centroids.Centroid);
        centroids = centroids(sum(isnan(centroids),2)==0,:);
        for set = 1 : length(setInfo)
             %noduleSlice = prediction_conn_comp(:,:,setInfo(set).coordinates(3));
             if(isempty(centroids))
                continue; %just empty slice found notthing
             end
             distances = pdist2(centroids, double(setInfo(set).coordinates)); %x and y
             [minimumDistance, minimumIx] = min(distances);
             
             if(minimumDistance <= distanceTolerance)
                %herewe found the nodule
                %minimumIx is the label
                %extract class 1 given threshold
                if thresHolds(x) == labelthreshold
                    fprintf(labelsFile,'%d\n', minimumIx);
                end
                numberOfTruePositive = numberOfTruePositive + 1;
             end
        end
        numberOfFalsePositive = max(prediction_conn_comp(:)) - numberOfTruePositive;
        returnStruct(x,:) = [length(setInfo), numberOfTruePositive, numberOfFalsePositive, thresHolds(x)];
       
    end

end

%return values are list of structs containing coordinates & possibilities
%both
function [returnValues] = getCoordinatesAndPossibilitiesFromTheFile(anotationFile, requiredSet)
	anotationFile = fopen(anotationFile,'r');
    counter = 1;
    while ~feof(anotationFile)
            line = fgetl(anotationFile);
            if ~ischar(line), break, end %break if no read a line
            lineInfos = textscan(line,'%s %d %d %d %d');
            if(strcmp(lineInfos{1},requiredSet) == false)
                continue;
            end
            coordinates = [lineInfos{:,[2 3 4]}]; % the coordinate of the candidate nodule
            possibility = lineInfos{:,5}; %possibiliry 1 or 2
            field1 = 'coordinates'; value1 = coordinates;
            field2 = 'possibility'; value2 = possibility;
            returnValues(counter) = struct(field1,value1,field2,value2);
            counter = counter + 1;
    end
        %fclose(anotationFile); %rewind the filepointer
        if(counter==1)
                returnValues = [];
        end
end
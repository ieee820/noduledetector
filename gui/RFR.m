classdef RFR
    properties
        file_info
        file_realpath
        var_alphastep
        var_alphastart
        var_alphastop
        var_mult
        var_treecount
        roc_values
        ilastik_roc_values
        batch_results
    end
    methods
        %init function constructor
        function obj = RFR(filePath, ilastikFile)
            if nargin > 0
                if exist(filePath, 'file')
                    %STUFF
                    obj.file_realpath = filePath;
                    file_infox = h5info(filePath);
                    obj.file_info = file_infox.Datasets;
                    obj.roc_values = h5read(filePath, '/roc_vals');
                    obj.var_alphastep = h5readatt(filePath, '/roc_vals', 'var_alphastep');
                    obj.var_treecount = h5readatt(filePath, '/roc_vals', 'var_treecount');
                    obj.var_mult = h5readatt(filePath, '/roc_vals', 'var_mult');
                    obj.var_alphastart = h5readatt(filePath, '/roc_vals', 'var_alphastart');
                    obj.var_alphastop = h5readatt(filePath, '/roc_vals', 'var_alphastop');
                    matFIlastik = matfile(ilastikFile);
                    obj.ilastik_roc_values = matFIlastik.z;
                    %insert batch probabilities
                    obj.batch_results = cell(length(obj.file_info) -1, 2);
                    batch_counter = 1;
                    for x = 1:length(obj.file_info)
                        dataSetName = obj.file_info(x).Name;
                        if strcmp(dataSetName, 'roc_vals')
                            continue;
                        end
                        probabilities = h5read(filePath, ['/', dataSetName]);
                        obj.batch_results{batch_counter, 1} = dataSetName;
                        obj.batch_results{batch_counter, 2} = probabilities;
                        batch_counter = batch_counter + 1;
                    end
                else
                    error('File does not exists.')
                end
            end
        end
        
        function testAlpha(obj, idx, alphaVal, ThresHold)
            addpath '/Users/ilker/Desktop/Thesis/CT';
            alpha = [1-alphaVal; alphaVal];
            alpha = diag(alpha);
            datasetname = obj.batch_results{idx, 1};
            fullPath = strcat('/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/NormalFeaturesSelected/', [datasetname '_Probabilities.h5']);
            originalPath = strcat('/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/', [datasetname '.h5']);
            prediction = obj.batch_results{idx, 2};
            prediction = alpha * prediction;
            [rowm rowarg] = max(prediction, [], 1);
            %rowarg, 1 = bg, 2 = nodule
            predMatrix = h5read(fullPath,'/exported_data'); %h5 read prediction matrix
            predMatrix = permute(predMatrix, [3 4 2 1]); %permute the matrix
            predMatrixTH = predMatrix(:,:,:,1)>ThresHold; %predictiondaki
            [sizey,sizex,sizez] = size(predMatrixTH);
            
            CC = bwconncomp(predMatrixTH);
            s  = regionprops(CC, 'centroid','BoundingBox','Area');
            CC.centroids = cat(1, s.Centroid);
            CC.bbx =  cat(1, s.BoundingBox);
            CC.areas =  cat(1, s.Area);
            
            imSize = CC.ImageSize;
            numObjects = CC.NumObjects;
            vec_areas= cat(1,CC.areas);
            vec_centroids = cat(1,CC.centroids);
            num = 0;
            normalcube = h5read(originalPath, '/set');
            normalcube = permute(permute(normalcube, [3, 2, 1]),[2,1,3]);
            for o = 1 : numObjects
                if (rowarg(o) == 1) %1 bg, 2 nodule
                    continue;
                end
                num = num + 1;
                bbx = floor(CC.bbx(o,:)+0.5);   %bounding box
                base = zeros(bbx(5), bbx(4),bbx (6));   %base of bounding box
                pix = CC.PixelIdxList{o};   %the pixel location of the cc object
                [py,px,pz] = ind2sub(imSize, pix); %converts the 1d point into 3d point
                lenx  =bbx(4); leny = bbx(5); lenz = bbx(6);
                
                startix = double([bbx(3), bbx(2), bbx(1)]);
                startixa=startix-10;
                
                counts = double([bbx(6),bbx(5), bbx(4)]);
                countsa = counts+20;
                
                startixa(startixa<1) = 1;
                countsa(countsa>=[sizez, sizey, sizex]) = min([sizez, sizey, sizex]);
               
                normalcube(py, px, pz) = normalcube(py, px, pz) + 1000;

                %graycube = h5read(originalPath, '/set', startixa, countsa);
                %graycube = permute(permute(graycube, [3, 2, 1]),[2,1,3]); %this is for matlab xyz order227122
                %graycube(py-bbx(2) + 10, px-bbx(1) + 10, pz-bbx(3) + 10) = graycube(py-bbx(2) + 10, px-bbx(1) + 10, pz-bbx(3) + 10)+500;
                %disp(startix);
                %obj_ct = CT(graycube);
                %sliceview(obj_ct); % uncomment to see detections as ROI's
            end
            obj_all_ct = CT(normalcube);
            sliceview(obj_all_ct);
            disp(num);
        end
    end
end
%READ ALL FEATURES AND LABELS
histbins = linspace(0,255,32);
featureLength = [1, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, length(histbins), 7, 14, 5, 2, 100, 50, 3*9];
feature_names = {'Volume','CentroidNorm','Centroid', 'Perimeter', 'PseudoRadius', 'Complexity',...
    'BoundingBox2Volume', 'BoundingBoxAspectRatio', 'IntensityMax','IntensityMean',...
    'IntensityMin','IntensityStd', 'CloseMassRatio','IntensityHist', 'gaussianCoefficients',...
    'gaussianBounds', 'gaussianGOF', 'gaussianGOV', 'CollapseZ', 'Gradient', 'GradientOfMag'};

datasets = ['example_01.h5'; 'example_02.h5'; 'example_03.h5'; 'example_05.h5'];
sets_num = [1 2 3 5];
general_path = '../noduledetectordata/ilastikoutput3/';
fea_path = '../noduledetectordata/ilastikoutput3/extractedfeatures/';
label_path = '../noduledetectordata/ilastikoutput3/extractedlabels/';

for f=1:size(datasets, 1),
    fea_file_name = [fea_path datasets(f, :)];
    label_file_name = [label_path 'labels_' datasets(f, :)];
    for i=1 : length(feature_names)
        features{f,i} = h5read(fea_file_name, ['/' cell2mat(feature_names(i))]);
    end
    labels{f} = h5read(label_file_name, '/labels');
end;

%CREATE SCENARIOS

scenerios = [1 2 3 (5-1); (5-1) 2 3 1; 1 (5-1) 2 3; 3 1 (5-1) 2];
%5-1 because we dont use example_04

for k=1:size(scenerios, 1),
    tr_1 = scenerios(k, 1);
    tr_2 = scenerios(k, 2);
    tr_3 = scenerios(k, 3);
    test = scenerios(k, 4);
    objectCounter = 0;
    total_feas = cell(1, length(feature_names));
    total_labels = [];
    %Train 1 items
    for i=1 : length(feature_names)
        [m, n] = size(features{tr_1,i});
        if m<n
            total_feas{i} = [total_feas{i} features{tr_1,i}];
        else
            total_feas{i} = [total_feas{i} ;features{tr_1,i}];
        end
    end
    
    %Train 2 items
    for i=1 : length(feature_names)
        [m n] = size(features{tr_2,i});
        if m<n
            total_feas{i} = [total_feas{i} features{tr_2,i}];
        else
            total_feas{i} = [total_feas{i} ;features{tr_2,i}];
        end
    end
    
    %Train 3 items
    for i=1 : length(feature_names)
        [m n] = size(features{tr_3,i});
        if m<n
            total_feas{i} = [total_feas{i} features{tr_3,i}];
        else
            total_feas{i} = [total_feas{i} ;features{tr_3,i}];
        end
    end
    
    %Empty Scenario Dir
    delete([general_path 's' num2str(k) '/*.h5']);
    
    %Set Labels
    total_labels = [labels{tr_1}; labels{tr_2}; labels{tr_3}];
    objectCounter = length(total_labels);
    %Write to hdf5
    for f = 1: length(total_feas)
        feature_data = total_feas{f};
        if (featureLength(f)==1)
            data_size = objectCounter;
        else
            data_size = ([featureLength(f), objectCounter]);
        end
        oFileName = [general_path 's' num2str(k) '/s' num2str(k) '.h5']; 
        h5create(oFileName, ['/',feature_names{f}], data_size,'Datatype','double');
        h5write(oFileName, ['/',feature_names{f}], feature_data);
    end
    
    
    %Write Labels
    oFileName = [general_path 's' num2str(k) '/s' num2str(k) '_labels.h5']; 
    h5create(oFileName, '/labels', objectCounter, 'Datatype','int16');
    h5write(oFileName, '/labels', int16(total_labels));
    
    %Write Test Sets
    copyfile([fea_path datasets(test, :)], [general_path 's' num2str(k)]);
    copyfile([label_path 'labels_' datasets(test, :)], [general_path 's'  num2str(k)]);
end;
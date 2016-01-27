function write_features(outfname, numObjects, features, featureNames, featureLength)

for f = 1: length(features)
    feature_data = features{f};
    if (featureLength(f)==1)
        data_size = numObjects;
    else
        data_size = fliplr([numObjects,featureLength(f)]);
        feature_data = feature_data';
    end
    
    h5create(outfname,['/',featureNames{f}],data_size,'Datatype','double');
    
    %     if(rank(feature_data)>1)
    %     feature_data = transpose(feature_data);
    %     end
    h5write(outfname, ['/',featureNames{f}], feature_data);
end
end

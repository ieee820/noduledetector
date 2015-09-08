function fea_vec = extract_cnn_features(impatch, net)

%convert it to single
im_ = single(impatch) ; % note: 255 range

if size(im_, 3) ~= 3
    im_ = cat(3, im_, im_, im_);
end

%normalisation is required
im_ = imresize(im_, net.normalization.imageSize(1:2)) ;
%im_ = im_ - net.normalization.averageImage ;

%prediction stage
res = vl_simplenn(net, im_);

%get values from layer conv5
layeruse = 13; %13 - Fast,, 12 - Slow conv5 layer
meancomp = 2; %max,mean,stddev rooms
filter_results = res(layeruse).x;
filter_size = size(res(layeruse).x, 3);


%check if the feature is just a column vector or a matrix
if size(res(layeruse).x, 2)==1 & size(res(layeruse).x, 2)==1
    fea_vec = squeeze(res(layeruse).x)';
else
    fea_vec = []; %= zeros(1, meancomp*(size(res(layeruse).x, 3))); %max,mean,stddev
    for i=1 : filter_size
        %calculate each filters, mean, std, min, max and concat to a vector
        filter = reshape(filter_results(:, :, i), [], 1);
        mu = mean(filter);
        sigma = std(filter);
        %skw = skewness(filter(:));
        %maxf = max(filter);
        vectorOfFilter = [mu sigma]; %skw maxf];
        %fancy vector assignment
        fea_vec = [fea_vec vectorOfFilter];
    end
    
end
fea_vec(isnan(fea_vec)) = 0;

end


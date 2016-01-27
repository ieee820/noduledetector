%This function fits a 2D rotatable gaussian to the summed summedcube on Z axis
%Uses the avg nodule as Godness of validation
%Inputs : summedcube, AvgNodule
%Outputs : fit coefficients, godness of fit, godness of validation
function [fitresult, gof, val_obj] = fit_gaussian(summedcube, avgNodule)
warning('off','all');

%Prepare AvgNodule Surface
avgNodule = (avgNodule - min(avgNodule(:))) / ( max(avgNodule(:)) - min(avgNodule(:)) );
[Xa, Ya] = meshgrid(1:size(avgNodule, 1), 1:size(avgNodule, 2));
[xDataVal, yDataVal, zDataVal] = prepareSurfaceData(Xa, Ya, avgNodule);

%Normalize summedcube, min-max normalisation
summedcube = imresize(summedcube, size(avgNodule));
summedcube = (summedcube - min(summedcube(:))) / ( max(summedcube(:)) - min(summedcube(:)) );

%Prepare surface
[X, Y] = meshgrid(1:size(summedcube, 1), 1:size(summedcube, 2));
[xData, yData, zData] = prepareSurfaceData(X, Y, summedcube);

%Set fittype and options
ft = fittype( 'a + b*exp(-(((x-c1)*cosd(t1)+(y-c2)*sind(t1))/w1)^2-((-(x-c1)*sind(t1)+(y-c2)*cosd(t1))/w2)^2)', 'independent', {'x', 'y'}, 'dependent', 'z' );
%model = ['A*exp( - (cos(theta)^2/2/sigma_x^2 + sin(theta)^2/2/sigma_y^2*(x-x0).^2 -'...
%         '2*-sin(2*theta)/4/sigma_x^2 + sin(2*theta)/4/sigma_y^2*(x-x0).*(y-y0) +'... 
%         'sin(theta)^2/2/sigma_x^2 + cos(theta)^2/2/sigma_y^2*(y-y0).^2))'];
%ft = fittype(model, 'independent', {'x', 'y'}, 'dependent', 'z');
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0 0.1 2 2 0.1 0.1 0.1]; %Start points are tested, may changed on further tests
opts.MaxIter = 100;
%Fit model to data
%ft = fittype( 'poly55' );
[fitresult, gof] = fit( [xData, yData], zData, ft, opts);

%Compare against validation data (GOV)
residual = zDataVal - fitresult( xDataVal, yDataVal );
nNaN = nnz( isnan( residual ) );
residual(isnan( residual )) = [];
sse = norm( residual )^2;
rmse = sqrt( sse/length( residual ) );
val_obj = struct('sse', sse ,'rmse', rmse);
warning('on','all');
end


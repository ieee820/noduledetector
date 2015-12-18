%This function fits a 2D rotatable gaussian to the summed cube on Z axis
%Uses the avg nodule as Godness of validation
%Inputs : Cube, AvgNodule
%Outputs : fit coefficients, godness of fit, godness of validation
function [fitresult, gof, val_obj] = fit_gaussian(cube, avgNodule)
warning('off','all');
%Prepare AvgNodule Surface
[Xa, Ya] = meshgrid(1:size(avgNodule, 1), 1:size(avgNodule, 2));
[xDataVal, yDataVal, zDataVal] = prepareSurfaceData(Xa, Ya, avgNodule);

%Normalize cube
cube = imresize(cube, size(avgNodule));
cube = (cube - min(cube(:))) / ( max(cube(:)) - min(cube(:)) );
%Prepare surface
[X, Y] = meshgrid(1:size(cube, 1), 1:size(cube, 2));
[xData, yData, zData] = prepareSurfaceData(X, Y, cube);

%Set fittype and options
ft = fittype( 'a + b*exp(-(((x-c1)*cosd(t1)+(y-c2)*sind(t1))/w1)^2-((-(x-c1)*sind(t1)+(y-c2)*cosd(t1))/w2)^2)', 'independent', {'x', 'y'}, 'dependent', 'z' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [5 5 5 5 5 5 5]; %Start points are tested, may changed on further tests

%Fit model to data
[fitresult, gof] = fit( [xData, yData], zData, ft, opts );

%Compare against validation data (GOV)
residual = zDataVal - fitresult( xDataVal, yDataVal );
nNaN = nnz( isnan( residual ) );
residual(isnan( residual )) = [];
sse = norm( residual )^2;
rmse = sqrt( sse/length( residual ) );
val_obj = struct('sse', sse ,'rmse', rmse);
warning('on','all');
end


function [fitresult, gof] = nonparametric_fit(summedcube)

summedcube = imresize(summedcube, [10 10]);
%summedcube = (summedcube - min(summedcube(:))) / ( max(summedcube(:)) - min(summedcube(:)) );
[X, Y] = meshgrid(1:size(summedcube, 1), 1:size(summedcube, 2));
[xData, yData, zData] = prepareSurfaceData(X, Y, summedcube);

% Set up fittype and options.
ft = fittype( 'poly44' );

% Fit model to data.
[fitresult, gof] = fit( [xData, yData], zData, ft, 'Normalize', 'on' );


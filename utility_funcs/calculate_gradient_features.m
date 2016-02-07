%% Gradient Calculation for n-dimensional voxels
function [hist_3d_grads, second_mag_hist] = calculate_gradient_features(graycube, th)
%Prepare Kernels for x,y,z
% graycube = smooth3(graycube);
% kernelx = diff(fspecial('gaussian', [8, 1], 1.5))';
% kernely = kernelx';
% kernelz = zeros(7, 7, 7);
% kernelz(4,4,1:end) = kernelx;
 graycube = (graycube-min(graycube(:)))/(max(graycube(:))-min(graycube(:)));
 kernelx = [-1,0,1];
 kernely = [-1;0;1];
 kernelz = zeros(3,3,3);
 kernelz(2,2,1) = -1;
 kernelz(2,2,3) = 1;

%Calculate derivatives for x,y,z using the kernels
dx = convn(graycube, kernelx, 'same');
dy = convn(graycube, kernely, 'same');
dz = convn(graycube, kernelz, 'same');

%Cut-off noises
dx = dx(2:end-1, 2:end-1, 2:end-1);
dy = dy(2:end-1, 2:end-1, 2:end-1);
dz = dz(2:end-1, 2:end-1, 2:end-1);

%Calculate Magnitude of the cube
%mag = abs(dx) + abs(dy) + abs(dz);
mag = sqrt(dx.*dx + dy.*dy + dz.*dz);


%Calculate angles (Azimuth & Theta)
angleazimuth = zeros(size(dx));
angletetha = zeros(size(dx));
for i = 1 : size(dx, 1) * size(dy, 2) * size(dz, 3),
    angletetha(i) = acos(dz(i) / sqrt(dx(i).*dx(i)+dy(i).*dy(i)+dz(i).*dz(i)));
    angleazimuth(i) = atan2(dx(i),dy(i));
end

%Calculate histogram for the gradient angles
nbins_u = 5; 
nbins_v = 10;
%th = 0;
uu = linspace(0,pi, nbins_u);                   %preparing bins for azimuth
vv = linspace(-pi,pi,nbins_v);                  %preparing bins for zenith or teta
hist_uu_vv = zeros(nbins_u, nbins_v);           %orientation histogram
for i = 1 : size(dx, 1) * size(dy, 2) * size(dz, 3),
    if mag(i)>th
    % lets find the bins that this particular azimuth and tetha belongs to
        k = 1; 
        while(angletetha(i)> uu(k)), k=k+1; end;  %assuming it is in the limits
        j = 1; 
        while(angleazimuth(i)> vv(j)), j=j+1; end;
        % k and j are the indices, transform them to 1 index
        hist_uu_vv(k,j) = hist_uu_vv(k,j) + mag(i); 
    end
end
% Normalization of the feature vector using L2-Norm
hist_uu_vv = hist_uu_vv(:);
hist_uu_vv=hist_uu_vv/sqrt(norm(hist_uu_vv)^2+.001);
hist_3d_grads = hist_uu_vv;

%% Calculate mag & orientation of the magnitude
%remember to normalize the magnitude if needed
x_s = squeeze(sum(mag, 1))/size(mag,1);
y_s = squeeze(sum(mag, 2))/size(mag,2);
z_s = sum(mag, 3)/size(mag,3);

dx_x = conv2(x_s, kernelx, 'same');
dy_x = conv2(x_s, kernely, 'same');
%mag_x = abs(dx_x) + abs(dy_x);
mag_x = sqrt(dx_x.*dx_x + dy_x.*dy_x);
angle_x = atan2(dx_x, dy_x);


dx_y = conv2(y_s, kernelx, 'same');
dy_y = conv2(y_s, kernely, 'same');
%mag_y = abs(dx_y) + abs(dy_y);
mag_y = sqrt(dx_y.*dx_y + dy_y.*dy_y);
angle_y = atan2(dx_y, dy_y);



dx_z = conv2(z_s, kernelx, 'same');
dy_z = conv2(z_s, kernely, 'same');
%mag_z = abs(dx_z) + abs(dy_z);
mag_z = sqrt(dx_z.*dx_z + dy_z.*dy_z);
angle_z = atan2d(dx_z, dy_z);


%investigate this threshold
[hist_x] = get_histogram(mag_x(:), angle_x(:), 9);
[hist_y] = get_histogram(mag_y(:), angle_y(:), 9);
[hist_z] = get_histogram(mag_z(:), angle_z(:), 9);
second_mag_hist = [hist_x hist_y hist_z];
end

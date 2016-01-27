%b?y?tt?kten sonra cube ? crop ediyoruz quantize
%quzntize etmemiz gerekiyor

kernelx = [-1 0 1];
kernely = [-1 0 1]'; %kernelx';
kernelz = zeros(3,3,3);
kernelz(2,2,:) = [-1 0 1];

%Demo Sphere
sesize = 100;
sw=(sesize-1)/2; 
ses2=ceil(sesize/2);            % ceil sesize to handle odd diameters
[y,x,z]=meshgrid(-sw:sw,-sw:sw,-sw:sw); 
m=sqrt(x.^2 + y.^2 + z.^2); 
b=(m <= m(ses2,ses2,sesize)); 
se=strel('arbitrary',b);
sph = [se.getnhood];


dx = convn(sph, kernelx, 'same');
dy = convn(sph, kernely, 'same');
dz = convn(sph, kernelz, 'same');

%Cut-off noises
dx = dx(2:end-1, 2:end-1, 2:end-1);
dy = dy(2:end-1, 2:end-1, 2:end-1);
dz = dz(2:end-1, 2:end-1, 2:end-1);

mag = abs(dx) + abs(dy) + abs(dz); 


ref = [1 0 0];
ori = zeros(size(dx));
for i = 1: size(dx, 1) * size(dy, 2) * size(dz, 3),
    v = [dx(i) dy(i) dz(i)];
    ori(i) = atan2(norm(cross(v,ref)),dot(v,ref));
end;

orsum = sum(ori ,3);

%Visualize
data = ori;
surfaceparam = 0;
p = patch(isosurface(data, surfaceparam));
isonormals(data,p)
p.FaceColor = 'red';
p.EdgeColor = 'green';
daspect([1,1,1])
view(3); axis tight
camlight 
lighting gouraud

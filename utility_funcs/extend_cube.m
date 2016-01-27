function graycube = extend_cube(bbx, bigcube, ex_size)
%extend the cube given;
[width,height,deep] = size(bigcube);
e_z = ex_size(3);
e_x = ex_size(2);
e_y = ex_size(1);

%detected locations
z = bbx(3);
y = bbx(1);
x = bbx(2);
z_count = bbx(6);
y_count = bbx(4);
x_count = bbx(5);

x = (x-(e_x/2));
y = (y-(e_y/2));
z = (z-(e_z/2));

%if startpoints are negative or zero, set them to detected ones
%add the patch size to the count
if x<=0
    x = bbx(2);
    x_count = bbx(5) + (e_x/2);
end
if y<=0
    y = bbx(1);
    y_count = bbx(4) + (e_y/2);
end
if z<=0
    z = bbx(3);
    z_count = bbx(6) + (e_z/2);
end

x_count = x_count + (e_x);
y_count = y_count + (e_y);
z_count = z_count + (e_z);

if x_count>height || x_count+x>height
    x_count = bbx(5);
    %if detection is more than dim
    if x+x_count>height
        x_count = x_count - mod(x+x_count,height);
    end
end
if y_count>width || y_count+y>width
    y_count = bbx(4);
    %if detection is more than dim
    if y+y_count>width
        y_count = y_count - mod(y+y_count,width);
    end
end
if z_count>deep || z_count+z>deep
    z_count = bbx(6);
    %if detection is more than dim
    if z+z_count>deep
        z_count = z_count - mod(z+z_count,deep);
    end
end

%startix = double([z, y, x])
%counts = double([z_count, y_count, x_count])
graycube = bigcube(x:x+x_count, y:y+y_count, z:z+z_count);
end
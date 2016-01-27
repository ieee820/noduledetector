function show_iso(cube)
p1 = patch(isosurface(cube, .99),'FaceColor','green',...
	'EdgeColor','none');
p2 = patch(isocaps(cube, .99),'FaceColor','green',...
	'EdgeColor','none');
view(3)
axis tight
daspect([1,1,.4])
colormap(gray(100))
camlight left
camlight
lighting gouraud
isonormals(cube,p1)
axis equal
end


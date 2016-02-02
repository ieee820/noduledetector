function show_iso(cube)
p1 = patch(isosurface(cube, .99),'FaceColor','red',...
	'EdgeColor','none', 'FaceAlpha', '0.9');
p2 = patch(isocaps(cube, .99),'FaceColor','red',...
	'EdgeColor','none', 'FaceAlpha', '0.9');
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


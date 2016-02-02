function sliceview(inp, titlename,sc,annots)
switch nargin
    case 0
        disp('function "sliceview" displayes an image formed of slices..')
        disp('usage: sliceview(inp, titlename*)')
        return
    case 1
        titlename = 'Unknown';
        sc = 0;
        annots=[];
    case 2
        sc = 0;
        annots=[];
end

if (isa(inp, 'CT'))
    [nrows, ncols,nslice] = size(inp); % take size
    if (sc==0)
        sc(1)= min(inp);
        sc(2)= max(inp);
    end
elseif (iscell(inp))
    nslice =  length(inp);
    [nrows, ncols] = size(inp{1}); % take size
    % convert to 3-d array. It is not the best.
else
    % else do this
    [nrows, ncols, nslice] = size(inp); % take size
    
    if ( islogical(inp))
        inp = uint8(inp);
    else
        if (sc==0)
            sc(1)= min(inp(:));
            sc(2)= max(inp(:));
        end
    end
    
end

disp(strcat('Displaying set of: ', int2str(nslice),' slices')); %Display what you read

fg_hnd =  figure('Visible','off','Position',[0,0,650,650]);  % create a figure, f is the handle
ax_hnd = axes('Units','Pixels','Position',[70,70,512,512]);     % create an axes

st_hnd = uicontrol(fg_hnd,'Style','text','String','Data Set name','Units','Pixels','Position',[20 620 500 30]);     % create and static textbox for filename
slice_txt_hnd = uicontrol(fg_hnd,'Style','text','String','Data Set name','Units','Pixels','Position',[50 600 500 30]); % create a static textbox for slice number

sld_hnd = uicontrol(fg_hnd,'Style','slider','Max',nslice,'Min',1,'Value',1,'SliderStep',...
    [1/(nslice-1) 1/(nslice-1)*20],'Position',[250 20 100 20],'Callback',{@SliceNumberChange_Callback,inp,ax_hnd,slice_txt_hnd,nslice,sc});  %create a slider for the slice manuplation.

% put a name
set(fg_hnd,'Name','Slice View');
% write the name of the file
if(~isempty(titlename))
    set(st_hnd,'String',titlename);
end
% Move the GUI to the center of the screen.
movegui(fg_hnd,'center');
% Make the GUI visible.
set(fg_hnd,'Visible','on');

guidata(fg_hnd,annots);

SliceNumberChange_Callback(sld_hnd,0,inp,ax_hnd,slice_txt_hnd,nslice,sc);




% Slider callback..
function SliceNumberChange_Callback(hObject,eventdata,inpt_img,ax_hndle,txt_hndl, n_slice,clim)
annots = guidata(hObject);
axes(ax_hndle);
s = get(hObject,'value'); % get slider value
s = fix(s);
if ( (s > n_slice) || (s<1) )
    return;
end
set(txt_hndl,'String',strcat(' Slice: ',int2str(s))); % set the textbox filename with slice no;

if (isa(inpt_img, 'CT'))
    slice = getslice(inpt_img,s);
elseif (iscell(inpt_img))
    slice = inpt_img{s};
elseif (isnumeric(inpt_img))
    slice = inpt_img(:,:,s);
end

if (clim ==0 )
    image(slice,'Parent',ax_hndle); %
else
    image(slice,'CDataMapping','scaled', 'Parent',ax_hndle); %
    set(ax_hndle,'CLim',clim);
end

if ~isempty(annots)
    falses = annots.falses;
    trues = annots.trues;
    negatives = annots.negatives;
    
    for i = 1:size(falses, 1)
        sno = falses(i, 3);
        snomax = falses(i, 6);
        if s>=sno && s<=sno+snomax
            %That is a false
            bbx = [falses(i, 1) falses(i, 2) falses(i, 4)+5 falses(i, 5)+5];
            plt = annotation('rectangle', 'Position',bbx, 'FaceColor', 'red', 'FaceAlpha', 0.45);
            set(plt,'parent',ax_hndle);
        end
    end
    
    for i = 1:size(trues, 1)
        sno = trues(i, 3);
        snomax = trues(i, 6);
        if s>=sno && s<=sno+snomax
            %That is a false
            bbx = [trues(i, 1) trues(i, 2) trues(i, 4)+5 trues(i, 5)+5];
            plt = annotation('rectangle', 'Position',bbx, 'FaceColor', 'green', 'FaceAlpha', 0.45);
            set(plt,'parent',ax_hndle);
        end
    end
    
    for i = 1:size(negatives, 1)
        sno = negatives(i, 3);
        snomax = negatives(i, 6);
        if s>=sno && s<=sno+snomax
            %That is a false
            bbx = [negatives(i, 1) negatives(i, 2) negatives(i, 4)+5 negatives(i, 5)+5];
            plt = annotation('rectangle', 'Position',bbx, 'FaceColor', 'blue', 'FaceAlpha', 0.45);
            set(plt,'parent',ax_hndle);
        end
    end
end
impixelinfo(ax_hndle);

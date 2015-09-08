function varargout = randomforest_gui(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @randomforest_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @randomforest_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end
% --- Executes just before randomforest_gui is made visible.
function randomforest_gui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.h5Selected = false;
set(handles.figure1, 'Name', 'Plot Random Forest Results For CT');
guidata(hObject, handles);
end
% --- Outputs from this function are returned to the command line.
function varargout = randomforest_gui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
end


% --- Executes on button press in select_file.
function select_file_Callback(hObject, eventdata, handles)
handles.output = hObject;
cla(handles.axes1,'reset');
[filename, pathname] = uigetfile('*.h5', 'Select H5 File');
if isequal(filename,0)
   disp('User selected Cancel')
else
   [ilastikFileName, ilastikpathname] = uigetfile('*.mat', 'Select ilastik Results File');
   disp(['User selected ilastikfile', fullfile(ilastikpathname, ilastikFileName)])
   disp(['User selected ', fullfile(pathname, filename)])
   random_file = fullfile(pathname, filename);
   ilastik_file = fullfile(ilastikpathname, ilastikFileName);
   obj_RFR = RFR(random_file, ilastik_file);
   handles.obj_RFR = obj_RFR;
   set(handles.var_mult,'string', obj_RFR.var_mult);
   set(handles.var_treecount,'string', obj_RFR.var_treecount);
   set(handles.var_alphastep,'string', obj_RFR.var_alphastep);
   set(handles.var_alphastart,'string', obj_RFR.var_alphastart);
   set(handles.var_alphastop,'string', obj_RFR.var_alphastop);
   set(handles.batch_results, 'String', obj_RFR.batch_results(:,1))
   handles.h5Selected = true;
end
guidata(hObject, handles);
end

% --- Executes on button press in plot_roc_for_avg.
function plot_roc_for_avg_Callback(hObject, eventdata, handles)
handles.output = hObject;
if handles.h5Selected
    axes(handles.axes1);
    cla(handles.axes1,'reset');
    roc_vals = handles.obj_RFR.roc_values;
    roc_vals_ilastik = handles.obj_RFR.ilastik_roc_values;
    hold on;
    plot(roc_vals(1,:), roc_vals(2,:),'--rp', 'LineWidth', 2);
    plot(roc_vals_ilastik(2,:), roc_vals_ilastik(1,:), '-.b', 'LineWidth', 2);
    legend('Random-forest Improvement', 'Ilastik pixel-Classification', 'Location','southeast');
    hold off;
end
guidata(hObject, handles);
end


function plot_roc_for_ilastik_Callback(hObject, eventdata, handles)
handles.output = hObject;
if handles.h5Selected
    axes(handles.axes1);
    roc_vals = handles.obj_RFR.roc_values;
    plot(roc_vals(1,:), roc_vals(2,:),'--rp')
    legend('Random-forest Improvement', 'Location','southeast');
end
guidata(hObject, handles);
end

% --- Executes on button press in plotilastik.
function plotilastik_Callback(hObject, eventdata, handles)
handles.output = hObject;
if handles.h5Selected
    axes(handles.axes1);
    roc_vals = handles.obj_RFR.ilastik_roc_values;
    plot(roc_vals(2,:), roc_vals(1,:),'--rp')
    legend('Ilastik Results', 'Location','southeast');
end
guidata(hObject, handles);
end


% --- Executes on button press in reset_figure.
function reset_figure_Callback(hObject, eventdata, handles)
handles.output = hObject;
axes(handles.axes1);
hold off;
cla(handles.axes1,'reset');
guidata(hObject, handles);
end

% --- Executes on button press in test_dataset.
function test_dataset_Callback(hObject, eventdata, handles)
handles.output = hObject;
num = str2num(get(handles.test_alpha_val,'string'));
index = get(handles.batch_results, 'value');
phi = str2num(get(handles.var_phi, 'string'));
%num is num and in range 0, 1 check them
testAlpha(handles.obj_RFR, index, num, phi);
%rowargmax is the point, 1 = it's background, 2 = it's nodule they said.
end

function var_mult_Callback(hObject, eventdata, handles)
end
function var_mult_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_mult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function var_treecount_Callback(hObject, eventdata, handles)
end
function var_treecount_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function var_alphastep_Callback(hObject, eventdata, handles)
end
function var_alphastep_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function var_alphastart_Callback(hObject, eventdata, handles)
end
function var_alphastart_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function var_alphastop_Callback(hObject, eventdata, handles)
end
function var_alphastop_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in batch_results.
function batch_results_Callback(hObject, eventdata, handles)
end
function batch_results_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function test_alpha_val_Callback(hObject, eventdata, handles)
% hObject    handle to test_alpha_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of test_alpha_val as text
%        str2double(get(hObject,'String')) returns contents of test_alpha_val as a double
end

% --- Executes during object creation, after setting all properties.
function test_alpha_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to test_alpha_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function var_phi_Callback(hObject, eventdata, handles)
% hObject    handle to var_phi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_phi as text
%        str2double(get(hObject,'String')) returns contents of var_phi as a double
end

% --- Executes during object creation, after setting all properties.
function var_phi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_phi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in c_th.
function c_th_Callback(hObject, eventdata, handles)
handles.output = hObject;
set(handles.var_phi, 'String', '0.97');
guidata(hObject, handles);
end
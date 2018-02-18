function varargout = ROISelector_v1(varargin)
% ROISELECTOR_V1 MATLAB code for ROISelector_v1.fig
%      ROISELECTOR_V1, by itself, creates a new ROISELECTOR_V1 or raises the existing
%      singleton*.
%
%      H = ROISELECTOR_V1 returns the handle to a new ROISELECTOR_V1 or the handle to
%      the existing singleton*.
%
%      ROISELECTOR_V1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROISELECTOR_V1.M with the given input arguments.
%
%      ROISELECTOR_V1('Property','Value',...) creates a new ROISELECTOR_V1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROISelector_v1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROISelector_v1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROISelector_v1

% Last Modified by GUIDE v2.5 16-Feb-2018 22:08:13

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROISelector_v1_OpeningFcn, ...
                   'gui_OutputFcn',  @ROISelector_v1_OutputFcn, ...
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


% --- Executes just before ROISelector_v1 is made visible.
function ROISelector_v1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROISelector_v1 (see VARARGIN)




% Run the folder name function if not throw an error
try 
    load('UserFolders.mat')
    handles.data_folder = data_folder ;
    handles.Pdata_folder = Pdata_folder ;
    handles.Path_folder = pathName ;
    
catch error
    errordlg('User folder information was not found please run the GUI Setup')
end


% Adds the path of the analysis functions in case
addpath(genpath(handles.Path_folder))

% Choose default command line output for ROISelector_v1
handles.output = hObject;

%Graphics objects



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ROISelector_v1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ROISelector_v1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in pushbutton7.
% SELECT THE FOLDER CONTAINING DATA
function handles = pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get the foldername
folder_name = uigetdir(handles.data_folder,'Select folder');
handles.foldername = folder_name;

%Updates or creates the text of selected folder on the GUI
if ~isfield(handles,'folderText')
        handles.folderText = text( 0.05,0.5, handles.foldername, ...
            'parent', handles.folderAxes, 'FontSize', 16 );
else
        set( handles.folderText,'String',handles.foldername)
end


guidata(hObject, handles);



% --------------------------------------------------------------------


%  INPUTTING THE IMAGE NUMBER AND UPDATING THE DISPLAY
function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Gets the image number for ROI selection
imageNumber = str2double(get(hObject, 'String'));
handles.imageNumber = imageNumber;

%Converts it to string for display
handles.imageNumberName = sprintf('Image %d',imageNumber);
if ~isfield(handles,'imageNumberText')
       
        handles.imageNumberText = text( 0.05,0.5, handles.imageNumberName, ...
            'parent', handles.imageNumberAxes, 'FontSize', 16 );
else
        set( handles.imageNumberText,'String',handles.imageNumberName)
end


guidata(hObject, handles);





% --- Executes during object creation, after setting all properties.
% Creating the button
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton8.
% Loading image data and previewing the average image
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('Visualizing ROIs')
imageData = ROI_Selector(handles.foldername,handles.imageNumber);
handles.imageData = imageData;
ROI_pre_view(imageData.out, handles)
clear handles.Ratios
msgbox(...
    'Image data is ready,  please select the option you want to use for ROI selection and run selection')


guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function pushbutton8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


%asd 



% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

handles.ROIaxes = gca;
guidata(hObject, handles);



% --- Executes on button press in pushbutton9.
% SAVING DATA BUTTON
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
out = FFFlash_res_display_BG_GUI(handles.Ratios, 2);
save_processed_data_1ch_BG_GUI(out);%
d = dir('_stimulus_*');
fid = fopen(d.name,'r');
currline = fgetl(fid);
ind = strfind(currline,'\');
disp(sprintf('stimulus: %s',currline(ind(end)+1:end)));
fclose(fid);
fprintf('Data successfully saved')

function axes7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.folderAxes = gca;
axis off
% Hint: place code in OpeningFcn to populate axes1
guidata(hObject, handles);
% --- Executes on mouse press over axes background.


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
secondImageNumber = str2double(get(hObject, 'String'));
handles.secondImageNumber = secondImageNumber;

handles.secondImageNumberName = sprintf('Image %d',secondImageNumber);
if ~isfield(handles,'secondImageNumberText')
        
        handles.secondImageNumberText = text( 0.05,0.5, handles.secondImageNumberName, ...
            'parent', handles.secondImageNumberAxes, 'FontSize', 16 );
else
        set( handles.secondImageNumberText,'String',handles.secondImageNumberName)
end
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
secondImageData = ROI_Selector(handles.foldername,handles.secondImageNumber);
clear handles.secondImageData
handles.secondImageData = secondImageData;
maskFileNo = handles.secondImageMaskNumber;
ROI_Show(secondImageData.out, maskFileNo, handles);


guidata(hObject, handles);


% --- Executes on mouse press over axes background.
function axes8_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function axes8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.showAxes = gca;
guidata(hObject, handles);
% Hint: place code in OpeningFcn to populate axes8


% --- Executes during object creation, after setting all properties.
function text7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close([1:20])

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton11.
function pushbutton11_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton13.
% For collecting pData to the pre-defined pData folder
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
collect_pdata_mac_BG_GUI(handles.data_folder, handles.Pdata_folder);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton7.
function pushbutton7_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox1.
% FOR RUNNING AUTO ROIs
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
AutoSelection = get(hObject,'Value');
if AutoSelection
    
    handles.SelectionType = 'Auto';
else
    handles.SelectionType = ''; 
end
guidata(hObject, handles);

% --- Executes on selection change in popupmenu1.
% FOR SELECTING CELL TYPES
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1



% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% FOR IMAGE NUMBER OF APPLYING A PREVIOUS MASK
function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double

try
    handles.previousMaskImage = str2double(get(hObject,'String'));
catch error
    errorMsg = 'Please enter a valid number and try again';
    errdlg(errorMsg)
end
guidata(hObject, handles);
    


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox2.
% MANUAL ROI SELECTION
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
ManualSelection = get(hObject,'Value');
if ManualSelection
    
    handles.SelectionType = 'Manual';
else
    handles.SelectionType = ''; 
end
guidata(hObject, handles);


% --- Executes on button press in pushbutton16.
% TO RUN THE DESIRED ANALYSIS
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


switch handles.SelectionType
    case 'Manual'
        handles.Ratios = ...
            ROI_Analysis_Manual( handles.imageData.out , handles );

    case 'Auto'
        handles.Ratios = ...
            ROI_Analysis_Auto( handles.imageData.out , handles );

    case 'PreviousMask'
        handles.Ratios = ...
            ROI_Analysis_Prev_Mask( handles.imageData.out , handles );

end
guidata(hObject, handles);
       
    

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
PreviousMask = get(hObject,'Value');
if PreviousMask
    
    handles.SelectionType = 'PreviousMask';
else
    handles.SelectionType = ''; 
end
guidata(hObject, handles);


% PREVIOUS MASK IMAGE NUMBER
function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
try
    handles.expectedROInumber = str2double(get(hObject,'String'));
catch error
    errorMsg = 'Please enter a valid number and try again';
    errdlg(errorMsg)
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton17.
% Resets the ROI selection figure
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
reset(handles.ROIaxes);


% --- Executes during object creation, after setting all properties.
% FOR DISPLAYING SELECTED IMAGE NUMBER
function axes9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.imageNumberAxes = gca;
axis off
% Hint: place code in OpeningFcn to populate axes9
guidata(hObject, handles);



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

secondImageMaskNumber = str2double(get(hObject, 'String'));
handles.secondImageMaskNumber = secondImageMaskNumber;
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axes10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

handles.secondImageNumberAxes = gca;
axis off
% Hint: place code in OpeningFcn to populate axes10
guidata(hObject, handles);

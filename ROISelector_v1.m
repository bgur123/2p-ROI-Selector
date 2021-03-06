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

% Last Modified by GUIDE v2.5 14-Nov-2019 10:02:57

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
    errordlg('User folder information was not found... please run the GUI Setup')
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
[a flyNumberName] = fileparts(folder_name);
flyNumberName = strrep(flyNumberName, '_',' ');
%Updates or creates the text of selected folder on the GUI
if ~isfield(handles,'folderText')
        handles.folderText = text( 0.05,0.5, flyNumberName, ...
            'parent', handles.folderAxes, 'FontSize', 16 );
else
        set( handles.folderText,'String',flyNumberName)
end


guidata(hObject, handles);



% --------------------------------------------------------------------

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

%  INPUTTING THE IMAGE NUMBER AND UPDATING THE DISPLAY
function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Gets the image number for ROI selection
imageNumber = str2double(get(hObject, 'String'));
handles.imageNumber = imageNumber;
set(handles.ROIstatusAxes,'Color',[1 0 0])

handles.imageNumberName = sprintf('TSeries-%d',imageNumber);
%Converts it to string for display
if ~isfield(handles,'imageNumberText')
       
        handles.imageNumberText = text( 0.05,0.5, handles.imageNumberName, ...
            'parent', handles.imageNumberAxes, 'FontSize', 16 );
else
        set( handles.imageNumberText,'String',handles.imageNumberName)
end


guidata(hObject, handles);


% --- Executes on button press in pushbutton8.
% Loading image data and previewing the average image
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('Visualizing ROIs')
[imageData, file] = ROI_Selector(handles.foldername,handles.imageNumber);

[~,handles.imageNumberName] = fileparts(file);
handles.seriesPath = file;
handles.imageData = imageData;
ROI_pre_view(imageData.out, handles)
clear handles.ROIdata
set(handles.ROIstatusAxes,'Color',[0 1 0])
set(handles.statusAxes,'Color',[1 0 0])

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function pushbutton8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


%asd 



% --- Executes during object creation, after setting all properties.
% UPPER ROI PLOTTING AXES
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

handles.ROIaxes = gca;
set(gca,'XColor','none','YColor','none','TickDir','out')
grid on;

guidata(hObject, handles);



% --- Executes on button press in pushbutton9.
% SAVING DATA BUTTON
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
out = display_responses(handles.ROIdata, handles);
save_processed_data(out, handles);%
[~,imageID] = fileparts(handles.seriesPath);
fprintf(sprintf('Data successfully saved: %s\n',imageID))

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
guidata(hObject, handles);
set(handles.ROISelstatusAxes,'Color',[1 0 0])
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
set(handles.ROISelstatusAxes,'Color',[0 1 0])
clear handles.secondImageData
handles.secondImageData = secondImageData;
ROI_Show(handles.secondImageData.out, handles.secondImageMaskNumber, handles);


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
set(gca,'XColor','none','YColor','none','TickDir','out')
grid on;
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



% --- Executes on button press in pushbutton16.
% TO RUN THE DESIRED ANALYSIS
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


switch handles.SelectionType
    case 'Manual'
        handles.ROIdata = ...
            ROI_Analysis_Manual( handles.imageData.out , handles );

    case 'Auto Selection'
        handles.ROIdata = ...
            ROI_Analysis_Auto( handles.imageData.out , handles );

    case 'Previous Mask'
        handles.ROIdata = ...
            ROI_Analysis_Prev_Mask( handles.imageData.out , handles );

end
set(handles.statusAxes,'Color',[0 1 0]);
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
cla(handles.ROIaxes)
set(handles.ROIaxes,'XColor','none','YColor','none','TickDir','out')
grid on;
set(handles.ROIstatusAxes,'Color',[1 0 0])

guidata(hObject, handles);


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


% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currentMaskData = ...
            current_mask_data( handles.imageData.out , handles );
        
set(handles.statusAxes,'Color',[0 1 0])

FFFlash_res_display_BG_GUI(handles.currentMaskData, 2, handles);

function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
previous_mask_number_for_ROI_selection = str2double(get(hObject, 'String'));
handles.prevMaskNumROIsel = previous_mask_number_for_ROI_selection;

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double
maskNumberToPlot = str2double(get(hObject, 'String'));
handles.maskNumberToPlot = maskNumberToPlot;

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
% ROI SELECTION
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
contents = cellstr(get(hObject,'String'));
handles.SelectionType = contents{get(hObject,'Value')};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
contents = cellstr(get(hObject,'String'));
handles.SelectionType = contents{get(hObject,'Value')};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
% -- ANALYSIS STATUS FOR PLOTTING
function axes11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.statusAxes = gca;
set(handles.statusAxes,'XColor','none','YColor','none','TickDir','out')
set(handles.statusAxes,'Color',[1 0 0])


guidata(hObject, handles);
% Hint: place code in OpeningFcn to populate axes11


% --- Executes during object creation, after setting all properties.
function axes12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes12
handles.ROIstatusAxes = gca;
set(handles.ROIstatusAxes,'XColor','none','YColor','none','TickDir','out')
set(handles.ROIstatusAxes,'Color',[1 0 0])


guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function axes14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes14
handles.ROISelstatusAxes = gca;
set(handles.ROISelstatusAxes,'XColor','none','YColor','none','TickDir','out')
set(handles.ROISelstatusAxes,'Color',[1 0 0])


guidata(hObject, handles);


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
contents = cellstr(get(hObject,'String'));
handles.FigureType = contents{get(hObject,'Value')};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
contents = cellstr(get(hObject,'String'));
handles.FigureType = contents{get(hObject,'Value')};
guidata(hObject, handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton20.
% VIDEO PLAYER
function pushbutton20_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu4.
% Average image or max image options
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4
contents = cellstr(get(hObject,'String'));
handles.ImageShowType = contents{get(hObject,'Value')};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
contents = cellstr(get(hObject,'String'));
handles.ImageShowType = contents{get(hObject,'Value')};
guidata(hObject, handles);


%  NOT USED ANYMORE
% % --- Executes on button press in pushbutton20.
% function pushbutton20_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton20 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% cd(handles.foldername)
% [handles.video_file_name,handles.ImagePathName] = uigetfile({'*.mp4'},'Select the video file');
% cd(handles.ImagePathName)
% implay(handles.video_file_name)
% 
% guidata(hObject, handles);


% --- Executes on button press in checkbox4.
% To hide ROIs
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
handles.hide_roi = get(hObject,'Value');
if isfield(handles,'secondImageData')
    ROI_Show(handles.secondImageData.out, handles.secondImageMaskNumber, handles);
else
    warning('Second image data is not loaded yet, please first load the second image by selecting an image and mask number and using "Click to view ROIs" button.')
end

guidata(hObject, handles);




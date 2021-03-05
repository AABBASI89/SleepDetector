function varargout = GUI_sleepduration(varargin)
% GUI_SLEEPDURATION MATLAB code for GUI_sleepduration.fig
%      GUI_SLEEPDURATION, by itself, creates a new GUI_SLEEPDURATION or raises the existing
%      singleton*.
%
%      H = GUI_SLEEPDURATION returns the handle to a new GUI_SLEEPDURATION or the handle to
%      the existing singleton*.
%
%      GUI_SLEEPDURATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_SLEEPDURATION.M with the given input arguments.
%
%      GUI_SLEEPDURATION('Property','Value',...) creates a new GUI_SLEEPDURATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_sleepduration_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_sleepduration_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_sleepduration

% Last Modified by GUIDE v2.5 20-Jul-2020 14:46:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_sleepduration_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_sleepduration_OutputFcn, ...
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

% --- Executes just before GUI_sleepduration is made visible.
function GUI_sleepduration_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_sleepduration (see VARARGIN)

% clear command line and workspace
clc; 

% Choose default command line output for GUI_sleepduration
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_sleepduration wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = GUI_sleepduration_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in LoadFile.
function LoadFile_Callback(hObject, eventdata, handles)
% hObject    handle to LoadFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filename;
global folder;
[filename, folder] = uigetfile('*.avi');
set(handles.loadedFile,'String',[folder, filename]);

% --- Executes on button press in DetectMotion.
function DetectMotion_Callback(hObject, eventdata, handles)
% hObject    handle to DetectMotion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filename;
global folder;
global motion;
global status;
filepath = [folder, filename];

% Create a progress bar
status = waitbar(0,'Start...');

% Read a video in an object
vR = VideoReader(filepath);
waitbar(0.01,status,'Start...');

% Read all frames from the video object
% frames = read(vR);
k = 1;
while hasFrame(vR)
    frames(:,:,k) = squeeze(mean(readFrame(vR),3));
    waitbar(0.00002*k,status,'Reading frames...');
    k = k+1;
end

% Convert into greyscale
% frames = squeeze(mean(frames,3));
% waitbar(0.01,status,'Detecting motion...');

% Detect motion  
motion = zeros(1,size(frames,3)-1);
for i = 1:size(frames,3)-1
  waitbar(0.0002*i,status,'Detecting motion...');
  frame1 = frames(:,:,i);
  frame2 = frames(:,:,i+1);
  subtracted_img = imsubtract(uint8(frame2),uint8(frame1));
  motion(i) = mean(mean(subtracted_img));
end
waitbar(1,status,'Done');
axes(handles.MotionPlot);
plot(motion);
clear frames;

% --- Executes on button press in GetSleepDur.
function GetSleepDur_Callback(hObject, eventdata, handles)
% hObject    handle to GetSleepDur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filename;
global folder;
global motion;
global threshold;
global status;
if ishandle(status)
  delete(status);
end
threshold = str2double(get(handles.threshold, 'String'));
sleepDur = length(find(motion < threshold))/60;
disp(['Total Sleep Duration (min) ', num2str(sleepDur)]);
set(handles.SleepDuration,'String', num2str(sleepDur));
save([folder, filename(1:end-4),'.mat'], 'motion','sleepDur');

function loadedFile_Callback(hObject, eventdata, handles)
% hObject    handle to loadedFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loadedFile as text
%        str2double(get(hObject,'String')) returns contents of loadedFile as a double

% --- Executes during object creation, after setting all properties.
function loadedFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadedFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function threshold_Callback(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold as text
%        str2double(get(hObject,'String')) returns contents of threshold as a double
global threshold;
threshold = str2num(get(hObject,'String'));
disp(['Detection Threshold ', num2str(threshold)]);


% --- Executes during object creation, after setting all properties.
function threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SleepDuration_Callback(hObject, eventdata, handles)
% hObject    handle to SleepDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SleepDuration as text
%        str2double(get(hObject,'String')) returns contents of SleepDuration as a double

% --- Executes during object creation, after setting all properties.
function SleepDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SleepDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

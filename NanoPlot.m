function varargout = NanoPlot(varargin)
% NANOPLOT MATLAB code for NanoPlot.fig
%      NANOPLOT, by itself, creates a new NANOPLOT or raises the existing
%      singleton*.
%
%      H = NANOPLOT returns the handle to a new NANOPLOT or the handle to
%      the existing singleton*.
%
%      NANOPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NANOPLOT.M with the given input arguments.
%
%      NANOPLOT('Property','Value',...) creates a new NANOPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NanoPlot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NanoPlot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NanoPlot

% Last Modified by GUIDE v2.5 12-Jul-2022 10:20:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NanoPlot_OpeningFcn, ...
                   'gui_OutputFcn',  @NanoPlot_OutputFcn, ...
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



function NanoPlot_OpeningFcn(hObject, eventdata, handles, varargin)
    
    handles.AfmData = cell(1);
    handles.FileNameList = cell(1);
    
    handles.HertzBoxplotOriginalSize = get(handles.CHertzBoxPlot, 'Position');
    handles.SneddonBoxplotOriginalSize = get(handles.CSneddonBoxPlot, 'Position');
            
    handles.DataSelection = 1;
    
    handles.Processed = 0;
    handles.Unprocessed = 0;
    handles.Total = 0;
    
    handles.CtrlButtonDown = 0;
    
    UpdateDeflectionPlot(hObject, handles);
    UpdateIndentationPlot(hObject, handles);
    UpdateBoxPlot(hObject, handles);
 
handles.output = hObject;
guidata(hObject, handles);

% UIWAIT makes NanoPlot wait for user response (see UIRESUME)
% uiwait(handles.MainWindow);

function varargout = NanoPlot_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


 function UpdateDeflectionPlot(object, handles)
 
    hold(handles.DeflectionPlot,'on');
    cla(handles.DeflectionPlot); 
    
    if ~isempty(handles.AfmData)
        NewPosition = get(handles.FileList,'Value');
        if ~cellfun('isempty', handles.AfmData(NewPosition))
            
            plot(handles.DeflectionPlot, ...
                 handles.AfmData{NewPosition}.Z, ... 
                 handles.AfmData{NewPosition}.DefErr, ...
                 'LineWidth',2);
 
            if ~isempty(handles.AfmData{NewPosition}.ContactPointIdx)
                ContactPointIdx = handles.AfmData{NewPosition}.ContactPointIdx;
                a = handles.AfmData{NewPosition}.Z(ContactPointIdx);
                b = handles.AfmData{NewPosition}.DefErr(ContactPointIdx);
                text(  0.5 , 0.8 ,[ '[ ' num2str(a,3) ' ,' num2str(b,3) ' ]' ],...
                    'Units','normalized',...
                    'HorizontalAlignment','center',...
                    'VerticalAlignment','bottom',...
                    'FontSize',12,...
                    'Parent',handles.DeflectionPlot);
                
                plot(handles.DeflectionPlot, ...
                     handles.AfmData{NewPosition}.Z(ContactPointIdx), ...
                     handles.AfmData{NewPosition}.DefErr(ContactPointIdx), ...
                     'ro', ...
                     'LineWidth',2);
            end
            
            
            if get(handles.ZMinFlag, 'Value') == 0
                xlim(handles.DeflectionPlot, ...
                     [handles.AfmData{NewPosition}.Z(1)
                      handles.AfmData{NewPosition}.Z(end)]);
            else
                my_min = str2double(get(handles.ZMinValue,'String'));
                xlim(handles.DeflectionPlot, ...
                     [(my_min/100)*handles.AfmData{NewPosition}.Z(end) 
                      handles.AfmData{NewPosition}.Z(end) ] );
            end

            ylim(handles.DeflectionPlot, ...
                [ min(handles.AfmData{NewPosition}.DefErr) - 0.1
                  max(handles.AfmData{NewPosition}.DefErr) + 0.1 ]);
            
        end
    end
    
    set(handles.DeflectionPlot,'FontSize',12);
    set(handles.DeflectionPlot,'XTickMode','auto','YTickMode','auto');
    set(handles.DeflectionPlot,'XTickLabelMode','auto','YTickLabelMode','auto');
    set(handles.DeflectionPlot,'XGrid','on','YGrid','on');
    ylabel(handles.DeflectionPlot, 'Deflection error [V]');
    xlabel(handles.DeflectionPlot, 'Z - height [nm]');
    hold(handles.DeflectionPlot,'off');
  
    
 function UpdateIndentationPlot(object, handles)
    
    hold(handles.HertzPlot,'on');
    hold(handles.SneddonPlot,'on');
    cla(handles.HertzPlot); 
    cla(handles.SneddonPlot); 
    
    if ~isempty(handles.AfmData)
        
        NewPosition = get(handles.FileList,'Value');
        
        if  ~cellfun('isempty', handles.AfmData(NewPosition))

            if  (~isempty(handles.AfmData{NewPosition}.ContactPointIdx) && ...
                 ~isempty(handles.AfmData{NewPosition}.Indentation) && ...
                 ~isempty(handles.AfmData{NewPosition}.HertzFit) && ...   
                 ~isempty(handles.AfmData{NewPosition}.HertzModulus) && ...
                 ~isempty(handles.AfmData{NewPosition}.SneddonFit) && ...
                 ~isempty(handles.AfmData{NewPosition}.SneddonModulus) )
             
                DataSelection = handles.DataSelection; 
                
                plot(handles.HertzPlot, ...
                     handles.AfmData{NewPosition}.Indentation, ...
                     handles.AfmData{NewPosition}.Force, ...
                     'b-', ...
                     handles.AfmData{NewPosition}.Indentation, ...
                     handles.AfmData{NewPosition}.HertzFit(DataSelection,1)*handles.AfmData{NewPosition}.Indentation.^(3/2), ...
                     'r-', ...
                     'LineWidth',2, ...
                     'ButtonDownFcn',{@HertzPlot_ButtonDownFcn, handles});

                xlim(handles.HertzPlot, ....
                     [min(handles.AfmData{NewPosition}.Indentation) 
                      max(handles.AfmData{NewPosition}.Indentation)]);
                
                ylim(handles.HertzPlot, ...
                     [min(handles.AfmData{NewPosition}.Force)
                      max(handles.AfmData{NewPosition}.Force)]);

                text(  0.05, 0.75, ['R2 ' '    ' num2str(handles.AfmData{NewPosition}.HertzFit(DataSelection,2),3)] ,...
                    'Units','normalized',...
                    'HorizontalAlignment','left',...
                    'VerticalAlignment','top',...
                    'FontWeight','normal',...
                    'Color',[1 0 0],...
                    'Parent',handles.HertzPlot,...
                    'FontSize',8);

                text(  0.05, 0.85, ['RMSE ' num2str(handles.AfmData{NewPosition}.HertzFit(DataSelection,3),3)] ,...
                    'Units','normalized',...
                    'HorizontalAlignment','left',...
                    'VerticalAlignment','top',...
                    'FontWeight','normal',...
                    'Color',[1 0 0],...
                    'Parent',handles.HertzPlot,...
                    'FontSize',8);
                
                 if DataSelection == 1
                    str = 'total';
                 else
                    str = num2str(DataSelection-1);
                 end
                 
                 text(  0.05, 0.95, ['Eh ' str '    ' num2str(handles.AfmData{NewPosition}.HertzModulus(DataSelection),4) ' kPa'] ,...
                        'Units','normalized',...
                        'HorizontalAlignment','left',...
                        'VerticalAlignment','top',...
                        'FontWeight','normal',...
                        'Color',[1 0 0],...
                        'Parent',handles.HertzPlot,...
                        'FontSize',8);

                plot(handles.SneddonPlot, ...
                     handles.AfmData{NewPosition}.Indentation, ...
                     handles.AfmData{NewPosition}.Force, ...
                     'b-', ...
                     handles.AfmData{NewPosition}.Indentation, ...
                     handles.AfmData{NewPosition}.SneddonFit(DataSelection,1)*handles.AfmData{NewPosition}.Indentation.^2, ...
                     'r-', ...
                     'LineWidth',2, ...
                     'ButtonDownFcn',{@SneddonPlot_ButtonDownFcn, handles});

                xlim(handles.SneddonPlot, ...
                    [min(handles.AfmData{NewPosition}.Indentation)
                     max(handles.AfmData{NewPosition}.Indentation)]);
                
                ylim(handles.SneddonPlot, ...
                    [min(handles.AfmData{NewPosition}.Force)
                     max(handles.AfmData{NewPosition}.Force)]);
                
                text(  0.05, 0.75, ['R2 ' '    ' num2str(handles.AfmData{NewPosition}.SneddonFit(DataSelection,2),3)] ,...
                    'Units','normalized',...
                    'HorizontalAlignment','left',...
                    'VerticalAlignment','top',...
                    'FontWeight','normal',...
                    'Color',[1 0 0],...
                    'Parent',handles.SneddonPlot,...
                    'FontSize',8);

                text(  0.05, 0.85, ['RMSE ' num2str(handles.AfmData{NewPosition}.SneddonFit(DataSelection,3),3)] ,...
                    'Units','normalized',...
                    'HorizontalAlignment','left',...
                    'VerticalAlignment','top',...
                    'FontWeight','normal',...
                    'Color',[1 0 0],...
                    'Parent',handles.SneddonPlot,...
                    'FontSize',8);

                 % str = 'total';
                 text(  0.05, 0.95, ['Es ' str '    ' num2str(handles.AfmData{NewPosition}.SneddonModulus(DataSelection),4) ' kPa'] ,...
                    'Units','normalized',...
                    'HorizontalAlignment','left',...
                    'VerticalAlignment','top',...
                    'FontWeight','normal',...
                    'Color',[1 0 0],...
                    'Parent',handles.SneddonPlot,...
                    'FontSize',8);
            else
                 text(  0.05, 0.95, ['Corrupted data'] ,...
                    'Units','normalized',...
                    'HorizontalAlignment','left',...
                    'VerticalAlignment','top',...
                    'FontWeight','normal',...
                    'Color',[1 0 0],...
                    'Parent',handles.SneddonPlot,...
                    'FontSize',8);
                
                     text(  0.05, 0.95, ['Corrupted data'] ,...
                    'Units','normalized',...
                    'HorizontalAlignment','left',...
                    'VerticalAlignment','top',...
                    'FontWeight','normal',...
                    'Color',[1 0 0],...
                    'Parent',handles.HertzPlot,...
                    'FontSize',8);
            end
        end                
    end
    
    set(handles.HertzPlot,'FontSize',12);
    set(handles.HertzPlot,'XTickMode','auto','YTickMode','auto');
    set(handles.HertzPlot,'XTickLabelMode','auto','YTickLabelMode','auto');
    set(handles.HertzPlot,'XGrid','on','YGrid','on');
    ylabel(handles.HertzPlot, 'Force [nN]');
    xlabel(handles.HertzPlot, 'Indentation [nm]');
    title(handles.HertzPlot, 'Hertz model');
    

    set(handles.SneddonPlot,'FontSize',12);
    set(handles.SneddonPlot,'XTickMode','auto','YTickMode','auto');
    set(handles.SneddonPlot,'XTickLabelMode','auto','YTickLabelMode','auto');
    set(handles.SneddonPlot,'XGrid','on','YGrid','on');
    ylabel(handles.SneddonPlot, 'Force [nN]');
    xlabel(handles.SneddonPlot, 'Indentation [nm]');
    title(handles.SneddonPlot, 'Sneddon model');
    
hold(handles.HertzPlot,'off');
hold(handles.SneddonPlot,'off');



function MainWindow_WindowButtonDownFcn(hObject, eventdata, handles)
     MousePosition = get(handles.DeflectionPlot, 'CurrentPoint');
     ErrorCode = 0;
     
     if ~isempty(handles.AfmData)
        NewPosition = get(handles.FileList,'Value');
        if ~cellfun('isempty', handles.AfmData(NewPosition))

            if MousePosition(1,1) > handles.AfmData{NewPosition}.ZMin && ...
               MousePosition(1,1) < handles.AfmData{NewPosition}.ZMax && ...
               MousePosition(1,2) > handles.AfmData{NewPosition}.DefErrMin && ...
               MousePosition(1,2) < handles.AfmData{NewPosition}.DefErrMax
                
                [C, I] = min ( abs(handles.AfmData{NewPosition}.Z - MousePosition(1,1)) );
                if  MousePosition(1,2) < (handles.AfmData{NewPosition}.DefErr(I)+5) && ...
                    MousePosition(1,2) > (handles.AfmData{NewPosition}.DefErr(I)-5)
                   
                    b = get(hObject,'selectiontype');
                    if strcmpi(b,'normal')
                         
                        if I < length(handles.AfmData{NewPosition}.DefErr) - 10
                                                        
                            if isempty(handles.AfmData{NewPosition}.ContactPointIdx)
                                handles.FileNameList{NewPosition} = ['<html><div style="color:black">' handles.AfmData{NewPosition}.FileName ' '];
                                set(handles.FileList,'String',char(handles.FileNameList));
                            end
                            
                            handles.AfmData{NewPosition}.ContactPointIdx = I;
                            DefErrBL = BaseLineCorrection(handles.AfmData{NewPosition});
                            handles.AfmData{NewPosition}.DefErrBL = DefErrBL;
                
                            [ Settings ] = GetInputData(handles);
                            [Indentation Force] = UpdateIndentationData(handles.AfmData{NewPosition}, Settings);
                            handles.AfmData{NewPosition}.Indentation = Indentation;
                            handles.AfmData{NewPosition}.Force = Force;
                            [handles.AfmData{NewPosition} ErrorCode] = FitData(handles.AfmData{NewPosition}, Settings); 
                                   
                        end
                        
                    elseif strcmpi(b,'alt')

                        handles.AfmData{NewPosition}.ContactPointIdx = [];
                        handles.AfmData{NewPosition}.DefErrBL = handles.AfmData{NewPosition}.DefErr; 
                        
                        handles.FileNameList{NewPosition} = ['<html><div style="color:red">' handles.AfmData{NewPosition}.FileName ' '];
                        set(handles.FileList,'String',char(handles.FileNameList));

                        handles.AfmData{NewPosition}.Indentation = [];
                        handles.AfmData{NewPosition}.Force = [];
                        handles.AfmData{NewPosition}.HertzModulus = [];
                        handles.AfmData{NewPosition}.HertzFit = [];
                        handles.AfmData{NewPosition}.SneddonModulus = [];
                        handles.AfmData{NewPosition}.SneddonFit = [];

                        UpdateListInfo(hObject, handles);
                    else
                    
                    end
                    handles.DataSelection = 1;
                    UpdateListInfo(hObject, handles);
                    UpdateDeflectionPlot(hObject, handles);
                    UpdateIndentationPlot(hObject, handles);
                    UpdateTable(hObject, eventdata, handles);
               end
            end
        end
     end
    guidata(hObject, handles); 

function MainWindow_WindowScrollWheelFcn(hObject, eventdata, handles)
    
    ErrorCode = 0;
    MousePosition = get(handles.DeflectionPlot, 'CurrentPoint'); 
    
    if ~isempty(handles.AfmData)
        NewPosition = get(handles.FileList,'Value');
        if ~cellfun('isempty', handles.AfmData(NewPosition))
            if ~isempty(handles.AfmData{NewPosition}.ContactPointIdx)

                if MousePosition(1,1) > handles.AfmData{NewPosition}.ZMin && ...
                   MousePosition(1,1) < handles.AfmData{NewPosition}.ZMax && ...
                   MousePosition(1,2) > handles.AfmData{NewPosition}.DefErrMin && ...
                   MousePosition(1,2) < handles.AfmData{NewPosition}.DefErrMax
               
                    I = handles.AfmData{NewPosition}.ContactPointIdx + eventdata.VerticalScrollCount*(-1);
                    if I < length(handles.AfmData{NewPosition}.DefErr) - 10
                                                        
                            if isempty(handles.AfmData{NewPosition}.ContactPointIdx)
                                handles.FileNameList{NewPosition} = ['<html><div style="color:black">' handles.AfmData{NewPosition}.FileName ' '];
                                set(handles.FileList,'String',char(handles.FileNameList));
                            end
                            
                            handles.AfmData{NewPosition}.ContactPointIdx = I;
                            DefErrBL = BaseLineCorrection(handles.AfmData{NewPosition});
                            handles.AfmData{NewPosition}.DefErrBL = DefErrBL;
                
                            [ Settings ] = GetInputData(handles);
                            [Indentation Force] = UpdateIndentationData(handles.AfmData{NewPosition}, Settings);
                            handles.AfmData{NewPosition}.Indentation = Indentation;
                            handles.AfmData{NewPosition}.Force = Force;
                            [handles.AfmData{NewPosition} ErrorCode] = FitData(handles.AfmData{NewPosition}, Settings); 

                            handles.DataSelection = 1;
                            UpdateDeflectionPlot(hObject, handles);
                            UpdateIndentationPlot(hObject, handles);
                            UpdateTable(hObject, eventdata, handles);
                                   
                    end
                end
            end
        end
    end
guidata(hObject, handles);          


function FileList_Callback(hObject, eventdata, handles)
    
    handles.DataSelection = 1;
    UpdateDeflectionPlot(hObject, handles);
    UpdateIndentationPlot(hObject, handles);
    UpdateTable(hObject, eventdata, handles);
    
guidata(hObject, handles);


function FileList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddFile.
function AddFile_Callback(hObject, eventdata, handles)
    
    ErrorCode = 0; 
    [FileName,PathName,FileFilter] = uigetfile('*.txt','Select the MATLAB code file','Multiselect','on');
    
    if FileFilter>0
        h = waitbar(0,'Processing data...'); 
        
        if iscell(FileName)
            FileNum = size(FileName,2);
        else
            FileNum = 1; 
        end
        
        for ii=1:FileNum
            
            if FileNum == 1
                NewFileName = FileName;
                NewPathName = PathName;
            else
                NewFileName = FileName{ii};
                NewPathName = PathName;
            end
            
            NewData = [];
            try
                NewData = ReadAFMData( strcat(NewPathName,NewFileName) );
            catch
                NewData = [];
            end
            
            SlotIndex = 0;
            
            if ~isempty(NewData)
                if ~isempty(handles.AfmData)
                    if cellfun('isempty', handles.AfmData(end,1))
                        SlotIndex = length(handles.AfmData(:,1));
                    else
                       SlotIndex = length(handles.AfmData(:,1)) + 1;
                    end
                else
                    SlotIndex = 1;
                end
                Data.FileName = NewFileName;
                Data.FilePath = NewPathName;
                Data.Z = NewData(:,1);
                Data.DefErr = NewData(:,2);
                
                Data.ZMin = min(Data.Z);
                Data.ZMax = max(Data.Z);
                
                Data.DefErrMin = min(Data.DefErr);
                Data.DefErrMax = max(Data.DefErr);
                
                Data.DefErrBL = NewData(:,2);
                Data.ContactPoint = [];
                Data.ContactPointIdx = [];
                Data.Indentation = [];
                Data.Force = [];
                Data.SneddonModulus = [];
                Data.SneddonFit = [];
                Data.HertzModulus = [];
                Data.HertzFit = [];
                
                handles.FileNameList{SlotIndex} = ['<html><div style="color:red">' NewFileName ' '];
                
                ContactPointIdx = GetIndentationPoint(Data.DefErr);
                Data.ContactPointIdx = ContactPointIdx;
                
                DefErrBL = BaseLineCorrection(Data);
                Data.DefErrBL = DefErrBL;
                
                if ~isempty(Data.ContactPointIdx)

                    [ Settings ] = GetInputData(handles);
                    [Indentation Force] = UpdateIndentationData(Data, Settings);
                    Data.Indentation = Indentation;
                    Data.Force = Force;
                    
                    [Data ErrorCode] = FitData(Data, Settings); 
                    
                    if ErrorCode == -1
                        Data.ContactPointIdx = [];
                        waitbar(ii/FileNum,h,'Error while processing data...');
                    else
                        handles.FileNameList{SlotIndex} = ['<html><div style="color:black">' NewFileName ' '];
                        set(handles.FileList,'String',char(handles.FileNameList));
                    end

                end       
                handles.AfmData{SlotIndex,1} = Data;
            end
            waitbar(ii/FileNum,h,'Processing data...'); 
        end
                   
        NewPosition = length(handles.AfmData);

        handles.DataSelection = 1;
        set(handles.FileList,'Value',NewPosition);
        set(handles.FileList,'String',char(handles.FileNameList));
        UpdateListInfo(hObject, handles);                
        UpdateDeflectionPlot(hObject, handles);
        UpdateIndentationPlot(hObject, handles);
        UpdateTable(hObject, eventdata, handles);
        close(h);
    end
guidata(hObject, handles);


                    
function RemoveFile_Callback(hObject, eventdata, handles)
    
    CurrentPosition = get(handles.FileList,'Value');
    if ~isempty(handles.AfmData)
        if ~cellfun('isempty', handles.AfmData(CurrentPosition))
            
            handles.AfmData(CurrentPosition) = [];
            handles.FileNameList(CurrentPosition) = [];
            
            set(handles.FileList,'String',char(handles.FileNameList));
            if ~isempty(handles.AfmData)
                NewLength = length(handles.FileNameList);
                if CurrentPosition > NewLength
                    set(handles.FileList,'Value',NewLength);
                else
                    if CurrentPosition == 1
                        set(handles.FileList,'Value',1);
                    elseif CurrentPosition > 1
                        set(handles.FileList,'Value',CurrentPosition-1);
                    end
                end
            else
                set(handles.FileList,'Value',1)
            end
        end
    end
    handles.DataSelection = 1;
    UpdateListInfo(hObject, handles);
    UpdateDeflectionPlot(hObject, handles);
    UpdateIndentationPlot(hObject, handles);
    UpdateTable(hObject, eventdata, handles);
guidata(hObject, handles);


                    

                    
                    

function CDeflectionSensitivity_Callback(hObject, eventdata, handles)

    h = waitbar(0,'Processing data...'); 
    ErrorCode = 0;
    [Settings] = GetInputData(handles);
    
    if Settings.DefSens <= 0 
        Settings.DefSens = 1;
        set(hObject,'String', num2str(Settings.DefSens));
    end
    
    if ~isempty(handles.AfmData)
        if ~cellfun('isempty', handles.AfmData(1))
            ln = length(handles.AfmData);
            for ii=1:ln
                if ~cellfun('isempty', handles.AfmData(ii))
                    if ~isempty(handles.AfmData{ii}.ContactPointIdx)
                        [Indetation Force] = UpdateIndentationData(handles.AfmData{ii}, Settings);
                        handles.AfmData{ii}.Indetation = Indetation;
                        handles.AfmData{ii}.Force = Force;
                        [handles.AfmData{ii} ErrorCode] = FitData(handles.AfmData{ii}, Settings);
                    end
                end
                waitbar(ii/ln,h,'Processing data...');
            end
        end
    end
    close(h);
    
    handles.DataSelection = 1;
    UpdateIndentationPlot(hObject, handles);
    UpdateTable(hObject, eventdata, handles);
    guidata(hObject, handles);
 

    
function CDeflectionSensitivity_CreateFcn(hObject, eventdata, handles)
    set(hObject,'String',num2str(1));
 if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor','white');
end



function CProbeK_Callback(hObject, eventdata, handles)
    
    h = waitbar(0,'Processing data...'); 
    ErrorCode = 0;
    [Settings] = GetInputData(handles);
    
    if Settings.CantStiff <= 0 
        Settings.CantStiff = 1;
        set(hObject,'String', num2str(Settings.CantStiff));
    end
    
    if ~isempty(handles.AfmData)
        if ~cellfun('isempty', handles.AfmData(1))
            ln = length(handles.AfmData(:));
            for ii=1:ln
                if ~cellfun('isempty', handles.AfmData(ii))
                    if ~isempty(handles.AfmData{ii}.ContactPointIdx)
                        [Indetation Force] = UpdateIndentationData(handles.AfmData{ii}, Settings);
                        handles.AfmData{ii}.Indetation = Indetation;
                        handles.AfmData{ii}.Force = Force;
                        [handles.AfmData{ii} ErrorCode] = FitData(handles.AfmData{ii}, Settings); 
                    end
                end
                waitbar(ii/ln,h,'Processing data...');
            end
            
        end
    end
    close(h);
   
    handles.DataSelection = 1;
    UpdateIndentationPlot(hObject, handles);
    UpdateTable(hObject, eventdata, handles);
    guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function CProbeK_CreateFcn(hObject, eventdata, handles)
    set(hObject,'String',num2str(1));
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ClearAll.
function ClearAll_Callback(hObject, eventdata, handles)
    Clear = questdlg('Clear all data ?', ...
                'AFM Data', ...
                'Yes','No','Yes');
            switch Clear
                case 'Yes'  
                    handles.AfmData = [];
                    handles.FileNameList = [];
                    set(handles.FileList,'String','');
                    set(handles.FileList,'Value',1);
     
                    UpdateListInfo(hObject, handles);
                    UpdateDeflectionPlot(hObject, handles);
                    UpdateIndentationPlot(hObject, handles);
                    UpdateBoxPlot(hObject, handles);
                    UpdateTable(hObject, eventdata, handles);
                    handles.DataSelection = 1;
                    
                case 'No'
                    
            end
            
     
 guidata(hObject, handles);


    
    
 OutputData.SneddonModulus = [];
    OutputData.SneddonFit = [];
    
function CTipRadius_Callback(hObject, eventdata, handles)
    
    h = waitbar(0,'Processing data...'); 
    ErrorCode = 0;
    
    [Settings] = GetInputData(handles);
    if Settings.TipRadius <= 0 
        Settings.TipRadius = 1;
        set(hObject,'String', num2str(Settings.TipRadius));
    end
    
    Ch = 4*sqrt(Settings.TipRadius)/(3*(1-Settings.Mu^2));
    Cs = 2*tan(Settings.Alpha*pi/180)/(pi*(1-Settings.Mu^2));   
    
    if ~isempty(handles.AfmData)
        if ~cellfun('isempty', handles.AfmData(1))
            ln = length(handles.AfmData(:,1));
            for ii=1:ln
                if ~cellfun('isempty', handles.AfmData(ii))
                    if ~isempty(handles.AfmData{ii}.ContactPointIdx)
                        
                        if ~isempty(handles.AfmData{ii}.SneddonFit)
                            for jj=1:length(handles.AfmData{ii}.SneddonModulus)
                                handles.AfmData{ii}.SneddonModulus(jj) = (handles.AfmData{ii}.SneddonFit(jj,1) / Cs) / 0.000001;
                            end
                        end

                        if ~isempty(handles.AfmData{ii}.HertzFit)
                            for jj=1:length(handles.AfmData{ii}.HertzModulus)
                                handles.AfmData{ii}.HertzModulus(jj) = (handles.AfmData{ii}.HertzFit(jj,1) / Ch) / 0.000001;
                            end
                        end

                    end
                end
                waitbar(ii/ln,h,'Processing data...');
            end
        end
    end
    close(h)
    handles.DataSelection = 1;
    UpdateIndentationPlot(hObject, handles);
    UpdateTable(hObject, eventdata, handles);
 guidata(hObject, handles);

    
    
    
function CTipRadius_CreateFcn(hObject, eventdata, handles)
set(hObject,'String','0.01');
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CMu_Callback(hObject, eventdata, handles)
    
    h = waitbar(0,'Processing data...'); 
    ErrorCode = 0;
    [Settings] = GetInputData(handles);
    
    if Settings.Mu <= 0 
        Settings.Mu = 0.1;
        set(hObject,'String', num2str(Settings.Mu));
    elseif Settings.Mu > 0.5
        Settings.Mu = 0.499;
        set(hObject,'String', num2str(Settings.Mu));
    end
        
    Ch = 4*sqrt(Settings.TipRadius)/(3*(1-Settings.Mu^2));
    Cs = 2*tan(Settings.Alpha*pi/180)/(pi*(1-Settings.Mu^2));   
    
    if ~isempty(handles.AfmData)
        if ~cellfun('isempty', handles.AfmData(1))
            ln = length(handles.AfmData(:,1));
            for ii=1:ln
                if ~cellfun('isempty', handles.AfmData(ii))
                    if ~isempty(handles.AfmData{ii}.ContactPointIdx)
                        
                        if ~isempty(handles.AfmData{ii}.SneddonFit)
                            for jj=1:length(handles.AfmData{ii}.SneddonModulus)
                                handles.AfmData{ii}.SneddonModulus(jj) = (handles.AfmData{ii}.SneddonFit(jj,1) / Cs) / 0.000001;
                            end
                        end

                        if ~isempty(handles.AfmData{ii}.HertzFit)
                            for jj=1:length(handles.AfmData{ii}.HertzModulus)
                                handles.AfmData{ii}.HertzModulus(jj) = (handles.AfmData{ii}.HertzFit(jj,1) / Ch) / 0.000001;
                            end
                        end

                    end
                end
                waitbar(ii/ln,h,'Processing data...');
            end
        end
    end
    close(h);
    handles.DataSelection = 1;
    UpdateIndentationPlot(hObject, handles);
    UpdateTable(hObject, eventdata, handles);
 guidata(hObject, handles);
    
    
    
function CMu_CreateFcn(hObject, eventdata, handles)
set(hObject,'String','0.3');
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CAlpha_Callback(hObject, eventdata, handles)
     
    h = waitbar(0,'Processing data...');     
    [Settings] = GetInputData(handles);
    if Settings.Alpha <= 0 
        Settings.Alpha = 0.1;
        set(hObject,'String', num2str(Settings.Alpha));
    elseif Settings.Alpha > 90
        Settings.Alpha = 90;
        set(hObject,'String', num2str(Settings.Alpha));
    end
            
    Ch = 4*sqrt(Settings.TipRadius)/(3*(1-Settings.Mu^2));
    Cs = 2*tan(Settings.Alpha*pi/180)/(pi*(1-Settings.Mu^2));   
    
    if ~isempty(handles.AfmData)
        if ~cellfun('isempty', handles.AfmData(1))
            ln = length(handles.AfmData(:,1));
            for ii=1:ln
                if ~cellfun('isempty', handles.AfmData(ii))
                    if ~isempty(handles.AfmData{ii}.ContactPointIdx)
                        
                        if ~isempty(handles.AfmData{ii}.SneddonFit)
                            for jj=1:length(handles.AfmData{ii}.SneddonModulus)
                                handles.AfmData{ii}.SneddonModulus(jj) = (handles.AfmData{ii}.SneddonFit(jj,1) / Cs) / 0.000001;
                            end
                        end

                        if ~isempty(handles.AfmData{ii}.HertzFit)
                            for jj=1:length(handles.AfmData{ii}.HertzModulus)
                                handles.AfmData{ii}.HertzModulus(jj) = (handles.AfmData{ii}.HertzFit(jj,1) / Ch) / 0.000001;
                            end
                        end
                        
                    end
                end
                waitbar(ii/ln,h,'Processing data...');
            end
        end
    end
    close(h);
    
    handles.DataSelection = 1;
    UpdateIndentationPlot(hObject, handles);
    UpdateTable(hObject, eventdata, handles);
 guidata(hObject, handles);

 
function CAlpha_CreateFcn(hObject, eventdata, handles)
set(hObject,'String','30');
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function AddFile_CreateFcn(hObject, eventdata, handles)
%tooltip = '<html>HTML-aware<br><b>tooltips</b><br><i>supported';
%labelTop= '<HTML><center><FONT color="red">Hello</Font> <b>world</b>';
%labelBot=['<div style="font-family:impact;color:green"><i>What a</i>'...
%          ' <Font color="blue" face="Comic Sans MS">nice day!'];
%set(hObject, 'tooltip',tooltip, 'string',[labelTop '<br>' labelBot]);


% --- Executes on button press in CNext.
function CNext_Callback(hObject, eventdata, handles)
    if ~isempty(handles.AfmData)
        if ~cellfun('isempty', handles.AfmData(1))
            CurrentPosition = get(handles.FileList,'Value');
            NewPosition = CurrentPosition+1;
            ln = length(handles.AfmData);
            if NewPosition > ln
                NewPosition = ln;
            end
            set(handles.FileList,'Value',NewPosition);
            FileList_Callback(hObject, eventdata, handles);
        end
    end
guidata(hObject, handles); 
    


% --- Executes on button press in CPrevious.
function CPrevious_Callback(hObject, eventdata, handles)
    if ~isempty(handles.AfmData)
        if ~cellfun('isempty', handles.AfmData(1))
            CurrentPosition = get(handles.FileList,'Value');
            NewPosition = CurrentPosition-1;
            if NewPosition < 1
                NewPosition = 1;
            end
            set(handles.FileList,'Value',NewPosition);
            FileList_Callback(hObject, eventdata, handles);
        end
    end
guidata(hObject, handles); 


% --------------------------------------------------------------------
function CExport_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function CAbout_Callback(hObject, eventdata, handles)

 L =  strcat('Copyright 2021 Piotr Pieczywek', 10, ...
             'p.pieczywek@ipan.lublin.pl', 10, 10,...
             'Institute of Agropgysics, Polish Academy of Sciences', 10, ...
             'https://www.ipan.lublin.pl/', 10, 10, ...
             'Permission is hereby granted, free of charge, to any person obtaining a ', ....
             ' copy of this software and associated documentation files (the "Software")', ... 
             ', to deal in the Software without restriction, including without limitation', ...
             ' the rights to use, copy, modify, merge, publish, distribute, sublicense,', ...
             ' and/or sell copies of the Software, and to permit persons to whom the', ...
             ' Software is furnished to do so, subject to the following conditions:', 10, 10, ...
             ' The above copyright notice and this permission notice shall be included', ...
             ' in all copies or substantial portions of the Software.', 10, 10, ... 
             'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF', 10, ...
             ' ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED', 10, ...
             'TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A', 10, ...
             'PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT ', 10, ...
             'SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ', 10, ...
             'ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ', 10, ...
             'ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, ', 10, ...
             'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE ', 10, ...
             'OR OTHER DEALINGS IN THE SOFTWARE.', 10,10);
    f = msgbox(L,'License Info','modal');

function CStepSize_Callback(hObject, eventdata, handles)
    ErrorCode = 0;

    [Settings] = GetInputData(handles);
    if Settings.StepSize < 1 
        Settings.StepSize = 1;
        String = num2str(Settings.StepSize);
        set(hObject,'String',String);
    end
     
    if ~isempty(handles.AfmData)
        if ~cellfun('isempty', handles.AfmData(1))
            h = waitbar(0,'Processing data...'); 
            ln = length(handles.AfmData);
            for ii=1:ln
                if ~cellfun('isempty', handles.AfmData(ii))
                    if ~isempty(handles.AfmData{ii}.ContactPointIdx)
                        [Indetation Force] = UpdateIndentationData(handles.AfmData{ii}, Settings);
                        handles.AfmData{ii}.Indetation = Indetation;
                        handles.AfmData{ii}.Force = Force;
                        [handles.AfmData{ii} ErrorCode] = FitData(handles.AfmData{ii}, Settings); 
                    end
                end
                waitbar(ii/ln,h,'Processing data...');
            end
            close(h);
        end
    end
    handles.DataSelection = 1;
    UpdateIndentationPlot(hObject, handles);
    UpdateTable(hObject, eventdata, handles);
guidata(hObject, handles); 


% --- Executes during object creation, after setting all properties.
function CStepSize_CreateFcn(hObject, eventdata, handles)

     set(hObject,'String','10');
    
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CNumberOfSteps_Callback(hObject, eventdata, handles)
    ErrorCode = 0;

    [Settings] = GetInputData(handles);
    if Settings.NumberOfSteps < 1 
        Settings.NumberOfSteps = 1;
        String = num2str(Settings.NumberOfSteps);
        set(hObject,'String',String);
    end    
    
    if ~isempty(handles.AfmData)
        if ~cellfun('isempty', handles.AfmData(1))
            h = waitbar(0,'Processing data...'); 
            ln = length(handles.AfmData);
            for ii=1:ln
                if ~cellfun('isempty', handles.AfmData(ii))
                    if ~isempty(handles.AfmData{ii}.ContactPointIdx)
                        [handles.AfmData{ii}.Indetation ...
                         handles.AfmData{ii}.Force] = UpdateIndentationData(handles.AfmData{ii}, Settings);
                         %= Indetation;
                         %= Force;
                        [handles.AfmData{ii} ErrorCode] = FitData(handles.AfmData{ii}, Settings); 
                    end
                end
                waitbar(ii/ln,h,'Processing data...');
            end
            close(h);
        end
    end
    
    UpdateIndentationPlot(hObject, handles);
    UpdateTable(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function CNumberOfSteps_CreateFcn(hObject, eventdata, handles)

    set(hObject,'String','2');
    
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [ OutputData ErrorCode] = FitData(Data, Settings)
    
    OutputData = Data;
    opt = fitoptions('Method','NonlinearLeastSquares',...
               'Robust', 'on',...
               'Lower', 0.0,...
               'StartPoint', 0.001,...
               'Upper',1000000);
           
    HertzFitParam = fittype('a*x.^(3/2)',...
                'dependent',{'y'},'independent',{'x'},...
                'coefficients',{'a'},...
                'options',opt);
            
    SneddonFitParam = fittype('a*x.^2',...
                'dependent',{'y'},'independent',{'x'},...
                'coefficients',{'a'},...
                'options',opt);
    
    Ch = 4*sqrt(Settings.TipRadius)/(3*(1-Settings.Mu^2));
    Cs = 2*tan(Settings.Alpha*pi/180)/(pi*(1-Settings.Mu^2));        
    
    OutputData.SneddonModulus = [];
    OutputData.SneddonFit = [];
    OutputData.HertzModulus = [];
    OutputData.HertzFit = [];
   
    ErrorCode = 0;   
    
    if isempty(Data.Indentation)
       ErrorCode = -1;
       return;   
    end

    ShowWarningWnd = 0;

    [C,I] = max(Data.Indentation);
    CurrentNumberOfSteps = C / Settings.StepSize;
    if CurrentNumberOfSteps >= Settings.NumberOfSteps
        CurrentNumberOfSteps = Settings.NumberOfSteps;
    elseif CurrentNumberOfSteps < Settings.NumberOfSteps
        CurrentNumberOfSteps = floor(CurrentNumberOfSteps);
    end
    %CurrentNumberOfSteps
    %NumberOfMatrixElements = floor(I / CurrentNumberOfSteps); 
    
    [C2, I2] = min(abs(Data.Indentation(1:I) - Settings.StepSize));
    NumberOfMatrixElements = I2;

    XX = Data.Indentation;
    YY = Data.Force; 
    XX(XX <0) = 0;
   
    try
        [c2,gof2] = fit(XX, YY, HertzFitParam);
    catch 
       if ShowWarningWnd  == 1
            wrn = warndlg(['Unable to fit Hertz model to AFM data. Check values', ...
                          ' of cantilever stiffness and deflection sensitivity.'], ...
                         'Warning', ...
                         'modal');
       end
       ErrorCode = -1;
       return;
    end
        
    HertzModulus = zeros(CurrentNumberOfSteps+1,1);
    HertzFit = zeros(CurrentNumberOfSteps+1,3);
    
    HertzModulus(1) = (c2.a / Ch) / 0.000001;
    HertzFit(1,:) = [ c2.a gof2.rsquare  gof2.rmse ];
    
    try
        [c2,gof2] = fit(XX, YY, SneddonFitParam);
    catch
       if ShowWarningWnd  == 1
            wrn = warndlg(['Unable to fit Hertz model to AFM data. Check values', ...
                          ' of cantilever stiffness and deflection sensitivity.'], ...
                         'Warning', ...
                         'modal');
       end
       ErrorCode = -1;
       return;
    end
        
    SneddonModulus = zeros(CurrentNumberOfSteps+1,1);
    SneddonFit = zeros(CurrentNumberOfSteps+1,3);
    
    SneddonModulus(1) = (c2.a / Cs) / 0.000001;
    SneddonFit(1,:) = [ c2.a gof2.rsquare  gof2.rmse ];
    
    if NumberOfMatrixElements >= 4 && CurrentNumberOfSteps > 0
        for ii=1:CurrentNumberOfSteps
            try
%                 X = XX((1+((ii-1)*NumberOfMatrixElements)):(ii*NumberOfMatrixElements));
%                 Y = YY((1+((ii-1)*NumberOfMatrixElements)):(ii*NumberOfMatrixElements));
                X = XX(1:(ii*NumberOfMatrixElements));
                Y = YY(1:(ii*NumberOfMatrixElements));
                X = X - X(1);
                X(X < 0) = 0;
                Y = Y - Y(1);
                [c2,gof2] = fit(X, Y, HertzFitParam);
            catch 
               if ShowWarningWnd  == 1
                    wrn = warndlg(['Unable to fit Hertz model to AFM data. Check values', ...
                          ' of cantilever stiffness and deflection sensitivity.'], ...
                         'Warning', ...
                         'modal');
               end
               ErrorCode = -1;
               return;
            end
            HertzModulus(ii+1) = (c2.a / Ch) / 0.000001;
            HertzFit(ii+1,:) = [ c2.a gof2.rsquare  gof2.rmse ];
        end
        
        for ii=1:CurrentNumberOfSteps
            try
%                 X = XX((1+((ii-1)*NumberOfMatrixElements)):(ii*NumberOfMatrixElements));
%                 Y = YY((1+((ii-1)*NumberOfMatrixElements)):(ii*NumberOfMatrixElements));
                X = XX(1:(ii*NumberOfMatrixElements));
                Y = YY(1:(ii*NumberOfMatrixElements));
                X = X - X(1);
                Y = Y - Y(1);
                [c2,gof2] = fit(X, Y, SneddonFitParam);
            
            catch
               if ShowWarningWnd  == 1
                      wrn = warndlg(['Unable to fit Hertz model to AFM data. Check values', ...
                          ' of cantilever stiffness and deflection sensitivity.'], ...
                         'Warning', ...
                         'modal');
               end
               ErrorCode = -1;
               return;
            end
            SneddonModulus(ii+1) = (c2.a / Cs) / 0.000001;
            SneddonFit(ii+1,:) = [ c2.a gof2.rsquare  gof2.rmse ];
        end
    end
    
    OutputData.SneddonModulus = SneddonModulus;
    OutputData.SneddonFit = SneddonFit;
    OutputData.HertzModulus = HertzModulus;
    OutputData.HertzFit = HertzFit;

function [ I ] = GetIndentationPoint(Y)
    
    Y = smooth(Y,0.01,'rloess');
    
    range = 0.5*(max(Y) - min(Y)) + min(Y);
    
    rng = 39;
    mask = [ones(rng,1)/rng; zeros(rng,1)]; 
    
    EY2 = conv(Y.^2,mask,'valid');
    E2Y = conv(Y,mask,'valid').^2;
  
    EY2_rev = conv(Y.^2,flipud(mask),'valid');
    E2Y_rev = conv(Y,flipud(mask),'valid').^2;
    
    VAR_BACK = EY2 - E2Y;
    VAR_AHEAD = EY2_rev-E2Y_rev;
    
    VAR_BACK(VAR_BACK < 0.0001) = 0.0001;
    VAR_AHEAD(VAR_AHEAD < 0.0001) = 0.0001;
    
    Y =Y(39:(end-39));
    
    sig = VAR_BACK./VAR_AHEAD;
    sig(Y > range) = 0;
    
    [C I] = max(sig);
    I = I + floor(0.5*rng);
%     figure;
%     plot(sig);

    
function [ DefErrBL ] = BaseLineCorrection(Data)
    DefErrBL = Data.DefErr;
    %p = polyfit(Data.Z(1:Data.ContactPointIdx),Data.DefErr(1:Data.ContactPointIdx),1);
    %DefErrBL = Data.DefErr - (p(1)*Data.Z + p(2));
    
                        
function [ Settings ] = GetInputData(handles)
        
        
        String = get(handles.CProbeK,'String');
        String = strrep(String, ',', '.');
        Settings.CantStiff = str2double(String);
                       
        String = get(handles.CDeflectionSensitivity,'String');
        String = strrep(String, ',', '.'); 
        Settings.DefSens = str2double(String);
       
        String = get(handles.CTipRadius,'String');
        String = strrep(String, ',', '.');
        Settings.TipRadius = str2double(String);

        String = get(handles.CMu,'String');
        String = strrep(String, ',', '.');
        Settings.Mu = str2double(String);
    
        String = get(handles.CAlpha,'String');
        String = strrep(String, ',', '.');
        Settings.Alpha = str2double(String);

        String = get(handles.CStepSize,'String');
        String = strrep(String, ',', '.');
        Settings.StepSize = str2double(String);

        String = get(handles.CNumberOfSteps,'String');
        String = strrep(String, ',', '.');
        Settings.NumberOfSteps = str2double(String);
    

% --- Executes when selected cell(s) is changed in CFitData.
function CFitData_CellSelectionCallback(hObject, eventdata, handles)
    
    if ~isempty(eventdata.Indices)
        if ~isempty(handles.AfmData)
            Data = get(hObject,'Data');
            if ~isempty(Data)   
               if eventdata.Indices(1,1) <= length(Data(:,1))
                   handles.DataSelection = eventdata.Indices(1,1);   
                   handles.DataSelection
               end
            end
        end
        UpdateIndentationPlot(hObject, handles);
        UpdateBoxPlot(hObject, handles);
    end
 guidata(hObject, handles); 

% hObject    handle to CFitData (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function CFitData_CreateFcn(hObject, eventdata, handles)
   
    cnames = {'<html><center /><font size=3>E</font><font size=-2>Hertz</font><br /><font size=-2>[kPa]</font></html>',...
              '<html><center /><font size=3>R2</font></html>',...
              '<html><center /><font size=3>RMSE</font></html>',...
              '<html><center /><font size=3>E</font><font size=-2>Sneddon</font><br /><font size=-2>[kPa]</font></html>',...
              '<html><center /><font size=3>R2</font></html>',...
              '<html><center /><font size=3>RMSE</font></html>'};
    set(hObject,'ColumnName',cnames);
    set(hObject,'ColumnWidth',{ 60 60 60 60 60 60} );
    set(hObject,'Data',[]);
         
guidata(hObject, handles); 

function UpdateTable(hObject, eventdata, handles)
    
    if ~isempty(handles.AfmData)
        CurrentPosition = get(handles.FileList,'Value');
        if ~cellfun('isempty', handles.AfmData(CurrentPosition))
            
            if (~isempty(handles.AfmData{CurrentPosition}.ContactPointIdx) && ...
                ~isempty(handles.AfmData{CurrentPosition}.Indentation) && ...
                ~isempty(handles.AfmData{CurrentPosition}.HertzFit) && ...
                ~isempty(handles.AfmData{CurrentPosition}.HertzModulus) && ...
                ~isempty(handles.AfmData{CurrentPosition}.SneddonFit) && ...
                ~isempty(handles.AfmData{CurrentPosition}.SneddonModulus))
                
                ln = length(handles.AfmData{CurrentPosition}.HertzModulus);
                Data = cell(ln,6);
                rnames = cell(ln,1);
                for ii=1:ln
                           
                    Data{ii,1} = sprintf('%.2G', handles.AfmData{CurrentPosition}.HertzModulus(ii));
                    Data{ii,2} = sprintf('%.2f', handles.AfmData{CurrentPosition}.HertzFit(ii,2));
                    Data{ii,3} = sprintf('%.2f', handles.AfmData{CurrentPosition}.HertzFit(ii,3));
                
                    Data{ii,4} = sprintf('%.2G', handles.AfmData{CurrentPosition}.SneddonModulus(ii));
                    Data{ii,5} = sprintf('%.2f', handles.AfmData{CurrentPosition}.SneddonFit(ii,2));
                    Data{ii,6} = sprintf('%.2f', handles.AfmData{CurrentPosition}.SneddonFit(ii,3));
                
                    if ii == 1
                        rnames{1} = 'Total';
                    else
                        rnames{ii} = num2str(ii-1);
                    end
                
                end
                
                set(handles.CFitData,'RowName',rnames);
                set(handles.CFitData,'Data',Data);
                
            else
                set(handles.CFitData,'Data',[]); 
            end
        else
            set(handles.CFitData,'Data',[]);
        end 
        
        if isstruct(handles.AfmData{CurrentPosition})
            if isfield(handles.AfmData{CurrentPosition}, 'ContactPointIdx')
                if ~isempty(handles.AfmData{CurrentPosition}.ContactPointIdx)
                    UpdateBoxPlot(hObject, handles);
                end
            end
        end
    
    else
        set(handles.CFitData,'Data',[]);
    end
    

    
guidata(hObject, handles); 


% --------------------------------------------------------------------
function CFitData_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to CFitData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function UpdateBoxPlot(hObject, handles)
    cla(handles.CHertzBoxPlot);
    cla(handles.CSneddonBoxPlot);
    
    sneddonLabel = '';
    hertzLabel = '';
    
    if ~isempty(handles.AfmData)
        CurrentPosition = get(handles.FileList,'Value');
        if ~cellfun('isempty', handles.AfmData(CurrentPosition))  
                    
            NumberOfFiles = length(handles.AfmData);
            
            if NumberOfFiles > 1
                
                if handles.DataSelection  == 1
                    sneddonLabel = ['Es total [kPa]'];
                    hertzLabel = ['Eh total [kPa]'];
                else
                    sneddonLabel = ['Es ' num2str(handles.DataSelection-1) ' [kPa]'];
                    hertzLabel = ['Eh ' num2str(handles.DataSelection-1) ' [kPa]'];
                end

                contents = cellstr(get(handles.CHistogramBins,'String'));
                nBins  = str2double(contents{get(handles.CHistogramBins,'Value')}); 

                HertzBoxplotData = zeros(NumberOfFiles, 1);
                SneddonBoxplotData = zeros(NumberOfFiles, 1);
                
                for ii=1:NumberOfFiles
                    if ~isempty(handles.AfmData{ii}.HertzModulus)
                        if length(handles.AfmData{ii}.HertzModulus) >= handles.DataSelection
                            HertzBoxplotData(ii) = handles.AfmData{ii}.HertzModulus(handles.DataSelection);
                        end
                    end

                    if ~isempty(handles.AfmData{ii}.SneddonModulus)
                        if length(handles.AfmData{ii}.SneddonModulus) >= handles.DataSelection
                            SneddonBoxplotData(ii) = handles.AfmData{ii}.SneddonModulus(handles.DataSelection);
                        end
                    end
                end
                    
                HertzBoxplotData(HertzBoxplotData == 0) = [];
                SneddonBoxplotData(SneddonBoxplotData == 0) = [];
                    
                    
                if ~isempty(HertzBoxplotData)
                    [n,xout] = hist(HertzBoxplotData ,nBins);   
                    hold(handles.CHertzBoxPlot,'on');
                    cla(handles.CHertzBoxPlot);
                    bar( handles.CHertzBoxPlot, xout , n);
                    Xmin = min(xout);
                    Xmax = max(xout); 

                    if ~isempty(handles.AfmData{CurrentPosition}.HertzModulus)

                        if length(handles.AfmData{CurrentPosition}.HertzModulus) >= handles.DataSelection
                            plot( handles.CHertzBoxPlot, ...
                                  handles.AfmData{CurrentPosition}.HertzModulus(handles.DataSelection), ...
                                  max(n)/2, ...
                                  'ro', ...
                                  'LineWidth', 4, ...
                                  'MarkerFaceColor','r');

                            xlim(handles.CHertzBoxPlot, ...
                                 [min([ Xmin handles.AfmData{CurrentPosition}.HertzModulus(handles.DataSelection)]) ...
                                  max([ Xmax handles.AfmData{CurrentPosition}.HertzModulus(handles.DataSelection)]) ]);

                            ylim(handles.CHertzBoxPlot, [ 0 max(n) ]);
                            hold(handles.CHertzBoxPlot,'off');
                        end
                    else
                        xlim(handles.CHertzBoxPlot, [ Xmin Xmax ]);
                        ylim(handles.CHertzBoxPlot, [ 0 max(n) ]);
                        hold(handles.CHertzBoxPlot,'off');
                    end
                end


                 if ~isempty(SneddonBoxplotData)

                    [n,xout] = hist(SneddonBoxplotData ,nBins); 
                    hold(handles.CSneddonBoxPlot,'on');
                    cla(handles.CSneddonBoxPlot);
                    bar( handles.CSneddonBoxPlot, xout , n);
                    Xmin = min(xout);
                    Xmax = max(xout); 

                    if ~isempty(handles.AfmData{CurrentPosition}.SneddonModulus)
                        if length(handles.AfmData{CurrentPosition}.SneddonModulus) >= handles.DataSelection
                            plot(handles.CSneddonBoxPlot, ...
                                 handles.AfmData{CurrentPosition}.SneddonModulus(handles.DataSelection), ...
                                 max(n)/2, 'ro', ...
                                 'LineWidth', 4, ...
                                 'MarkerFaceColor','r');

                            xlim(handles.CSneddonBoxPlot, ...
                                [min([ Xmin handles.AfmData{CurrentPosition}.SneddonModulus(handles.DataSelection)]) ...
                                 max([ Xmax handles.AfmData{CurrentPosition}.SneddonModulus(handles.DataSelection)])]);

                            ylim(handles.CSneddonBoxPlot, [ 0 max(n) ]);
                            hold(handles.CSneddonBoxPlot,'off');
                        end
                    else
                        xlim(handles.CSneddonBoxPlot, [ Xmin Xmax ]);
                        ylim(handles.CSneddonBoxPlot, [ 0 max(n) ]);
                        hold(handles.CSneddonBoxPlot,'off');
                    end
                 end
  
            else
                cla(handles.CHertzBoxPlot);    
                cla(handles.CSneddonBoxPlot);    
            end
                        
        else
          cla(handles.CHertzBoxPlot);
          cla(handles.CSneddonBoxPlot);    
        end
    else
        cla(handles.CHertzBoxPlot);
        cla(handles.CSneddonBoxPlot);    
    end
    
    set(handles.CHertzBoxPlot,'FontSize',12);
    set(handles.CSneddonBoxPlot,'FontSize',12);

    set(handles.CHertzBoxPlot,'XTickMode','auto','YTickMode','auto');
    set(handles.CHertzBoxPlot,'XTickLabelMode','auto','YTickLabelMode','auto');
    set(handles.CHertzBoxPlot, 'Position', handles.HertzBoxplotOriginalSize);
    set(handles.CHertzBoxPlot,'LineWidth',2);
    ylabel(handles.CHertzBoxPlot, 'Counts');
    xlabel(handles.CHertzBoxPlot, hertzLabel);
    
   
    set(handles.CSneddonBoxPlot,'XTickMode','auto','YTickMode','auto');
    set(handles.CSneddonBoxPlot,'XTickLabelMode','auto','YTickLabelMode','auto');
    set(handles.CSneddonBoxPlot, 'Position', handles.SneddonBoxplotOriginalSize);
    set(handles.CSneddonBoxPlot,'LineWidth',2);
    ylabel(handles.CSneddonBoxPlot, 'Counts');
    xlabel(handles.CSneddonBoxPlot, sneddonLabel);
    
 %guidata(hObject, handles); 
    
    
   

% --------------------------------------------------------------------
function CExportDataBatch_Callback(hObject, eventdata, handles)
    if ~isempty(handles.AfmData)
        CurrentPosition = get(handles.FileList,'Value');
        if ~cellfun('isempty', handles.AfmData(CurrentPosition,1))  
            [File,Path,FileFilter] = uiputfile('*.mat','Save Workspace As');
            if FileFilter>0
                 combinedStr = strcat(Path,File(1:(end-4)));
                 combinedStr = strcat(combinedStr,'.mat');
                 AfmData = handles.AfmData;
                 FileNameList = handles.FileNameList;
                 [ Settings ] = GetInputData(handles);
                 
                 save(combinedStr, 'AfmData','Settings' , 'FileNameList');
            end
        end
    end
guidata(hObject, handles); 

function CImport_Callback(hObject, eventdata, handles)
    

guidata(hObject, handles); 
    

% --- Executes on selection change in CHistogramBins.
function CHistogramBins_Callback(hObject, eventdata, handles)

UpdateBoxPlot(hObject, handles);
guidata(hObject, handles); 

% --- Executes during object creation, after setting all properties.
function CHistogramBins_CreateFcn(hObject, eventdata, handles)
set(hObject,'String', '10|15|20|25|30');
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function CImportDataBatch_Callback(hObject, eventdata, handles)
   [File,Path,FileFilter] = uigetfile('*.mat','Select the MATLAB workspace file','Multiselect','off');
    if FileFilter > 0 
                
        set(handles.FileList,'String','');
        handles.AfmData = [];
        load(strcat(Path,File));
        handles.AfmData = AfmData;
        handles.FileNameList = FileNameList;

        guidata(hObject, handles); 
        
        set(handles.CProbeK,'String',num2str(Settings.CantStiff));
        set(handles.CDeflectionSensitivity,'String',num2str(Settings.DefSens));
        set(handles.CTipRadius,'String',num2str(Settings.TipRadius));
        set(handles.CMu,'String',num2str(Settings.Mu));
        set(handles.CAlpha,'String',num2str(Settings.Alpha));
        set(handles.CStepSize,'String',num2str(Settings.StepSize));
        set(handles.CNumberOfSteps,'String',num2str(Settings.NumberOfSteps));
        
        clear Data Settings FileNameList;
        set(handles.FileList,'Value',1);
        set(handles.FileList,'String',char(handles.FileNameList));
        

        
        UpdateListInfo(hObject, handles);
        UpdateDeflectionPlot(hObject, handles);
        UpdateIndentationPlot(hObject, handles);
        UpdateTable(hObject, eventdata, handles);
    end
guidata(hObject, handles); 

      
function f = gauss_distribution(x, mu, s)
    p1 = -.5 * ((x - mu)/s) .^ 2;
    p2 = (s * sqrt(2*pi));
    f = exp(p1) ./ p2; 
    


% --------------------------------------------------------------------
function CExportToXls_Callback(~, ~, handles)
    
    if ~isempty(handles.AfmData)
        CurrentPosition = get(handles.FileList,'Value');
        if ~isempty(handles.AfmData{CurrentPosition})  
            [FileName,PathName,FileFilter] = uiputfile('*.xls','Save Workspace As');
            if FileFilter>0     
                
                h = waitbar(0,'Processing data...');  
                
                NumberOfFiles = length(handles.AfmData);
                Path = strcat(PathName, FileName);
                
                
                
                TotalBarLength = NumberOfFiles *2;
                BarCount = 0;
                waitbar(BarCount/TotalBarLength,h,'Processing data...');
                
                [Settings] = GetInputData(handles);

                modulus_header = {'file_name' 'depth' 'modulus' 'R2' 'RMSE'};
                
                FullData = cell(0);
                for kk=1:1:(Settings.NumberOfSteps+1)
                    DataFrame = cell(NumberOfFiles, 5);

                     for ii=1:NumberOfFiles
                        if ~isempty(handles.AfmData{ii}.HertzModulus) 
                            if length(handles.AfmData{ii}.HertzModulus) >= kk
                              
                              DataFrame{ii,1} = handles.AfmData{ii}.FileName;   
                              DataFrame{ii,2} = (kk-1)*Settings.StepSize; 
                              DataFrame{ii,3} = handles.AfmData{ii}.HertzModulus(kk);
                              DataFrame{ii,4} = handles.AfmData{ii}.HertzFit(kk,2);
                              DataFrame{ii,5} = handles.AfmData{ii}.HertzFit(kk,3);

                            end
                        end
                     end
                     FullData = [FullData; DataFrame];
                end
                xlswrite(Path, modulus_header,'hertz_modulus','A1');
                xlswrite(Path, FullData,'hertz_modulus','A2');
                
                FullData = cell(0);
                for kk=1:1:(Settings.NumberOfSteps+1)
                    DataFrame = cell(NumberOfFiles, 5);

                     for ii=1:NumberOfFiles
                        if ~isempty(handles.AfmData{ii}.SneddonModulus) 
                            if length(handles.AfmData{ii}.SneddonModulus) >= kk
                              
                              DataFrame{ii,1} = handles.AfmData{ii}.FileName;   
                              DataFrame{ii,2} = (kk-1)*Settings.StepSize; 
                              DataFrame{ii,3} = handles.AfmData{ii}.SneddonModulus(kk);
                              DataFrame{ii,4} = handles.AfmData{ii}.SneddonFit(kk,2);
                              DataFrame{ii,5} = handles.AfmData{ii}.SneddonFit(kk,3);

                            end
                        end
                     end
                     FullData = [FullData; DataFrame];
                end
                xlswrite(Path, modulus_header,'sneddon_modulus','A1');
                xlswrite(Path, FullData,'sneddon_modulus','A2');
                
%                 for ii=1:NumberOfFiles
%                     
%                     Modulus{ii,1} = handles.AfmData{ii}.FileName;
%                     RMS{ii,1} = handles.AfmData{ii}.FileName;
%                     R2{ii,1} = handles.AfmData{ii}.FileName;
%                     
%                     if ~isempty(handles.AfmData{ii}.HertzModulus) 
%                         for kk =1:1:length(handles.AfmData{ii}.HertzModulus)
%                             Modulus{ii,kk+1} = handles.AfmData{ii}.HertzModulus(kk);
%                             RMS{ii,kk+1} = handles.AfmData{ii}.HertzFit(kk);
%                             R2{ii,kk+1} = handles.AfmData{ii}.HertzFit(kk);
%                         end
%                     end
%                     BarCount = BarCount + 1;
%                     waitbar(BarCount/TotalBarLength,h,'Processing data...');
%                 end       
                                
%                 xlswrite(Path, modulus_header,'hertz_modulus','A1');
%                 xlswrite(Path, Modulus,'hertz_modulus','A2');
%                 
%                 xlswrite(Path, modulus_header,'hertz_rms','A1');
%                 xlswrite(Path, RMS,'hertz_rms','A2');
%                 
%                 xlswrite(Path, modulus_header,'hertz_r2','A1');
%                 xlswrite(Path, R2,'hertz_r2','A2');
%                         
%                 Modulus = cell(NumberOfFiles,Settings.NumberOfSteps+1);
%                 RMS = cell(NumberOfFiles,Settings.NumberOfSteps+1);
%                 R2 = cell(NumberOfFiles,Settings.NumberOfSteps+1);
                
%                 for ii=1:NumberOfFiles
%                     
%                     Modulus{ii,1} = handles.AfmData{ii}.FileName;
%                     RMS{ii,1} = handles.AfmData{ii}.FileName;
%                     R2{ii,1} = handles.AfmData{ii}.FileName;
%                     
%                     if ~isempty(handles.AfmData{ii}.SneddonModulus) 
%                         for kk =1:1:length(handles.AfmData{ii}.SneddonModulus)
%                             Modulus{ii,kk+1} = handles.AfmData{ii}.SneddonModulus(kk);
%                             RMS{ii,kk+1} = handles.AfmData{ii}.SneddonFit(kk);
%                             R2{ii,kk+1} = handles.AfmData{ii}.SneddonFit(kk);
%                         end
%                     end
%                     BarCount = BarCount + 1;
%                     waitbar(BarCount/TotalBarLength,h,'Processing data...');
%                 end       
%                         
%                 xlswrite(Path, modulus_header,'sneddon_modulus','A1');
%                 xlswrite(Path, Modulus,'sneddon_modulus','A2');
%                 
%                 xlswrite(Path, modulus_header,'sneddon_rms','A1');
%                 xlswrite(Path, RMS,'sneddon_rms','A2');
%                 
%                 xlswrite(Path, modulus_header,'sneddon_r2','A1');
%                 xlswrite(Path, R2,'sneddon_r2','A2');

                close(h);
            end
        end
    end
    
    
function [ Data ] = ReadAFMData( Path )

    if ~isempty(Path) && ischar(Path)
        FileId = fopen(Path,'r');
        if FileId > 0
            Calc_Ramp_Ex_nm = -1;
            Defl_V_Ex = -1;
            
            FirstLine = fgetl(FileId);
            splits = regexp(FirstLine,'\t','split');

            for ii = 1:length(splits)
               if strcmp(splits{ii}, 'Calc_Ramp_Ex_nm') == 1
                    Calc_Ramp_Ex_nm = ii;
               end
               
               if strcmp(splits{ii}, 'Defl_V_Ex') == 1
                    Defl_V_Ex = ii;
               end
            end
            
            if Calc_Ramp_Ex_nm == -1   
                error('Calc_Ramp_Ex_nm data column not found.'); 
            end
            
            if Defl_V_Ex == -1
                error('Defl_V_Ex data column not found.'); 
            end
            
            columns = sum(cellfun('length',splits) > 0);
            if columns  > 1

                Data = fscanf(FileId,'%f',  [columns inf]);
                Data = Data';
                ix = find( diff(Data(:,1))<0 ,1);
                if ~isempty(ix)
                    Data = Data(1:ix-1,:);
                end
                
                Data = Data(:, [Calc_Ramp_Ex_nm Defl_V_Ex]);
                fclose(FileId);
            else
                fclose(FileId);
                error('Wrong file format or corrupted data'); 
            end   
        else
            error('Could not open file.'); 
        end
    else
        error('Input variable expected to be string.'); 
    end
    
    
function [ Indentation Force ] = UpdateIndentationData(Data, Settings)
    Z = Data.Z(Data.ContactPointIdx:end);
    DefErrBL = Data.DefErrBL(Data.ContactPointIdx:end);
    
    Z = Z - Z(1);
    DefErrBL =  DefErrBL - DefErrBL(1);
    
    Indentation = Z - (DefErrBL * Settings.DefSens); 
    Force = (Settings.CantStiff*Settings.DefSens) * DefErrBL; 
    
    if sum(Indentation > 0) == 0
        Indentation = [];
        Force = [];
    end
    
    if isreal(Indentation.^(3/2)) == 0
        Indentation = [];
        Force = [];
    end
    
% --- Executes on key press with focus on FileList and none of its controls.
function FileList_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to FileList (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on MainWindow or any of its controls.
function MainWindow_WindowKeyPressFcn(hObject, eventdata, handles)
    %eventdata.Key
    switch eventdata.Key
        case 'downarrow'
            CNext_Callback(hObject, eventdata, handles);            
        case 'uparrow'
            CPrevious_Callback(hObject, eventdata, handles);            
        case 'delete'
            RemoveFile_Callback(hObject, eventdata, handles); 
        case 'z'
           if handles.CtrlButtonDown == 0
                handles.CtrlButtonDown = 1;
           end
    end
guidata(hObject, handles); 
    
 function UpdateListInfo(hObject, handles)
     if ~isempty(handles.AfmData)
        CurrentPosition = get(handles.FileList,'Value');
        if ~cellfun('isempty', handles.AfmData(CurrentPosition))  
           
            handles.Total = length(handles.AfmData);
            handles.Processed = 0;
            handles.Unprocessed = 0;
            
            for ii=1:handles.Total
                if ~isempty(handles.AfmData{ii}.HertzFit) || ~isempty(handles.AfmData{ii}.SneddonFit)
                    handles.FileNameList{ii} = ['<html><div style="color:black">' handles.AfmData{ii}.FileName ' '];
                    handles.Processed = handles.Processed + 1;
                else
                    handles.FileNameList{ii} = ['<html><div style="color:red">' handles.AfmData{ii}.FileName ' '];
                    handles.Unprocessed = handles.Unprocessed + 1;
                end
            end
            
            set(handles.FileList,'String',char(handles.FileNameList));
            
        else
            handles.Total = 0;
            handles.Unprocessed = 0;
            handles.Processed = 0;
        end
     end
        
    set(handles.CUnprocessed,'string', num2str(handles.Unprocessed));
    set(handles.CProcessed,'string', num2str(handles.Processed));
    set(handles.CTotal,'string', num2str(handles.Total));
guidata(hObject, handles);      
     
% --- Executes on key release with focus on MainWindow or any of its controls.
function MainWindow_WindowKeyReleaseFcn(hObject, eventdata, handles)
 
    switch eventdata.Key
        case 'z'
            if handles.CtrlButtonDown == 1
                handles.CtrlButtonDown = 0;
               % handles.CtrlButtonDown
            end
    end
guidata(hObject, handles);


% --- Executes when user attempts to close MainWindow.
function MainWindow_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to MainWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
 dlgTitle    = 'User Question';
 dlgQuestion = 'Do you wish to close program?';
 choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');
 
 if strcmpi(choice, 'Yes') 
    delete(hObject);
 else
     
 end


% --- Executes on button press in ZMinFlag.
function ZMinFlag_Callback(hObject, eventdata, handles)
    String = get(handles.ZMinValue,'String');
    if get(hObject, 'Value') == 1 && isempty(String) == 1
         wrn = warndlg('First you must put min Z value.');
         set(hObject, 'Value', 0)
    else
        UpdateDeflectionPlot(hObject, handles);
    end
guidata(hObject, handles);    


function ZMinValue_Callback(hObject, eventdata, handles)
    String = get(hObject,'String');
    String = strrep(String, ',', '.');
    
    value = str2double(String);
    if value > 90
    	set(hObject,'String','90.0');
    else
        set(hObject,'String',String);
    end
    
    if get(handles.ZMinFlag, 'Value') == 1
        UpdateDeflectionPlot(hObject, handles);
    end
    
guidata(hObject, handles);    


% --- Executes during object creation, after setting all properties.
function ZMinValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ZMinValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ZMaxFlag_Callback(hObject, eventdata, handles)
    String = get(handles.ZMaxValue,'String');
    if get(hObject, 'Value') == 1 && isempty(String) == 1
         wrn = warndlg('First you must put max Z value.');
         set(hObject, 'Value', 0)
    else
        UpdateDeflectionPlot(hObject, handles);
    end
guidata(hObject, handles);    



function ZMaxValue_Callback(hObject, eventdata, handles)
    String = get(hObject,'String');
    String = strrep(String, ',', '.');
	set(hObject,'String',String);
    
    if get(handles.ZMaxFlag, 'Value') == 1
        UpdateDeflectionPlot(hObject, handles);
    end
    
guidata(hObject, handles);    


function ZMaxValue_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CPrevious_CreateFcn(hObject, eventdata, handles)


% --------------------------------------------------------------------
function CExportToCsv_Callback(hObject, eventdata, handles)
  if ~isempty(handles.AfmData)
        CurrentPosition = get(handles.FileList,'Value');
        if ~isempty(handles.AfmData{CurrentPosition})  
            [FileName,PathName,FileFilter] = uiputfile('*.csv','Save Workspace As');
            if FileFilter>0     
                
                h = waitbar(0,'Processing data...');  
                
                NumberOfFiles = length(handles.AfmData);
                Path = strcat(PathName, FileName);
                
                TotalBarLength = NumberOfFiles *2;
                BarCount = 0;
                waitbar(BarCount/TotalBarLength,h,'Processing data...');
                
                [Settings] = GetInputData(handles);
                
                Modulus = cell(NumberOfFiles,Settings.NumberOfSteps+1);
                RMS = cell(NumberOfFiles,Settings.NumberOfSteps+1);
                R2 = cell(NumberOfFiles,Settings.NumberOfSteps+1);

                modulus_header = {'file_name' 'total'};
                rms_header = {'file_name' 'total'};
                r2_header = {'file_name' 'total'};
                
                for kk=1:1:Settings.NumberOfSteps
                    modulus_header = [modulus_header ['modulus at ' num2str(kk*Settings.StepSize,3) ' nm [kPa]']];
                    rms_header = [rms_header ['rms at ' num2str(kk*Settings.StepSize,3) ' [kPa]']];
                    r2_header = [r2_header ['r2 at ' num2str(kk*Settings.StepSize,3)]];
                end
                
                for ii=1:NumberOfFiles
                    
                    Modulus{ii,1} = handles.AfmData{ii}.FileName;
                    RMS{ii,1} = handles.AfmData{ii}.FileName;
                    R2{ii,1} = handles.AfmData{ii}.FileName;
                    
                    if ~isempty(handles.AfmData{ii}.HertzModulus) 
                        for kk =1:1:length(handles.AfmData{ii}.HertzModulus)
                            Modulus{ii,kk+1} = handles.AfmData{ii}.HertzModulus(kk);
                            RMS{ii,kk+1} = handles.AfmData{ii}.HertzFit(kk);
                            R2{ii,kk+1} = handles.AfmData{ii}.HertzFit(kk);
                        end
                    end
                    BarCount = BarCount + 1;
                    waitbar(BarCount/TotalBarLength,h,'Processing data...');
                end       
                
                output_data = [modulus_header; Modulus];
                [rows cols] = size(output_data);
                
                fid = fopen([Path(1:end-4) '_Hertz.csv'],'w');
                for jj=1:1:rows
                    str = '';
                    for ii=1:1:cols  
                        if ii == 1
                            str = strcat(str, num2str(output_data{jj,ii}));
                        else
                            str = strcat(str, ',', num2str(output_data{jj,ii}));
                        end
                    end
                    fprintf(fid,'%s\n', str)
                end
                fclose(fid)
                
                        
                Modulus = cell(NumberOfFiles,Settings.NumberOfSteps+1);
                RMS = cell(NumberOfFiles,Settings.NumberOfSteps+1);
                R2 = cell(NumberOfFiles,Settings.NumberOfSteps+1);
                
                for ii=1:NumberOfFiles
                    
                    Modulus{ii,1} = handles.AfmData{ii}.FileName;
                    RMS{ii,1} = handles.AfmData{ii}.FileName;
                    R2{ii,1} = handles.AfmData{ii}.FileName;
                    
                    if ~isempty(handles.AfmData{ii}.SneddonModulus) 
                        for kk =1:1:length(handles.AfmData{ii}.SneddonModulus)
                            Modulus{ii,kk+1} = handles.AfmData{ii}.SneddonModulus(kk);
                            RMS{ii,kk+1} = handles.AfmData{ii}.SneddonFit(kk);
                            R2{ii,kk+1} = handles.AfmData{ii}.SneddonFit(kk);
                        end
                    end
                    BarCount = BarCount + 1;
                    waitbar(BarCount/TotalBarLength,h,'Processing data...');
                end       
                
                fid = fopen([Path(1:end-4) '_Sneddon.csv'],'w');
                for jj=1:1:rows
                    str = '';
                    for ii=1:1:cols  
                        if ii == 1
                            str = strcat(str, num2str(output_data{jj,ii}));
                        else
                            str = strcat(str, ',', num2str(output_data{jj,ii}));
                        end
                    end
                    fprintf(fid,'%s\n', str)
                end
                fclose(fid)
                

                
%                 xlswrite(Path, modulus_header,'sneddon_modulus','A1');
%                 xlswrite(Path, Modulus,'sneddon_modulus','A2');
%                 
%                 xlswrite(Path, modulus_header,'sneddon_rms','A1');
%                 xlswrite(Path, RMS,'sneddon_rms','A2');
%                 
%                 xlswrite(Path, modulus_header,'sneddon_r2','A1');
%                 xlswrite(Path, R2,'sneddon_r2','A2');

                close(h);
            end
        end
    end
    

% --- Executes on mouse press over axes background.
function HertzPlot_ButtonDownFcn(hObject, eventdata, handles)
     MousePosition = get(handles.HertzPlot, 'CurrentPoint');
     ErrorCode = 0;
     
     if ~isempty(handles.AfmData)
        NewPosition = get(handles.FileList,'Value');
        if ~cellfun('isempty', handles.AfmData(NewPosition))
            Indentation = handles.AfmData{NewPosition}.Indentation;
            Force = handles.AfmData{NewPosition}.Force;
            MousePosition(1,1)
            if MousePosition(1,1) > min(Indentation) && ...
               MousePosition(1,1) < max(Indentation)
               
                [C, I] = min(abs(( Indentation - MousePosition(1,1))));
                indentation_value = Indentation(I);
                force_value = Force(I);
                f = msgbox({['indentation = ', num2str(indentation_value, 4)], ...
                            ['force = ', num2str(force_value, 4)]});
            end
        end
     end
guidata(hObject, handles);    


% --- Executes on mouse press over axes background.
function SneddonPlot_ButtonDownFcn(hObject, eventdata, handles)
     MousePosition = get(handles.SneddonPlot, 'CurrentPoint');
     ErrorCode = 0;
     
     if ~isempty(handles.AfmData)
        NewPosition = get(handles.FileList,'Value');
        if ~cellfun('isempty', handles.AfmData(NewPosition))
            Indentation = handles.AfmData{NewPosition}.Indentation;
            Force = handles.AfmData{NewPosition}.Force;
            MousePosition(1,1)
            if MousePosition(1,1) > min(Indentation) && ...
               MousePosition(1,1) < max(Indentation)
               
                [C, I] = min(abs(( Indentation - MousePosition(1,1))));
                indentation_value = Indentation(I);
                force_value = Force(I);
                f = msgbox({['indentation = ', num2str(indentation_value, 4)], ...
                            ['force = ', num2str(force_value, 4)]});
            end
        end
     end
guidata(hObject, handles);    

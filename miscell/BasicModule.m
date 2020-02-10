function BasicModule(MainPanel)
% ==================================
% VERSION 1.0
%   - First release
% VERSION 1.1
%   - Added MasterColor definition
%   - Added autonomous file types
% ==================================
VERSION = '1.1';

global InterControl InterVar  % Variables for module interface

[MainPath, FuncName, xt] = fileparts(mfilename('fullpath')); %#ok<ASGLU>
InfoFilename = [MainPath filesep FuncName '_Info_v', strrep(VERSION, '.', ''), '.Info'];
InfoFile = matfile(InfoFilename, 'Writable',true);
InitEmptyVariable('DataFolder', pwd);

% ----- Customization ---------------------------------------------------------- %
MasterColor = [0.7 1.0 0.7];    % YOU CAN CHANGE THIS VALUE
BaseFileTypes = {'*.*'};        % YOU CAN CHANGE THIS VALUE
% ------------------------------------------------------------------------------ %

InterVar.(FuncName).MasterColor = MasterColor;
InterVar.(FuncName).InfoFile = InfoFile;
InitEmptyVariable('FileTypes_String', BaseFileTypes)

%% =================================
if nargin == 0
    MainFigure = figure('name',FuncName, 'NumberTitle','off', 'Units','norm', 'Position',[.1 .1 .8 .8]);
    
    MainPanel = uipanel('parent',MainFigure, 'units','norm', 'pos',[0 0 1 1], ...
        'BorderType','None', 'Tag',FuncName);
    CTRmaster(MainPanel);
    delete(MainFigure);
    MainFigure = gcf;
else
    MainPanel.Tag = FuncName;
    CurrentObj = MainPanel;
    while not(strcmp(CurrentObj.Type, 'figure'))
        CurrentObj = CurrentObj.Parent;
    end
    MainFigure = CurrentObj;
end
figure(MainFigure);
MainPanel.DeleteFcn = @DeletingMainPanel;

if ishandle(InterControl)
    InterListener = addlistener(InterControl, 'UserData', 'PostSet', @InterCommand);
end

%% VERSION
VersionText = uicontrol('parent',MainPanel, 'style','text', ...
    'units','norm', 'pos', [0.92, 0.975, 0.08, 0.025], ...
    'FontSize',12, 'string',['Version: ',VERSION], ...
    'backgroundcolor',[.8 1 .8], 'foregroundcolor',[.4 0 0]);

Test = [];

%% -------------  WRITE HERE YOUR CODE ------------- %%





%% ==================== %%
%  === SubFunctions === %%
%  ==================== %%

%% DeletingMainPanel
    function DeletingMainPanel(~, ~)    
        delete(InterListener)
        if isfield(InterVar, FuncName)
            InterVar = rmfield(InterVar, FuncName);
        end
    end

%% TestLoadedFunction
    function TestLoadedFunction(Data)
        Test = Data.Test;
        %         fprintf('Loaded test file %s\n', Data.FilePath)
        %         cmd = struct(...
        %             'Command','TestFileLoaded', ...
        %             'Source','Master', ...
        %             'Destination','All', ...
        %             'Data', struct( ...
        %                 'FileInfo',dir(FilePath), ...
        %                 'FilePath',FilePath, ...
        %                 'FileFolder', InfoFile.DataFolder, ...
        %                 'FileType','.test.mat', ...
        %                 'Test',Test));
    end

%% FolderChangeFunction
    function FolderChangeFunction()
        %         fprintf('Folder changed folder %s\n', InfoFile.DataFolder)
        %         cmd = struct(...
        %             'Command','FolderChange', ...
        %             'Source','Master', ...
        %             'Destination','All', ...
        %             'Data', struct('Folder',InfoFile.DataFolder));
    end

%% MultipleFileSelected
    function MultipleFileSelected(Data)
        %         fprintf('%d files selected in folder:\n %s\n\n', length(Data.FileList), Data.Folder)
        %         cmd = struct(...
        %             'Command','MultipleFilesSelected', ...
        %             'Source','Master', ...
        %             'Destination','All', ...
        %             'Data', struct('FileList', ListaFiles(FilesListbox.Value), ...
        %                     'Folder', InfoFile.DataFolder));
    end


%% SingleFileSelected
    function SingleFileSelected(Data)
        
% --------------- EXAMPLE --------------- %
        if strcmp(Data.FileType, '.log')
            % do something with .log file 
            % e.g.  LogFunction(Data.FilePath)
        elseif strcmp(Data.FileType, '.xyz')
            % do something with .log file
            % e.g.  xyzFunction(Data)
        end
% --------------------------------------- %
        
        %         fprintf('File selected:\nType: %s\nFilename %s\nFolder: %s\n\n', Data.FileType, Data.FileInfo.name, InfoFile.DataFolder)
        % Commands(1) = struct(...
        %                 'Command','FileSelected', ...
        %                 'Source','Master', ...
        %                 'Destination','All', ...
        %                 'Data', struct( ...
        %                     'FileInfo',dir(FilePath), ...
        %                     'FilePath',FilePath, ...
        %                     'FileFolder', InfoFile.DataFolder, ...
        %                     'FileType',extension ));
    end

%% InterCommand
    function InterCommand(~, ~)
        commands = InterControl.UserData;
        for i = 1:length(commands)
            cmd = commands(i);
            if strcmp(cmd.Command, 'FileSelected')
                InfoFile.DataFolder = cmd.Data.FileFolder;
                SingleFileSelected(cmd.Data)
            elseif strcmp(cmd.Command, 'TestFileLoaded') && ...
                    strcmp(cmd.Data.FileType, '.test.mat')
                %                 Test = cmd.Data.Test;
                %                 [InfoFile.DataFolder, ~, ~] = fileparts(cmd.Data.FilePath);
                InfoFile.DataFolder = cmd.Data.FileFolder;
                TestLoadedFunction(cmd.Data);
            elseif strcmp(cmd.Command, 'FolderChange')
                InfoFile.DataFolder = cmd.Data.Folder;
                FolderChangeFunction();
            elseif strcmp(cmd.Command, 'MultipleFilesSelected')
                InfoFile.DataFolder = cmd.Data.Folder;
                MultipleFileSelected(cmd.Data)
            end
        end
    end





%% InitEmptyVariable
    function InitEmptyVariable(VariableName, DefaultValue)
        FileVariables = whos(InfoFile);
        FileVariables = {FileVariables.name};
        % Assign default values if no value is saved
        if all(strcmp(VariableName, FileVariables) == 0)
            InfoFile.(VariableName) = DefaultValue;
        end
    end

%% InitVar
    function InitVar(Object, prop, DefaultValue, VariableName)
        InitEmptyVariable(VariableName, DefaultValue);
        Ud = Object.UserData;
        Ud.(prop) = VariableName;
        set(Object, prop,InfoFile.(VariableName), 'UserData',Ud);
        addlistener(handle(Object), prop, 'PostSet', @SaveUpdatedVariable);
    end

%% InitVars
    function InitVars(Object, props, BaseName)
        if ischar(props)
            props = {props};
        end
        for i = 1:length(props)
            prop = props{i};
            VariableName = [BaseName, '_', prop];
            InitEmptyVariable(VariableName, Object.(prop));
            Ud = Object.UserData;
            Ud.(prop) = VariableName;
            set(Object, prop,InfoFile.(VariableName), 'UserData',Ud);
            addlistener(handle(Object), prop, 'PostSet', @SaveUpdatedVariable);
        end
    end

%% InitVarsByTag
    function InitVarsByTag(Object, props)
        if isempty(Object.Tag)
            error('EmptyTag');
        end
        if ischar(props)
            props = {props};
        end
        for i = 1:length(props)
            prop = props{i};
            VariableName = [Object.Tag, '_', prop];
            InitEmptyVariable(VariableName, Object.(prop));
            Ud = Object.UserData;
            Ud.(prop) = VariableName;
            set(Object, prop,InfoFile.(VariableName), 'UserData',Ud);
            addlistener(handle(Object), prop, 'PostSet', @SaveUpdatedVariable);
        end
    end

%% SaveUpdatedVariable
    function SaveUpdatedVariable(obj, event)
        InfoFile.(event.AffectedObject.UserData.(obj.Name)) = get(event.AffectedObject, obj.Name);
    end

end
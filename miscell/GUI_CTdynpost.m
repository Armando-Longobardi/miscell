function GUI_CTdynpost(MainPanel)
% ==================================
% VERSION 1.0
% - first release, branches from ForcesAnalysis
% ==================================
VERSION = '1.0';

global InterControl InterVar  % Variables for module interface

[MainPath, FuncName, xt] = fileparts(mfilename('fullpath')); %#ok<ASGLU>
InfoFilename = [MainPath filesep FuncName '_Info_v', strrep(VERSION, '.', ''), '.Info'];
InfoFile = matfile(InfoFilename, 'Writable',true);

% iNode = 1;

%% =================================

if nargin == 0
    MainFigure = figure('name','Figure name', 'NumberTitle','off', 'Units','norm', 'Position',[.1 .1 .8 .8]);
    
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

if ishandle(InterControl)
    InterListener = addlistener(InterControl, 'UserData', 'PostSet', @InterCommand); %#ok<NASGU>
end

%% Tabs
Tabs = uitabgroup('parent',MainPanel, 'units','norm', 'position',[0 0 1 1], ...
    'Tag','Tabs');
ConfigurationTab = uitab(Tabs, 'Title','Configuration', ...
    'Tag','ConfigurationTab');
AnalysisTab = uitab(Tabs, 'Title','Analysis', ...
    'Tag','ConfigurationTab');

VersionText = uicontrol('parent',MainPanel, 'style','text', ...
    'units','norm', 'pos', [0.92, 0.975, 0.08, 0.025], ...
    'FontSize',12, 'string',['Version: ',VERSION], ...
    'backgroundcolor',[.8 1 .8], 'foregroundcolor',[.4 0 0]);


%% ========  Test  ======== %%

tempload = [];
tempfilename = [];
handles = [];
Test = [];
Tyres = {'FL'; 'FR';'RL';'RR'};
Color = {'b', 'r', 'c', 'm'};
IndTyres = [];
P_manualFlag = 0;
pFL_manual = [];
pFR_manual = [];
pRL_manual = [];
pRR_manual = [];
Regs_Offline_Selection_check = [];
Regs_Online_Selection_check = [];
Regs_NewNames_Selection_check = [];
Regs_Offline_Selection_flag = [];
Regs_Online_Selection_flag = [];
Regs_NewNames_Selection_flag = [];
Regs_Adjusted_Selection_flag = [];
data = [];
data2interp = [];
DataInt = [];
CommonTime = [];
fs = [];
H = [];

Raw2save = [];
Testpathname = [];
Testname = [];
Front_tyre_radius = []; %[m]
Rear_tyre_radius = []; %[m]
Results = [];
ExcelTable = [];
VehicleParameter = [];
Params = {'Static_FZ_FL','Static_FZ_FR','Static_FZ_RL','Static_FZ_RR',...
                  'Static_FZ_FrontAxle','Static_FZ_RearAxle','Static_FZ_Vehicle',...
                  'WheelBase','WheelTrackFront','WheelTrackRear',...
                  'FrontSection'};
DFTVehicle_Value = [5000,5000,4000,4000,...
                    10000,10000,18000,...
                    2.82,1.557,1.6,...
                    1.8];
FigHandle = [];               
FigVect = [];
FigInd = [];
FigInd2 = [];



%%%=== Configuration tab ===%%%
Configuration_Panel = uipanel('parent',ConfigurationTab,'units','norm', 'pos', [0, 0, 1, 1]);
VehicleFigure = axes('parent',Configuration_Panel, 'units','norm', 'pos', [0.35, 0.2, 0.3, 0.7]);
VehicleImageFile = 'vehicle.jpg';
VehicleImage = imread(VehicleImageFile);
imagesc(VehicleImage)
set(VehicleFigure,'handlevisibility','off','visible','off');


Test_name_text = uicontrol('parent',Configuration_Panel, 'style','text', ...
    'units','norm', 'pos',[0.35 0.925 0.3 0.025], ...
    'backgroundcolor',[1 1 0], 'string','');
EvaluateForces_button = uicontrol('parent',Configuration_Panel, 'style','push', ...
    'units','normalized', 'position', [0.45 0.10 0.1 0.05],'backgroundcolor',[1 0.8 0],...
    'fontsize',10, 'string','Evaluate Forces','FontWeight','bold','callback',@EvaluateForces);

Automatic_Multiple_EvaluateForces_button = uicontrol('parent',Configuration_Panel, 'style','push', ...
    'units','normalized', 'position', [0.56 0.10 0.2 0.05],'backgroundcolor',[0 1 0],...
    'fontsize',8, 'string','MultiFile Evaluate Forces & Saving','FontWeight','bold','callback',@AutomaticEvaluateForces);

Saving_SingleFile_button = uicontrol('parent',Configuration_Panel, 'style','push', ...
    'units','normalized', 'position', [0.77 0.10 0.1 0.05],'backgroundcolor',[1 1 0],...
    'fontsize',8, 'string','Saving Single File','FontWeight','bold','callback',@Saving_SingleFile);

SetManualPressure_check = uicontrol('parent',Configuration_Panel, 'style','pushbutton', ...
    'units','norm', 'pos',[0.05 0.65 0.3 0.05], ...
    'backgroundcolor',[0 1 1], 'string','Set Manual Pressures', ...'value',InfoFile.GainModeIndex,
    'callback',@SetManualPressure);

TyreRadiusFront_label = uicontrol('parent',Configuration_Panel, 'style','text', ...
    'units','norm', 'pos',[0.75 0.95 0.1 0.03],...
    'string','Tyre Radius Front [m]');
TyreRadiusRear_label = uicontrol('parent',Configuration_Panel, 'style','text', ...
    'units','norm', 'pos',[0.75 0.91 0.1 0.03],...
    'string','Tyre Radius Rear [m]');

TyreRadiusFront_edit = uicontrol('parent',Configuration_Panel, 'style','edit', ...
    'units','norm', 'pos',[0.85 0.95 0.05 0.03], ...
    'backgroundcolor',[1 1 1], ...'value',InfoFile.GainModeIndex,
    'callback',@SetTyreRadius);
TyreRadiusRear_edit = uicontrol('parent',Configuration_Panel, 'style','edit', ...
    'units','norm', 'pos',[0.85 0.91 0.05 0.03], ...
    'backgroundcolor',[1 1 1], ...'value',InfoFile.GainModeIndex,
    'callback',@SetTyreRadius);

InitVar(TyreRadiusFront_edit, 'String', num2str(0.339), 'FrontRad');
InitVar(TyreRadiusRear_edit, 'String', num2str(0.349), 'RearRad');


SamplingFrequency_label = uicontrol('parent',Configuration_Panel, 'style','text', ...
    'units','norm', 'pos',[0.45 0.05 0.1 0.03],...
    'string','Sampling Freq [hz]:');
SamplingFrequency_edit = uicontrol('parent',Configuration_Panel, 'style','edit', ...
    'units','norm', 'pos',[0.55 0.05 0.04 0.03], ...
    'backgroundcolor',[1 1 1], 'string','');
InitVar(SamplingFrequency_edit, 'String', num2str(100), 'SF');

FL_Panel = uipanel('parent',Configuration_Panel, 'units','norm', 'pos',[0.05 0.7 0.3 0.2], ...
    'backgroundcolor',[1 1 1], 'title','FL wheel','Fontsize',12,'FontWeight','bold');
FR_Panel = uipanel('parent',Configuration_Panel, 'units','norm', 'pos',[0.65 0.7 0.3 0.2], ...
    'backgroundcolor',[1 1 1], 'title','FR wheel','Fontsize',12,'FontWeight','bold');
RL_Panel = uipanel('parent',Configuration_Panel, 'units','norm', 'pos',[0.05 0.2 0.3 0.2], ...
    'backgroundcolor',[1 1 1], 'title','RL wheel','Fontsize',12,'FontWeight','bold');
RR_Panel = uipanel('parent',Configuration_Panel, 'units','norm', 'pos',[0.65 0.2 0.3 0.2], ...
    'backgroundcolor',[1 1 1], 'title','RR wheel','Fontsize',12,'FontWeight','bold');

SelectionForcesPanel = uipanel('parent',Configuration_Panel, 'units','norm', 'pos',[0.05 0.9 0.1 0.1], ...
    'backgroundcolor',[1 0.8 0], 'title','Forces Selection','Fontsize',8,'FontWeight','bold');

%%% Forces checkbox
FZ_DR_Checkbox = uicontrol('parent',SelectionForcesPanel, 'style','checkbox', ...
    'units','norm', 'pos',[0.0 0.67 0.8 0.3], ...
    ...'foregroundcolor',[1 1 1], ...'value',InfoFile.EvaluateCANIndex,
    'callback',@InitChecks,'tag','FZ_DR_Check','String','Fz - DR','Fontsize',10,'FontWeight','bold');
InitVarsByTag(FZ_DR_Checkbox,'Value')
% InitEmptyVariable('FL_FZ_DR_Check', pwd);
FZ_PL_Checkbox = uicontrol('parent',SelectionForcesPanel, 'style','checkbox', ...
    'units','norm', 'pos',[0.0 0.36 0.8 0.3], ...
    ...'foregroundcolor',[1 1 1], ...'value',InfoFile.EvaluateCANIndex,
    'callback',@InitChecks,'tag','FZ_PL_Check','String','Fz - PL','Fontsize',10,'FontWeight','bold');
InitVarsByTag(FZ_PL_Checkbox,'Value')
FX_DRCV_Checkbox = uicontrol('parent',SelectionForcesPanel, 'style','checkbox', ...
    'units','norm', 'pos',[0.0 0.05 0.8 0.3], ...
    ...'foregroundcolor',[1 1 1], ...'value',InfoFile.EvaluateCANIndex,
    'callback',@InitChecks,'tag','FX_DRCV_Check','String','Fx - DRCV','Fontsize',10,'FontWeight','bold');
InitVarsByTag(FX_DRCV_Checkbox,'Value')

%%% Node selection
uicontrol('parent',Configuration_Panel, 'style', 'text', 'Fontsize',8, ...
    'units','norm', 'position', [0.2 0.9 0.05 0.075], 'String','Node', 'FontWeight','Bold');
SensorOrdered = {'SN0', 'SN1', 'SN2', 'SN3','Double','Triple'};
% iNode = 1;
NVect = 1;
SensorToUseList = uicontrol('parent',Configuration_Panel, 'style','pop', ...
    'units','normalized', 'position', [0.2 0.88 0.05 0.075], ...
    'backgroundcolor',[.5 1 .5],'String',SensorOrdered, ...
    'callback',@ChangeSensor);
InitVar(SensorToUseList, 'Value', NVect, 'NodeValue');
ChangeSensor();

%%% FZ - DR pushbutton
BrowseFL_FZ_DR_pushbutton = uicontrol('parent',FL_Panel, 'style','push', ...
    'units','normalized', 'position', [0.07 0.8 0.15 0.2], ...
    'fontsize',10, 'string','browse','callback',@ChooseCalibFL_FZ_DR);
BrowseFR_FZ_DR_pushbutton = uicontrol('parent',FR_Panel, 'style','push', ...
    'units','normalized', 'position', [0.07 0.8 0.15 0.2], ...
    'fontsize',10, 'string','browse','callback',@ChooseCalibFR_FZ_DR);
BrowseRL_FZ_DR_pushbutton = uicontrol('parent',RL_Panel, 'style','push', ...
    'units','normalized', 'position', [0.07 0.8 0.15 0.2], ...
    'fontsize',10, 'string','browse','callback',@ChooseCalibRL_FZ_DR);
BrowseRR_FZ_DR_pushbutton = uicontrol('parent',RR_Panel, 'style','push', ...
    'units','normalized', 'position', [0.07 0.8 0.15 0.2], ...
    'fontsize',10, 'string','browse','callback',@ChooseCalibRR_FZ_DR);

%%% FZ - PL pushbutton
BrowseFL_FZ_PL_pushbutton = uicontrol('parent',FL_Panel, 'style','push', ...
    'units','normalized', 'position', [0.07 0.6 0.15 0.2], ...
    'fontsize',10, 'string','browse','callback',@ChooseCalibFL_FZ_PL);
BrowseFR_FZ_PL_pushbutton = uicontrol('parent',FR_Panel, 'style','push', ...
    'units','normalized', 'position', [0.07 0.6 0.15 0.2], ...
    'fontsize',10, 'string','browse','callback',@ChooseCalibFR_FZ_PL);
BrowseRL_FZ_PL_pushbutton = uicontrol('parent',RL_Panel, 'style','push', ...
    'units','normalized', 'position', [0.07 0.6 0.15 0.2], ...
    'fontsize',10, 'string','browse','callback',@ChooseCalibRL_FZ_PL);
BrowseRR_FZ_PL_pushbutton = uicontrol('parent',RR_Panel, 'style','push', ...
    'units','normalized', 'position', [0.07 0.6 0.15 0.2], ...
    'fontsize',10, 'string','browse','callback',@ChooseCalibRR_FZ_PL);

%%% FX - DRCV pushbutton
BrowseFL_FX_DRCV_pushbutton = uicontrol('parent',FL_Panel, 'style','push', ...
    'units','normalized', 'position', [0.07 0.4 0.15 0.2], ...
    'fontsize',10, 'string','browse','callback',@ChooseCalibFL_FX_DRCV);
BrowseFR_FX_DRCV_pushbutton = uicontrol('parent',FR_Panel, 'style','push', ...
    'units','normalized', 'position', [0.07 0.4 0.15 0.2], ...
    'fontsize',10, 'string','browse','callback',@ChooseCalibFR_FX_DRCV);
BrowseRL_FX_DRCV_pushbutton = uicontrol('parent',RL_Panel, 'style','push', ...
    'units','normalized', 'position', [0.07 0.4 0.15 0.2], ...
    'fontsize',10, 'string','browse','callback',@ChooseCalibRL_FX_DRCV);
BrowseRR_FX_DRCV_pushbutton = uicontrol('parent',RR_Panel, 'style','push', ...
    'units','normalized', 'position', [0.07 0.4 0.15 0.2], ...
    'fontsize',10, 'string','browse','callback',@ChooseCalibRR_FX_DRCV);


%%% FZ - DR edit
FileFL_FZ_DR_edit = uicontrol('parent',FL_Panel, 'style','text', ...
    'units','norm', 'pos',[0.22 0.8 0.6 0.2], ...
    'backgroundcolor',[0.8 0.8 1], 'string','','tag','FileFL_FZ_DR_path');
InitVarsByTag(FileFL_FZ_DR_edit,'String')
InitEmptyVariable('Path_FL_FZ_DR', pwd);
FileFR_FZ_DR_edit = uicontrol('parent',FR_Panel, 'style','text', ...
    'units','norm', 'pos',[0.22 0.8 0.6 0.2], ...
    'backgroundcolor',[0.8 0.8 1], 'string','','tag','FileFR_FZ_DR_path');
InitVarsByTag(FileFR_FZ_DR_edit,'String')
InitEmptyVariable('Path_FR_FZ_DR', pwd);
FileRL_FZ_DR_edit = uicontrol('parent',RL_Panel, 'style','text', ...
    'units','norm', 'pos',[0.22 0.8 0.6 0.2], ...
    'backgroundcolor',[0.8 0.8 1], 'string','','tag','FileRL_FZ_DR_path');
InitVarsByTag(FileRL_FZ_DR_edit,'String')
InitEmptyVariable('Path_RL_FZ_DR', pwd);
FileRR_FZ_DR_edit = uicontrol('parent',RR_Panel, 'style','text', ...
    'units','norm', 'pos',[0.22 0.8 0.6 0.2], ...
    'backgroundcolor',[0.8 0.8 1], 'string','','tag','FileRR_FZ_DR_path');
InitVarsByTag(FileRR_FZ_DR_edit,'String')
InitEmptyVariable('Path_RR_FZ_DR', pwd);

%%% FZ - PL edit
FileFL_FZ_PL_edit = uicontrol('parent',FL_Panel, 'style','text', ...
    'units','norm', 'pos',[0.22 0.6 0.6 0.2], ...
    'backgroundcolor',[0.8 0.8 1], 'string','','tag','FileFL_FZ_PL_path');
InitVarsByTag(FileFL_FZ_PL_edit,'String')
InitEmptyVariable('Path_FL_FZ_PL', pwd);
FileFR_FZ_PL_edit = uicontrol('parent',FR_Panel, 'style','text', ...
    'units','norm', 'pos',[0.22 0.6 0.6 0.2], ...
    'backgroundcolor',[0.8 0.8 1], 'string','','tag','FileFR_FZ_PL_path');
InitVarsByTag(FileFR_FZ_PL_edit,'String')
InitEmptyVariable('Path_FR_FZ_PL', pwd);
FileRL_FZ_PL_edit = uicontrol('parent',RL_Panel, 'style','text', ...
    'units','norm', 'pos',[0.22 0.6 0.6 0.2], ...
    'backgroundcolor',[0.8 0.8 1], 'string','','tag','FileRL_FZ_PL_path');
InitVarsByTag(FileRL_FZ_PL_edit,'String')
InitEmptyVariable('Path_RL_FZ_PL', pwd);
FileRR_FZ_PL_edit = uicontrol('parent',RR_Panel, 'style','text', ...
    'units','norm', 'pos',[0.22 0.6 0.6 0.2], ...
    'backgroundcolor',[0.8 0.8 1], 'string','','tag','FileRR_FZ_PL_path');
InitVarsByTag(FileRR_FZ_PL_edit,'String')
InitEmptyVariable('Path_RR_FZ_PL', pwd);

%%% FX - DRCV edit
FileFL_FX_DRCV_edit = uicontrol('parent',FL_Panel, 'style','text', ...
    'units','norm', 'pos',[0.22 0.4 0.6 0.2], ...
    'backgroundcolor',[0.8 0.8 1], 'string','','tag','FileFL_FX_DRCV_path');
InitVarsByTag(FileFL_FX_DRCV_edit,'String')
InitEmptyVariable('Path_FL_FX_DRCV', pwd);
FileFR_FX_DRCV_edit = uicontrol('parent',FR_Panel, 'style','text', ...
    'units','norm', 'pos',[0.22 0.4 0.6 0.2], ...
    'backgroundcolor',[0.8 0.8 1], 'string','','tag','FileFR_FX_DRCV_path');
InitVarsByTag(FileFR_FX_DRCV_edit,'String')
InitEmptyVariable('Path_FR_FX_DRCV', pwd);
FileRL_FX_DRCV_edit = uicontrol('parent',RL_Panel, 'style','text', ...
    'units','norm', 'pos',[0.22 0.4 0.6 0.2], ...
    'backgroundcolor',[0.8 0.8 1], 'string','','tag','FileRL_FX_DRCV_path');
InitVarsByTag(FileRL_FX_DRCV_edit,'String')
InitEmptyVariable('Path_RL_FX_DRCV', pwd);
FileRR_FX_DRCV_edit = uicontrol('parent',RR_Panel, 'style','text', ...
    'units','norm', 'pos',[0.22 0.4 0.6 0.2], ...
    'backgroundcolor',[0.8 0.8 1], 'string','','tag','FileRR_FX_DRCV_path');
InitVarsByTag(FileRR_FX_DRCV_edit,'String')
InitEmptyVariable('Path_RR_FX_DRCV', pwd);

%%% FZ - DR label
FileFL_FZ_DR_label = uicontrol('parent',FL_Panel, 'style','text', ...
    'units','norm', 'pos',[0.82 0.79 0.2 0.2], 'string','FZ(DR)',...
    'backgroundcolor',[1 1 1], 'FontSize',12);
FileFR_FZ_DR_label = uicontrol('parent',FR_Panel, 'style','text', ...
    'units','norm', 'pos',[0.82 0.79 0.2 0.2], 'string','FZ(DR)',...
    'backgroundcolor',[1 1 1], 'FontSize',12);
FileRL_FZ_DR_label = uicontrol('parent',RL_Panel, 'style','text', ...
    'units','norm', 'pos',[0.82 0.79 0.2 0.2], 'string','FZ(DR)',...
    'backgroundcolor',[1 1 1], 'FontSize',12);
FileRR_FZ_DR_label = uicontrol('parent',RR_Panel, 'style','text', ...
    'units','norm', 'pos',[0.82 0.79 0.2 0.2], 'string','FZ(DR)',...
    'backgroundcolor',[1 1 1], 'FontSize',12);

%%% FZ - PL label
FileFL_FZ_PL_label = uicontrol('parent',FL_Panel, 'style','text', ...
    'units','norm', 'pos',[0.82 0.59 0.2 0.2], 'string','FZ(PL)',...
    'backgroundcolor',[1 1 1], 'FontSize',12);
FileFR_FZ_PL_label = uicontrol('parent',FR_Panel, 'style','text', ...
    'units','norm', 'pos',[0.82 0.59 0.2 0.2], 'string','FZ(PL)',...
    'backgroundcolor',[1 1 1], 'FontSize',12);
FileRL_FZ_PL_label = uicontrol('parent',RL_Panel, 'style','text', ...
    'units','norm', 'pos',[0.82 0.59 0.2 0.2], 'string','FZ(PL)',...
    'backgroundcolor',[1 1 1], 'FontSize',12);
FileRR_FZ_PL_label = uicontrol('parent',RR_Panel, 'style','text', ...
    'units','norm', 'pos',[0.82 0.59 0.2 0.2], 'string','FZ(PL)',...
    'backgroundcolor',[1 1 1], 'FontSize',12);

%%% FX - DRCV label
FileFL_FX_DRCV_label = uicontrol('parent',FL_Panel, 'style','text', ...
    'units','norm', 'pos',[0.82 0.39 0.2 0.2], 'string','FX(DRCV)',...
    'backgroundcolor',[1 1 1], 'FontSize',8);
FileFR_FX_DRCV_label = uicontrol('parent',FR_Panel, 'style','text', ...
    'units','norm', 'pos',[0.82 0.39 0.2 0.2], 'string','FX(DRCV)',...
    'backgroundcolor',[1 1 1], 'FontSize',8);
FileRL_FX_DRCV_label = uicontrol('parent',RL_Panel, 'style','text', ...
    'units','norm', 'pos',[0.82 0.39 0.2 0.2], 'string','FX(DRCV)',...
    'backgroundcolor',[1 1 1], 'FontSize',8);
FileRR_FX_DRCV_label = uicontrol('parent',RR_Panel, 'style','text', ...
    'units','norm', 'pos',[0.82 0.39 0.2 0.2], 'string','FX(DRCV)',...
    'backgroundcolor',[1 1 1], 'FontSize',8);

InitChecks

Regs_Online_Selection_check = uicontrol('parent',Configuration_Panel, 'style','check', ...
    'units','norm', 'pos',[0.35 0.125 0.1 0.025],'backgroundcolor',[1 1 1], 'string','ONline Regs',...
    'fontsize',9); %'callback',@SetEvaluationSelection);
Regs_Offline_Selection_check = uicontrol('parent',Configuration_Panel, 'style','check', ...
    'units','norm', 'pos',[0.35 0.10 0.1 0.025],'backgroundcolor',[1 1 1], 'string','OFFline Regs',...
    'fontsize',9); %'callback',@SetEvaluationSelection);
Regs_NewNames_Selection_check = uicontrol('parent',Configuration_Panel, 'style','check', ...
    'units','norm', 'pos',[0.35 0.075 0.1 0.025],'backgroundcolor',[1 1 1], 'string','Regs New Names',...
    'fontsize',9); %'callback',@SetEvaluationSelection);
Regs_Adjusted_Selection_check = uicontrol('parent',Configuration_Panel, 'style','check', ...
    'units','norm', 'pos',[0.35 0.05 0.1 0.025],'backgroundcolor',[1 1 1], 'string','Regs Adjusted',...
    'fontsize',9); %'callback',@SetEvaluationSelection);

FxChangeSign = uicontrol('style','checkbox','parent',Configuration_Panel, 'units','norm', 'pos',[.12 .12 .153 .03],...
            'BackgroundColor',[1 1 1],'string','Change Right Wheel Fx Sign','Fontsize',10,'Fontweight','bold');
InitVar(FxChangeSign, 'Value', 0, 'ChangeFxSign');

%%%=== Analysis Tab ===%%%
Manouver_Fig1.asse = axes('parent',AnalysisTab, 'units','norm', 'pos', [0.1, 0.71, 0.55, 0.25],'XGrid','on','YGrid','on');
Manouver_Fig2.asse = axes('parent',AnalysisTab, 'units','norm', 'pos', [0.1, 0.43, 0.55, 0.25],'XGrid','on','YGrid','on');
Manouver_Fig3.asse = axes('parent',AnalysisTab, 'units','norm', 'pos', [0.1, 0.15, 0.55, 0.25],'XGrid','on','YGrid','on');
linkaxes([Manouver_Fig1.asse Manouver_Fig2.asse Manouver_Fig3.asse],'x');

Manouver_Fig1.linea1 = line('parent',Manouver_Fig1.asse,'visible','off');
Manouver_Fig1.linea2 = line('parent',Manouver_Fig1.asse,'visible','off');
Manouver_Fig1.linea3 = line('parent',Manouver_Fig1.asse,'visible','off');

Manouver_Fig2.linea1 = line('parent',Manouver_Fig2.asse,'visible','off');
Manouver_Fig2.linea2 = line('parent',Manouver_Fig2.asse,'visible','off');
Manouver_Fig2.linea3 = line('parent',Manouver_Fig2.asse,'visible','off');
Manouver_Fig2.linea4 = line('parent',Manouver_Fig2.asse,'visible','off');

Manouver_Fig3.linea1 = line('parent',Manouver_Fig3.asse,'visible','off');
Manouver_Fig3.linea2 = line('parent',Manouver_Fig3.asse,'visible','off');
Manouver_Fig3.linea3 = line('parent',Manouver_Fig3.asse,'visible','off');
Manouver_Fig3.linea4 = line('parent',Manouver_Fig3.asse,'visible','off');


RegsFZ_Popup = uicontrol('parent',AnalysisTab, 'style','popup', ...
    'units','norm', 'pos',[0.005 0.63 0.05 0.05], ...
    'backgroundcolor',[0 0 .75], 'foregroundcolor',[1 1 1], ...
    'string',{'FZ_DR','FZ_PL','FX_DRCV'}, ...'value',InfoFile.XdirIndex, ...
    'callback',@SetForces);
InitVar(RegsFZ_Popup, 'Value', 1, 'RegsFZ_Index');

% Analysis Panel
AnalysisPanel = uipanel('parent',AnalysisTab, 'units','norm', 'pos',[0.7 0.35 0.25 0.6], ...
    'backgroundcolor',[0.8 0.8 1]);

uicontrol('parent',AnalysisPanel,'Style','text','units','norm','pos',[0 0.94 1 0.05], ...
    'backgroundcolor',[0.8 0.8 1],'String','Available Analysis','fontsize',16,'fontweight','bold');

ScriptList = uicontrol('parent',AnalysisPanel,'Style','listbox','units','norm','pos',[0.02 0.08 0.96 0.84], ...
    'backgroundcolor',[1 1 1],'String',{},'callback',@RunAnalisys);
InitVar(ScriptList, 'String', {}, 'AnalysisScripts');
InitEmptyVariable('AnalysisFolders', {});

AddScript_button = uicontrol('parent',AnalysisPanel, 'style','push', ...
    'units','normalized', 'position', [0.02 0.02 0.46 0.04],'backgroundcolor',[0.9 0.9 0.9],...
    'fontsize',8, 'string','Add Analysis','FontWeight','bold','callback',@AddScript);
RemScript_button = uicontrol('parent',AnalysisPanel, 'style','push', ...
    'units','normalized', 'position', [0.52 0.02 0.46 0.04],'backgroundcolor',[0.9 0.9 0.9],...
    'fontsize',8, 'string','Remove Analysis','FontWeight','bold','callback',@RemoveScript);

Ginput_Selection = uicontrol('parent',AnalysisTab, 'style','check', ...
    'units','norm', 'pos',[0.7 0.25 0.1 0.04],'backgroundcolor',[.8 .8 .8], 'string','Use GInput',...
    'fontsize',9);
Filter_Selection = uicontrol('parent',AnalysisTab, 'style','check', ...
    'units','norm', 'pos',[0.7 0.20 0.1 0.04],'backgroundcolor',[.8 .8 .8], 'string','Filter Force',...
    'fontsize',9);
DBGFigure_Selection = uicontrol('parent',AnalysisTab, 'style','check', ...
    'units','norm', 'pos',[0.7 0.15 0.1 0.04],'backgroundcolor',[.8 .8 .8], 'string','DBG Figure',...
    'fontsize',9);

SaveExcel_button = uicontrol('parent',AnalysisTab, 'style','push', ...
    'units','normalized', 'position', [0.82 0.15 0.13 0.04],'backgroundcolor',[0 0.8 0],...
    'fontsize',10, 'string','Save Analysis Data','FontWeight','bold','callback',@SaveExcel);

ClearExcel_button = uicontrol('parent',AnalysisTab, 'style','push', ...
    'units','normalized', 'position', [0.82 0.2 0.13 0.04],'backgroundcolor',[0 0.8 0],...
    'fontsize',10, 'string','Clear Analysis Data','FontWeight','bold','callback',@ClearExcel);

VisualizeExcel_button = uicontrol('parent',AnalysisTab, 'style','push', ...
    'units','normalized', 'position', [0.82 0.25 0.13 0.04],'backgroundcolor',[0 0.8 0],...
    'fontsize',10, 'string','Visualize Analysis Data','FontWeight','bold','callback',@VisualizeExcel);

VehicleParamsSetup = uicontrol('parent',AnalysisTab, 'style','push', ...
    'units','normalized', 'position', [0.7 0.04 0.25 0.08],'backgroundcolor',[0 0.8 0.8],...
    'fontsize',16, 'string','Set Vehicle Parameter','FontWeight','bold','callback',@SetParams);
for IndP = 1:length(Params)
    InitEmptyVariable(Params{IndP},DFTVehicle_Value(IndP));
end
UpdateVehicleParams;

% ========  End Test  ======== %

%%
% ResizeFilePanel();
% FMPanel.ResizeFcn = @ResizeFilePanel;
% END files management
%%

% UpdateList();

%% ==================== %%
%  === SubFunctions === %%
%  ==================== %%


%% ChooseCalibFL_FZ_DR
    function ChooseCalibFL_FZ_DR(obj, event)
        [filename, pathname] = uigetfile([InfoFile.Path_FL_FZ_DR, filesep, '*.calibration.mat'],'Select a calibration file','MultiSelect', 'off');
        if ischar(filename)
            InfoFile.Path_FL_FZ_DR = pathname;
            set(FileFL_FZ_DR_edit , 'String' , filename)
        end
    end

%% ChooseCalibFR_FZ_DR
    function ChooseCalibFR_FZ_DR(obj, event)
        [filename, pathname] = uigetfile([InfoFile.Path_FR_FZ_DR, filesep, '*.calibration.mat'],'Select a calibration file','MultiSelect', 'off');
        if ischar(filename)
            InfoFile.Path_FR_FZ_DR = pathname;
            set(FileFR_FZ_DR_edit , 'String' , filename)
        end
    end

%% ChooseCalibRL_FZ_DR
    function ChooseCalibRL_FZ_DR(obj, event)
        [filename, pathname] = uigetfile([InfoFile.Path_RL_FZ_DR, filesep, '*.calibration.mat'],'Select a calibration file','MultiSelect', 'off');
        if ischar(filename)
            InfoFile.Path_RL_FZ_DR = pathname;
            set(FileRL_FZ_DR_edit , 'String' , filename)
        end
    end

%% ChooseCalibRR_FZ_DR
    function ChooseCalibRR_FZ_DR(obj, event)
        [filename, pathname] = uigetfile([InfoFile.Path_RR_FZ_DR, filesep, '*.calibration.mat'],'Select a calibration file','MultiSelect', 'off');
        if ischar(filename)
            InfoFile.Path_RR_FZ_DR = pathname;
            set(FileRR_FZ_DR_edit , 'String' , filename)
        end
    end

%% ChooseCalibFL_FZ_PL
    function ChooseCalibFL_FZ_PL(obj, event)
        [filename, pathname] = uigetfile([InfoFile.Path_FL_FZ_PL, filesep, '*.calibration.mat'],'Select a calibration file','MultiSelect', 'off');
        if ischar(filename)
            InfoFile.Path_FL_FZ_PL = pathname;
            set(FileFL_FZ_PL_edit , 'String' , filename)
        end
    end
%% ChooseCalibFR_FZ_PL
    function ChooseCalibFR_FZ_PL(obj, event)
        [filename, pathname] = uigetfile([InfoFile.Path_FR_FZ_PL, filesep, '*.calibration.mat'],'Select a calibration file','MultiSelect', 'off');
        if ischar(filename)
            InfoFile.Path_FR_FZ_PL = pathname;
            set(FileFR_FZ_PL_edit , 'String' , filename)
        end
    end

%% ChooseCalibRL_FZ_PL
    function ChooseCalibRL_FZ_PL(obj, event)
        [filename, pathname] = uigetfile([InfoFile.Path_RL_FZ_PL, filesep, '*.calibration.mat'],'Select a calibration file','MultiSelect', 'off');
        if ischar(filename)
            InfoFile.Path_RL_FZ_PL = pathname;
            set(FileRL_FZ_PL_edit , 'String' , filename)
        end
    end

%% ChooseCalibRR_FZ_PL
    function ChooseCalibRR_FZ_PL(obj, event)
        [filename, pathname] = uigetfile([InfoFile.Path_RR_FZ_PL, filesep, '*.calibration.mat'],'Select a calibration file','MultiSelect', 'off');
        if ischar(filename)
            InfoFile.Path_RR_FZ_PL = pathname;
            set(FileRR_FZ_PL_edit , 'String' , filename)
        end
    end

%% ChooseCalibFL_FX_DRCV
    function ChooseCalibFL_FX_DRCV(obj, event)
        [filename, pathname] = uigetfile([InfoFile.Path_FL_FX_DRCV, filesep, '*.calibration.mat'],'Select a calibration file','MultiSelect', 'off');
        if ischar(filename)
            InfoFile.Path_FL_FX_DRCV = pathname;
            set(FileFL_FX_DRCV_edit , 'String' , filename)
        end
    end
%% ChooseCalibFR_FX_DRCV
    function ChooseCalibFR_FX_DRCV(obj, event)
        [filename, pathname] = uigetfile([InfoFile.Path_FR_FX_DRCV, filesep, '*.calibration.mat'],'Select a calibration file','MultiSelect', 'off');
        if ischar(filename)
            InfoFile.Path_FR_FX_DRCV = pathname;
            set(FileFR_FX_DRCV_edit , 'String' , filename)
        end
    end

%% ChooseCalibRL_FX_DRCV
    function ChooseCalibRL_FX_DRCV(obj, event)
        [filename, pathname] = uigetfile([InfoFile.Path_RL_FX_DRCV, filesep, '*.calibration.mat'],'Select a calibration file','MultiSelect', 'off');
        if ischar(filename)
            InfoFile.Path_RL_FX_DRCV = pathname;
            set(FileRL_FX_DRCV_edit , 'String' , filename)
        end
    end

%% ChooseCalibRR_FX_DRCV
    function ChooseCalibRR_FX_DRCV(obj, event)
        [filename, pathname] = uigetfile([InfoFile.Path_RR_FX_DRCV, filesep, '*.calibration.mat'],'Select a calibration file','MultiSelect', 'off');
        if ischar(filename)
            InfoFile.Path_RR_FX_DRCV = pathname;
            set(FileRR_FX_DRCV_edit , 'String' , filename)
        end
    end


%% LoadTest
    function LoadTest(Testpathname, Testname) %(obj, event) %#ok<INUSD>
        if Testname
            data = [];
            DataInt = [];
            h = waitbar(1/10,'Please wait, loading file');
            FilePath = [Testpathname, filesep, Testname];
            Test = load(FilePath);
            waitbar(1,h,'Test loaded')
            pause(0.5)
            close(h)
            set(Test_name_text,'string',Testname,'Fontsize',12,'FontWeight','bold');
            
            CommonTimeDef();
            
            data2int      = Test.DecodedCAN;
            
            DataInt = CommonTimeInterp(data2int,fs,CommonTime(1),CommonTime(end));
            
            ElaborateTest();
        end
    end

%% CommonTimeDefinition
    function CommonTimeDef(obj, event)
        MaxEndTime = [];
        if isfield(Test,'DecodedCAN')
            CANfields = fields(Test.DecodedCAN);
            for nFields = 1 : length(CANfields)
                if not(isempty(strfind(CANfields{nFields},'time')))
                    if isempty(MaxEndTime)
                        MaxEndTime = max(Test.DecodedCAN.(CANfields{nFields}));
                    elseif max(Test.DecodedCAN.(CANfields{nFields})) > MaxEndTime
                        MaxEndTime = max(Test.DecodedCAN.(CANfields{nFields}));
                    end
                end
            end
        end
        
        fs = str2double(InfoFile.SF); %[Hz]
        fs_export = str2double(InfoFile.SF); %[Hz]
        dt_export = 1/fs_export; %[Hz]
        FirstTime_export = 0; %[s]
        CommonTime = FirstTime_export : dt_export : (ceil(MaxEndTime/dt_export))*dt_export;
    end

%% ElaborateTest
    function ElaborateTest(obj, event)
        set(Manouver_Fig1.linea3,'xdata',DataInt.Time,'ydata',DataInt.Vehicle_Speed/10,'visible','on','color','k','Linewidth',2,'DisplayName','Vehicle_Speed [km/h]');
        set(Manouver_Fig1.linea2,'xdata',DataInt.Time,'ydata',DataInt.LongAcc,'visible','on','color','b','Linewidth',2,'DisplayName','Long Acc [m/s^2]');
        set(Manouver_Fig1.linea1,'xdata',DataInt.Time,'ydata',DataInt.LatAcc,'visible','on','color','r','Linewidth',2,'DisplayName','Lat Acc [m/s^2]');
        
        set(Manouver_Fig1.asse,'XLimMode','auto','YLimMode','auto')
        legendFromDisplayName(Manouver_Fig1.asse);
        linkaxes([Manouver_Fig1.asse Manouver_Fig2.asse Manouver_Fig3.asse],'x');
    end

%% EvaluateForces

    function EvaluateForces(obj, event) %#ok<INUSD>
        Testpathname = InfoFile.DataFolder;
        
        h = waitbar(1/10,'Please wait, evaluating forces');
        for iNode = NVect
            if get(Regs_Offline_Selection_check,'value') == 0 & get(Regs_Online_Selection_check,'value') == 0
                msgbox('Please choose Online - Offline');
                return
            elseif get(Regs_Offline_Selection_check,'value') == 0 & get(Regs_Online_Selection_check,'value') == 1
                regsfields = fields(Test.Tire(1).Node(iNode).regs);
                checkSum(1) = sum(strcmp(regsfields,'Time_online'));
                checkSum(2) = sum(strcmp(regsfields,'DR_online'));
                checkSum(3) = sum(strcmp(regsfields,'PL_online'));
                checkSum(4) = sum(strcmp(regsfields,'DRCV_online'));
                checkSum(5) = sum(strcmp(regsfields,'omega_online'));
                checkPresence = sum(checkSum);
                if  checkPresence < 5
                    msgbox('Sorry , at least one online reg missing');
                    return
                else
                    Regs_Online_Selection_flag = get(Regs_Online_Selection_check,'value');
                    Regs_Offline_Selection_flag = 0;
                end
            elseif get(Regs_Offline_Selection_check,'value') == 1 & get(Regs_Online_Selection_check,'value') == 0
                if get(Regs_NewNames_Selection_check, 'value') & not(isfield(Test.Tire(1).Node(1).regs,'DR_filtMain')) & not(get(Regs_Adjusted_Selection_check, 'value'))
                    msgbox('Sorry , at least one offline reg missing');
                    return
                elseif not(get(Regs_NewNames_Selection_check, 'value')) & not(isfield(Test.Tire(1).Node(iNode).regs,'DR_adj')) & get(Regs_Adjusted_Selection_check, 'value')
                    msgbox('Sorry , at least one offline reg missing');
                    return
                elseif not(get(Regs_NewNames_Selection_check, 'value')) & not(isfield(Test.Tire(1).Node(iNode).regs,'DR')) & not(get(Regs_Adjusted_Selection_check, 'value'))
                    msgbox('Sorry , at least one offline reg missing');
                    return
                end
                Regs_Offline_Selection_flag = get(Regs_Offline_Selection_check,'value');
                Regs_Online_Selection_flag = 0;
                %         elseif get(Regs_Offline_Selection_check,'value') == 1 & get(Regs_Online_Selection_check,'value') == 0
                %             Regs_Offline_Selection_flag = get(Regs_Offline_Selection_check,'value');
                %             Regs_Online_Selection_flag = 0;
            end
            
            
            if get(Regs_NewNames_Selection_check,'value') == 1
                Regs_NewNames_Selection_flag = true;
            else
                Regs_NewNames_Selection_flag = false;
            end
            
            if get(Regs_Adjusted_Selection_check,'value') == 1
                Regs_Adjusted_Selection_flag = true;
            else
                Regs_Adjusted_Selection_flag = false;
            end
            
            
            %         Tyres = fields(handles);
            IndTyres(find(strcmp(Tyres,'FR'))) = 1;
            IndTyres(find(strcmp(Tyres,'FL'))) = 2;
            IndTyres(find(strcmp(Tyres,'RR'))) = 3;
            IndTyres(find(strcmp(Tyres,'RL'))) = 4;
            
            %%%%%%%% Load Forces Calib coeff
            for t = 1 : length(Tyres)
                
                % ========== FZ - DR
                if InfoFile.FL_FZ_DR_Check
                    eval(['tempfilename = get(File',(Tyres{t}),'_FZ_DR_edit,''String'');']);
                    if ischar(tempfilename)
                        eval(['tempload = load([InfoFile.Path_',(Tyres{t}),'_FZ_DR,filesep,tempfilename]);']);
                        eval(['handles.',(Tyres{t}),'.FZ.DR.head = tempload.head;']);
                        eval(['handles.',(Tyres{t}),'.FZ.DR.coef = single(tempload.coef);']);
                        eval(['handles.',(Tyres{t}),'.FZ.DR.mdl = tempload.mdl;']);
                        eval(['handles.',(Tyres{t}),'.FZ.DR.flag = 1;']);
                    else
                        eval(['handles.FL.FZ.DR.flag = 0']);
                    end
                end
                
                if InfoFile.FL_FZ_PL_Check
                    %=========== FZ - PL
                    eval(['tempfilename = get(File',(Tyres{t}),'_FZ_PL_edit,''String'');']);
                    if ischar(tempfilename)
                        eval(['tempload = load([InfoFile.Path_',(Tyres{t}),'_FZ_PL,filesep,tempfilename]);']);
                        eval(['handles.',(Tyres{t}),'.FZ.PL.head = tempload.head;']);
                        eval(['handles.',(Tyres{t}),'.FZ.PL.coef = single(tempload.coef);']);
                        eval(['handles.',(Tyres{t}),'.FZ.PL.mdl = tempload.mdl;']);
                        eval(['handles.',(Tyres{t}),'.FZ.PL.flag = 1;']);
                    else
                        eval(['handles.FL.FZ.PL.flag = 0']);
                    end
                end
                
                % ========== FX - DRCV
                if InfoFile.FL_FX_DRCV_Check
                    eval(['tempfilename = get(File',(Tyres{t}),'_FX_DRCV_edit,''String'');']);
                    if ischar(tempfilename)
                        eval(['tempload = load([InfoFile.Path_',(Tyres{t}),'_FX_DRCV,filesep,tempfilename]);']);
                        eval(['handles.',(Tyres{t}),'.FX.DRCV.head = tempload.head;']);
                        eval(['handles.',(Tyres{t}),'.FX.DRCV.coef = single(tempload.coef);']);
                        eval(['handles.',(Tyres{t}),'.FX.DRCV.mdl = tempload.mdl;']);
                        eval(['handles.',(Tyres{t}),'.FX.DRCV.flag = 1;']);
                    else
                        eval(['handles.FL.FX.DRCV.flag = 0']);
                    end
                end
            end
            
            %%%%%%%% Evaluate Forces from mdl
            
            if exist('Test') & not(isempty(Test))
                for t = 1 : length(Tyres)
                    handles.(Tyres{t}).OutdoorData = [];
                    if (length(Test.Tire(IndTyres(t)).Node) < iNode) || isempty(Test.Tire(IndTyres(t)).Node(iNode).dbinfo)
                        continue
                    else
                        if isnan(Test.Tire(IndTyres(t)).Node(iNode).regs.Time)
                            continue
                        else
                            if Regs_Offline_Selection_flag
                                if Regs_NewNames_Selection_flag
                                    data.Tire(IndTyres(t)).regs.DR = Test.Tire(IndTyres(t)).Node(iNode).regs.DR_filtMain;
                                    data.Tire(IndTyres(t)).regs.PL = Test.Tire(IndTyres(t)).Node(iNode).regs.PL_filtMain;
                                    if length(Test.Tire(IndTyres(t)).Node) > 1
                                        if ~isempty(Test.Tire(IndTyres(t)).Node(1).dbinfo) && ~isempty(Test.Tire(IndTyres(t)).Node(2).dbinfo)
                                            data.Tire(IndTyres(t)).regs.PL_SN0 = Test.Tire(IndTyres(t)).Node(1).regs.PL_filtMain;
                                            data.Tire(IndTyres(t)).regs.PL_SN1 = Test.Tire(IndTyres(t)).Node(2).regs.PL_filtMain;
                                        end
                                    end
                                    data.Tire(IndTyres(t)).regs.DRCV = Test.Tire(IndTyres(t)).Node(iNode).regs.DRCV_filtMain;
                                elseif Regs_Adjusted_Selection_flag
                                    data.Tire(IndTyres(t)).regs.DR = Test.Tire(IndTyres(t)).Node(iNode).regs.DR_adj;
                                    data.Tire(IndTyres(t)).regs.PL = Test.Tire(IndTyres(t)).Node(iNode).regs.PL_DR;
                                    if length(Test.Tire(IndTyres(t)).Node) > 1
                                        if ~isempty(Test.Tire(IndTyres(t)).Node(1).dbinfo) && ~isempty(Test.Tire(IndTyres(t)).Node(2).dbinfo)
                                            data.Tire(IndTyres(t)).regs.PL_SN0 = Test.Tire(IndTyres(t)).Node(1).regs.PL_DR;
                                            data.Tire(IndTyres(t)).regs.PL_SN1 = Test.Tire(IndTyres(t)).Node(2).regs.PL_DR;
                                        end
                                    end
                                    data.Tire(IndTyres(t)).regs.DRCV = Test.Tire(IndTyres(t)).Node(iNode).regs.DRCV_adj;
                                else
                                    data.Tire(IndTyres(t)).regs.DR = Test.Tire(IndTyres(t)).Node(iNode).regs.DR;
                                    data.Tire(IndTyres(t)).regs.PL = Test.Tire(IndTyres(t)).Node(iNode).regs.PL;
                                    if length(Test.Tire(IndTyres(t)).Node) > 1
                                        if ~isempty(Test.Tire(IndTyres(t)).Node(1).dbinfo) && ~isempty(Test.Tire(IndTyres(t)).Node(2).dbinfo)
                                            data.Tire(IndTyres(t)).regs.PL_SN0 = Test.Tire(IndTyres(t)).Node(1).regs.PL;
                                            data.Tire(IndTyres(t)).regs.PL_SN1 = Test.Tire(IndTyres(t)).Node(2).regs.PL;
                                        end
                                    end
                                    data.Tire(IndTyres(t)).regs.DRCV = Test.Tire(IndTyres(t)).Node(iNode).regs.DRCV;
                                end
                                data.Tire(IndTyres(t)).regs.Time = Test.Tire(IndTyres(t)).Node(iNode).regs.Time;
                                data.Tire(IndTyres(t)).regs.omega = Test.Tire(IndTyres(t)).Node(iNode).regs.omega;
                                data.Tire(IndTyres(t)).regs.Temp = Test.Tire(IndTyres(t)).Node(iNode).regs.Temp;
                                if length(Test.Tire(IndTyres(t)).Node) > 1
                                    if ~isempty(Test.Tire(IndTyres(t)).Node(1).dbinfo) && ~isempty(Test.Tire(IndTyres(t)).Node(2).dbinfo)
                                        data.Tire(IndTyres(t)).regs.PL_SN0_Time = Test.Tire(IndTyres(t)).Node(1).regs.Time;
                                        data.Tire(IndTyres(t)).regs.PL_SN1_Time = Test.Tire(IndTyres(t)).Node(2).regs.Time;
                                    end
                                end
                            elseif Regs_Online_Selection_flag
                                data.Tire(IndTyres(t)).regs.DR = Test.Tire(IndTyres(t)).Node(iNode).regs.DR_online;
                                data.Tire(IndTyres(t)).regs.PL = Test.Tire(IndTyres(t)).Node(iNode).regs.PL_online;
                                data.Tire(IndTyres(t)).regs.PL_SN0 = Test.Tire(IndTyres(t)).Node(1).regs.PL_online;
                                data.Tire(IndTyres(t)).regs.PL_SN1 = Test.Tire(IndTyres(t)).Node(2).regs.PL_online;
                                data.Tire(IndTyres(t)).regs.DRCV = Test.Tire(IndTyres(t)).Node(iNode).regs.DRCV_online;
                                data.Tire(IndTyres(t)).regs.Time = Test.Tire(IndTyres(t)).Node(iNode).regs.Time_online;
                                data.Tire(IndTyres(t)).regs.omega = Test.Tire(IndTyres(t)).Node(iNode).regs.omega_online;
                                data.Tire(IndTyres(t)).regs.Temp = [];
                            end
                        end
                    end
                    
                    % ======= FZ - DR
                    if InfoFile.FL_FZ_DR_Check
%                         datafields = fields(handles.(Tyres{t}).FZ.DR.mdl.Variables);
                        datafields = FindTerms(handles.(Tyres{t}).FZ.DR);
                        for iFields = 1 : length(datafields)
                            if not(strcmp(datafields{iFields},'Properties'))
                                handles.(Tyres{t}).OutdoorData.(datafields{iFields}) = zeros(size(data.Tire(IndTyres(t)).regs.DR'));
                            end
                        end
                        if P_manualFlag
                            if Regs_NewNames_Selection_flag
                                eval(['handles.',(Tyres{t}),'.OutdoorData.P = 100*p',(Tyres{t}),'_manual * ones(size(handles.',(Tyres{t}),'.OutdoorData.DR_filtMain));'])
%                                 eval(['handles.',(Tyres{t}),'.OutdoorData.P = 100*p',(Tyres{t}),'_manual * ones(size(handles.',(Tyres{t}),'.OutdoorData.Time));'])
                            elseif Regs_Adjusted_Selection_flag
                                eval(['handles.',(Tyres{t}),'.OutdoorData.P = 100*p',(Tyres{t}),'_manual * ones(size(handles.',(Tyres{t}),'.OutdoorData.DR_adj));'])
                            else
                                eval(['handles.',(Tyres{t}),'.OutdoorData.P = 100*p',(Tyres{t}),'_manual * ones(size(handles.',(Tyres{t}),'.OutdoorData.DR));'])
                            end
                        else
                            %                         eval(['Test.DecodedCAN.Pressure_',(Tyres{t}),'_good = [false not(diff(Test.DecodedCAN.Pressure_',(Tyres{t}),'_time))];']);
                            eval(['Test.Aux.Pressure_',(Tyres{t}),'_good = [false not(diff(Test.DecodedCAN.Pressure_',(Tyres{t}),'_time)==0)];']);
                            eval(['handles.',(Tyres{t}),'.OutdoorData.P = 100.*interp1(Test.DecodedCAN.Pressure_',(Tyres{t}),'_time(Test.Aux.Pressure_',(Tyres{t}),'_good),Test.DecodedCAN.Pressure_',(Tyres{t}),'(Test.Aux.Pressure_',(Tyres{t}),'_good),data.Tire(',num2str(IndTyres(t)),').regs.Time,''Linear'',''extrap'')'';']);
                            eval(['handles.',(Tyres{t}),'.OutdoorData.Pt_Filtered = 100.*interp1(Test.DecodedCAN.Pressure_',(Tyres{t}),'_time(Test.Aux.Pressure_',(Tyres{t}),'_good),Test.DecodedCAN.Pressure_',(Tyres{t}),'(Test.Aux.Pressure_',(Tyres{t}),'_good),data.Tire(',num2str(IndTyres(t)),').regs.Time,''Linear'',''extrap'')'';']);
                        end
                        
                        handles.(Tyres{t}).OutdoorData.DR = data.Tire(IndTyres(t)).regs.DR';
                        handles.(Tyres{t}).OutdoorData.DR_filtBase = data.Tire(IndTyres(t)).regs.DR';
                        handles.(Tyres{t}).OutdoorData.DR_filtMain = data.Tire(IndTyres(t)).regs.DR';
                        handles.(Tyres{t}).OutdoorData.omega = data.Tire(IndTyres(t)).regs.omega';
                        
                        Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.FZ_DR = -1 * predictLRM(handles.(Tyres{t}).FZ.DR,struct2table(handles.(Tyres{t}).OutdoorData));
                        Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.FZ_DR_Time = data.Tire(IndTyres(t)).regs.Time';
                    end
                    
                    % ======= FZ - PL
                    if InfoFile.FL_FZ_PL_Check
%                         datafields = fields(handles.(Tyres{t}).FZ.PL.mdl.Variables);
                        datafields = FindTerms(handles.(Tyres{t}).FZ.PL);
                        for iFields = 1 : length(datafields)
                            if not(strcmp(datafields{iFields},'Properties'))
                                handles.(Tyres{t}).OutdoorData.(datafields{iFields}) = zeros(size(data.Tire(IndTyres(t)).regs.PL'));
                            end
                        end
                        if P_manualFlag
                            if Regs_NewNames_Selection_flag
                                eval(['handles.',(Tyres{t}),'.OutdoorData.P = 100*p',(Tyres{t}),'_manual * ones(size(handles.',(Tyres{t}),'.OutdoorData.PL_filtMain));'])
                            elseif Regs_Adjusted_Selection_flag
                                eval(['handles.',(Tyres{t}),'.OutdoorData.P = 100*p',(Tyres{t}),'_manual * ones(size(handles.',(Tyres{t}),'.OutdoorData.PL_adj));'])
                            else
                                eval(['handles.',(Tyres{t}),'.OutdoorData.P = 100*p',(Tyres{t}),'_manual * ones(size(handles.',(Tyres{t}),'.OutdoorData.PL));'])
                            end
                        else
                            %                         eval(['Test.DecodedCAN.Pressure_',(Tyres{t}),'_good = [false not(diff(Test.DecodedCAN.Pressure_',(Tyres{t}),'_time))];']);
                            eval(['Test.Aux.Pressure_',(Tyres{t}),'_good = [false not(diff(Test.DecodedCAN.Pressure_',(Tyres{t}),'_time)==0)];']);
                            eval(['handles.',(Tyres{t}),'.OutdoorData.P = 100.*interp1(Test.DecodedCAN.Pressure_',(Tyres{t}),'_time(Test.Aux.Pressure_',(Tyres{t}),'_good),Test.DecodedCAN.Pressure_',(Tyres{t}),'(Test.Aux.Pressure_',(Tyres{t}),'_good),data.Tire(',num2str(IndTyres(t)),').regs.Time,''Linear'',''extrap'')'';']);
                            eval(['handles.',(Tyres{t}),'.OutdoorData.Pt_Filtered = 100.*interp1(Test.DecodedCAN.Pressure_',(Tyres{t}),'_time(Test.Aux.Pressure_',(Tyres{t}),'_good),Test.DecodedCAN.Pressure_',(Tyres{t}),'(Test.Aux.Pressure_',(Tyres{t}),'_good),data.Tire(',num2str(IndTyres(t)),').regs.Time,''Linear'',''extrap'')'';']);
                        end
                        
                        handles.(Tyres{t}).OutdoorData.PL = data.Tire(IndTyres(t)).regs.PL';
                        handles.(Tyres{t}).OutdoorData.PL_filtBase = data.Tire(IndTyres(t)).regs.PL';
                        handles.(Tyres{t}).OutdoorData.PL_filtMain = data.Tire(IndTyres(t)).regs.PL';
                        handles.(Tyres{t}).OutdoorData.omega = data.Tire(IndTyres(t)).regs.omega';
                        Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.FZ_PL = -1 * predictLRM(handles.(Tyres{t}).FZ.PL,struct2table(handles.(Tyres{t}).OutdoorData));
                        Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.FZ_PL_Time = data.Tire(IndTyres(t)).regs.Time';
                    end
                    
                    
                    % ======= FX - DRCV
                    if InfoFile.FL_FX_DRCV_Check
%                         datafields = fields(handles.(Tyres{t}).FX.DRCV.mdl.Variables);
                        datafields = FindTerms(handles.(Tyres{t}).FX.DRCV);
                        for iFields = 1 : length(datafields)
                            if not(strcmp(datafields{iFields},'Properties'))
                                handles.(Tyres{t}).OutdoorData.(datafields{iFields}) = zeros(size(data.Tire(IndTyres(t)).regs.DRCV'));
                            end
                        end
                        
                        if P_manualFlag
                            if Regs_NewNames_Selection_flag
                                eval(['handles.',(Tyres{t}),'.OutdoorData.P = 100*p',(Tyres{t}),'_manual * ones(size(handles.',(Tyres{t}),'.OutdoorData.DRCV_filtMain));'])
%                                 eval(['handles.',(Tyres{t}),'.OutdoorData.P = 100*p',(Tyres{t}),'_manual * ones(size(handles.',(Tyres{t}),'.OutdoorData.Time));'])
                            elseif Regs_Adjusted_Selection_flag
                                eval(['handles.',(Tyres{t}),'.OutdoorData.P = 100*p',(Tyres{t}),'_manual * ones(size(handles.',(Tyres{t}),'.OutdoorData.DRCV_adj));'])
                            else
                                eval(['handles.',(Tyres{t}),'.OutdoorData.P = 100*p',(Tyres{t}),'_manual * ones(size(handles.',(Tyres{t}),'.OutdoorData.DRCV));'])
                            end
                        else
                            %                         eval(['Test.DecodedCAN.Pressure_',(Tyres{t}),'_good = [false not(diff(Test.DecodedCAN.Pressure_',(Tyres{t}),'_time))];']);
                            eval(['Test.Aux.Pressure_',(Tyres{t}),'_good = [false not(diff(Test.DecodedCAN.Pressure_',(Tyres{t}),'_time)==0)];']);
                            eval(['handles.',(Tyres{t}),'.OutdoorData.P = 100.*interp1(Test.DecodedCAN.Pressure_',(Tyres{t}),'_time(Test.Aux.Pressure_',(Tyres{t}),'_good),Test.DecodedCAN.Pressure_',(Tyres{t}),'(Test.Aux.Pressure_',(Tyres{t}),'_good),data.Tire(',num2str(IndTyres(t)),').regs.Time,''Linear'',''extrap'')'';']);
                            eval(['handles.',(Tyres{t}),'.OutdoorData.Pt_Filtered = 100.*interp1(Test.DecodedCAN.Pressure_',(Tyres{t}),'_time(Test.Aux.Pressure_',(Tyres{t}),'_good),Test.DecodedCAN.Pressure_',(Tyres{t}),'(Test.Aux.Pressure_',(Tyres{t}),'_good),data.Tire(',num2str(IndTyres(t)),').regs.Time,''Linear'',''extrap'')'';']);
                        end
                        
                        handles.(Tyres{t}).OutdoorData.DRCV = data.Tire(IndTyres(t)).regs.DRCV';
                        handles.(Tyres{t}).OutdoorData.DRCV_filtBase = data.Tire(IndTyres(t)).regs.DRCV';
                        handles.(Tyres{t}).OutdoorData.DRCV_filtMain = data.Tire(IndTyres(t)).regs.DRCV';
                        handles.(Tyres{t}).OutdoorData.omega = data.Tire(IndTyres(t)).regs.omega';
                        handles.(Tyres{t}).OutdoorData.Fz = -Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.FZ_DR;
                        
                        if IndTyres(t)==2 | IndTyres(t)==4 | FxChangeSign.Value == 0
                            Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.FX_DRCV = predictLRM(handles.(Tyres{t}).FX.DRCV,struct2table(handles.(Tyres{t}).OutdoorData));
                        else
                            Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.FX_DRCV = -predictLRM(handles.(Tyres{t}).FX.DRCV,struct2table(handles.(Tyres{t}).OutdoorData));
                        end
                        Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.FX_DRCV_Time = data.Tire(IndTyres(t)).regs.Time';
                        
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%% RELIABILITY INDEX OFFLINE EVALUATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    Front_tyre_radius = str2double(get(TyreRadiusFront_edit,'string')); %[m]
                    Rear_tyre_radius = str2double(get(TyreRadiusRear_edit,'string')); %[m]
                    
                    time = Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.FZ_DR_Time;
                    omega = data.Tire(IndTyres(t)).regs.omega;
                    temp = data.Tire(IndTyres(t)).regs.Temp;
                    
                    % removing NaN from wheel turn signals
                    selectionNotNaN = not(isnan(time));
                    time_clear = time(selectionNotNaN);
                    omega_clear = omega(selectionNotNaN);
                    temp_clear  = temp(selectionNotNaN);
                    
                    % interpolating auxiliary variables on CommonTime
                    omega_interp = interp1(time_clear, omega_clear, CommonTime,'previous');
                    temp_interp  = interp1(time_clear, temp_clear, CommonTime,'previous');
                    % creating control variable for finding 'dead zones = missing data portion'
                    T_clear = (2*pi)./omega_clear; %[s] wheel turn period based on Cybet Tyre Omega
                    deltaTimeCT = [0 diff(time_clear)'];
                    selectionDT = deltaTimeCT > 3*T_clear;
                    % find missing data portion on feature time
                    Clear_Indexes_tmp = find(selectionDT);
                    Clear_Indexes = [];
                    k1 = 1;
                    if not(isempty(Clear_Indexes_tmp))
                        for k2 = 1:length(Clear_Indexes_tmp)
                            Clear_Indexes(k1) = Clear_Indexes_tmp(k2)-1;
                            Clear_Indexes(k1+1) = Clear_Indexes_tmp(k2);
                            k1 = k1+2;
                        end
                    end
                    % finding missing data portion on 100 hz time
                    Clear_Indexes_100Hz = zeros(size(Clear_Indexes));
                    for j = 1 : length(Clear_Indexes)
                        Clear_Indexes_100Hz(j) = find(CommonTime < time_clear(Clear_Indexes(j)),1,'last')-1;
                        Clear_Times_100Hz(j) =  CommonTime(Clear_Indexes_100Hz(j));
                    end
                    
                    % building logical selection vector for missing data
                    % portion (control 1/3 for Reliability Index)
                    NotReliableSelection = false(size(CommonTime));
                    for k = 1 : 2 : length(Clear_Indexes_100Hz)
                        NotReliableSelection(Clear_Indexes_100Hz(k):Clear_Indexes_100Hz(k+1)) = true(1,Clear_Indexes_100Hz(k+1)-Clear_Indexes_100Hz(k)+1);
                    end
                    
                    % CAN Speed CrossCheck for agganci V/2 e agganci rumore (control 2/3 for Reliability Index)
                    selection = [true not(diff(Test.DecodedCAN.Vehicle_Speed_time) == 0)];
                    VehicleSpeed = interp1(Test.DecodedCAN.Vehicle_Speed_time(selection),Test.DecodedCAN.Vehicle_Speed(selection),CommonTime);
                    if strcmp(Tyres{t},'FL') || strcmp(Tyres{t},'FR')
                        CANSpeed_CrossCheck = (((omega_interp*Front_tyre_radius*3.6)-VehicleSpeed)./VehicleSpeed);
                    else
                        CANSpeed_CrossCheck = (((omega_interp*Rear_tyre_radius*3.6)-VehicleSpeed)./VehicleSpeed);
                    end
                    CANSpeed_CrossCheck_Selection  = abs(CANSpeed_CrossCheck) > 0.2;
                    
                    % finding for very first start time (control 3/3 for Reliability Index)
                    StartTime_Selection  = CommonTime <= time_clear(1);
                    StopTime_Selection = CommonTime > time_clear(end);
                    
                    %definition of Reliability Index for generic feature
                    ReliabilityIndex = 100*ones(size(CommonTime));
                    ReliabilityIndex(NotReliableSelection) = 0; % missing data portion
                    ReliabilityIndex(StartTime_Selection) = 0; % start time
                    ReliabilityIndex(StopTime_Selection) = 0; % start time
                    
                    %definition of Reliability Index for temperature (even if V/2 temperature is
                    %still good)
                    ReliabilityIndex_temperature = 100*ones(size(CommonTime));
                    ReliabilityIndex_temperature(NotReliableSelection) = 0; % missing data portion
                    ReliabilityIndex_temperature(StartTime_Selection) = 0; % start time
                    ReliabilityIndex_temperature(StopTime_Selection) = 0; % start time
                    
                    
                    if Regs_Offline_Selection_flag & not(isfield(Test.Tire(IndTyres(t)).Node(iNode).regs,'RI'))
                        ReliabilityIndex(CANSpeed_CrossCheck_Selection) = 0; % V/2
                        
                    elseif Regs_Offline_Selection_flag & isfield(Test.Tire(IndTyres(t)).Node(iNode).regs,'RI')
                        OfflineRI_int = interp1(time_clear, single(Test.Tire(IndTyres(t)).Node(iNode).regs.RI(selectionNotNaN)), CommonTime,'previous');
                        OfflineRI_int(isnan(OfflineRI_int)) = 0;
                        ReliabilityIndex(~logical(OfflineRI_int)) = 0; % RI calculation from GUI
                        
                    else
                        OnlineRI_int = interp1(time_clear, Test.Tire(IndTyres(t)).Node(iNode).regs.reliability_online(selectionNotNaN), CommonTime,'previous');
                        OnlineRI_int(isnan) = 0;
                        ReliabilityIndex(~logical(OnlineRI_int)) = 0; % RI calculation from GUI
                    end
                    
                    % Fz_DR
                    if InfoFile.FL_FZ_DR_Check
                        % creating auxiliary variables
                        feat_Fz = Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.FZ_DR;
                        feat_Fz_clear = feat_Fz(selectionNotNaN);
                        feat_Fz_interp = interp1(time_clear, feat_Fz_clear, CommonTime,'previous');
                        Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.FZ_DR_int = feat_Fz_interp;
                        Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.FZ_DR_Time_int = CommonTime;
                        Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.RI_FZ_DR_int = ReliabilityIndex;
                        Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.RI_FZ_DR_Time_int = CommonTime;
                        
                        % Fx_DRCV
                        if InfoFile.FL_FX_DRCV_Check
                            feat_Fx = Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.FX_DRCV;
                            feat_Fx_clear = feat_Fx(selectionNotNaN);
                            feat_Fx_interp = interp1(time_clear, feat_Fx_clear, CommonTime,'previous');
                            Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.FX_DRCV_int = feat_Fx_interp;
                            Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.FX_DRCV_Time_int = CommonTime;
                            Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.RI_FX_DRCV_int = ReliabilityIndex;
                            Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.RI_FX_DRCV_Time_int = CommonTime;
                        end
                    end
                    
                    % Temp
                    Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.Temp_int = temp_interp;
                    Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.Temp_Time_int = CommonTime;
                    Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.RI_Temp_int = ReliabilityIndex_temperature;
                    Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.RI_Temp_Time_int = CommonTime;
                    
                end
            end
        end
        
        if length(NVect) > 1 && ~isempty(Test.Tire(IndTyres(t)).Node(1).dbinfo) && ~isempty(Test.Tire(IndTyres(t)).Node(2).dbinfo)
            for t = 1 : length(Tyres)
                Test.Tire(IndTyres(t)).ForcesOffline.FZ_DR_int    = zeros(size(Test.Tire(IndTyres(t)).Node(1).ForcesOffline.FZ_DR_int));
                Test.Tire(IndTyres(t)).ForcesOffline.RI_FZ_DR_int = zeros(size(Test.Tire(IndTyres(t)).Node(1).ForcesOffline.FZ_DR_int));
                for INode = NVect
                    Reliable = Test.Tire(IndTyres(t)).Node(INode).ForcesOffline.RI_FZ_DR_int == 100;
                    Test.Tire(IndTyres(t)).ForcesOffline.RI_FZ_DR_int(Reliable) = Test.Tire(IndTyres(t)).ForcesOffline.RI_FZ_DR_int(Reliable) +...
                                                                                  Test.Tire(IndTyres(t)).Node(INode).ForcesOffline.RI_FZ_DR_int(Reliable);
                    Test.Tire(IndTyres(t)).ForcesOffline.FZ_DR_int(Reliable) = Test.Tire(IndTyres(t)).ForcesOffline.FZ_DR_int(Reliable) +...
                                                                               Test.Tire(IndTyres(t)).Node(INode).ForcesOffline.FZ_DR_int(Reliable);
                end                                              
%                 Test.Tire(IndTyres(t)).ForcesOffline.FZ_DR_int = (Test.Tire(IndTyres(t)).Node(1).ForcesOffline.FZ_DR_int.*Test.Tire(IndTyres(t)).Node(1).ForcesOffline.RI_FZ_DR_int/100 +...
%                                                                   Test.Tire(IndTyres(t)).Node(2).ForcesOffline.FZ_DR_int.*Test.Tire(IndTyres(t)).Node(2).ForcesOffline.RI_FZ_DR_int/100)./...
%                                                                  (Test.Tire(IndTyres(t)).Node(1).ForcesOffline.RI_FZ_DR_int/100 + Test.Tire(IndTyres(t)).Node(2).ForcesOffline.RI_FZ_DR_int/100);
%                 Test.Tire(IndTyres(t)).ForcesOffline.FZ_DR_int(~isfinite(Test.Tire(IndTyres(t)).Node(1).ForcesOffline.FZ_DR_int)) = ...
%                     Test.Tire(IndTyres(t)).Node(2).ForcesOffline.FZ_DR_int(~isfinite(Test.Tire(IndTyres(t)).Node(1).ForcesOffline.FZ_DR_int));
%                 Test.Tire(IndTyres(t)).ForcesOffline.FZ_DR_int(~isfinite(Test.Tire(IndTyres(t)).Node(2).ForcesOffline.FZ_DR_int)) = ...
%                     Test.Tire(IndTyres(t)).Node(1).ForcesOffline.FZ_DR_int(~isfinite(Test.Tire(IndTyres(t)).Node(2).ForcesOffline.FZ_DR_int));
%                 Test.Tire(IndTyres(t)).ForcesOffline.FZ_DR_int(~isfinite(Test.Tire(IndTyres(t)).ForcesOffline.FZ_DR_int)) =...
%                     (Test.Tire(IndTyres(t)).Node(1).ForcesOffline.FZ_DR_int(~isfinite(Test.Tire(IndTyres(t)).ForcesOffline.FZ_DR_int)) +...
%                      Test.Tire(IndTyres(t)).Node(2).ForcesOffline.FZ_DR_int(~isfinite(Test.Tire(IndTyres(t)).ForcesOffline.FZ_DR_int)))/2;
                Test.Tire(IndTyres(t)).ForcesOffline.FZ_DR_int(Reliable) = Test.Tire(IndTyres(t)).ForcesOffline.FZ_DR_int(Reliable)./ Test.Tire(IndTyres(t)).ForcesOffline.RI_FZ_DR_int(Reliable) * 100;
                Test.Tire(IndTyres(t)).ForcesOffline.FZ_DR_Time_int    = Test.Tire(IndTyres(t)).Node(1).ForcesOffline.FZ_DR_Time_int;
%                 Test.Tire(IndTyres(t)).ForcesOffline.RI_FZ_DR_int      = (Test.Tire(IndTyres(t)).Node(1).ForcesOffline.RI_FZ_DR_int == 100 | Test.Tire(IndTyres(t)).Node(2).ForcesOffline.RI_FZ_DR_int == 100)*100;
                Test.Tire(IndTyres(t)).ForcesOffline.RI_FZ_DR_Time_int = Test.Tire(IndTyres(t)).Node(1).ForcesOffline.RI_FZ_DR_Time_int;
                Test.Tire(IndTyres(t)).ForcesOffline.RI_FZ_DR_int(Test.Tire(IndTyres(t)).ForcesOffline.RI_FZ_DR_int > 0) = 100;
                
                if InfoFile.FL_FX_DRCV_Check
%                     Test.Tire(IndTyres(t)).ForcesOffline.FX_DRCV_int = (Test.Tire(IndTyres(t)).Node(1).ForcesOffline.FX_DRCV_int.*Test.Tire(IndTyres(t)).Node(1).ForcesOffline.RI_FX_DRCV_int/100 +...
%                         Test.Tire(IndTyres(t)).Node(2).ForcesOffline.FX_DRCV_int.*Test.Tire(IndTyres(t)).Node(2).ForcesOffline.RI_FX_DRCV_int/100)./...
%                         (Test.Tire(IndTyres(t)).Node(1).ForcesOffline.RI_FX_DRCV_int/100 + Test.Tire(IndTyres(t)).Node(2).ForcesOffline.RI_FX_DRCV_int/100);
%                     Test.Tire(IndTyres(t)).ForcesOffline.FX_DRCV_int(~isfinite(Test.Tire(IndTyres(t)).Node(1).ForcesOffline.FX_DRCV_int)) = ...
%                         Test.Tire(IndTyres(t)).Node(2).ForcesOffline.FZ_DR_int(~isfinite(Test.Tire(IndTyres(t)).Node(1).ForcesOffline.FX_DRCV_int));
%                     Test.Tire(IndTyres(t)).ForcesOffline.FX_DRCV_int(~isfinite(Test.Tire(IndTyres(t)).Node(2).ForcesOffline.FX_DRCV_int)) = ...
%                         Test.Tire(IndTyres(t)).Node(1).ForcesOffline.FZ_DR_int(~isfinite(Test.Tire(IndTyres(t)).Node(2).ForcesOffline.FZ_DR_int));
%                     Test.Tire(IndTyres(t)).ForcesOffline.FX_DRCV_int(~isfinite(Test.Tire(IndTyres(t)).ForcesOffline.FX_DRCV_int)) =...
%                         (Test.Tire(IndTyres(t)).Node(1).ForcesOffline.FX_DRCV_int(~isfinite(Test.Tire(IndTyres(t)).ForcesOffline.FX_DRCV_int)) +...
%                         Test.Tire(IndTyres(t)).Node(2).ForcesOffline.FX_DRCV_int(~isfinite(Test.Tire(IndTyres(t)).ForcesOffline.FX_DRCV_int)))/2;
%                     Test.Tire(IndTyres(t)).ForcesOffline.FX_DRCV_Time_int    = Test.Tire(IndTyres(t)).Node(1).ForcesOffline.FX_DRCV_Time_int;
%                     Test.Tire(IndTyres(t)).ForcesOffline.RI_FX_DRCV_int      = (Test.Tire(IndTyres(t)).Node(1).ForcesOffline.RI_FX_DRCV_int == 100 | Test.Tire(IndTyres(t)).Node(2).ForcesOffline.RI_FX_DRCV_int == 100)*100;
%                     Test.Tire(IndTyres(t)).ForcesOffline.RI_FX_DRCV_Time_int = Test.Tire(IndTyres(t)).Node(1).ForcesOffline.RI_FX_DRCV_Time_int;
%                     Test.Tire(IndTyres(t)).ForcesOffline.FZ_DR_int    = zeros(size(Test.Tire(IndTyres(t)).Node(1).ForcesOffline.FZ_DR_int));
                    Test.Tire(IndTyres(t)).ForcesOffline.FX_DRCV_int    = zeros(size(Test.Tire(IndTyres(t)).Node(1).ForcesOffline.FZ_DR_int));
                    Test.Tire(IndTyres(t)).ForcesOffline.RI_FX_DRCV_int = zeros(size(Test.Tire(IndTyres(t)).Node(1).ForcesOffline.FX_DRCV_int));
                    for INode = NVect
                        Reliable = Test.Tire(IndTyres(t)).Node(INode).ForcesOffline.RI_FX_DRCV_int == 100;
                        Test.Tire(IndTyres(t)).ForcesOffline.RI_FX_DRCV_int(Reliable) = Test.Tire(IndTyres(t)).ForcesOffline.RI_FX_DRCV_int(Reliable) +...
                            Test.Tire(IndTyres(t)).Node(INode).ForcesOffline.RI_FX_DRCV_int(Reliable);
                        Test.Tire(IndTyres(t)).ForcesOffline.FX_DRCV_int(Reliable) = Test.Tire(IndTyres(t)).ForcesOffline.FX_DRCV_int(Reliable) +...
                            Test.Tire(IndTyres(t)).Node(INode).ForcesOffline.FX_DRCV_int(Reliable);
                    end
                    Test.Tire(IndTyres(t)).ForcesOffline.FX_DRCV_int(Reliable) = Test.Tire(IndTyres(t)).ForcesOffline.FX_DRCV_int(Reliable)./ Test.Tire(IndTyres(t)).ForcesOffline.RI_FX_DRCV_int(Reliable)  * 100;
                    Test.Tire(IndTyres(t)).ForcesOffline.FX_DRCV_Time_int    = Test.Tire(IndTyres(t)).Node(1).ForcesOffline.FX_DRCV_Time_int;
                    Test.Tire(IndTyres(t)).ForcesOffline.RI_FX_DRCV_Time_int = Test.Tire(IndTyres(t)).Node(1).ForcesOffline.RI_FX_DRCV_Time_int;
                    Test.Tire(IndTyres(t)).ForcesOffline.RI_FX_DRCV_int(Test.Tire(IndTyres(t)).ForcesOffline.RI_FX_DRCV_int > 0) = 100;
                end
            end
        end
        
        
        % Interpolate data and create structure for following analysis
        for t = 1 : length(Tyres)
            if (length(data.Tire) >= IndTyres(t)) && isfield(data.Tire(IndTyres(t)),'regs')
                if ~isempty(data.Tire(IndTyres(t)).regs)
                    if length(NVect) > 1 && ~isempty(Test.Tire(IndTyres(t)).Node(1).dbinfo) && ~isempty(Test.Tire(IndTyres(t)).Node(2).dbinfo) % Double SN regressor
                        if Regs_Offline_Selection_flag
                            Time = [Test.Tire(IndTyres(t)).Node(1).regs.Time, Test.Tire(IndTyres(t)).Node(2).regs.Time];
                            [Time,Ind] = sort(Time);
                            if Regs_NewNames_Selection_flag
                                Regs = [Test.Tire(IndTyres(t)).Node(1).regs.DR_filtMain, Test.Tire(IndTyres(t)).Node(2).regs.DR_filtMain];
                                data2int.([Tyres{t},'_DR']) = Regs(Ind);
                                Regs = [Test.Tire(IndTyres(t)).Node(1).regs.PL_filtMain, Test.Tire(IndTyres(t)).Node(2).regs.PL_filtMain];
                                data2int.([Tyres{t},'_PL']) = Regs(Ind);
                                Regs = [Test.Tire(IndTyres(t)).Node(1).regs.DRCV_filtMain, Test.Tire(IndTyres(t)).Node(2).regs.DRCV_filtMain];
                                data2int.([Tyres{t},'_DRCV']) = Regs(Ind);
                            elseif Regs_Adjusted_Selection_flag
                                Regs = [Test.Tire(IndTyres(t)).Node(1).regs.DR_adj, Test.Tire(IndTyres(t)).Node(2).regs.DR_adj];
                                data2int.([Tyres{t},'_DR']) = Regs(Ind);
                                Regs = [Test.Tire(IndTyres(t)).Node(1).regs.PL_DR, Test.Tire(IndTyres(t)).Node(2).regs.PL_DR];
                                data2int.([Tyres{t},'_PL']) = Regs(Ind);
                                Regs = [Test.Tire(IndTyres(t)).Node(1).regs.DRCV_adj, Test.Tire(IndTyres(t)).Node(2).regs.DRCV_adj];
                                data2int.([Tyres{t},'_DRCV']) = Regs(Ind);
                            else
                                Regs = [Test.Tire(IndTyres(t)).Node(1).regs.DR, Test.Tire(IndTyres(t)).Node(2).regs.DR];
                                data2int.([Tyres{t},'_DR']) = Regs(Ind);
                                Regs = [Test.Tire(IndTyres(t)).Node(1).regs.PL, Test.Tire(IndTyres(t)).Node(2).regs.PL];
                                data2int.([Tyres{t},'_PL']) = Regs(Ind);
                                Regs = [Test.Tire(IndTyres(t)).Node(1).regs.DRCV, Test.Tire(IndTyres(t)).Node(2).regs.DRCV];
                                data2int.([Tyres{t},'_DRCV']) = Regs(Ind);
                            end
                            Regs = [Test.Tire(IndTyres(t)).Node(1).regs.omega, Test.Tire(IndTyres(t)).Node(2).regs.omega];
                            data2int.([Tyres{t},'_omega']) = Regs(Ind);
                            Regs = [Test.Tire(IndTyres(t)).Node(1).regs.Temp, Test.Tire(IndTyres(t)).Node(2).regs.Temp];
                            data2int.([Tyres{t},'_Temp']) = Regs(Ind);
                        elseif Regs_Online_Selection_flag
                            Time = [Test.Tire(IndTyres(t)).Node(1).regs.Time_online, Test.Tire(IndTyres(t)).Node(2).regs.Time_online];
                            [Time,Ind] = sort(Time);
                            Regs = [Test.Tire(IndTyres(t)).Node(1).regs.DR_online, Test.Tire(IndTyres(t)).Node(2).regs.DR_online];
                            data2int.([Tyres{t},'_DR']) = Regs(Ind);
                            Regs = [Test.Tire(IndTyres(t)).Node(1).regs.PL_online, Test.Tire(IndTyres(t)).Node(2).regs.PL_online];
                            data2int.([Tyres{t},'_PL']) = Regs(Ind);
                            Regs = [Test.Tire(IndTyres(t)).Node(1).regs.DRCV_online, Test.Tire(IndTyres(t)).Node(2).regs.DRCV_online];
                            data2int.([Tyres{t},'_DRCV']) = Regs(Ind);
                            Regs = [Test.Tire(IndTyres(t)).Node(1).regs.omega_online, Test.Tire(IndTyres(t)).Node(2).regs.omega_online];
                            data2int.([Tyres{t},'_omega']) = Regs(Ind);
                            data2int.([Tyres{t},'_Temp']) = nan(size(Time));
                        end
                        data2int.([Tyres{t},'_DR_time'])    = Time;
                        data2int.([Tyres{t},'_PL_time'])    = Time;
                        data2int.([Tyres{t},'_DRCV_time'])  = Time;
                        data2int.([Tyres{t},'_omega_time']) = Time;
                        data2int.([Tyres{t},'_Temp_time'])  = Time;
                    else
                        data2int.([Tyres{t},'_DR'])      = data.Tire(IndTyres(t)).regs.DR;
                        data2int.([Tyres{t},'_DR_time']) = data.Tire(IndTyres(t)).regs.Time;
                        data2int.([Tyres{t},'_PL'])      = data.Tire(IndTyres(t)).regs.PL;
                        data2int.([Tyres{t},'_PL_time']) = data.Tire(IndTyres(t)).regs.Time;
                        if length(Test.Tire(IndTyres(t)).Node) > 1
                            if ~isempty(Test.Tire(IndTyres(t)).Node(1).dbinfo) && ~isempty(Test.Tire(IndTyres(t)).Node(2).dbinfo)
                                data2int.([Tyres{t},'_PL_SN0'])      = data.Tire(IndTyres(t)).regs.PL_SN0;
                                data2int.([Tyres{t},'_PL_SN0_time']) = data.Tire(IndTyres(t)).regs.PL_SN0_Time;
                                data2int.([Tyres{t},'_PL_SN1'])      = data.Tire(IndTyres(t)).regs.PL_SN1;
                                data2int.([Tyres{t},'_PL_SN1_time']) = data.Tire(IndTyres(t)).regs.PL_SN1_Time;
                            end
                        end
                        data2int.([Tyres{t},'_DRCV'])      = data.Tire(IndTyres(t)).regs.DRCV;
                        data2int.([Tyres{t},'_DRCV_time']) = data.Tire(IndTyres(t)).regs.Time;
                        data2int.([Tyres{t},'_omega'])      = data.Tire(IndTyres(t)).regs.omega;
                        data2int.([Tyres{t},'_omega_time']) = data.Tire(IndTyres(t)).regs.Time;
                        data2int.([Tyres{t},'_Temp'])      = data.Tire(IndTyres(t)).regs.Temp;
                        data2int.([Tyres{t},'_Temp_time']) = data.Tire(IndTyres(t)).regs.Time;
                    end
                    
                    if length(NVect) > 1
                        data2int.([Tyres{t},'_FZ_DR'])      = Test.Tire(IndTyres(t)).ForcesOffline.FZ_DR_int;
                        data2int.([Tyres{t},'_FZ_DR_time']) = Test.Tire(IndTyres(t)).ForcesOffline.FZ_DR_Time_int;
                        data2int.([Tyres{t},'_RI_FZ_DR'])      = Test.Tire(IndTyres(t)).ForcesOffline.RI_FZ_DR_int;
                        data2int.([Tyres{t},'_RI_FZ_DR_time']) = Test.Tire(IndTyres(t)).ForcesOffline.RI_FZ_DR_Time_int;
                        if InfoFile.FL_FX_DRCV_Check
                            data2int.([Tyres{t},'_FX_DRCV'])      = Test.Tire(IndTyres(t)).ForcesOffline.FX_DRCV_int;
                            data2int.([Tyres{t},'_FX_DRCV_time']) = Test.Tire(IndTyres(t)).ForcesOffline.FX_DRCV_Time_int;
                            data2int.([Tyres{t},'_RI_FX_DRCV'])      = Test.Tire(IndTyres(t)).ForcesOffline.RI_FX_DRCV_int;
                            data2int.([Tyres{t},'_RI_FX_DRCV_time']) = Test.Tire(IndTyres(t)).ForcesOffline.RI_FX_DRCV_Time_int;
                        end
                    else
                        data2int.([Tyres{t},'_FZ_DR'])      = Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.FZ_DR_int;
                        data2int.([Tyres{t},'_FZ_DR_time']) = Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.FZ_DR_Time_int;
                        data2int.([Tyres{t},'_RI_FZ_DR'])      = Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.RI_FZ_DR_int;
                        data2int.([Tyres{t},'_RI_FZ_DR_time']) = Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.RI_FZ_DR_Time_int;
                        if InfoFile.FL_FX_DRCV_Check
                            data2int.([Tyres{t},'_FX_DRCV'])      = Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.FX_DRCV_int;
                            data2int.([Tyres{t},'_FX_DRCV_time']) = Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.FX_DRCV_Time_int;
                            data2int.([Tyres{t},'_RI_FX_DRCV'])      = Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.RI_FX_DRCV_int;
                            data2int.([Tyres{t},'_RI_FX_DRCV_time']) = Test.Tire(IndTyres(t)).Node(iNode).ForcesOffline.RI_FX_DRCV_Time_int;
                        end
                    end
                end
            end
        end
        DataInttemp = CommonTimeInterp(data2int,fs,CommonTime(1),CommonTime(end));
        Field2Add = fields(DataInttemp);
        for IF = 1 :length(Field2Add)
            DataInt.(Field2Add{IF}) = DataInttemp.(Field2Add{IF});
        end
        
        ElaboratedTest(obj, event);
        
        waitbar(1,h,'Forces properly loaded')
        pause(1)
        close(h)
        
%         figure;
%         h1 = subplot(211); hold on; grid on;
%         plot(Test.Tire(3).ForcesOffline.FZ_DR_Time_int,Test.Tire(3).Node(1).ForcesOffline.FZ_DR_int,'b');
%         plot(Test.Tire(3).ForcesOffline.FZ_DR_Time_int,Test.Tire(3).Node(2).ForcesOffline.FZ_DR_int,'r');
%         plot(Test.Tire(3).ForcesOffline.FZ_DR_Time_int,Test.Tire(3).ForcesOffline.FZ_DR_int,'g');
%         h2 = subplot(212); hold on; grid on;
%         plot(Test.Tire(3).ForcesOffline.RI_FZ_DR_Time_int,Test.Tire(3).Node(1).ForcesOffline.RI_FZ_DR_int,'b');
%         plot(Test.Tire(3).ForcesOffline.RI_FZ_DR_Time_int,Test.Tire(3).Node(2).ForcesOffline.RI_FZ_DR_int,'r');
%         plot(Test.Tire(3).ForcesOffline.RI_FZ_DR_Time_int,Test.Tire(3).ForcesOffline.RI_FZ_DR_int,'g');
%         linkaxes([h1 h2],'x')
    end

%% CommonTimeInterpolator
    function [OutputData] = CommonTimeInterp(InputData,SapmFreq,tin,tf)
        Inputfields = fields(InputData);
        dt = 1/SapmFreq;
        timeSet2Zero = tin : dt : (ceil(tf/dt))*dt;
        
        for nFields = 1 : length(Inputfields)
            if isempty(strfind(Inputfields{nFields},'time')) && not(isempty(InputData.(Inputfields{nFields})))
                dato = InputData.(Inputfields{nFields});
                dato_time = InputData.([Inputfields{nFields},'_time']);
                validSelection = [true not(diff(dato_time) == 0)] & isfinite(dato) & isfinite(dato_time);
                if sum(validSelection)>1
                    OutputData.(Inputfields{nFields}) = interp1(dato_time(validSelection), dato(validSelection),timeSet2Zero,'Linear','extrap');
                end
            end
        end
        
        OutputData.Time = timeSet2Zero;
    end

%% ElaboratedTest
    function ElaboratedTest(obj, event)
        Forces2Disp = RegsFZ_Popup.String{InfoFile.RegsFZ_Index};
        for t = 1 : length(Tyres)
            if isfield(DataInt,[Tyres{t},'_',Forces2Disp])
                set(Manouver_Fig2.(['linea',num2str(4-t+1)]),'xdata',DataInt.Time,'ydata',DataInt.([Tyres{t},'_',Forces2Disp]),'visible','on','color',Color{t},'Linewidth',2,'DisplayName',Tyres{t});
                set(Manouver_Fig3.(['linea',num2str(4-t+1)]),'xdata',DataInt.Time,'ydata',DataInt.([Tyres{t},'_RI_',Forces2Disp]),'visible','on','color',Color{t},'Linewidth',2,'DisplayName',Tyres{t});
            end
        end
        set(Manouver_Fig2.asse,'XLimMode','auto','YLimMode','auto')
        legendFromDisplayName(Manouver_Fig2.asse);
        set(Manouver_Fig3.asse,'XLimMode','auto','YLimMode','auto','Ylim',[0 150])
        legendFromDisplayName(Manouver_Fig3.asse);
        linkaxes([Manouver_Fig1.asse Manouver_Fig2.asse Manouver_Fig3.asse],'x');
    end

%% Save Excel
    function SaveExcel(obj, event)
        [FileName,PathName,~] = uiputfile([InfoFile.DataFolder,filesep,'*.xlsx']);
        xlswrite([PathName,filesep,FileName],ExcelTable);
        for Fig = 1:length(FigInd)
            xlswritefig(FigVect(Fig),[PathName,filesep,FileName],'sheet1',[FigInd2{Fig},num2str(FigInd(Fig))]);
            Figname = [FigVect(Fig).Children(end).Title.String{1,1},'_',FigVect(Fig).Children(end).Title.String{2,1}];
            savefig(FigVect(Fig),[PathName,filesep,Figname]);
        end
        disp('Saved!');
    end

%% Clear Excel
    function ClearExcel(obj, event)
        ExcelTable = [];
        FigVect = [];
        FigInd = [];
        FigInd2 = [];
    end

%% Visualize analysis data
    function VisualizeExcel(obj, event)
        [R,C] = size(ExcelTable);
        if ~isempty(ExcelTable)
            Text = [];
            RowCellArray = cell(1,R*C);
            cont = 1;
            for IR = 1:R
                for IC = 1:C
                    Text = [Text,'%15s'];
                    if isnumeric(ExcelTable{IR,IC})
                        RowCellArray{1,cont} = num2str(single(ExcelTable{IR,IC}));
                    else
                        if length(ExcelTable{IR,IC}) > 15
                            RowCellArray{1,cont} = ExcelTable{IR,IC}(1:15);
                        else
                            RowCellArray{1,cont} = ExcelTable{IR,IC}(1:end);
                        end
                    end
                    cont = cont+1;
                end
                Text = [Text,'\n'];
            end
            STR = sprintf(Text,RowCellArray{:});
            
            set(MainFigure, 'units','pixels');
            MainPos = get(MainFigure, 'pos');
            MainPos(3) = round(MainPos(3) *.90);
            MainPos(1) = MainPos(1) + round(MainPos(3) / 4);
            MsgboxFigure = figure('WindowStyle','modal', ...
                'units','pixels', 'pos',MainPos);
            uicontrol('parent',MsgboxFigure, 'style','edit', ...
                'units','norm', 'pos',[0.025 .1 .95 .875], ...
                'enable','inactive', 'min',0,'max',2, ...
                'HorizontalAlignment', 'left', ...
                'fontsize',10, 'fontname','courier', ...
                'string',STR);
            uicontrol('parent',MsgboxFigure, 'style','push', ...
                'units','norm', 'pos',[.45 .02 .1 .03], ...
                'string','OK', 'callback',@CloseMsgbox)
        end
        function CloseMsgbox(o, e) %#ok<INUSD>
            close(MsgboxFigure);
        end
    end

%% SetRegsFZ
    function SetForces(obj, event)
        if isfield(DataInt,'FL_FZ_DR') || isfield(DataInt,'FR_FZ_DR') || isfield(DataInt,'RL_FZ_DR') || isfield(DataInt,'RR_FZ_DR')
            ElaboratedTest();
        end
    end


%% Run Analisys
    function RunAnalisys(obj, event)
        FiltOption  = Filter_Selection.Value;
        DBGFigures  = DBGFigure_Selection.Value;
        
        if Ginput_Selection.Value
            Manouver_Fig1.asse;
            [X,~] = ginput(2);
            if X(1) > X(2)
                FinalTime = X(1);
                StartTime = X(2);
            else
                StartTime = X(1);
                FinalTime = X(2);
            end
        else
            StartTime = CommonTime(1);
            FinalTime = CommonTime(end);
        end
        
        ScriptIndex = ScriptList.Value;
        Script2Eval = char(InfoFile.AnalysisScripts(ScriptIndex,1));
        eval(['[Results,FigHandle] = ',Script2Eval(1:end-2),'(DataInt,VehicleParameter,FiltOption,StartTime,FinalTime,fs,DBGFigures,Testname(1:end-9),Script2Eval(1:end-2));']);
        
        % Save Results
        [A,B] = size(ExcelTable);
        [R,C] = size(Results);
        if isempty(ExcelTable)
            shift = 2;
        else
            if isempty(FigInd)
                shift = 2;
            elseif FigInd(end)<A
                shift = 2;
            else
                shift = 23;
            end
        end
        ExcelTable{A+shift,1} = Script2Eval(1:end-2);
        for IR = 1:R
            for IC = 1:C
                ExcelTable{A+shift+IR,IC} = Results{IR,IC};
            end
        end
        if DBGFigures
            for IF = 1:length(FigHandle)
                FigVect = [FigVect;FigHandle{IF}];
                FigInd = [FigInd;A+shift+R+1];
                if IF<4
                    FigInd2{end+1} = char(66+(IF-1)*9);
                else
                    FigInd2{end+1} = [char(64+floor((IF-1)*9/25)),char(65+rem((IF-1)*9,25))];
                end
            end
        end
        disp('DONE!');
    end

%% Add Analysis
    function AddScript(obj, event)
        [FileName,PathName,FilterIndex] = uigetfile([cd,filesep,'*.m'],'Please Select Valid Script','multiselect','off');
        InfoFile.AnalysisScripts = [InfoFile.AnalysisScripts; {FileName}];
        InfoFile.AnalysisFolders = [InfoFile.AnalysisFolders; {PathName}];
        UpdateAnalysisList();
    end


%% Remove Analysis
    function RemoveScript(obj, event)
        [Selection,~] = listdlg('ListString',InfoFile.AnalysisScripts,'SelectionMode','multiple','PromptString','Select Analysis To remove');
        if ~isempty(Selection)
            if length(Selection) == length(InfoFile.AnalysisScripts)
                InfoFile.AnalysisScripts = {};
                InfoFile.AnalysisFolders = {};
            else
                VectSelection = true(size(InfoFile.AnalysisScripts));
                VectSelection(Selection) = false;
                TempScripts = InfoFile.AnalysisScripts;
                TempFolders = InfoFile.AnalysisFolders;
                InfoFile.AnalysisScripts = TempScripts(find(VectSelection),1);
                InfoFile.AnalysisFolders = TempFolders(find(VectSelection),1);
            end
        end
        UpdateAnalysisList();
    end

%% Update Analysis List
    function UpdateAnalysisList(obj, event)
        set(ScriptList,'string',InfoFile.AnalysisScripts);
    end



%% AutomaticEvaluateForces

    function AutomaticEvaluateForces(obj, event)
        
        Testpathname = InfoFile.DataFolder;
        Files = dir([Testpathname, filesep, '*.mat']);
        Names = {Files.name};
        
        [s,v] = listdlg('PromptString','Select files to parser:','SelectionMode','multiple','ListSize',[400 300],'ListString', Names);
        
        nfile = length(s);
        
        for IndFile = 1:nfile
            
            Testname = Names{s(IndFile)};
            
            LoadTest(Testpathname, Testname)
            EvaluateForces(obj, event)
            
            if isfield(Test,'Aux')
            Test = rmfield(Test,'Aux');
            end
            save([Testpathname, filesep, Testname],'-struct','Test','-v7.3')
                        
        end
        
            
    end

%% GInputSelection

    function GInputSelection(obj, event)
        
        [x y] = ginput(2);
        time_start = x(1);
        time_end = x(2);
        
        data.Tire(1).CheckManeuver  = (data.Tire(1).Fz_time > time_start) & (data.Tire(1).Fz_time < time_end);
        data.Tire(2).CheckManeuver  = (data.Tire(2).Fz_time > time_start) & (data.Tire(2).Fz_time < time_end);
        data.Tire(3).CheckManeuver  = (data.Tire(3).Fz_time > time_start) & (data.Tire(3).Fz_time < time_end);
        data.Tire(4).CheckManeuver  = (data.Tire(4).Fz_time > time_start) & (data.Tire(4).Fz_time < time_end);
                
        set(Manouver_Fig3.linea5,'xdata',data.Tire(1).Fz_time(data.Tire(1).CheckManeuver),'ydata',data.Tire(1).Fz(data.Tire(1).CheckManeuver),'visible','on','color',[1 0.5 0],'Marker','o','Linestyle','none','LineWidth',2)
        set(Manouver_Fig3.linea6,'xdata',data.Tire(2).Fz_time(data.Tire(2).CheckManeuver),'ydata',data.Tire(2).Fz(data.Tire(2).CheckManeuver),'visible','on','color',[1 0.5 0],'Marker','o','Linestyle','none','LineWidth',2)
        set(Manouver_Fig3.linea7,'xdata',data.Tire(3).Fz_time(data.Tire(3).CheckManeuver),'ydata',data.Tire(3).Fz(data.Tire(3).CheckManeuver),'visible','on','color',[1 0.5 0],'Marker','o','Linestyle','none','LineWidth',2)
        set(Manouver_Fig3.linea8,'xdata',data.Tire(4).Fz_time(data.Tire(4).CheckManeuver),'ydata',data.Tire(4).Fz(data.Tire(4).CheckManeuver),'visible','on','color',[1 0.5 0],'Marker','o','Linestyle','none','LineWidth',2)

        Fz_FL_mean = nanmean(data.Tire(2).Fz(data.Tire(2).CheckManeuver));
        Fz_FR_mean = nanmean(data.Tire(1).Fz(data.Tire(1).CheckManeuver));
        Fz_RL_mean = nanmean(data.Tire(4).Fz(data.Tire(4).CheckManeuver));
        Fz_RR_mean = nanmean(data.Tire(3).Fz(data.Tire(3).CheckManeuver));
        
        Fz_FrontAxle = Fz_FL_mean + Fz_FR_mean;
        Fz_RearAxle = Fz_RL_mean + Fz_RR_mean;
        
        Fz_Vehicle = Fz_FrontAxle + Fz_RearAxle;
        
        Fx_FL_mean = nanmean(data.Tire(2).Fx(data.Tire(2).CheckManeuver));
        Fx_FR_mean = nanmean(data.Tire(1).Fx(data.Tire(1).CheckManeuver));
        Fx_RL_mean = nanmean(data.Tire(4).Fx(data.Tire(4).CheckManeuver));
        Fx_RR_mean = nanmean(data.Tire(3).Fx(data.Tire(3).CheckManeuver));
        
        set(Static_FZ_FL_edit,'string',sprintf('%.0f',Fz_FL_mean/9.81),'FontSize',12,'FontWeight','bold');
        set(Static_FZ_FR_edit,'string',sprintf('%.0f',Fz_FR_mean/9.81),'FontSize',12,'FontWeight','bold');
        set(Static_FZ_RL_edit,'string',sprintf('%.0f',Fz_RL_mean/9.81),'FontSize',12,'FontWeight','bold');
        set(Static_FZ_RR_edit,'string',sprintf('%.0f',Fz_RR_mean/9.81),'FontSize',12,'FontWeight','bold');
        set(Static_FZ_FrontAxle_edit,'string',sprintf('%.0f',Fz_FrontAxle/9.81),'FontSize',12,'FontWeight','bold');
        set(Static_FZ_RearAxle_edit,'string',sprintf('%.0f',Fz_RearAxle/9.81),'FontSize',12,'FontWeight','bold');
        set(Static_FZ_Vehicle_edit,'string',sprintf('%.0f',Fz_Vehicle/9.81),'FontSize',12,'FontWeight','bold');
        
      
    end


%% InterCommand
    function InterCommand(~, ~)
        commands = InterControl.UserData;
        for i = 1:length(commands)
            cmd = commands(i);
            if strcmp(cmd.Command, 'TestFileLoaded') && ...
                    strcmp(cmd.Data.FileType, '.test.mat')
                Test = cmd.Data.Test;
                [InfoFile.DataFolder, ~, ~] = fileparts(cmd.Data.FilePath);
                Testname = cmd.Data.FileInfo.name;
                LoadTest(cmd.Data.FileFolder,cmd.Data.FileInfo.name);
                break
            elseif strcmp(cmd.Command, 'FolderChange')
                InfoFile.DataFolder = cmd.Data.Folder;
            end
        end
        
    end

%% SetManualPressure
    function SetManualPressure(obj, event)
        
        TITLE='Set Pressures';
        ANSWER={'3.05','3.05','2.6','2.74'};
        prompt={'p FL [bar]','p FR [bar]','p RL [bar]','p RR [bar]'};
        name=TITLE;
        numlines=1.2;
        defaultanswer=ANSWER;
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        
        options.Resize='on';
        options.WindowStyle='normal';
        options.Interpreter='tex';
        
        pFL_manual = str2double(answer{1});
        pFR_manual = str2double(answer{2});
        pRL_manual = str2double(answer{3});
        pRR_manual = str2double(answer{4});
        
        P_manualFlag = 1;
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

%% InitChecks
    function InitChecks(Object, props)    
        CheckBoxes = {'FZ_DR_Checkbox'; 'FZ_PL_Checkbox'; 'FX_DRCV_Checkbox'};
        Forces = {'FZ_DR'; 'FZ_PL'; 'FX_DRCV'};
        %         Tyres = {'FL'; 'FR';'RL';'RR'};
        check_temp =[];
        
        for IndCheck = 1 : length(CheckBoxes)
            eval(['check_temp = get(',CheckBoxes{IndCheck},',''Value'');'])
            
            for iTyre = 1 : length(Tyres)
                if check_temp == 0
                    eval(['set([Browse',Tyres{iTyre},'_',Forces{IndCheck},'_pushbutton,File',Tyres{iTyre},'_',Forces{IndCheck},'_edit], ''enable'',''off'');']);
                    eval(['InfoFile.',Tyres{iTyre},'_',Forces{IndCheck},'_Check = 0;']);
                else
                    eval(['set([Browse',Tyres{iTyre},'_',Forces{IndCheck},'_pushbutton,File',Tyres{iTyre},'_',Forces{IndCheck},'_edit], ''enable'',''on'');']);
                    eval(['InfoFile.',Tyres{iTyre},'_',Forces{IndCheck},'_Check = 1;']);
                end
            end
        end
    end

%% ChangeSensor
    function ChangeSensor(obj, evn) %#ok<INUSD>
        SelectedSensor = SensorToUseList.String{SensorToUseList.Value};
        NVect = find(strcmp(SensorOrdered, SelectedSensor));
        if NVect == 5
            NVect = [1 2];
        elseif NVect == 6
            NVect = [1 2 3];
        end
    end

%% Saving_SingleFile
    function Saving_SingleFile(obj, evn)
        if isfield(Test,'Aux')
            Test = rmfield(Test,'Aux');
        end
        h = waitbar(1/10,'Please wait, saving file');
        save([Testpathname, filesep, Testname],'-struct','Test','-v7.3')
        waitbar(1,h,'File properly saved')
        pause(1)
        close(h)
    end

%% SetTyreRadius

    function SetTyreRadius(obj, evn)      
        Front_tyre_radius = str2double(get(TyreRadiusFront_edit,'string')); %[m]
        Rear_tyre_radius = str2double(get(TyreRadiusRear_edit,'string')); %[m]        
    end

%% Set Vehicle Params
    function SetParams(obj, evn)
        for IP = 1:length(Params)
            DFT_Value{IP} = num2str(InfoFile.(Params{IP}));
        end
        answer = inputdlg(Params,'Set Params Value',1,DFT_Value);
        for IP = 1:length(Params)
            InfoFile.(Params{IP}) = str2double(answer{IP});
        end
        UpdateVehicleParams;
    end

%% Update Vehicle Parameter
    function UpdateVehicleParams(obj, evn)
        for IP = 1:length(Params)
            VehicleParameter.(Params{IP}) = InfoFile.(Params{IP});
        end
    end

%% Legend From DisplayName
    function varargout = legendFromDisplayName(h, varargin)
        %legendFromDisplayName Display legend with names from DisplayName property
        %   legendFromDisplayName(handle, varargin...) puts a legend on the axes in
        %   handle. handle can be an array of handles to axes and/or figures.
        %   All other arguments are passed on to LEGEND() command.
        %
        %   Returns an array of handles to created legends.
        %
        %   See also  LEGEND
        
        hAxes = findobj(h, 'type', 'axes');
        
        hLegend = zeros(size(hAxes)); % Initialize empty legend handle array
        for iAxes = 1:length(hAxes)
            % Find all lines that are in current axes and loop through them to get
            % their DisplayName
            hLines = findobj(hAxes(iAxes), 'type', 'line');
            eLegend = cell(length(hLines), 1);
            for iLines = 1:length(hLines)
                eLegend{iLines} = get(hLines(iLines), 'DisplayName');
            end
            hLegend(iAxes) = legend(hLines, eLegend{:},  varargin{:});
        end
        if nargout == 1
            % Return array of handles to all legends created if asked for
            varargout = hLegend;
        end
    end

end
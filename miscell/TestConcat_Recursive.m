function TestConcat_Recursive (~,~)
% Test concatenator
% Description: This script generate a unic test file (not a structure of
% test files) starting from many single tests.
%
% Input: n tests to concatenate
%
% Output: unic test
%
% VERSION 0.0.0
%  - Creation 07/01/2016 (Marco Rocca)
% VERSION 0.0.1
%  - Creation 03/03/2016 (M.S.)
%  - Added file sorting by date before diplaying listdgl
%  - Added fields of 'DecodedCANOutput' for Cyber Fleet data analysis (wear
%  test, suitable fo IVECO Daily Tests)
%  - Added proper concat of 'DecodedCANOutput' in order to mantain
%  time coherence of output logics --> RR_Av100...etc
%
% VERSION 0.0.2
% - Creation 29/04/2016 (G.M.)
% - Major change: recursive function call (MergeStruct) instead of "for" cycles
% - Added proper time concat (all time vectors shifted by max Test.DecodedCAN.*_time)
%
% VERSION 0.0.3
% - Creation 23/01/2017 (G.M.)
% - Modify MergeStruct function to allow Sample A concat
% - Added Test.**.regs.Time check for LastTime

% clear all
clc

global DeltaTime
persistent BaseFolder

if isempty(BaseFolder)
    BaseFolder = pwd;
end

DeltaTime = 0;
LastTime = 0;

% Folder selection
pathname = uigetdir(BaseFolder, 'Select Test root folder');
if pathname == 0
    return
end
BaseFolder = pathname;

% mat file list
cdir=dir([pathname,filesep,'*.mat']);

% time sort files
dates = zeros(size(cdir));

for Ifile = 1 : length(dates)
    fileName = cdir(Ifile).name;
    
    for digit = 0:9
        st1 = sprintf('-%d-', digit);
        st1_0 = sprintf('-%02d-', digit);
        st2 = sprintf('-%d_', digit);
        st2_0 = sprintf('-%02d_', digit);
        st3 = sprintf('_%d-', digit);
        st3_0 = sprintf('_%02d-', digit);
        fileName = strrep(fileName, st1, st1_0);
        fileName = strrep(fileName, st2, st2_0);
        fileName = strrep(fileName, st3, st3_0);
    end
    
    
    for digit = 0:9
        st1 = sprintf('-%d-', digit);
        st1_0 = sprintf('-%02d-', digit);
        st2 = sprintf('-%d_', digit);
        st2_0 = sprintf('-%02d_', digit);
        st3 = sprintf('_%d-', digit);
        st3_0 = sprintf('_%02d-', digit);
        fileName = strrep(fileName, st1, st1_0);
        fileName = strrep(fileName, st2, st2_0);
        fileName = strrep(fileName, st3, st3_0);
    end
    
    undescores = find(fileName == '_');
    %     startDate = undescores(end-1)+1;
    startDate = undescores(end-1)+1;
    %     endDate = length(fileName)-9;
    fileDate = fileName(startDate : end-9);
    dates(Ifile) = datenum(fileDate, 'dd-mm-yyyy_HH-MM-SS');
    % Sample B dd-mm-yyyy_HH-MM-SS
    % Sample A yyyymmdd_HHMMSS
end
        

[~,sortIndex] = sort(dates);

cdir = cdir(sortIndex);

fileTest={cdir.name};

% select files to be analyzed (only first of each quartet showed)
pause(0.1)
[s,~] = listdlg('PromptString','Select a file:','SelectionMode','multiple','ListSize',[400 400],'ListString', fileTest);
clc

% loop all the selected files
nfile=length(s);

% s = fliplr(s);

for numFile = 1:nfile
    clear Test_temp
    
    matname = fileTest(s(numFile));
    
    % convert from cell to string
    matname=matname{1};
    disp(matname)
    
    Test_temp = load([pathname,filesep,matname]);
    initTimeTest = 0;
    
    % Configuration compare
    if isfield(Test_temp,'Configuration')
        Config_names = fields(Test_temp.Configuration); %#ok<*NASGU>
    end
    
    if numFile < 2
        
        Test = Test_temp;
        
    else
        
        %%% CT concat
        if length(Test.Tire)==1
            lastTime=0;
            for nInd = 1:length(Test.Tire.Node)
                if max(Test.Tire.Node(nInd).regs.Time)>lastTime
                    LastTime = max(Test.Tire.Node(nInd).regs.Time);
                end
            end
        end
        
        %%% MTS concat
        if isfield(Test,'FT')
            if max(Test.FT.Data.Time) > LastTime
                LastTime = max(Test.FT.Data.Time);
            end
        end
        
        %%% normal Concat
        if isfield(Test,'DecodedCAN')
            CANfields = fields(Test.DecodedCAN);
            for nFields = 1 : length(CANfields)
                if not(isempty(strfind(CANfields{nFields},'time'))) &&...
                    not(strcmp(CANfields{nFields},'Trig_time'))
                    if isempty(LastTime)
                        LastTime = max(Test.DecodedCAN.(CANfields{nFields}));
                    elseif max(Test.DecodedCAN.(CANfields{nFields})) > LastTime
                        LastTime = max(Test.DecodedCAN.(CANfields{nFields}));
                    end
                end
            end
            
        end
        
        %%% Daily concat
        if isfield(Test,'DecodedCANOutput')
            CANfields = fields(Test.DecodedCANOutput);
            for nFields = 1 : length(CANfields)
                if not(isempty(strfind(CANfields{nFields},'time')))
                    if isempty(LastTime)
                        LastTime = max(Test.DecodedCANOutput.(CANfields{nFields}));
                    elseif max(Test.DecodedCANOutput.(CANfields{nFields})) > LastTime
                        LastTime = max(Test.DecodedCANOutput.(CANfields{nFields}));
                    end
                end
            end
            
        end
        
        Test = MergeStruct (Test,Test_temp,LastTime);
        
    end
    
    for o1 = 1 : length(Test.Tire)
        for o2 = 1 : length(Test.Tire(o1).Node)
            if max(Test.Tire(o1).Node(o2).regs.Time) > LastTime
                LastTime = max(Test.Tire(o1).Node(o2).regs.Time);
            end
        end
    end
end

% good turn selection
for v1 = 1:length(Test.Tire) % 4 tire
    fo1 = fields(Test.Tire);
    for o1 = 1: length(fo1) % 3 node regsDN dbinfoDN
        for v2 = 1:length(Test.Tire(v1).(fo1{o1})) % 1 or 2 is node 1/2 or DN
            fo2 = fields(Test.Tire(v1).(fo1{o1}));
            for o2 = 1:length(fo2) % 4 in node, n se DN
                if strcmp(fo2(o2), 'regs')
                    for v3 = 1: length(Test.Tire(v1).(fo1{o1})(v2).(fo2{o2}))
                        fo3 = fields(Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3));
                        for o3 = 1: length(fo3)
                            if strcmp(fo3{o3}, 'Time') || strcmp(fo3{o3}, 'Time_online')
                                good = (not(isnan(Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).Time)));
                            end
                        end
                    end
                end
            end
            for o2 = 1:length(fo2) % 4 in node, n se DN
                %                                 for v3 = 1: length(Test.Tire(v1).(fo1{o1})(v2).(fo2{o2}))
                %                                     if strcmp(fo2{o2}(end-1:end),'in') || strcmp(fo2{o2}(end-1:end),'pl')
                %
                %                                     else
                %                                         fo3 = fields(Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3));
                %                                         for o3 = 1: length(fo3)
                %                                             if not(strcmp(fo3{o3}(end-1:end),'in') || strcmp(fo3{o3}(end-1:end),'pl'))
                %                                                 Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3}) = ...
                %                                                     Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3})(good);
                %                                             end
                %                                         end
                %                                     end
                %                                 end
                
                if strcmp(fo2{o2},'regs') || strcmp(fo2{o2},'dbinfo')
                    for v3 = 1: length(Test.Tire(v1).(fo1{o1})(v2).(fo2{o2}))
                        fo3 = fields(Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3));
                        for o3 = 1: length(fo3)
                            if not(strfind(fo3{o3},'online'))
                                Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3}) = ...
                                    Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3})(good);
                            end
                        end
                    end
                end
            end
        end
    end
end


% saving
%
TITLE='File name';
ANSWER={'name'};
prompt={'File name'};
name=TITLE;
numlines=1.2;
defaultanswer=ANSWER;
options.Resize='on';
options.WindowStyle='modal';
options.Interpreter='tex';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);
namefile = ([pathname,filesep,answer{1},'.test.mat']);

h=msgbox('Save in Progress');
save(namefile, '-struct', 'Test','-v7.3')
close(h);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% recursive function

function Res = MergeStruct(A,B,LastTime)
%% Recursively merges fields and subfields of structures A and B to result structure Res
% Simple recursive algorithm merges fields and subfields of two structures
% function related to TestConcat

global DeltaTime

Res=[];
if nargin>0
    Res=A;
end
if nargin==1 || isstruct(B)==0
    return;
end
LA = length(A);
LB = length(B);



if LA>1 || LB>1        % this cycle is just to split struct into 1x1 struct
    for Ind = 1 : LB
        if Ind <= LA
            Res_temp = MergeStruct (A(Ind),B(Ind),LastTime);
            field_temp = fieldnames(Res_temp);
            for IndField = 1 : length(field_temp)
                Res(Ind).(field_temp{IndField})=Res_temp.(field_temp{IndField});
            end
        else
            Res_temp = MergeStruct ([],B(Ind),LastTime);
            field_temp = fieldnames(Res_temp);
            for IndField = 1 : length(field_temp)
                    Res(Ind).(field_temp{IndField})=Res_temp.(field_temp{IndField}); %#ok<*AGROW>
            end
        end
    end
else
    fnb=fieldnames(B);
    for i=1:length(fnb)
        s=char(fnb(i));
        
        if isempty(B.(s))
            
        else
            
            % avoid Configuration and TyreInfo concat (they are equal for any single test)
            % check based on surface analysis test (modify for a specific case)
            % Flat Track data avoided actually, to be implemented
            % !!!!!!!!!!!!!!
            if not(strcmp(s,'Configuration')) && not(strcmp(s,'TyreInfo')) &&...
                    not(strcmp(s,'MachineName')) && not(strcmp(s,'ConditionDescription')) &&...
                    not(strcmp(s,'Size')) && not(strcmp(s,'ShortChannelDescriptions')) &&...
                    not(strcmp(s,'ChannelDescription')) && not(strcmp(s,'Units')) &&...
                    not(strcmp(s,'RotationDirection'))
                
                oldfield=[];
                if (isfield(A,s))
                    oldfield = A.(s);
                end
                newfield = B.(s);
                
                if strcmp(s,'patch')    % check based on surface analysis test (modify for a specific case)
                    Res.(s) = [oldfield,newfield];
                elseif strcmp(s,'name')     % check based on surface analysis test (modify for a specific case)
                    Res.(s) = [oldfield,{newfield}];
                elseif isstruct(newfield)==0
                    if length(s)==1
                        [a,b] = size(Res.(s));
                        if a > b
                            Res.(s) = [oldfield; newfield];
                        else
                            Res.(s) = [oldfield, newfield];
                        end
                    % check based on surface analysis test (modify for a specific case)
                    elseif (strcmp(s(end-1:end),'in') || strcmp(s(end-1:end),'pl'))
                        if length(s)>6 && strcmp(s(end-6:end-4),'ime')
                            Res.(s) = [oldfield, newfield + LastTime + DeltaTime];
                        else
                            Res.(s) = [oldfield newfield];
                        end
                    else
                        if strcmp(s,'Time') || strcmp(s,'Time_online')
                            [a,b] = size(Res.(s));
                            if a > b
                                Res.(s) = [oldfield; newfield + LastTime + DeltaTime];
                            else
                                Res.(s) = [oldfield, newfield + LastTime + DeltaTime];
                            end
                            
                        elseif length(s)>3 && strcmp(s(end-2:end),'ime')
                            [a,b] = size(Res.(s));
                            if a > b
                                Res.(s) = [oldfield; newfield + LastTime + DeltaTime];
                            else
                                Res.(s) = [oldfield, newfield + LastTime + DeltaTime];
                            end
                            %                         if not(isempty(oldfield))
%                             Res.(s) = [oldfield, newfield + oldfield(end) + DeltaTime];
                            %                         else
                            %                             Res.(s) = [oldfield, newfield + DeltaTime];
                            %                         end
                        else
                            [a,b] = size(Res.(s));
                            if a > b
                                Res.(s) = [oldfield; newfield];
                            else
                                Res.(s) = [oldfield, newfield];
                            end
                        end
                    end
                else
                    Res.(s) = MergeStruct(oldfield, newfield, LastTime);
                end
                % ancora da sistemare la sincronizzazzione FT - CT
%             elseif strcmp(s,'FT')
%                 TranspA = TranspStruct(A.FT.Data);
%                 TranspB = TranspStruct(B.FT.Data);
%                 TranspRes = MergeStruct(TranspA, TranspB);
%                 Res.FT.Data = TranspStruct(TranspRes);
            end
            
        end
    end
    
end

end

function Transp = TranspStruct(A) %#ok<*DEFNU>
% transpose each matrix of a structure
% added to implement MTS concat, MTS data are colum vectors and not row 
Transp = A;
fnb=fieldnames(A);
for i=1:length(fnb)
    s=char(fnb(i));
    if isnumeric(A.(s)) || iscell(A.(s))
        Transp.(s)=A.(s)';
    end
    
end
end


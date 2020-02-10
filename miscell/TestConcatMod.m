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
% VERSION 0.0.2
%  - Creation 03/05/2016 (G.M.)
%  - Corrected regsDN_Int and dbinfoDN_Int concat
%  - Corrected regs_Int and dbinfo_Int concat (no more good turn selection)
%  - Added proper time concat (all time vectors shifted by max Test.DecodedCAN.*_time)
%  - Reduced computing time

% Test concatenator
clear all
DeltaTime = 0;

% Folder selection
pathname = uigetdir('Z:\TestData\SampleB\OutdoorTest\Audi_A4\19WK12_AudiA4_ObjHandlingLoop\20190329_DryBraking\acquisition\set8\test','Select Test root folder');

% mat file list
cdir=dir([pathname,filesep,'*.mat']);

% time sort files
dates = zeros(size(cdir));

for Ifile = 1 : length(dates)
    fileName = cdir(Ifile).name;
    undescores = find(fileName == '_');
    startDate = undescores(end-1)+1;
    endDate = length(fileName)-9;
    fileDate = fileName(startDate : endDate);
    dates(Ifile) = datenum(fileDate, 'dd-mm-yyyy_HH-MM-SS');
end

[~,sortIndex] = sort(dates);

cdir = cdir(sortIndex);

fileTest={cdir.name};

% select files to be analyzed (only first of each quartet showed)
pause(0.1)
[s,v] = listdlg('PromptString','Select a file:','SelectionMode','multiple','ListSize',[400 400],'ListString', fileTest);
clc

% loop all the selected files
nfile=length(s);

%  s = fliplr(s);

for numFile = 1:nfile
    clear Test_temp
    
    matname = fileTest(s(numFile));
    
    % convert from cell to string
    matname=matname{1}
    
    Test_temp = load([pathname,filesep,matname]);
    initTimeTest = 0;
    
    if not(isfield(Test_temp, 'Tire'))
        Test_temp.Tire = [];
    end
    
    % Configuration compare
    Config_names = fields(Test_temp.Configuration);
    
    if numFile > 1
        
        % MaxEndTime calculation
        
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
        if isfield(Test,'DecodedCANOutput')
            CANfields = fields(Test.DecodedCANOutput);
            for nFields = 1 : length(CANfields)
                if not(isempty(strfind(CANfields{nFields},'time')))
                    if isempty(MaxEndTime)
                        LastTime = max(Test.DecodedCANOutput.(CANfields{nFields}));
                    elseif max(Test.DecodedCANOutput.(CANfields{nFields})) > MaxEndTime
                        LastTime = max(Test.DecodedCANOutput.(CANfields{nFields}));
                    end
                end
            end
            
        end
        
        
        for i = 1:length(Config_names)
            if strcmp(Test_temp.Configuration.(Config_names{i}), Test.Configuration.(Config_names{i}));
            else
                break
            end
        end
        
        for v1 = 1:length(Test_temp.Tire) % 4 tire
            fo1 = fields(Test_temp.Tire);
            for o1 = 1: length(fo1) % 3 node regsDN dbinfoDN
                if strcmp(fo1{o1},'Node')
                    for v2 = 1:length(Test_temp.Tire(v1).(fo1{o1})) % 1 or 2 is node 1/2 or DN
                        fo2 = fields(Test_temp.Tire(v1).(fo1{o1}));
                        for o2 = 1:length(fo2) % 4 in node, n se DN
                            if strcmp(fo2(o2), 'regs')
                                for v3 = 1: length(Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2}))
                                    fo3 = fields(Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3));
                                    for o3 = 1: length(fo3)
                                        if strcmp(fo3{o3}, 'Time')
                                            good = (not(isnan(Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).Time)));
                                        end
                                    end
                                end
                            end
                        end
                        for o2 = 1:length(fo2) % 4 in node, n se DN
                            %                         % controllo
                            %
                            
                            for v3 = 1: length(Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2}))
                                fo3 = fields(Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3));
                                for o3 = 1: length(fo3)
                                    if strcmp(fo2{o2},'regs_Int') || strcmp(fo3{o3}(end-1:end),'in') || strcmp(fo3{o3}(end-1:end),'pl')
                                        if strcmp(fo3{o3},'Time') || (length(fo3{o3})>6 && (strcmp(fo3{o3}(end-6:end-4),'ime')))
                                            Test.Tire(v1).(fo1{o1})(v2).(fo2{o2}).(fo3{o3}) = ...
                                                [Test.Tire(v1).(fo1{o1})(v2).(fo2{o2}).(fo3{o3}) (Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2}).(fo3{o3}) + MaxEndTime + DeltaTime)];
                                            %                                     [Test.Tire(v1).(fo1{o1})(v2).(fo2{o2}) (Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2}) + Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(end) + DeltaTime)];
                                        else
                                            Test.Tire(v1).(fo1{o1})(v2).(fo2{o2}).(fo3{o3}) = ...
                                                [Test.Tire(v1).(fo1{o1})(v2).(fo2{o2}).(fo3{o3}) Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2}).(fo3{o3})];
                                        end
                                    else
                                        if strcmp(fo3{o3}, 'Time')
                                            Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3}) = ...
                                                [Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3}) (Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3})(good) + MaxEndTime + DeltaTime)];
                                            %                                             [Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3}) (Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3})(good) + Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3})(end) + DeltaTime)];
                                        else
                                            %                                         if strcmp(fo3{o3}(end-1:end),'in') || strcmp(fo3{o3}(end-1:end),'pl')
                                            %                                             Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3}) = ...
                                            %                                                 [Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3}) Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3})];
                                            %                                         else
                                            Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3}) = ...
                                                [Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3}) Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3})(good)];
                                            %                                         end
                                        end
                                    end
                                end
                            end
                        end
                    end
                else
                    for v2 = 1:length(Test_temp.Tire(v1).(fo1{o1})) % 1 or 2 is node 1/2 or DN
                        fo2 = fields(Test_temp.Tire(v1).(fo1{o1}));
                        for o2 = 1:length(fo2)
                            if strcmp(fo2{o2}(end-6:end-4),'ime')
                                Test.Tire(v1).(fo1{o1})(v2).(fo2{o2}) = ...
                                    [Test.Tire(v1).(fo1{o1})(v2).(fo2{o2}) (Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2}) + MaxEndTime + DeltaTime)];
                                %                                     [Test.Tire(v1).(fo1{o1})(v2).(fo2{o2}) (Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2}) + Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(end) + DeltaTime)];
                            else
                                Test.Tire(v1).(fo1{o1})(v2).(fo2{o2}) = ...
                                    [Test.Tire(v1).(fo1{o1})(v2).(fo2{o2}) Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2})];
                            end
                        end
                    end
                end % fin qui corretto
            end
        end
        
        Test.name{numFile} = Test_temp.name;
        
        Can_flds = fields(Test_temp.DecodedCAN);
        for nCf = 1:length(Can_flds)
            if strcmp(Can_flds{nCf}(end-2:end), 'ime')                
                Test.DecodedCAN.(Can_flds{nCf}) = ...
                    [Test.DecodedCAN.(Can_flds{nCf}) (Test_temp.DecodedCAN.(Can_flds{nCf}) + MaxEndTime + DeltaTime)];                
            else
                Test.DecodedCAN.(Can_flds{nCf}) = ...
                    [Test.DecodedCAN.(Can_flds{nCf}) Test_temp.DecodedCAN.(Can_flds{nCf})];
            end
        end
        
        % Daily concat
        if isfield(Test_temp,'DecodedCANOutput')
            Can_flds = fields(Test_temp.DecodedCANOutput);
            for nCf = 1:length(Can_flds)
                if strcmp(Can_flds{nCf}(end-2:end), 'ime')                    
                    Test.DecodedCANOutput.(Can_flds{nCf}) = ...
                        [Test.DecodedCANOutput.(Can_flds{nCf}) (Test_temp.DecodedCANOutput.(Can_flds{nCf}) + MaxEndTime + DeltaTime)];                    
                else
                    Test.DecodedCANOutput.(Can_flds{nCf}) = ...
                        [Test.DecodedCANOutput.(Can_flds{nCf}) Test_temp.DecodedCANOutput.(Can_flds{nCf})];
                end
            end
        end
        
    else %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% first test %%%%%%%%%%
        for v1 = 1:length(Test_temp.Tire) % 4 tire
            fo1 = fields(Test_temp.Tire);
            for o1 = 1: length(fo1) % 3 node regsDN dbinfoDN
                if strcmp(fo1{o1},'Node')
                    for v2 = 1:length(Test_temp.Tire(v1).(fo1{o1})) % 1 or 2 is node 1/2 or DN
                        fo2 = fields(Test_temp.Tire(v1).(fo1{o1}));
                        for o2 = 1:length(fo2) % 4 in node, n se DN
                            if strcmp(fo2(o2), 'regs')
                                for v3 = 1: length(Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2}))
                                    fo3 = fields(Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3));
                                    for o3 = 1: length(fo3)
                                        if strcmp(fo3{o3}, 'Time')
                                            good = (not(isnan(Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).Time)));
                                        end
                                    end
                                end
                            end
                        end
                        for o2 = 1:length(fo2) % 4 in node, n se DN
                            if strcmp(fo2{o2},'regs') || strcmp(fo2{o2},'dbinfo')
                                for v3 = 1: length(Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2}))
                                    fo3 = fields(Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3));
                                    for o3 = 1: length(fo3)
                                        Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3}) = ...
                                            Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3})(good);
                                    end
                                end
                            else
                                for v3 = 1: length(Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2}))
                                    fo3 = fields(Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3));
                                    for o3 = 1: length(fo3)
                                        Test.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3}) = ...
                                            Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2})(v3).(fo3{o3});
                                    end
                                end
                            end
                        end
                    end
                else
                    for v2 = 1:length(Test_temp.Tire(v1).(fo1{o1})) % 1 or 2 is node 1/2 or DN
                        fo2 = fields(Test_temp.Tire(v1).(fo1{o1}));
                        for o2 = 1:length(fo2)
                            Test.Tire(v1).(fo1{o1})(v2).(fo2{o2}) = ...
                                [Test_temp.Tire(v1).(fo1{o1})(v2).(fo2{o2})];
                        end
                    end
                end
            end
        end
        
        Test.DecodedCAN = Test_temp.DecodedCAN;
        Test.Configuration = Test_temp.Configuration;
        Test.name{1} = Test_temp.name;
        
        % Daily concat
        if isfield(Test_temp,'DecodedCANOutput')
            Test.DecodedCANOutput = Test_temp.DecodedCANOutput;
        end
    end   
end



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

save(namefile, '-struct', 'Test','-v7.3')


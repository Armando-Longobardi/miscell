function [OutputData] = CommonTimeInterpolator(InputData,fs,tin,tf)

% Preliminary evaluation
    LastTime = [];
    FirstTime = [];
    dt = [];
    Inputfields = fields(InputData);
    for nFields = 1 : length(Inputfields)
        if not(isempty(strfind(Inputfields{nFields},'time'))) && not(isempty(InputData.(Inputfields{nFields})))
            % maxTime
            if isempty(LastTime)
                LastTime = max(InputData.(Inputfields{nFields}));
            elseif max(InputData.(Inputfields{nFields})) > LastTime
                LastTime = max(InputData.(Inputfields{nFields}));
            end
            % startTime
            if isempty(FirstTime)
                FirstTime = min(InputData.(Inputfields{nFields}));
            elseif min(InputData.(Inputfields{nFields})) < FirstTime
                FirstTime = min(InputData.(Inputfields{nFields}));
            end
            % dt
            indexes = find(not(isnan(InputData.(Inputfields{nFields}))),2,'first');
            samples = InputData.(Inputfields{nFields})(indexes);
            dts = samples(2) - samples(1);
            if isempty(dt)
                dt = dts;
            elseif dts < dt
                dt = dts;
            end
        end
    end

% nargin evaluation

if nargin > 1 && nargin < 3
    dt = 1/fs;
elseif nargin  > 2 && nargin <= 3
    dt = 1/fs;
    FirstTime = tin;
elseif nargin > 3
    dt = 1/fs;
    FirstTime = tin;
    LastTime = tf;
end

timeSet2Zero = FirstTime : dt : (ceil(LastTime/dt))*dt;

for nFields = 1 : length(Inputfields)
    if isempty(strfind(Inputfields{nFields},'time')) && not(isempty(InputData.(Inputfields{nFields})))
        dato = InputData.(Inputfields{nFields});
        dato_time = InputData.([Inputfields{nFields},'_time']);
        validSelection = [true not(diff(dato_time) == 0)];
        OutputData.(Inputfields{nFields}) = interp1(dato_time(validSelection), dato(validSelection),timeSet2Zero,'Linear','extrap');
    end
end

OutputData.Time = timeSet2Zero;
end
 

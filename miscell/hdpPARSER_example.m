function [Info, Data] = hdploader(filename)
% Patrucco, Cyber Tyre Pirelli, 2020
% Reads HDP raw, proprietary data

N_header = 10000;

f1 = fopen(filename, 'r');
header_bytes = fread(f1, N_header);
fclose(f1);


header_char = char(header_bytes');
ind_newline = strfind(header_char, sprintf('%s', [13, 10]));
ind_startbin = ind_newline(end) + 2;
header_lines = strsplit(header_char, sprintf('%s', [13, 10]));
header_lines(end) = []; % beginning of binary data.
info_fields = ~contains(header_lines, '#');

Info = struct();
header_info = header_lines(info_fields);
for ii = 1:length(header_info)
    [n, v] = parse_info_field(header_info{ii}(1:end-1));
    Info.(n) = v;
end

if isfield(Info, 'TireCount')
    N_sections = Info.TireCount;
else
    error('Could not determine number of sections from file');
end

Data = repmat(struct(), N_sections, 1);

for i_sec = 1:N_sections
    str2src = ['#', num2str(i_sec-1)];
    data_lines = header_lines(contains(header_lines, str2src));
    for i_lin = 1:length(data_lines)
        this_line = data_lines{i_lin};
        i_ss = strfind(this_line, str2src);
        this_line(i_ss:i_ss+length(str2src)-1) = '';
        [n, v] = parse_info_field(this_line(1:end-1));
        Data(i_sec).(n) = v;
    end
    Data(i_sec).numel = Data(i_sec).Width * Data(i_sec).Height;
end

num_prev = [0; [Data.numel]'];

ind_skip = ind_startbin + cumsum(num_prev).*4;
for i_sec = 1:N_sections
    f1 = fopen(filename, 'r');
    fread(f1, ind_skip(i_sec));
    Data(i_sec).raw = fread(f1, [Data(i_sec).Width, Data(i_sec).Height], 'single', 'ieee-le');
    Data(i_sec).raw(Data(i_sec).raw < -1e20) = NaN;
    fclose(f1);
end

% keyboard







    function [name, val] = parse_info_field(str_in)
        s_splt = strsplit(str_in, '=', 'CollapseDelimiters', false);
        name = s_splt{1};
        valh = str2double(s_splt{2});
        if ~isnan(valh)
            val = valh;
        else
            val = s_splt{2};
        end
    end



end
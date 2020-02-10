function [merged_struct] = MergeStructs(struct_a,struct_b,fields)
% merge the fields of struct_b specified (all if not specified)


%% if one of the structres is empty do not merge
if isempty(struct_a)
    merged_struct=struct_b;
    return
end
if isempty(struct_b)
    merged_struct=struct_a;
    return
end

%% specify fields if not
if nargin<3
fields = fieldnames(struct_b);
end

f_a = fieldnames(struct_a);

%% main
% copy struct_a
merged_struct=struct_a;

if ~isempty(intersect(f_a,fields))
    warning('Fields over-written')
    disp(intersect(f_a,fields))
end

% add fields of struct_b
for j=1:length(struct_b)
    
    for i = 1:length(fields)
        merged_struct(j).(fields{i}) = struct_b(j).(fields{i});
    end
end

end
function [ dir_name parent_name] = dir_name( dir_path )
%Estraggo il nome della cartella dal path completo
%   Detailed explanation goes here
start_char=char(dir_path);

%dummy è l'indice dell'ultimo \ del path, dopo il quale ho il nome della
%cartella
i_slash = find(start_char=='\',2,'last');
dummy=length(i_slash);
dir_name=start_char(i_slash(dummy)+1:length(start_char));

if dummy > 1
   parent_name = start_char(i_slash(1)+1:i_slash(2))

end


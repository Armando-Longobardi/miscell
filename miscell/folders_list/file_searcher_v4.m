function [ indice_new, target_new, i_count_new ] = file_searcher_v4( start,excel_name,excel_dir,indice, target, i_count )
%Funzione ricorsiva che salva in un excel
%   Versione 2: salvo excel ad ogni passo, tanto riscrive
%               le stesse cose
%   Versione 3: link alle sottocartelle in excel
%   Versione 4:salvo una sola volta il foglio, link alle cartelle genitore
%% Check input
if nargin ==3
    i_count = 1;
    indice = 0;
    target = 0;
end

if nargin ==2
    excel_dir=start;
    i_count = 1;
    indice = 0;
    target = 0;
end

if nargin ==1
    [excel_name, ~]= dir_name_v2(start);
    excel_name=correct_name(excel_name);
    excel_dir=start;
    i_count = 1;
    indice = 0;
    target = 0;
end

if nargin ==0
    start=cd;
    [excel_name, ~]= dir_name_v2(start);
    excel_name=correct_name(excel_name);
    excel_dir=start;
    i_count = 1;
    indice = 0;
    target = 0;
end

if isempty(start)
    start=cd;
end

%% Salvo excel
local_path=cd;

%ottengo la lista di file e cartelle contenuti nella cartella attuale
[files, folders]=file_folder_separator_v2(local_path);

% definisco il target come numero di cartelle presenti
if ~isempty(folders)
    target(i_count)= size(folders,1);
else
    target(i_count)=0;
end

if indice(i_count)==0
    %definisco il nome della sheet, cambiandolo se non compatibile con Matlab
    [excel_sheet_name, excel_parent_sheet]=dir_name_v2(local_path);
    
    excel_sheet_name=correct_name(excel_sheet_name);
    
    
    if ~isempty(excel_parent_sheet) && i_count>1
        excel_parent_sheet=correct_name(excel_parent_sheet);
        files(2,1)=cellstr(strcat('=HYPERLINK("#',excel_parent_sheet, '!A', num2str(indice(i_count-1)+3), '";"' ,char(files(2)), '")' ));
    end
    
    
    if isempty(folders)
        excel_sheet_content=cellstr([local_path;' ';files]);
    else
        %aggiungo il link tra cartella e propria sheet
        folder_links = cell(size(folders,1),1);
        for etabeta=1:size(folders,1)
            folders_links(etabeta,1)=cellstr(strcat('=HYPERLINK("#', correct_name(char(folders(etabeta))) ,'!A1";"' ,char(folders(etabeta)), '")'));
        end
        
        
        
        excel_sheet_content=cellstr([local_path;' ';folders_links;' ';files]);
    end
    %salvo in excel, sempre nella stessa directory iniziale
    warning('off','MATLAB:xlswrite:AddSheet');
    
    cd(excel_dir)
    xlswrite(excel_name,excel_sheet_content, excel_sheet_name);
    cd(local_path)
    
    warning('on','MATLAB:xlswrite:AddSheet');
    
end
%checko se devo stopparmi
if indice(i_count)==target(i_count) && i_count==1
    return;
end

%% Gioco con i vettori indice e indicatore e decido cosa fare andare
% 1) ENTRO IN UNA SOTTOCARTELLA NON ESPLORATA-> aumento di 1 
% l'i_count e la dimensione di indice con uno 0, faccio ripartire il tutto
% 2) ESCO DA UNA CARTELLA a) SENZA SOTTOCARTELLE O b)CON TUTTE 
% GIA' ESPLORATE -> riduco di 1 l'i_count e la la dimensione di indice,
% aumentando di 1 la nuova ultima componente, faccio ripartire il tutto

%2)
if target(i_count)==indice(i_count)
    cd ..
    
    i_count_new=i_count-1;
    indice_new=indice(1:i_count_new);
    indice_new(i_count_new)=indice_new(i_count_new)+1;
    
     
    file_searcher_v4( start,excel_name,excel_dir,indice_new, target, i_count_new );
else
    cd(char(folders(indice(i_count)+1)))
    
    i_count_new=i_count+1;
    indice_new=indice(1:i_count);
    indice_new(i_count_new)=0;
    
    file_searcher_v4( start,excel_name,excel_dir,indice_new, target, i_count_new );
    
    
end

%1)







end


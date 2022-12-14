function save_all_open_figs(save_folder,varargin)

if nargin<1 || not(isfolder(save_folder))
    save_folder=uigetdir;
end
    close_check=false;
    ext=[];
    nameOpt = 'figName';
    
    Props={'CloseAll','SaveAs','NameAs','CorrectName'};
for iInput= 1:2:numel(varargin)
    switch validatestring(varargin{iInput},Props)
        case 'CloseAll'
            close_check=varargin{iInput+1};
        case 'SaveAs'
            ext=varargin{iInput+1};
        case 'NameAs'
            nameOpt=validatestring(varargin{iInput+1},{'figName','Title'});
    end
end

hands   = get (0,'Children');   % locate fall open figure handles
hands   = sort(hands);          % sort figure handles
numfigs = size(hands,1);        % number of open figures

for i_fig=1:numfigs
    
        switch nameOpt
            case 'figName'
                partial_name=hands(i_fig).Name;
            case 'Title'
                Axs=findobj(hands(i_fig),'Type','Axes');
                partial_name=string(Axs.Title.String);
                partial_name=char(strjoin(partial_name));
                partial_name=regexprep(partial_name(:)',' *','_');           
        end
        
        partial_name=matlab.lang.makeValidName(partial_name);
        partial_name=matlab.lang.makeUniqueStrings(partial_name,{},47);
        

        
        figname=[save_folder,filesep,partial_name,'_',datestr(datetime,'yyyymmdd_HHMMSS')];
                
        
    if isempty(ext)    
        savefig(hands(i_fig),figname,'compact')
    else
        try
            saveas(hands(i_fig),figname,ext)
        catch
            warning('Extension not valid. /n Function interrupted')
            return
        end
    end
end

if close_check
    close all
end

end
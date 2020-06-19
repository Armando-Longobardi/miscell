function save_all_open_figs(save_folder,close_check,ext)

if nargin<1
    close_check=false;
    save_folder=pwd;
    ext=[];
elseif nargin<2
    close_check=false;
    ext=[];
elseif nargin<3
    ext=[];
end

hands   = get (0,'Children');   % locate fall open figure handles
hands   = sort(hands);          % sort figure handles
numfigs = size(hands,1);        % number of open figures

for i_fig=1:numfigs
    if isempty(ext)
        
        
        
        savefig(hands(i_fig),[save_folder,filesep,correct_name(hands(i_fig).Name,50),'_',datestr(datetime,'yyyymmdd_HHMMSS')],'compact')
    else
        try
            saveas(hands(i_fig),[save_folder,filesep,correct_name(hands(i_fig).Name,50),'_',datestr(datetime,'yyyymmdd_HHMMSS')],ext)
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
hands   = get (0,'Children');   % locate fall open figure handles
hands   = sort(hands);          % sort figure handles
numfigs = size(hands,1);        % number of open figures

save_folder='C:\Users\longoar001\Desktop\AL_desk\Topics\14_DMA\figures\PSN\analisi-giri concatenati e hannati';

for i_fig=1:numfigs
    savefig(hands(i_fig),[save_folder,filesep,hands(i_fig).Name,'_',datestr(datetime,'yyyymmdd_HHMMSS')])
end

% close all

function createGIF(ref_dir,dt,fig_pos)
% input
if nargin<1
    dt=1;
    ref_dir=[];
    fig_pos=[];
elseif nargin<2
    dt=1;
    fig_pos=[];
elseif nargin<3
    fig_pos=[];
end

if isempty(ref_dir)
    ref_dir=uigetdir();
end
if isempty(dt)
    dt=1;
end
% selection figs
figs=dir([ref_dir,filesep,'*.fig']);
figs={figs.name};

i_figs = listdlg('PromptString','Select figs','ListString',figs,'ListSize',[300 300]);

%salva immagini per gif
nIm=0;
for fig=figs(i_figs)
    openfig([ref_dir,filesep,fig{:}]);
    if ~isempty(fig_pos)      
        set(gcf,'Position',fig_pos)              
    end
    AX=gca;
    set(AX.Toolbar,'Visible','off')
    nIm=nIm+1;
    frame = getframe(gcf);
    im{nIm} = frame2im(frame);
    close(gcf)
end

% salva alla fine
filename=[ref_dir, filesep,'GIF_',strrep(strrep(num2str(fix(clock)),'    ','_'),'__','_'),'.gif'];

for idx = 1:nIm
    [A,map] = rgb2ind(im{idx},256);
    if idx == 1
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',dt);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',dt);
    end
end

end

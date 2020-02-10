function tilefigs(tile,border,hands,maxpos)
% <cpp> tile figure windows usage: tilefigs ([nrows ncols],border_in pixels,hands,maxpos)
% Restriction: maximum of 100 figure windows
% Without arguments, tilefigs will determine the closest N x N grid
% Added optional input: handle with the only figures to adjust
% Added optional input: part of the screen where put the figures





if nargin < 2
  border = 0;
end
if nargin<3
    hands   = get (0,'Children');   % locate fall open figure handles
    hands   = sort(hands);          % sort figure handles
end
if nargin<4
    maxpos  = get (0,'screensize'); % determine terminal size in pixels
    maxpos(4) = maxpos(4) - 50;
end
numfigs = length(hands);        % number of open figures


maxfigs = 100;

if nargin == 0
  maxfactor = sqrt(maxfigs);       % max number of figures per row or column
  sq = (2:maxfactor).^2;             % vector of integer squares
  sq = sq((sq>=numfigs));          % determine square grid size
  gridsize = sq(1);                % best grid size
  nrows = sqrt(gridsize);          % figure size screen scale factor
  ncols = nrows;                   % figure size screen scale factor
elseif nargin > 0 
  nrows = tile(1);
  ncols = tile(2);
  if numfigs > nrows*ncols
    disp ([' requested tile size too small for ' ...
        num2str(numfigs) ' open figures '])
        return
  end
end



if (numfigs>maxfigs)            % figure limit check
        disp([' More than ' num2str(maxfigs) ' figures ... get serious pal'])
        return
end




xlen = fix(maxpos(3)/ncols) ; % new tiled figure width
ylen = fix(maxpos(4)/nrows) ; % new tiled figure height

  maxpos(3) = maxpos(3) - 2*border;
  maxpos(4) = maxpos(4) - 2*border;


% tile figures by postiion 
% Location (1,1) is at bottom left corner
pnum=0;
for iy = 1:nrows
  ypos = maxpos(2)+maxpos(4) - fix((iy)*maxpos(4)/nrows) + border ; % figure location (row)
  for ix = 1:ncols
        xpos = maxpos(1) + fix((ix-1)*maxpos(3)/ncols + 1) + border;     % figure location (column)
        pnum = pnum+1;
        if (pnum>numfigs)
                break
        else
          figure(hands(pnum))
      set(hands(pnum),'OuterPosition',[ xpos ypos xlen ylen ]); % move figure
        end
  end
end
return
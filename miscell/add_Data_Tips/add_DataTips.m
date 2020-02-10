function h_Dtip_out = add_DataTips( x_values , h_curve_Array, fontSize, nx,ny)
% ADD_DATATIPS( x_values , [h_curve_Array], [fontSize, nx,ny])
% Creates multiple data tips on multiple line handles
% with color matched to that of each curve.
% Tips are created at location xi,fn(xi) where 
% xi     = x_values,
% fn(xi) = defined by (XData,YData) in h_curve_Array(n)
%
% INPUTS:    
% ------
% h_curve_Array = a single Line handle or an array of them
% x_values      = array of x value where data tips are requested
% fontSize      = self explanatory
% nx,ny         = nr of digits used for representation x,y(z)

% EXAMPLE:
% figure(); hold on;
% p_h(1) = plot(0:10,(0:10).^2,'b'); 
% p_h(2) = plot(0:10,(0:10),'r'); 
% add_DataTips( [3.3,5.5,7.7] , p_h, 7)
% 
% EXAMPLE:
% figure(); hold on;
% plot(0:10,(0:10).^2,'b'); 
% plot(0:10,(0:10),'r'); 
% add_DataTips( [3.3,5.5,7.7])
%
% M.Ciacci, 2019/11/26, rev1.4

global fmt_x
global fmt_y

if nargin < 2,                         h_curve_Array = [];  end
if nargin < 3 || isempty(fontSize),    fontSize = 10;       end
if nargin < 4 || isempty(nx),          nx = 4;              end
if nargin < 5 || isempty(ny),          ny = 4;              end

if isempty(x_values) || isempty(h_curve_Array) || ~ishandle(h_curve_Array(1))
    if ~isempty(h_curve_Array)
        fprintf('add_DataTips: invalid x or non handle passed as argument. No tips were added.\n');
        h_Dtip_out=[];
        return
    else
        h_curve_Array = getPlottedHandles(gca);
        if ~ishandle(h_curve_Array(1))
            fprintf('add_DataTips: empty handle passed and gca has no valid handles. No tips were added.\n');            
            h_Dtip_out=[];
            return
        end
    end
end


fh     = gcf; %figure handle, here it probably exists since h_curve_Array existed few lines above
drawnow %this is a must else it will fail very likely for MatlabV > 2014b

% internal settings
DBG_ON          = 0;
markerEColor    = 'k'; % edge of marker color
chgBckGrndColor = 1;   % 1 = match DataTip background color with curve color
fontName        = 'Comic Sans MS';
% d = listfonts

% define format precision for text update function
fmt_x = sprintf('%%%d.%dg',nx+2,nx);
fmt_y = sprintf('%%%d.%dg',ny+2,ny);

% loop over array of curve handles, and for each over array of x values
nCurves = numel(h_curve_Array);
nVals   = numel(x_values);
h_Dtip  = cell(nCurves,nVals);
for iCurve = 1:nCurves
    hTarget = handle(h_curve_Array(iCurve));
    if ~ishandle(hTarget)
        continue;
    end    
    % curves may be on different axes, retrieve handle every time, this is fast
    ax_hdl = ancestor(hTarget,'axes');
    xLims  = get(ax_hdl,'xlim');
    if ~DBG_ON
        set(hTarget,'visible','off'); %save time in creating data tips !    
    end    
    lineColor = get(hTarget,'color'); % will be used to match data tip color

    % retrieve the datacursor manager
    cursorMode = datacursormode(fh);
    set(cursorMode, 'UpdateFcn',@customDatatipFunction);

    xdata = get(hTarget,'XData') ;
    ydata = get(hTarget,'YData') ;

    % add the datatip for each x value 
    for idx_evt = 1:numel(x_values)
        x_val = min(max(xdata(1),x_values(idx_evt)),xdata(end));
        if (x_val < xLims(1) || x_val > xLims(2))
            fprintf('add_DataTips: value %5.3g out of xlim (%5.3g,%5.3g), will not add data tip... \n',x_val,xLims(1),xLims(2));
            break; %no tip out of limits or we will fire an error!
        end
        try  % create a tip somewhere
            hDatatip = cursorMode.createDatatip(hTarget) ; % a lot will happen in here..
        catch MSG
            set(hTarget,'visible','on');  h_Dtip_out = []; disp(MSG)% restore visible, show exception
            warning('Failed to create data tip (is drawnow in place?)');
            return
        end
        
        % set tip properties
        set(hDatatip, 'MarkerSize',5,'MarkerFaceColor',lineColor,'MarkerEdgeColor',markerEColor, 'Marker','o'); %'HitTest','off'
        
        % move it into the right place
        [~,idx_DATA] = min(abs(xdata - x_val)) ;%// find the index of the corresponding time
        
        %% ==> set tip in the right x,y location, use interpolation
        hDatatip.Interpolate ='on'; %this one can fire warnings...
        [pos,xx] = getInterpPosition(x_val, xdata,ydata,idx_DATA);
        set(hDatatip, 'Position', pos);
        
        %% check for internal interpolate failure, if so, fix it!
        pos_re_check = get(hDatatip,'pos');
        err_x = abs(pos_re_check(1) - pos(1));
        if err_x > abs(xx(2)-xx(1))
            % Without this check a warning will be fired (see below) and/or not plot the tip at all !
            % "Warning: Error updating PointDataTip. 
            % DataSpace or ColorSpace transform method failed"
            %
            % So far it was the internal interpolate which was occasionally failing (ML2016b) [xscale was linear, x-value (evt) was between 2nd and 3rd x data points]
            if DBG_ON, warning('Interp Data Tip Failed, using non-interp'); end
            hDatatip.Interpolate = 'off';
            set(hDatatip, 'Position', [xdata(idx_DATA) , ydata(idx_DATA),0]); % set nearest
        end

        if chgBckGrndColor 
            tipBckGndColor = desaturateAndBrightenUp(lineColor);
            set(hDatatip, 'BackgroundColor', tipBckGndColor)
        end        
        
        % Set the data-tip orientation 
        set(hDatatip,'OrientationMode','manual','Orientation','topright');
        
        % invoke text update function and more
        updateDataCursors(cursorMode);        
        
        h_Dtip{iCurve,idx_evt} = hDatatip;
    end %for idx_evt
    if ~DBG_ON
        set(hTarget,'visible','on'); % done with this line, restore visibility
    end
end %for iCurve

%set other properties
alldatacursors = findall(fh,'type','hggroup');
set(alldatacursors,'FontSize',fontSize);
set(alldatacursors,'FontName',fontName);
if nargout > 0
    h_Dtip_out = h_Dtip;
end




% ----------------------------------  Text Update callback function ------------------
% note: do not change data tip properties inside this function, it would be bad practice and fire traversing object warnings
function output_txt = customDatatipFunction(~,evt)
global fmt_x
global fmt_y

pos = get(evt,'Position');
output_txt = { 
   ['X = ',sprintf(fmt_x,pos(1))] ; 
   ['Y = ',sprintf(fmt_y,pos(2))] };       

% check if there is a Z-coordinate, if so display that too
if length(pos) > 2
    output_txt{end+1} = ['Z = ',sprintf(fmt_y,pos(3))];
end


% ----------------------------------  Aux Functions ------------------
function [pos,xx] = getInterpPosition(xVal, xdata,ydata,idx_DATA)
if idx_DATA < length(xdata)
    if idx_DATA > 1
        xx=xdata([idx_DATA-1,idx_DATA,idx_DATA+1]); 
        yy=ydata([idx_DATA-1,idx_DATA,idx_DATA+1]);
    else
        xx=xdata([idx_DATA,idx_DATA+1]); 
        yy=ydata([idx_DATA,idx_DATA+1]);                
    end
else
    xx=xdata([idx_DATA-1,idx_DATA]); 
    yy=ydata([idx_DATA-1,idx_DATA]);  
end
yItp= interp1(xx,yy,xVal,'pchip');
pos = [xVal , yItp ,0];




% ------------------------------  Color handling --------------------
function rgb1 = desaturateAndBrightenUp(rgbVec)
% convert to HSL
[~,HSL_pc] = RGBint_2_HSVpc_HSLpc(rgbVec*255);

% increase brightness significantly
L = HSL_pc(3);
L = max(min(4/3*L,98),85);   
HSL_pc(3) = L;

% convert back to RGB
[RGBint] = HSLpc_2_RGBint(HSL_pc);
rgb1 = RGBint/255;


%HSV and HSB are the same thing (Value = Brightness)
%HSL has a different definition of both Saturation and Lightness
%
% INPUT:
% --------
% RGBint: a Nx3 matrix with one RGB value per row, in [0..255]
% 
% OUTPUT:
% --------
% HSVpc : a Nx3 matrix, H=0..360, S=0..100, V=0..100  (pc = per-cent)
% HSLpc : a Nx3 matrix, H=0..360, S=0..100, L=0..100  (pc = per-cent)
% 
% note: r,g,b denote values in [0..1] but still in companded lightness (CRT domain)
%       i.e. r=R/255 etc
function [HSVpc, HSLpc] = RGBint_2_HSVpc_HSLpc(RGBint)
if size(RGBint,2) ~= 3
    error('each input column is expected to be one RGB entry');
end
if (max(max(RGBint))) > 255
    error('RGB values out of range');
end
% extract channels
% A colormap has values on [0,1], while a uint8 image has values on [0,255]. This is what rgb2hsv expects
% RGBintis in 0..255, keep precision
r = double(RGBint(:,1)) / 255;
g = double(RGBint(:,2)) / 255;
b = double(RGBint(:,3)) / 255;

[hsv] = rgb2hsv(r,g,b);

%HSV to HSL (http://codeitdown.com/hsl-hsb-hsv-color/)
H       = hsv(:,1);
S       = hsv(:,2);
V       = hsv(:,3);
L       = 0.5.*V.*(2-S) ;
S_HSL   = V.*S./(1-abs(2*L-1));

S_HSL(abs(2*L-1)==1) = 0;

%prevent 100+eps or 0-eps to appear
H = max(0,min(H,1));
S = max(0,min(S,1));
S_HSL = max(0,min(S_HSL,1));
V = max(0,min(V,1));
L = max(0,min(L,1));

% keep precision
HSVpc = cat(2,360*H,100*S,     100*V);
HSLpc = cat(2,360*H,100*S_HSL, 100*L);



%HSV and HSB are the same thing (Value = Brightness)
%HSL has a different definition of both Saturation and Lightness
% note: r,g,b denote values in [0..1] but still in companded lightness (CRT domain)
%       i.e. r=R/255 etc
function [RGBint] = HSLpc_2_RGBint(HSLpc)
if size(HSLpc,2) ~= 3
    error('each input row is expected to be one HSL entry');
end

H = HSLpc(:,1);
S = HSLpc(:,2);  
L = HSLpc(:,3);  

% HSV is in 0..360, 0..100, 0..100, but keep precision
H     = double(H) / 360;
S_HSL = double(S) / 100;
L     = double(L) / 100;

%from HSL to HSV(B) (http://codeitdown.com/hsl-hsb-hsv-color/)
V       = L + S_HSL.*(1-abs(2*L-1))/2;
S_HSV   = 2*(V-L)./V;
S_HSV(V==0) = 0;

% HSV 2 rgb in [0 1]
[rgb] = hsv2rgb(H,S_HSV,V);

% scale up, keep precision, and get rid of singleton dimensions
RGBint = squeeze(rgb*255);

if size(RGBint,2)==1
    %one single color, convert to row
    RGBint=RGBint.';
end
RGBint = max(0,min(RGBint,255));



function allCurves = getPlottedHandles( axh )
%GETPLOTTEDHANDLES Summary of this function goes here
%   Detailed explanation goes here

if isempty(axh)
    axh=findobj(gcf,'type','axes','Tag',''); %avoid legend axis
end

axChild= get(axh,'Children');

allCurves=findobj(axChild,'type','line');

allCurves = flip(allCurves); %preserve order of handles as in plotting order not reversed!


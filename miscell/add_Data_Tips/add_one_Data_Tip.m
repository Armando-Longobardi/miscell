% M.Ciacci, 24/09/2019
function add_one_Data_Tip( x0 , h_curve, fontSize)
    % ADD_ONE_DATA_TIP( x0 , h_curve, fontSize)
    % Creates a data tip at location x0,f(x0) where f(x) is defined by xy data in h_curve
    %
    % INPUTS:    
    % ------
    % h_curve    = a single Line handle
    % sel_x_val  = x value where data tip is requested
    %
    % EXAMPLE:
    % figure(); p_h = plot(0:10,(0:10).^2,'b'); add_one_Data_Tip( 4.5 , p_h, 16)
    
    % retrieve the datacursor manager
    cursorMode = datacursormode(gcf);
    set(cursorMode, 'UpdateFcn',@customDatatipFunction);
    
    % create a tip somewhere
    h_Dtip = cursorMode.createDatatip(h_curve) ;
    
    % set tip properties
    markerColor  = get(h_curve,'color'); %same color as curve
    markerEColor = 'k';
    set(h_Dtip, 'MarkerSize',5,'MarkerFaceColor',markerColor,...
        'MarkerEdgeColor',markerEColor, 'Marker','o'); %'HitTest','off'

    %% ==> set tip in the right x,y location
    xdata = get(h_curve,'XData') ;
    ydata = get(h_curve,'YData') ;
    [~,idx] = min(abs(xdata - x0));
    
    % use interpolation
    h_Dtip.Interpolate ='on';
    if idx < length(xdata)
        if idx > 1
            xx=xdata([idx-1,idx,idx+1]); 
            yy=ydata([idx-1,idx,idx+1]);
        else
            xx=xdata([idx,idx+1]); 
            yy=ydata([idx,idx+1]);                
        end
    else
        xx=xdata([idx-1,idx]); 
        yy=ydata([idx-1,idx]);  
    end
    yItp=interp1(xx,yy,x0);
    
    % set tip location
    pos = [x0 , yItp ,0];
    set(h_Dtip, 'Position', pos,'BackgroundColor',[238 235 141]/255);
    
    % invoke text update function and more: ### no changing allowed in there !! ###
    updateDataCursors(cursorMode)
    
    %% set other properties
    set(h_Dtip,'FontSize',fontSize,'FontName','Comic Sans MS');    
    
    
    
    % no tip properties changing allowed in here, would risk to crash as well
    function output_txt = customDatatipFunction(~,evt)
    pos = get(evt,'Position');
    
    output_txt = { 
    ['X = ',sprintf('%6.2g',pos(1))] ;
    ['Y = ',sprintf('%7.3g',pos(2))] };        
    
    % check if there is a Z-coordinate, if so display that too
    if length(pos) > 2
        output_txt{end+1} = ['Z: ',num2str(pos(3),3)];
    end    
    % e.g. this would cause the error 
    %% "Attempt to modify the tree during an update traversal"
    %% and even crash Matlab at times
    % alldatacursors = findall(gcf,'type','hggroup');
    % set(alldatacursors,'FontSize',12);
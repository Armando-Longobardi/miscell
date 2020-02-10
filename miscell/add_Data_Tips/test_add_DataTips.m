close all;
clearvars

figure; hold on; 
set(gcf,'Color',[1,1,1],'units','normalized','position',[.1 .1 .8 .6]);
axh=gca;
set(axh,'FontSize',16,'FontName','Times'); 

xlabel('x');ylabel('y');title('a family plot with data tips');
x       = (0:10:1000);
xMid    = (x(1)+2*x(end))/3;
parVals = [1 1.5 2]; 

LineTypes   = {'-.','-','--'};
colors      = {'r','b',[1 1 1]*0.5};
for ip=1:length(parVals)
    col           =  colors{1+mod(ip-1,length(colors))};
    ls            =  LineTypes{1+mod(ip,length(LineTypes))};
    g             =  parVals(ip);
    y             =  1 + 1/g*abs(1e4./(xMid + (x-xMid/g).^(2-0.2*g)));   % a function that changes with parameter g
%     h_curve_Array(ip) = line(x,y,'color',col,'linestyle',ls, 'linewidth',2, 'parent',axh,...
%                              'DisplayName',sprintf('g=%2.2f',g));
    line(x,y,'color',col,'linestyle',ls, 'linewidth',2, 'parent',axh,...
                             'DisplayName',sprintf('g=%2.2f',g));

end
leg = legend(axh,'-DynamicLegend','Location','NorthWest');

% --------------------------------
x_values   = [333, 666];
fontSize   = 12;

% profile off; profile on
% tic

h_Dtip_out = add_DataTips( x_values , [], fontSize);
% h_Dtip_out = add_DataTips( x_values , h_curve_Array, fontSize);
% h_Dtip_out = add_DataTips( x_values , h_curve_Array, fontSize,3,8);

% toc
% profile viewer

% move last tip to be visible
h_Dtip_out{length(parVals),length(x_values)}.Orientation = 'bottomright';
% --------------------------------
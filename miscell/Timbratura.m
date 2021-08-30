function varargout = Timbratura(askmode)
%  function varargout = Timbratura(askmode)
% askmode == true => tells last timbratura;  
% askmode == false => set 'now' as last timbratura (Timbratura manuale);  

actualDir=fileparts(which(mfilename));

if not(isfile([actualDir filesep 'lastTimbratura.Info']))
    lastTimbratura=now-datenum(0,0,1);
    save([actualDir filesep 'lastTimbratura.Info'],'lastTimbratura');
else
    load([actualDir filesep 'lastTimbratura.Info'],'lastTimbratura','-mat');
end
% lastTimbratura=now;
if nargin>0 && askmode
    varargout={lastTimbratura};
    return
elseif nargin>0 && ~askmode
    lastTimbratura=now;
    save([actualDir filesep 'lastTimbratura.Info'],'lastTimbratura');
    varargout={};
    return
end


% mex 'C:\Users\longoar001\Desktop\buffer\textInject.cc'
import java.awt.Robot;
import java.awt.event.*;
mouse = Robot;

system('start iexplore http://lynda.it.pirelli.com:8112/irj/portal','-echo')
uiwait(mydialog)

%TODO: setta finestra alla massima grandezza
%      usa CMDOW, controllando di averlo come file e nel path di sistema
%      oppure come alternativa usi mydialog per ingrandirlo oppure
%      myDialog e fai fare all'utente
% setx path "%path%;c:\directoryPath"
% 

%TODO: rendi parametrici le posizioni del mouse

% elimina banner fine mese
% if day(datetime('today'))>=20    
%     mouse.mouseMove(1348, 95);
%     mouse.mousePress(InputEvent.BUTTON1_MASK);
%     mouse.mouseRelease(InputEvent.BUTTON1_MASK);
%     pause(1)
% end
% apri menù a tendina
mouse.mouseMove(45, 104);
pause(2)
mouse.mousePress(InputEvent.BUTTON1_MASK);
mouse.mouseRelease(InputEvent.BUTTON1_MASK);
% clicca su calendario
mouse.mouseMove(138, 161);pause(1);
mouse.mouseMove(138, 182);pause(1);
mouse.mousePress(InputEvent.BUTTON1_MASK);
mouse.mouseRelease(InputEvent.BUTTON1_MASK);
% inserisci smartworking
pause(5)
mouse.mouseMove(413, 569);
mouse.mousePress(InputEvent.BUTTON1_MASK);
mouse.mouseRelease(InputEvent.BUTTON1_MASK);

mouse.keyPress(KeyEvent.VK_S);
mouse.keyPress(KeyEvent.VK_M);pause(1);
mouse.keyPress(KeyEvent.VK_ENTER);
% seleziona giorno
mouse.keyPress(KeyEvent.VK_TAB);pause(1);
mouse.keyPress(KeyEvent.VK_ENTER);pause(1);
mouse.keyPress(KeyEvent.VK_TAB);pause(1);
mouse.keyPress(KeyEvent.VK_ENTER);pause(1);
% premi ok
mouse.keyPress(KeyEvent.VK_TAB);pause(1);
mouse.keyPress(KeyEvent.VK_TAB);pause(1);
mouse.keyPress(KeyEvent.VK_TAB);pause(1);
mouse.keyPress(KeyEvent.VK_TAB);pause(1);
mouse.keyPress(KeyEvent.VK_ENTER);pause(3);
mouse.keyPress(KeyEvent.VK_ENTER);

% chiudi tutto
system('taskkill /F /IM iexplore.exe')
clc

lastTimbratura=now;
save([actualDir filesep 'lastTimbratura.Info'],'lastTimbratura');

end

function d=mydialog
d = dialog('Position',[300 300 250 150],'Name','My Dialog','WindowStyle','normal');

uicontrol('Parent',d,...
    'Style','text',...
    'Position',[20 80 210 40],...
    'String','Maximize window and remove banner');

uicontrol('Parent',d,...
    'Position',[85 20 70 25],...
    'String','Close',...
    'Callback','delete(gcf)');
end
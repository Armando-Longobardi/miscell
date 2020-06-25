function Timbratura
% mex 'C:\Users\longoar001\Desktop\buffer\textInject.cc'
import java.awt.Robot;
import java.awt.event.*;
mouse = Robot;

system('start iexplore http://lynda.it.pirelli.com:8112/irj/portal','-echo')
pause(5)
% elimina banner fine mese
mouse.mouseMove(1348, 95);
mouse.mousePress(InputEvent.BUTTON1_MASK);
mouse.mouseRelease(InputEvent.BUTTON1_MASK);
pause(1)
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

end
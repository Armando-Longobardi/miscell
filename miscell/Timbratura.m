function Timbratura
% mex 'C:\Users\longoar001\Desktop\buffer\textInject.cc'
import java.awt.Robot;
import java.awt.event.*;
mouse = Robot;

system('start iexplore http://lynda.it.pirelli.com:8112/irj/portal','-echo')
pause(5)
mouse.mouseMove(45, 104);
pause(2)
mouse.mousePress(InputEvent.BUTTON1_MASK);
mouse.mouseRelease(InputEvent.BUTTON1_MASK);

mouse.mouseMove(138, 161);pause(1);
mouse.mouseMove(138, 182);pause(1);
mouse.mousePress(InputEvent.BUTTON1_MASK);
mouse.mouseRelease(InputEvent.BUTTON1_MASK);

pause(5)
mouse.mouseMove(413, 569);
mouse.mousePress(InputEvent.BUTTON1_MASK);
mouse.mouseRelease(InputEvent.BUTTON1_MASK);

mouse.keyPress(KeyEvent.VK_S);
mouse.keyPress(KeyEvent.VK_M);pause(1);
mouse.keyPress(KeyEvent.VK_ENTER);



mouse.keyPress(KeyEvent.VK_TAB);pause(1);
mouse.keyPress(KeyEvent.VK_ENTER);pause(1);
mouse.keyPress(KeyEvent.VK_TAB);pause(1);
mouse.keyPress(KeyEvent.VK_ENTER);pause(1);


mouse.keyPress(KeyEvent.VK_TAB);pause(1);
mouse.keyPress(KeyEvent.VK_TAB);pause(1);
mouse.keyPress(KeyEvent.VK_TAB);pause(1);
mouse.keyPress(KeyEvent.VK_TAB);pause(1);
mouse.keyPress(KeyEvent.VK_ENTER);pause(1);

end
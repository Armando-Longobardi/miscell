% -------------------------------------------------------------------------
%  ====================
%   Pirelli Cyber Tyre
%  ====================
%
%   Milan, 26/09/2013
%
%   File name: GetNodeCalibration.m
%
%   Function name: GetNodeCalibration
%
%   Description: returns calibration coefficients for a given node
%   
%   Input parameter:
%       nodenumber = unique node identifier
%
%   Output parameters:
%       Kacc(1,:)  calibration coefficients for z axis (radial)
%       Kacc(2,:)  calibration coefficients for y axis (lateral)
%       Kacc(3,:)  calibration coefficients for x axis (tangential)
%
% -------------------------------------------------------------------------

function Kacc = GetNodeCalibration(nodenumber)

    if     nodenumber == 128
        Kacc(1,1)=6.3794; Kacc(1,2)=2.0276; %rad
        Kacc(2,1)=3.7833; Kacc(2,2)=7.6696; %lat
        Kacc(3,1)=3.7303; Kacc(3,2)=5.3907; %tan
        
    elseif nodenumber == 130
        Kacc(1,1)=5.9286; Kacc(1,2)=3.9604;
        Kacc(2,1)=3.5821; Kacc(2,2)=8.5651;
        Kacc(3,1)=3.3134; Kacc(3,2)=7.1474;

    elseif nodenumber == 131          
        Kacc(1,1)=6.2848; Kacc(1,2)=2.7527;
        Kacc(2,1)=3.6423; Kacc(2,2)=10.9388;
        Kacc(3,1)=3.6989; Kacc(3,2)=8.6764; 
        
    elseif nodenumber == 132              
         Kacc(1,1)=5.7505; Kacc(1,2)=3.6143;
         Kacc(2,1)=3.4904; Kacc(2,2)=9.4476;
         Kacc(3,1)=3.5985; Kacc(3,2)=7.4765; 
     
    elseif nodenumber == 133 %cheked against the word calibration file             
         Kacc(1,1)=6.2972; Kacc(1,2)=3.3071;%Z from word file
         Kacc(2,1)=3.6203; Kacc(2,2)=8.5134;%Y from word file  
         Kacc(3,1)=3.4446; Kacc(3,2)=8.5142;%X from word file      
         
    elseif nodenumber == 134       
        Kacc(1,1)=5.7709; Kacc(1,2)=1.5933;
        Kacc(2,1)=3.6043; Kacc(2,2)=4.0446;
        Kacc(3,1)=3.5722; Kacc(3,2)=3.5741; 
        
    elseif nodenumber == 135        
        Kacc(1,1)=5.9872; Kacc(1,2)=2.7889;
        Kacc(2,1)=3.444;  Kacc(2,2)=5.7056;
        Kacc(3,1)=3.3488; Kacc(3,2)=7.1644; 
        
    elseif nodenumber == 136        
        Kacc(1,1)=6.2269; Kacc(1,2)=2.1384;
        Kacc(2,1)=3.5404; Kacc(2,2)=11.3875;
        Kacc(3,1)=3.5018; Kacc(3,2)=6.6315; 
        
    elseif nodenumber == 137       
        Kacc(1,1)=6.7983;  Kacc(1,2)=5.0159;
        Kacc(2,1)=3.6999;  Kacc(2,2)=6.3577;
        Kacc(3,1)=3.5600;  Kacc(3,2)=13.5463; 
        
    elseif nodenumber == 138
        Kacc(1,1)=6.9666; Kacc(1,2)=1.4597;
        Kacc(2,1)=3.8685; Kacc(2,2)=11.9631;
        Kacc(3,1)=3.907;  Kacc(3,2)=7.3163; 
        
    elseif nodenumber == 139
        Kacc(1,1)=6.1453; Kacc(1,2)=2.521;
        Kacc(2,1)=3.4726; Kacc(2,2)=11.7728;
        Kacc(3,1)=3.4525; Kacc(3,2)=7.3736;
        
    elseif nodenumber == 140       
        Kacc(1,1)=5.9872; Kacc(1,2)=2.7889;
        Kacc(2,1)=3.4726; Kacc(2,2)=11.7728;
        Kacc(3,1)=3.3488; Kacc(3,2)=7.3736;
        
    elseif nodenumber == 141       
        Kacc(1,1)=5.9872; Kacc(1,2)=2.7889;%to update
        Kacc(2,1)=3.444;  Kacc(2,2)=5.7056;
        Kacc(3,1)=3.3488; Kacc(3,2)=7.1644;
        
    elseif nodenumber == 142        
        Kacc(1,1)=6.2056; Kacc(1,2)=-2.3829;
        Kacc(2,1)=3.651;  Kacc(2,2)=6.0307;
        Kacc(3,1)=3.6166; Kacc(3,2)=6.9796; 
    
    elseif nodenumber == 143       
        Kacc(1,1)=5.4293; Kacc(1,2)=2.0979;
        Kacc(2,1)=3.3454; Kacc(2,2)=3.9234;
        Kacc(3,1)=3.223;  Kacc(3,2)=17.4456;  
        
    elseif nodenumber == 144                  
        Kacc(1,1)=6.425;  Kacc(1,2)=-0.89787; %cheked against the word calibration file
        Kacc(2,1)=3.7235; Kacc(2,2)=2.2151;
        Kacc(3,1)=3.5977; Kacc(3,2)=2.347;  
        
    elseif nodenumber == 147
        Kacc(1,1)=6.068;  Kacc(1,2)=-0.061853; %cheked against the word calibration file
        Kacc(2,1)=3.5495; Kacc(2,2)=2.002;
        Kacc(3,1)=3.5565; Kacc(3,2)=1.9764; 
       
    elseif nodenumber == 149
        Kacc(1,1)=5.5293; Kacc(1,2)=-0.67242; %cheked against the word calibration file
        Kacc(2,1)=3.367;  Kacc(2,2)=2.4394;
        Kacc(3,1)=3.4854; Kacc(3,2)=0.41369; 
        
    elseif nodenumber == 150
        Kacc(1,1)=6.0667; Kacc(1,2)=-1.6316; %cheked against the word calibration file
        Kacc(2,1)=3.5739;  Kacc(2,2)=0.8762;
        Kacc(3,1)=3.6118; Kacc(3,2)=-0.19026; 
    
    elseif nodenumber == 151
        Kacc(1,1)=5.6941; Kacc(1,2)=-0.11679; %cheked against the word calibration file
        Kacc(2,1)=3.3559; Kacc(2,2)=3.18;
        Kacc(3,1)=3.3269; Kacc(3,2)=2.0168;
        
    elseif nodenumber == 152   
        Kacc(1,1)=5.786;  Kacc(1,2)=2.6034; 
        Kacc(2,1)=3.7456; Kacc(2,2)=5.3642;
        Kacc(3,1)=3.7531; Kacc(3,2)=4.4368;
        
    elseif nodenumber == 154        
        Kacc(1,1)=6.6504; Kacc(1,2)=-1.0177; %cheked against the word calibration file
        Kacc(2,1)=3.8826; Kacc(2,2)=0.26656;
        Kacc(3,1)=3.9221; Kacc(3,2)=-0.87546; 
        
   elseif nodenumber == 155        
        Kacc(1,1)=6.1082; Kacc(1,2)=-1.6065; 
        Kacc(2,1)=3.8021; Kacc(2,2)=0.92111;
        Kacc(3,1)=3.6348; Kacc(3,2)=-0.72227; 

   elseif nodenumber == 156
        Kacc(1,1)=5.6366; Kacc(1,2)=-1.5405;
        Kacc(2,1)=3.459; Kacc(2,2)=3.818;
        Kacc(3,1)=3.252; Kacc(3,2)=3.2622;
        
    elseif nodenumber == 157        
        Kacc(1,1)=5.9333; Kacc(1,2)=-1.7454; %cheked against the word calibration file
        Kacc(2,1)=3.3587; Kacc(2,2)=4.4503;
        Kacc(3,1)=3.3346; Kacc(3,2)=1.5806;
    
    elseif nodenumber == 158        
        Kacc(1,1)=5.6469; Kacc(1,2)=-0.1254; %cheked against the word calibration file
        Kacc(2,1)=3.3141; Kacc(2,2)=3.25;
        Kacc(3,1)=3.3052; Kacc(3,2)=7.1671; 
        
     elseif nodenumber == 159        
        Kacc(1,1)=6.2097; Kacc(1,2)=-0.94043; %cheked against the word calibration file
        Kacc(2,1)=3.7041; Kacc(2,2)=3.3036;
        Kacc(3,1)=3.5142; Kacc(3,2)=4.5459; 
    
    elseif nodenumber == 160        
        Kacc(1,1)=6.1279; Kacc(1,2)=-2.2881; %cheked against the word calibration file
        Kacc(2,1)=3.5386; Kacc(2,2)=5.2939;
        Kacc(3,1)=3.6558; Kacc(3,2)=3.7232;     
        
    elseif nodenumber == 161        
        Kacc(1,1)=6.4005; Kacc(1,2)=-0.78551; %cheked against the word calibration file
        Kacc(2,1)=4.2221; Kacc(2,2)=10.5695;
        Kacc(3,1)=3.5979; Kacc(3,2)=2.1944; 
    
    elseif nodenumber == 162        
        Kacc(1,1)=5.0306; Kacc(1,2)=-1.4694; %cheked against the word calibration file
        Kacc(2,1)=3.1868; Kacc(2,2)=3.7;
        Kacc(3,1)=3.087; Kacc(3,2)=4.618; 

    elseif nodenumber == 163
        Kacc(1,1)=5.3828; Kacc(1,2)=-0.90568; %cheked against the word calibration file
        Kacc(2,1)=3.3119; Kacc(2,2)=4.1337;
        Kacc(3,1)=3.2887; Kacc(3,2)=3.3444;

    elseif nodenumber == 164
        Kacc(1,1)=6.1471; Kacc(1,2)=-1.5562; %cheked against the word calibration file
        Kacc(2,1)=3.4971; Kacc(2,2)=5.1262;
        Kacc(3,1)=3.4377; Kacc(3,2)=2.0655;
        
     elseif nodenumber == 166        
        Kacc(1,1)=6.2644; Kacc(1,2)=-1.0498; %cheked against the word calibration file
        Kacc(2,1)=3.8846; Kacc(2,2)=3.1334;
        Kacc(3,1)=3.7328; Kacc(3,2)=1.1903; 
    
    elseif nodenumber == 167        
        Kacc(1,1)=5.7155; Kacc(1,2)=-1.6528; %cheked against the word calibration file
        Kacc(2,1)=3.2148; Kacc(2,2)=3.3188;
        Kacc(3,1)=3.2919; Kacc(3,2)=5.8199; 
        
    elseif nodenumber == 0    
        Kacc(1,1)=0.0; Kacc(1,2)=0; %rad
        Kacc(2,1)=0.0; Kacc(2,2)=0; %lat
        Kacc(3,1)=0.0; Kacc(3,2)=0; %tan        
        
    else 
        
        disp('---------------------------------------------------')
        disp(['node number:',num2str(nodenumber),'; not found'])
        disp('Using defaulf values');
%         disp(['Please insert the calibration for node:',num2str(nodenumber)])
%         disp('If you continue theoretical calibration will be assigned')
%         pause 
        Kacc(1,1)=6.0; Kacc(1,2)=0; %rad
        Kacc(2,1)=3.0; Kacc(2,2)=0; %lat
        Kacc(3,1)=3.0; Kacc(3,2)=0; %tan
%         Kacc
%         pause
        disp('---------------------------------------------------')
       

    end
    
   
    
end
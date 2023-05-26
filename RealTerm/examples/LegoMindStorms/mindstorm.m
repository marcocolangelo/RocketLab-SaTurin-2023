function [] = mindstorm();

% Robot Controller for LEGO Mindstorm NXT
% G.Gutt 11/27/2005, Ver 1.0
% greg@mymailbox.org

% Uses Bluetooth serial port emulation/port 5, and RealTerm
% control for robust serial communications.   RealTerm controlled via
% ActiveX commands in matlab.  Get RealTerm here:http://realterm.sourceforge.net

% This program assumes that you have RealTerm installed and that you have a
% Bluetooth configured as a virtual serial com port (here I use port 5).

% (You can also use the Matlab native serial communication routines if you wish.
% However I have found to not be as robust as RealTerm.)

% See Mindstorm NXT Bluetooth Development documentation to understand the
% structure of Byte Strings.  Specifically:  Appendix 2-LEGO MINDSTORMS NXT Direct commands.pdf
% http://mindstorms.lego.com/Overview/NXTreme.aspx

% Other useful links and documentation
% Using RealTerm and Matlab: http://realterm.sourceforge.net/realterm_from_matlab.html
% Example of Bluetooth Remote for NXT written in C: http://www.norgesgade14.dk/legoSider/mindstorm_en.html

% Program should play "Ode to Joy" and Move motor 0 back and forth
% Developed Using Matlab 6.5 Release 13

clear;                                 %clear variables
close all;                             %close open figures
fclose('all');                         %close all ports/files
clc;                                   %clear the command window

% Global variable declarations
global ppwrstring;                     % hex string for
default powr - positive
global npwrstring;                     % hex string for
default powr - negative
global hrealterm;                      % activex handle for
realterm RS-232 terminal program

% Open and Configure RealTerm as a Server
disp('GMU Neural Engineering Lab');
disp('Mindstorm NXT Interface Test Program Ver 1.0');
disp('G.Gutt 11/27/2006');
disp(' ');

power = 65;                             % default power
level (65%) for the nxt motors       
ppwrstring=['0x', dec2hex(75)];         % pos pwr, convert
default power level to hex string 0x00 format
npwrstring=['0x', dec2hex(power +128)]; % negative powr string
realtermstart;                          % start realterm
under ActiveX for RS-232 control
song;                                   % Plays Ode to joy
testmotor;                              % reset all the
motors to absolute positioning 

disp('');
disp('Type "return" to finish program and close down
RealTerm');  
keyboard;                               % Keeps RealTerm and
Matlab active for debugging
invoke(hrealterm,'close');              % Close realterm down
delete(hrealterm);                      % Delete realterm handle

% Main Program Ends Here
******************************************************

% Sub Functions start here
%******************************************************************************
function [] = twait(t); 
  % twait(t)
  % simple routine to wait is in units of 100ms.  
  t=t/10; 
  tic
    while(toc<t)
    end;    % end of twait function
%******************************************************************************

%******************************************************************************
function [] = realtermstart();
  % setup real term for active x control of serial port, com5
  global hrealterm;   % activex handle for realterm RS-232
terminal program

  hrealterm=actxserver('realterm.realtermintf'); % start
Realterm as a server
  hrealterm.baud=9600;
  hrealterm.caption='Matlab Realterm Server';
  hrealterm.windowstate=0; %minimized
  hrealterm.Port='5'; %select port 5
  hrealterm.PortOpen=1; %open the comm port
  hrealterm.HalfDuplex=1;
  hrealterm.FlowControl=0;
  hrealterm.LinefeedIsNewline=0;
  hrealterm.DisplayAs=2;
%******************************************************************************

%******************************************************************************
function []= testmotor();
  global ppwrstring;   % motor power string in 0x00 Hex format
  global npwrstring;   % neg power string

  % resets the tachometer of motor to absolute positioning,
motor 0 
  %(5th byte in string sets motor to reset: 0,1,2)

  % sends command to turn motor 0 forward 25 degrees, pause,
then reverse
  sendbytes(['0x0D 0x00 0x80 0x04 0x00 ', ppwrstring, ' 0x07
0x01 0x50 0x10 0x19 0x00 0x00 0x00 0x00']);
  twait(20);  % wait 200msec)
  sendbytes(['0x0D 0x00 0x80 0x04 0x00 ', npwrstring, ' 0x07
0x01 0x50 0x10 0x19 0x00 0x00 0x00 0x00']);
  twait(20);  
  sendbytes(['0x0D 0x00 0x80 0x04 0x00 0x00 0x00 0x00 0x50
0x00 0x00 0x00 0x00 0x00 0x00']); % turn off motor
  
  % Breif byte structure for SetOutputState, NXT command to
move the motor
  % Byte 1, number of bytes in the message, message starts
on 3rd byte
  % Byte 2, 0x00 format byte, never changes
  % Byte 3, Begining of message, 0x80 format byte, never changes
  % Byte 4, 0x04, the actual command, never changes
  % Byte 5, Motor number 0x00, 0x01 or 0x02
  % Byte 6, Power level, -100 to 100 
  % Byte 7, Mode bit field, see Mindstorm Bluetooth documetation
  % Byte 8, Regulation Mode, see Mindstorm Bluetooth
documetation
  % Byte 9, Turn Ratio, -100 to 100
  % Byte 10, Run State, see Mindstorm Bluetooth documetation
  % Byte 11-15, Tacholimit, number of degrees to turn (all
zeros means run forever)
  
  
%******************************************************************************

%******************************************************************************
  function [] = tone(freq,duration);
  % plays a tone.  freq is in units of Hz, duration is in
units of 100ms

  fstring=dec2hex(freq);       % convert to hex
  padzeros=4-length(fstring);  % number of zeros needed to
pad hex output
  for i=1:padzeros
     fstring=['0',fstring];
  end;
  fstring=[' 0x',fstring(3:4),' 0x',fstring(1:2)];  %formats
frequency in 2 byte string 0x00 0x00
                                                    %note
bytes are reversed to form Uword
  tstring=dec2hex(duration*10);   % convert to hex
  padzeros=4-length(tstring);     % number of zeros needed
to pad hex output
  for i=1:padzeros
      tstring=['0',tstring];
  end;
  tstring=[' 0x',tstring(3:4),' 0x',tstring(1:2)];  %formats
tune in 2 byte string 0x00 0x00
                                                    %note
bytes are reversed to form Uword
  sendbytes(['0x06 0x00 0x80 0x03',fstring, tstring]);
  
  % Breif byte structure for PlayTone, NXT command to play a
tone
  % Byte 1, number of bytes in the message, message starts
on 3rd byte
  % Byte 2, 0x00 format byte, never changes
  % Byte 3, Begining of message, 0x80 format byte, never changes
  % Byte 4, 0x03, the actual command, never changes
  % Byte 5-6, Frequency of the tone in Hz, Uword
  % Byte 7-8, Duration of the tone in ms, Uword  
%******************************************************************************

%******************************************************************************
                                            
function [] = sendbytes(sendstring);
  % Converts String of HEX Numbers in 0x00 form to
Characters and sends
  % them out via Realterm

  global hrealterm;   % activex handle for realterm RS-232
terminal program

  byteparse=findstr(sendstring,'0x');  %finds the hex
notation start characters for the string
  outstring='';
  for i=1:length(byteparse);
      bytestring=sendstring(byteparse(i)+2:byteparse(i)+3);
      outchar=char(hex2dec(bytestring));
      outstring=[outstring, outchar];
      invoke(hrealterm,'PutChar',outchar); % send the
characters byte by byte
  end;
  disp(['Bytes Sent: ', sendstring]);
%******************************************************************************

%******************************************************************************
function [] = song();
  % format (freq - Hz, Duration units of 100 ms)
  % delay in units of 100ms
  % Song: "Ode to Joy"

  tone(440,4); twait(4);    
  tone(440,4); twait(4);
  tone(494,4); twait(4);
  tone(523,4); twait(4);
  tone(523,4); twait(4);
  tone(494,4); twait(4);
  tone(440,4); twait(4);
  tone(392,4); twait(4);
  tone(349,4); twait(4);
  tone(349,4); twait(4);
  tone(392,4); twait(4);
  tone(440,4); twait(4);
  tone(440,6); twait(6);
  tone(392,3); twait(3);
  tone(392,3); twait(6);
  tone(440,4); twait(4);
  tone(440,4); twait(4);
  tone(494,4); twait(4);
  tone(523,4); twait(4);
  tone(523,4); twait(4);
  tone(494,4); twait(4);
  tone(440,4); twait(4);
  tone(392,4); twait(4);
  tone(349,4); twait(4);
  tone(349,4); twait(4);
  tone(392,4); twait(4);
  tone(440,4); twait(4);
  tone(392,6); twait(6);
  tone(349,3); twait(3);
  tone(349,3);     
%******************************************************************************



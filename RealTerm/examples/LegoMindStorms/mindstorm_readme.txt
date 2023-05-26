Below are two files describing how to control Lego Mindstorm
NXT with Matlab and RealTerm.  RealTerm was a great tool. 
Therefore I am sending this to return the favor, hope you
could post it in an apporopriate place!  I think some users
would find this helpful.  Regards.  Greg. (greg@mymailbox.org)

****** Readme file ************

Using Matlab, RealTerm and Bluetooth to control Lego
Mindstorm NXT

Developed by Gregory Gutt,  greg@mymailbox.org
For the George Mason University Neural Engineering Laboratory

Background:  My wife (Nathalia Peixoto) is a professor at
George Mason University in the ECE Department.  She wants to
control a Lego Mindstorm NXT Robot using increasingly
sophisticated biosensors and voice recognition.  Matlab was
the ideal platform to create the tools and interfaces
because of its relatively easy development environment and
sophisticated digital signal processing tools.  I developed
this code for her Laboratory.

Important references:

1)See Mindstorm NXT Bluetooth Development documentation to
understand the
structure of Byte Strings.  Appendix 2-LEGO MINDSTORMS NXT
Direct commands.pdf. 
http://mindstorms.lego.com/Overview/NXTreme.aspx

2) RealTerm and Matlab:
http://realterm.sourceforge.net/realterm_from_matlab.html

3) Example of Bluetooth Remote for NXT written in C:
www.norgesgade14.dk/legoSider/mindstorm_en.html


Start Up Procedure:

I. Make sure your Bluetooth hardware and software support
Virtual Serial Port Mapping.  Basically this allows standard
serial port software to send commands through Bluetooth.  I
had some problems using the default Windows XP drivers with
a Zoom USB Bluetooth interface.  However, when I installed
the software that came with the device all went well.  For
illustration purposes I will assume the following
configuration:  Com Port 5, 9600 Baud, 8 bits, 1 stop pit,
No Parity, No Flow Control. 

II. The first step is to download and install RealTerm
(http://realterm.sourceforge.net/).  RealTerm is an
outstanding terminal program and offered free of charge (see
the site for license terms).  This tool allows for ROBUST
RS-232 communications within Matlab.  It also provides a
good way to observe communication traffic, which is critical
when developing and debugging new code.  In principle you
can also use the embedded Matlab RS-232 communications. 
However, some versions of Matlab have known serial port issues.

III. Test the interface.  Turn on the Mindstorm and
establish a Bluetooth connection with your PC.  Assuming
this is done correctly you should now have Com Port 5 (or
another port) ready for communication.  Run RealTerm and set
the following configuration.

Display Tab:  Click these options -  Hex[space], Half Duplex
Port Tab:  Baud-9600, Port 5 (or per your configuration),
Click Open, (Other defaults: Parity-None, 8 bits, Stop Bits
- 1, Hardware Flow Control - None, etc.).

Go to the send tab and copy and paste the following byte
stream into one of the "Send Numbers" fields:  0x06 0x00
0x80 0x03 0xB8 0x01 0x28 0x00
Hit the "Send Numbers" button to the right of the copied
text.  If all goes well you should here a brief "beep".  If
you  here the "beep", great! You are half way there.  If
not, debug to this point before proceeding.


IV. Try the Matlab program.  Close down real term.  Open
matlab and run the m-file: mindstorm.m  The file is
documented with useful comments.  If all goes well you
should hear "Ode to Joy" and see motor 0 move back and
forth.  I developed this m-file in Matlab 6.5 Release 13.

Enjoy!

Greg

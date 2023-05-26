// RealtermDemo: Simple test and demo of Realterm
//amended to work under windows XP using "START"
// http://realterm.sourceforge.net
// see also:

// 8:19PM 07/11/2003 SJB $Revision: 1.2 $ $Date: 2006-08-10 15:15:02+13 $

unix('start realterm')  //Start Realterm and return without waiting...
//might need a pause to let it start
sleep(1000)
//Don't forget to start with FIRST. This is what send commands to the existing instance instead of starting a new instance of Scilab
unix('start /wait realterm first capture=c:\temp\capsci.txt') //set capture file. Starts Capturing

//Sendfile can be used to send both ascii and binary data
unix('start /wait realterm first sendfile=startlogging.txt'); //sends initialsation commands to data logger

unix('start /wait realterm first sendfile=read_voltage.txt'); //send commands to read a voltage

//Now open capsci.txt and read the data...

//send str can be used for short ascii commands. Note strings need to be quoted " "
unix('start /wait realterm first sendstr=VOLTAGE? CR LF sendstr=AMPS? CR LF');

//read the results

//the following line sends commands every 1 second, for ever
unix('start /wait realterm first capture=c:\temp\capsci.txt senddly=1000 sendrep=0 sendfile=read_voltage.txt');  

unix('start /wait realterm first quit') //close Realterm down

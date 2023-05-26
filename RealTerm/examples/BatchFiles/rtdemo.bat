echo off
rem Batch file for Windows XP. 
rem Windows XP has to use START to launch programs without waiting for them to close, unlike earlier versions.
rem Windows 98 won't use the START command
rem sleep is a unixutils utility, or download our simple version
rem 
echo on
set rt=realterm
start %rt% caption=BatchDemo half=1 
rem allow time for Realterm to start before trying to send messages to it

sleep 1000
start /wait %rt% first sendstr=S4256677890P
sleep 100

start /wait %rt% first sendstr=S4050607080P
sleep 100

pause Press any key to close Realterm 

start /wait %rt% first quit

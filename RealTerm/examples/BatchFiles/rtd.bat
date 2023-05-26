rem Batch file for Windows XP. Windows XP has to use START to launch programs, waits for programs to quit, unlike earlier
echo on
set rt=..\realterm
start %rt% caption=Bongo half=1 
rem allow time for Realterm to start
sleep 1000
start /wait %rt% first sendstr=S4256677890P
rem sleep 200
rem %rt% first newline

start /wait %rt% first sendstr=S4050607080P
rem sleep 200

pause Press any key to close Realterm 

start /wait %rt% first quit

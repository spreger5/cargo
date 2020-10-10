@ECHO off
 REM ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
 REM Home-Laufwerk von Rpri275 als H: zuordnen.
 REM
 REM ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 REM Parameter: keine
 REM ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 REM Erstellt von: Gerhard Sprenger
 REM           am: 18.09.2014
 REM ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 REM ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

 ECHO Ordne Home-Laufwerk von Rpri275 als H: zu
 ECHO ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
 ECHO.
 ECHO ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 ECHO VPN muss hier aktiv sein! (Wenn zu Hause)
 ECHO.
 ECHO    --- oder ---
 ECHO.
 ECHO Gltige LAN-Verbindung zum ARZ-10er-Netz muss bestehen (wenn in Fa.)
 ECHO ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 ECHO.
 ECHO Weiter mit ENTER oder mit ^^C abbrechen...
 PAUSE >NUL

 rem SET befehl=NET USE H: \\a8600681\!homelw\rpri275 * /USER:rpri275@m086.local /PERSISTENT:NO --- 12.05.2016
 rem SET befehl=NET USE H: \\a8600689\!homelw\rpri275 * /USER:rpri275@m086.local /PERSISTENT:NO --- 23.02.2018
 ren SET befehl=NET USE H: \\a8600681.m086.local\!homelw\rpri275 * /USER:rpri275@m086.local /PERSISTENT:NO --- 01.12.2019
     SET befehl=NET USE H: \\a8600689.m086.local\!homelw\rpri275 * /USER:rpri275@m086.local /PERSISTENT:NO

 echo %befehl%
 %befehl%

 ECHO Aktuelle Laufwerkzuordnungen lauten jetzt:
 NET USE
 PAUSE

 GOTO Ende

:Ende

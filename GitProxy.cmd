@ECHO off
 REM ============================================================================================
 REM Umgebungsvariable setzen, damit Git und andere Tools in dieser Session den ARZ-Proxy verwenden.
 REM
 REM Dies erfolgt ueber den Aufruf der Prozedur 'ArzProxy.cmd'.
 REM Dies ist sozusagen ein 'Alias' zum eig. Setzen der Umgebungsvariablen 'ArzProxy.cmd' in BatNT.
 REM
 REM --------------------------------------------------------------------------------------------
 REM
 REM  D-Lib: C:/BatNT
 REM
 REM  T-Lib: C:/BatNT
 REM
 REM --------------------------------------------------------------------------------------------
 REM Parameter: keine
 REM --------------------------------------------------------------------------------------------
 REM Erstellt von: Gerhard Sprenger
 REM           am: 10.10.2020
 REM ============================================================================================

 REM ECHO Parameter %%*: ^>%*^<.
 REM PAUSE

 REM Aktuelle CMD wird *ersetzt*, also Aufruf in Form von XCTL, nicht Link/Call!

 %SystemDrive%\BatNT\ArzProxy.cmd


@ECHO off
 REM ============================================================================================
 REM Umgebungsvariable setzen, damit die gaengigen Tools (Git z.B.) den ARZ-Proxy verwenden.
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

 ECHO.
 ECHO Setze die Umgebungsvariablen 'http_proxy' und 'https_proxy' auf den ARZ-Proxy (IGW)
 ECHO.

 SET http_proxy=http://10.1.149.10:3128
 SET https_proxy=http://10.1.149.10:3128

 SET HTTP
 ECHO.


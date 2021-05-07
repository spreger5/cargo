@ECHO off
 REM ============================================================================================
 REM Datei mit DOS-Zeilenschaltungen in eine mit Unix-Zeilenschaltungen umwandeln.
 REM
 REM
 REM Achtung: DosUnix.exe weist einige Schwaechen auf. So bleibt der Errorlevel auf 0,
 REM          auch wenn es nicht auf StdOut schreiben kann (w/ Readonly-Attribut z.B.).
 REM          Deshalb wird Dos2Unix.exe nur aufgerufen, wenn die temporaere Zwischendatei
 REM          noch nicht existiert.
 REM
 REM          Auch der CMD-interne DEL-Befehl setzt den Errorlevel nicht immer sauber (z.B.
 REM          wenn er eine Datei w/ Readonly-Attribut nicht loeschen kann [das Loeschen koennte
 REM          mit der Option /F erzwungen werden. Ist hier aber nicht sinnvoll]).
 REM
 REM     Solche Schwaechen koennen z.B. mit gezielten IF [NOT] EXIST-Abfragen umgangen werden.
 REM
 REM --------------------------------------------------------------------------------------------
 REM
 REM  D-Lib: C:/UtilNT/SFU/apps/util/Spg_MCJobs
 REM
 REM  T-Lib: C:/BatNT
 REM --------------------------------------------------------------------------------------------
 REM Parameter: 1. [muss] ... Name der zu konvertierenden Datei. Der komplette Parameterstring
 REM                          wird als *ein* Dateiname aufgefasst.
 REM --------------------------------------------------------------------------------------------
 REM Erstellt von: Gerhard Sprenger
 REM           am: 24.10.2014
 REM --------------------------------------------------------------------------------------------
 REM Aenderungen:  01.  21.03.2015 - Sprenger
 REM                       - Alle externen Programme voll qualifizieren.
 REM
 REM               02.  06.02.2017 - Sprenger
 REM                       - Pruefen, ob die zu konvertierende Datei kein Verzeichnis ist.
 REM                         Verzeichnisse (inkl. '..') werden ignoriert!
 REM
 REM               03.  07.05.2021 - Sprenger
 REM                       - Wenn Dateien auf LAN-Laufwerken konvertiert werden, nimmt das
 REM                         Programm 'dos2unix.exe' recht viel Zeit in Anspruch. Div. Versuche
 REM                         legen den Schluss nahe, dass das Oeffnen der Zieldatei recht lange
 REM                         dauert. Deshalb erfolgt das Speichern der konvertierten Datei ueber
 REM                         eine Pipe und 'tee.exe' uebernimmt das eigentliche Speichern.
 REM                       - Codepunkte ueber 127 ersetzen.
 REM ============================================================================================

 SET Spg.MaxCC=1

 REM ECHO Parameter %%*: ^>%*^<.
 REM PAUSE

 REM IF !%1==!/? GOTO Syntax  --- bringt Syntaxfehler, wenn Prozedur mit '/?' aufgerufen wird!!!
     IF [%1]==[/?] GOTO Syntax
     IF !%1==!-? GOTO Syntax
     IF !%1==!? GOTO Syntax

 SET Spg.Parm=%*
 IF NOT DEFINED Spg.Parm GOTO Syntax

 REM --- Parameter gequotet und nicht gequotet aufbereiten --------------------------------------- Anfang ---

 SET Spg.First1=
 SET Spg.Last1=
 SET Spg.First1=%Spg.Parm:~0,1%
 SET Spg.Last1=%Spg.Parm:~-1%

 REM ECHO Spg.Parm original ________________ex Input: %Spg.Parm%.
 REM ECHO Erster  Char des Parms ___________________: %Spg.First1%.
 REM ECHO Letzter Char des Parms ___________________: %Spg.Last1%.
 REM ECHO.

 SET Spg.ParmQuot=
 SET Spg.ParmNoQuot=

 IF  NOT !^%Spg.First1%==!^" (
     REM Das erste Zeichen ist kein Gaensefueszchen. Hoffentlich das letzte auch!
     SET Spg.ParmQuot="%Spg.Parm%"
     SET Spg.ParmNoQuot=%Spg.Parm%
 )  ELSE (
     REM Das erste Zeichen ist ein Gaensefueszchen. Das letzte Zeichen auch? Wenn ja, *beide* entfernen
     IF NOT !^%Spg.Last1%==!^" (
        SET Spg.ParmQuot=%Spg.Parm%
        SET Spg.ParmNoQuot=%Spg.Parm%
    ) ELSE (
        REM Das erste und das letzte Zeichen sind ein Gaensefueszchen
        SET Spg.ParmQuot=%Spg.Parm%
        SET Spg.ParmNoQuot=%Spg.Parm:~1,-1%
    )
 )

 REM ECHO Spg.Parm gequotet _______________ ex Input: %Spg.ParmQuot%.
 REM ECHO Spg.Parm nicht gequotet _________ ex Input: %Spg.ParmNoQuot%.
 REM ECHO.

 REM --- Parameter gequotet und nicht gequotet aufbereiten --------------------------------------- Ende -----

 IF NOT EXIST %Spg.ParmQuot% GOTO FileNotFound
 IF EXIST "%Spg.ParmNoQuot%\*" GOTO Is_Dir

 %SystemDrive%\UtilNT\Ctext.exe "{bwhite on black}Konvertiere die DOS-Zeilenschaltungen in Unix-konforme f. {bgreen on black}'%Spg.ParmNoQuot%'{white on black}{\n}"

 SET Spg.TmpFileQuot="%Spg.ParmNoQuot%___"
 REM ECHO Temporaeres File _________________________: %Spg.TmpFileQuot%.

 IF EXIST %Spg.TmpFileQuot% GOTO TmpfileFound

 REM %SystemDrive%\UtilNT\dos2unix.exe %Spg.ParmQuot%>%Spg.TmpFileQuot% --- 07.05.2021
 REM Ueber einen Input-Redirect und eine Pipe verhindern, dass 'dos2unix.exe' eine physische Datei zum Schreiben oeffnen muss.

 %SystemDrive%\UtilNT\dos2unix.exe <%Spg.ParmQuot%|%SystemDrive%\UtilNT\tee.exe %Spg.TmpFileQuot% 1>NUL
 SET Spg.D2U_EL=%ERRORLEVEL%
 IF %Spg.D2U_EL% NEQ 0 GOTO Dos2Unix_Fehler
 IF NOT EXIST %Spg.TmpFileQuot% GOTO Dos2Unix_Fehler

 %SystemDrive%\UtilNT\touch.exe -r %Spg.ParmQuot% %Spg.TmpFileQuot%
 SET Spg.TCH_EL=%ERRORLEVEL%
 IF %Spg.TCH_EL% NEQ 0 GOTO Touch_Fehler

 copy %Spg.TmpFileQuot% %Spg.ParmQuot% 1>NUL
 SET Spg.CPY_EL=%ERRORLEVEL%
 IF %Spg.CPY_EL% NEQ 0 GOTO ReCopy_Fehler

 DEL %Spg.TmpFileQuot%
 IF EXIST %Spg.TmpFileQuot% GOTO Delete_Fehler

 SET Spg.MaxCC=0
 %SystemDrive%\UtilNT\Ctext.exe "{bwhite on black}Konvertierung o.k.{white on black}{\n}"
 GOTO Ende

 REM -------------------------------------------------------------------------

:Delete_Fehler
 ECHO 
 ECHO Fehler!!! Temporaere Zwischendatei %Spg.TmpFileQuot% konnte nach erfolgter Konvertierung der Masterdatei nicht geloescht werden!
 ECHO.
 GOTO Ende

:ReCopy_Fehler
 ECHO 
 ECHO Abbruch!!! Rueckkopieren von temp. Zwischendatei %Spg.TmpFileQuot% auf Masterdatei %Spg.ParmQuot% war fehlerhaft. Copy-RC=%Spg.CPY_EL%!
 ECHO.
 GOTO Ende

:Touch_Fehler
 ECHO 
 ECHO Abbruch!!! Setzen des Timestamps der temporaeren Zwischendatei %Spg.TmpFileQuot% war fehlerhaft. Touch-RC=%Spg.TCH_EL%!
 ECHO.
 GOTO Ende

:Dos2Unix_Fehler
 ECHO 
 ECHO Abbruch!!! Programm 'Dos2Unix.exe' konnte %Spg.ParmQuot% nicht in eine temporaere Zwischendatei %Spg.TmpFileQuot% umwandeln!
 ECHO.
 GOTO Ende

:TmpfileFound
 ECHO 
 ECHO Abbruch!!! Die temporaere Zwischendatei %Spg.TmpFileQuot% existiert bereits!!!
 ECHO.
 GOTO Ende

:FileNotFound
 ECHO 
 ECHO Die Datei %Spg.ParmQuot% wurde nicht gefunden, die
 ECHO Konvertierung der Zeilenenden wurde nicht durchgefuehrt!!!
 ECHO.
 GOTO Ende

:Is_Dir
 ECHO 
 ECHO Die Datei %Spg.ParmQuot% ist ein Verzeichnis, die
 ECHO Konvertierung der Zeilenenden wurde nicht durchgefuehrt!!!
 ECHO.
 GOTO Ende

:Syntax
 ECHO.
 ECHO Dos2Unix_Konv
 ECHO.
 ECHO Funktion: Datei mit DOS-Zeilenschaltungen in eine mit Unix-Zeilenschaltungen umwandeln.
 ECHO.
 ECHO Syntax: Dos2Unix_Konv ^<Name zu konvertierender Datei^>
 ECHO.
 GOTO Ende

:Ende
 EXIT /B %Spg.MaxCC%

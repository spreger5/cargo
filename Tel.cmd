@ECHO off
 REM ============================================================================================
 REM ARZ-Telefonnummer in ASCII-File suchen.
 REM
 REM    Mittels dem ack-Tool Namen in privatem Telefonfile (ASCII mit ANSI-Umlauten)
 REM    suchen und die entspr. Zeile(n) ausgeben mit der Telefonnummer ausgeben.
 REM
 REM    Der zu suchende Name muss als Parameter uebergeben worden sein.
 REM    !!! Keine Windows-Quotes (") verwenden. Alle Parameter werden als *ein*
 REM    !!! Suchstring aufgefasst und deshalb vor dem ack-Aufruf gequotet.
 REM
 REM    Auch Windows 7 arbeitet wie XP im Befehlsfenster mit der Codepage 850.
 REM    Die von SprG unter Windows 7 installierten Perls scheinen die ASCII-Umlaute
 REM    aber in ANSI-Umlaute zu konvertieren.
 REM
 REM    Deshalb sollten dieser CMD ex Befehlszeile ASCII-Umlaute uebergeben werden,
 REM    das ack-Tool (Perl) konvertiert diese in ANSI. Da das Telefonnummernfile die
 REM    Umlaute in ANSI enthaelt, werden sie von ack korrekt gefunden.
 REM
 REM --------------------------------------------------------------------------------------------
 REM
 REM  D-Lib: C:/BatNT
 REM
 REM  T-Lib: C:/BatNT
 REM
 REM --------------------------------------------------------------------------------------------
 REM Parameter: 1. [muss] ... zu suchender Name als Perl-RegEx
 REM --------------------------------------------------------------------------------------------
 REM Erstellt von: Gerhard Sprenger
 REM           am: 26.06.2013
 REM --------------------------------------------------------------------------------------------
 REM Aenderungen:  01.  12.12.2020 - Sprenger
 REM                     - Das Telefonfile wird zuerst auf dem H-Laufwerk gesucht.
 REM                     - Refactoring
 REM ============================================================================================

 REM ECHO Parameter %%*: ^>%*^<.
 REM PAUSE

 SET Spg.Telfile=?

 FOR %%E IN (C:/$ebka/Doku H:/Rpri275/eBKa/Doku) DO (
    IF EXIST %%E/Telefon.txt SET Spg.Telfile=%%E/Telefon.txt
 )

 IF !%Spg.Telfile%==!? GOTO TelfileNotFound

 REM IF !%1==!/? GOTO Syntax  --- bringt Syntaxfehler, wenn Prozedur mit '/?' aufgerufen wird!!!
     IF [%1]==[/?] GOTO Syntax
     IF !%1==!-? GOTO Syntax
     IF !%1==!? GOTO Syntax
     IF !%1==! GOTO Syntax

 SET Spg.SearchPattern=%*
 IF NOT DEFINED Spg.SearchPattern GOTO Syntax

 ECHO.
 ECHO Suche in Datei '%Spg.Telfile%'
 ECHO.

 CALL %SystemDrive%\BatNT\ack.cmd -i --nocolor "%Spg.SearchPattern%" "%Spg.Telfile%"

 GOTO Ende

 REM --------------------------------------------------------------------------------------------
:TelfileNotFound

 ECHO.
 ECHO Fehler: Die Text-Datei mit den Namen und Telefonnummern namens
 ECHO.
 ECHO            '%Spg.Telfile%'
 ECHO.
 ECHO         wurde nicht gefunden. Prozedur wird abgebrochen!
 ECHO.
 GOTO Ende

 REM --------------------------------------------------------------------------------------------
:Syntax

 ECHO.
 ECHO Syntax: Tel ^<Name als Perl-RegEx^>
 ECHO.
 ECHO Sucht den uebergebenen Namen mittels ack-Tool in der ASCII-Datei '%Spg.Telfile%'
 ECHO.
 ECHO Hinweise:
 ECHO.
 ECHO    * Der Name wird ohne Beachtung von Grosz-/Kleinschreibung gesucht.
 ECHO.
 ECHO    * Er darf *nicht* gequotet werden!
 ECHO.
 ECHO    * Auch Umlaute sind erlaubt, sollten aber als als '.' spezifiziert werden.
 ECHO.
 ECHO.
 GOTO Ende

 REM --------------------------------------------------------------------------------------------
:Ende


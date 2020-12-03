@ECHO off
 REM ============================================================================================
 REM ePub-Dokument mit Sumatra PDF [Portable] lesen.
 REM
 REM --------------------------------------------------------------------------------------------
 REM
 REM  D-Lib: C:/BatNT
 REM
 REM  T-Lib: C:/BatNT
 REM
 REM --------------------------------------------------------------------------------------------
 REM Parameter: 1. [muss] ... Name des zu lesenden ePub-Dokumentes.
 REM
 REM                          Wenn dieser Blanks enthaelt, muss der Parameter bereits
 REM                          gequotet uebergeben werden (dies macht z.B. der FC/W so).
 REM --------------------------------------------------------------------------------------------
 REM Erstellt von: Gerhard Sprenger
 REM           am: 04.10.2013
 REM --------------------------------------------------------------------------------------------
 REM Aenderungen:  01.  03.12.2020 - Sprenger
 REM                       Weiteres Tool 'Icecream Ebook Reader' aufnehmen
 REM ============================================================================================

 REM ECHO Parameter: ^>%*^<.

 REM IF !%1==!/? GOTO Syntax  --- bringt Syntaxfehler, wenn Prozedur mit '/?' aufgerufen wird!!!
     IF [%1]==[/?] GOTO Syntax
     IF !%1==!-? GOTO Syntax
     IF !%1==!? GOTO Syntax
     IF !%1==! GOTO Syntax

 SET Spg.ePubDsn=%*

 IF NOT DEFINED Spg.ePubDsn GOTO Usage
 IF NOT EXIST %Spg.ePubDsn% GOTO ePubDocNotFound

 SET Spg.ePubReaderExeDsn=?

 FOR %%E IN (SumatraPDFPortable\SumatraPDFPortable IcecreamEpubReader\ebookreader) DO (
    FOR %%L IN (D C) DO (
       IF EXIST %%L:\UtilNT\%%E.exe SET Spg.ePubReaderExeDsn=%%L:\UtilNT\%%E.exe
    )
 )

 IF !%Spg.ePubReaderExeDsn%==!? GOTO ePubReaderExeNotFound

 ECHO Starte den ePub-Reader '%Spg.ePubReaderExeDsn%' mit Option '%Spg.ePubDsn%'
 START "ePub-Reader" %Spg.ePubReaderExeDsn% %Spg.ePubDsn%
 GOTO Ende

 REM --------------------------------------------------------------------------------------------
:ePubDocNotFound
 ECHO.
 ECHO Fehler: Das ePub-Dokument '%Spg.ePubDsn%' wurde nicht gefunden!
 ECHO         Prozedur wird abgebrochen!
 ECHO.
 GOTO Ende

 REM --------------------------------------------------------------------------------------------
:ePubReaderExeNotFound
 ECHO.
 ECHO Fehler: Kann den Pfad des ePub-Readers nicht ermitteln!
 ECHO         Prozedur wird abgebrochen!
 ECHO.
 GOTO Ende

 REM --------------------------------------------------------------------------------------------
:Usage
 ECHO.
 ECHO Syntax: Start_ePub ^<Name des Dokuments^>
 ECHO.
 ECHO Startet einen ePub-Reader (z.B. Sumatra PDF oder Icecream) als separaten Prozess.
 ECHO Der Name des ePub-Dokuments, das gelesen werden soll,
 ECHO muss als Parameter (ggf. gequotet) uebergeben werden.
 ECHO.
 ECHO Achtung: ePub-Reader wurde NICHT gestartet!!!
 ECHO.
 GOTO Ende

 REM --------------------------------------------------------------------------------------------
:Ende

@ECHO off
 REM =============================================================================================
 REM Dive.
 REM
 REM A tool for exploring a docker image, layer contents, and discovering ways to shrink the size
 REM of your Docker/OCI image.
 REM ---------------------------------------------------------------------------------------------
 REM
 REM  D-Lib: C:/BatNT
 REM
 REM  T-Lib: C:/BatNT
 REM
 REM ---------------------------------------------------------------------------------------------
 REM Parameter: beliebige ... werden 1:1 an das Dive-Programm 'dive.exe' weitergereicht.
 REM ---------------------------------------------------------------------------------------------
 REM Erstellt von: Gerhard Sprenger
 REM           am: 29.06.2021
 REM =============================================================================================

 REM ECHO Parameter %%*: ^>%*^<.
 REM PAUSE

 SET Spg.Dive_Exe=?

 FOR %%L IN (D C) DO (
    IF EXIST %%L:\UtilNT\Kubernetes\dive.exe (
       SET Spg.Dive_Exe=%%L:\UtilNT\Kubernetes\dive.exe
    )
 )

 REM ECHO Spg.Dive_Exe.... ^>%Spg.Dive_Exe%^<.
 REM PAUSE

 IF !%Spg.Dive_Exe%==!? GOTO DiveNotFound

 %Spg.Dive_Exe% %*

 GOTO Ende

 REM ---------------------------------------------------------------------------------
:DiveNotFound

 ECHO.
 ECHO Fehler: Kann den Pfad fuer das Dive-Programm 'dive.exe' nicht ermitteln!
 ECHO         Prozedur wird abgebrochen!
 ECHO.
 GOTO Ende

 REM ---------------------------------------------------------------------------------
:Ende


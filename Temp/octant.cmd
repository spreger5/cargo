@ECHO off
 REM =============================================================================================
 REM Octant. Kubernetes-Workloads visualisieren.
 REM ---------------------------------------------------------------------------------------------
 REM
 REM  D-Lib: C:/BatNT
 REM
 REM  T-Lib: C:/BatNT
 REM
 REM ---------------------------------------------------------------------------------------------
 REM Parameter: beliebige ... werden 1:1 an das Octant-Programm 'octant.exe' weitergereicht.
 REM ---------------------------------------------------------------------------------------------
 REM Erstellt von: Gerhard Sprenger
 REM           am: 29.06.2021
 REM =============================================================================================

 REM ECHO Parameter %%*: ^>%*^<.
 REM PAUSE

 SET Spg.Octant_Exe=?

 FOR %%L IN (D C) DO (
    IF EXIST %%L:\UtilNT\Kubernetes\octant.exe (
       SET Spg.Octant_Exe=%%L:\UtilNT\Kubernetes\octant.exe
    )
 )

 REM ECHO Spg.Octant_Exe.... ^>%Spg.Octant_Exe%^<.
 REM PAUSE

 IF !%Spg.Octant_Exe%==!? GOTO OctantNotFound

 %Spg.Octant_Exe% %*

 GOTO Ende

 REM ---------------------------------------------------------------------------------
:OctantNotFound

 ECHO.
 ECHO Fehler: Kann den Pfad fuer das Octant-Programm 'octant.exe' nicht ermitteln!
 ECHO         Prozedur wird abgebrochen!
 ECHO.
 GOTO Ende

 REM ---------------------------------------------------------------------------------
:Ende


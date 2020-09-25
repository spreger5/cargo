@ECHO off
 REM ============================================================================================
 REM Auf Computer mit HyperV-Unterstuetzung booten.
 REM
 REM Achtung: Diese Prozedur muss als Administrator ausgefuehrt werden! Deshalb sollte
 REM          ein Icon auf dem Desktop erstellt werden.
 REM
 REM Booteintrag erstellen: Als Administrator ausfuehren. Am Beispiel "mit aktiviertem HyperV" auf HP15
 REM ----------------------
 REM
 REM 1. Aktuellen Booteintrag unter einem neuen Namen kopieren, das Ergebnis ist die GUID des
 REM    neuen Booteintrags (noch inhaltlich eine Kopie des aktuellen)
 REM
 REM    bcdedit /copy {current} /d "Hyper-V aktiv"
 REM
 REM    ---> Der Eintrag wurde erfolgreich in {xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx} kopiert.
 REM
 REM 2. Beim neuen Booteintrag die Option Hyper-V aktivieren ('hypervisorlaunchtype auto')
 REM
 REM    bcdedit /set {xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx} hypervisorlaunchtype auto
 REM
 REM    Hinweis: Das Gegenteil von 'hypervisorlaunchtype auto' ist 'hypervisorlaunchtype off'
 REM
 REM 3. Beim Booten die Shift-Taste druecken und den entsprechenden Booteintrag auswaehlen
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
 REM           am: 26.12.2019
 REM --------------------------------------------------------------------------------------------
 REM Aenderungen:  01.  04.04.2020 - Sprenger
 REM                       Unterscheidung nach Computer. Jede Maschine hat separate Ids fuer
 REM                       die Boot-Sequenzen.
 REM                       Dadurch heiszt diese Prozedur nur noch 'Booten_mit_HyperV.cmd', d.h.
 REM                       der Computername ist nicht mehr Namens-Bestandsteil.
 REM
 REM               02.  08.08.2020 - Sprenger
 REM                       Neue Boot-ID. Durch das Update auf Windows 10 v20-04 hat die bisherige
 REM                       ID nicht mehr funktioniert.
 REM                       Sowohl fuer HP15 und SURFACEPRO3.
 REM
 REM               03.  25.09.2020 - Sprenger
 REM                       Neue Boot-ID fuer Surface Pro 3.
 REM ============================================================================================

 REM ECHO Parameter %%*: ^>%*^<.
 REM PAUSE

 ECHO.
 ECHO.
 ECHO Setze die Bootreihenfolge auf 'Start *mit* HyperV-Unterstuetzung'...

 SET Spg.BootSeqId=?

 REM IF /I "%COMPUTERNAME%" == "HP15"         SET Spg.BootSeqId={ae34f796-f9b9-11e9-b8e9-ab9b871cb2e2} --- 08.08.2020
     IF /I "%COMPUTERNAME%" == "HP15"         SET Spg.BootSeqId={ae34f79d-f9b9-11e9-b8e9-ab9b871cb2e2}

 REM IF /I "%COMPUTERNAME%" == "SURFACEPRO3"  SET Spg.BootSeqId={3ccfd8b7-e6eb-11e9-8408-9d2b43e60f90} --- 08.08.2020
 REM IF /I "%COMPUTERNAME%" == "SURFACEPRO3"  SET Spg.BootSeqId={3ccfd8bd-e6eb-11e9-8408-9d2b43e60f90} --- 25.09.2020
     IF /I "%COMPUTERNAME%" == "SURFACEPRO3"  SET Spg.BootSeqId={3ccfd8c0-e6eb-11e9-8408-9d2b43e60f90}

 IF !%Spg.BootSeqId%==!? GOTO Fehler1

 bcdedit.exe /bootsequence %Spg.BootSeqId%

 ECHO.
 ECHO Fuehre nun einen OS-Restart durch, weiter mit ENTER...
 PAUSE >NUL
 %SystemRoot%\system32\shutdown.exe /r /f /t 0

 GOTO Ende

 REM --------------------------------------------------------------------------------------------
:Fehler1

 ECHO.
 ECHO Fehler: F. den Computer %COMPUTERNAME% ist kein Booten *mit* HyperV-Unterstuetzung eingerichtet!
 ECHO         Prozedur wird abgebrochen!
 ECHO.
 GOTO Ende

 REM ---------------------------------------------------------------------------------
:Ende


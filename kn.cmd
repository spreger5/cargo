@ECHO off
 REM ============================================================================================
 REM Befehlszeilentool 'knife.bat' ohne Pfad aufrufen.
 REM
 REM Dies ist ein 'Alias' zum eig. Befehlszeilentool der Chef-SW von Opscode.
 REM
 REM --------------------------------------------------------------------------------------------
 REM
 REM  D-Lib: C:/BatNT
 REM
 REM  T-Lib: C:/BatNT
 REM
 REM --------------------------------------------------------------------------------------------
 REM Parameter: beliebige [kann] ... werden ggf. 1:1 weitergereicht
 REM --------------------------------------------------------------------------------------------
 REM Erstellt von: Gerhard Sprenger
 REM           am: 18.06.2015
 REM --------------------------------------------------------------------------------------------
 REM Aenderungen:  01.  30.11.2020 - Sprenger
 REM                       Codepunkte ueber 127 durch ASCII-Zeichen ersetzt. Manche Tools fassen
 REM                       dieses Skript sonst als binaer auf.
 REM ============================================================================================

 REM Aktuelle CMD wird *ersetzt*, also Aufruf in Form von XCTL, nicht Link/Call!

 knife.bat %*


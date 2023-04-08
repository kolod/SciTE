@ECHO off
ECHO Copy repositary to destination (without .git subdir)
ECHO ------------------------------------------------------------------------------
ECHO.
CD /D %~dp0
SET /P dest=Enter destination [Default - C:\TEMP\scite-ru\]:
IF "%dest%"=="" SET dest=C:\TEMP\scite-ru\
ECHO \.git\>exlist
ECHO exlist>>exlist
ECHO copy_git.cmd>>exlist
XCOPY "%~dp0*.*" "%dest%" /S /H /K /EXCLUDE:exlist
DEL exlist

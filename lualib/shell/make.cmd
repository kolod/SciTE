@ECHO OFF
SET PATH=C:\MinGW\bin;%ProgramFiles%\CodeBlocks\bin;C:\MinGW\upx;%PATH%

mingw32-make all
if errorlevel 1 exit /b 1
mingw32-make clean
upx.exe --best --compress-resources=0 shell.dll
MOVE shell.dll ..\..\Pack\tools\LuaLib\

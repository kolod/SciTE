@ECHO OFF
SETLOCAL
::-----------------------------------------
:: ���� � MinGW (���������� ���� �� ��������)
SET PATH=C:\MinGW\bin;%ProgramFiles%\CodeBlocks\bin
::-----------------------------------------

CALL :check "gcc.exe"
IF ERRORLEVEL 1 (
	ECHO Error : Please install MinGW!
	ECHO - For more information visit: http://code.google.com/p/scite-ru/
	GOTO error
)

ECHO Start building ...
ECHO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CD /D "%~dp0"
windres -o resfile.o toolbar.rc
IF ERRORLEVEL 1 GOTO error
gcc -s -shared -nostdlib -o cool.dll resfile.o
IF ERRORLEVEL 1 GOTO error

DEL resfile.o

ECHO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ECHO Building successfully completed!
EXIT 0

:check
FOR /f %%i IN (%1) DO IF "%%~$PATH:i"=="" EXIT /b 1
EXIT /b 0

:error
ECHO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ECHO Compile errors were found!
EXIT 1

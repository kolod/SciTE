@ECHO off
CHCP 1251>nul
ECHO ����������� �������� TRUNK � ��������� ����� (��� ��������� ������������ .svn)
ECHO ------------------------------------------------------------------------------
ECHO .
CD /D %~dp0
SET /P dest=���� �����������? [�� ��������� - � C:\TEMP\TRUNK\]:
IF "%dest%"=="" SET dest=C:\TEMP\TRUNK\
ECHO \.svn\>exlist
ECHO exlist>>exlist
ECHO copy_svn.cmd>>exlist
XCOPY %~dp0*.* %dest% /S /H /K /EXCLUDE:exlist
DEL exlist

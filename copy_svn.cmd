@ECHO off
ECHO ����஢���� ��⠫��� TRUNK � 㪠������ ���� (��� �㦥���� �����⠫���� .svn)
ECHO ------------------------------------------------------------------------------
ECHO .
CD /D %~dp0
SET /P dest=�㤠 ᪮��஢���? [�� 㬮�砭�� - � C:\TEMP\TRUNK\]:
IF "%dest%"=="" SET dest=C:\TEMP\TRUNK\
ECHO \.svn\>exlist
ECHO exlist>>exlist
ECHO copy_svn.cmd>>exlist
XCOPY %~dp0*.* %dest% /S /H /K /EXCLUDE:exlist
DEL exlist


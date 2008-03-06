-- ���� ���� �������� ��� �������� SciTE
-- ����� �� �������� ��� ��� �������� ����������� ������������ ��������, ��������� ��� ���������� ������ ���������, ����������� �� ��� �������� � ������������ ������ � �������� ������ ��� ������ ���������������� ������ ���� Tools.
-- ����� (� ������� dofile) �������� ������ �������, �������������� ������� ���������.

----[[ C O M M O N ]]-------------------------------------------------------

-- ����������� ����� � ������ ���������, ��������������� �� ������ ��������
dofile (props["SciteDefaultHome"].."\\tools\\COMMON.lua")

-- ��������� ������ � ��������������� ��������
dofile (props["SciteDefaultHome"].."\\tools\\macro_support.lua")

----[[ � � � � � � � � � ]]-------------------------------------------------

-- �������������� ������������ ��������� � UTF-8
dofile (props["SciteDefaultHome"].."\\tools\\UTF8_check.lua")

-- ����� ��������� Win1251/DOS866
dofile (props["SciteDefaultHome"].."\\tools\\win2dos.lua")

----[[ � � � � � � � � �   � � � � � � ]]-----------------------------------

-- ��������� ������� ��������� � ������ ���������
dofile (props["SciteDefaultHome"].."\\tools\\codepage.lua")

-- ����� ����� �������� ������� � ��������� ������
dofile (props["SciteDefaultHome"].."\\tools\\lexer_name.lua")

----[[ � � � � � � ]]-------------------------------------------------------

-- ����� ������� ������� (Ctrl+F11)
-- dofile (props["SciteDefaultHome"].."\\tools\\FontChanger.lua")

-- ��� ��������� �������� ������� ������ (Ctrl+-), �������������� � ��������� �� ������� ����� � ���������� � ������ ���������
dofile (props["SciteDefaultHome"].."\\tools\\Zoom.lua")

----[[ � � � � � � � � � � ]]--------------------------------------------------

-- ���������� ���������� ��������� SciTE, ���������� ����� ����
dofile (props["SciteDefaultHome"].."\\tools\\save_settings.lua")

-- �������������� �������� ��������� ����� ������������� ������
dofile (props["SciteDefaultHome"].."\\tools\\auto_backup.lua")

-- ����� ����������������� ������� ���������� ������� ������� ��� �������� SciTE
-- (���� � SciTEGlobal.properties ����������� ��������� session.manager=1 � save.session.manager.on.quit=1)
dofile (props["SciteDefaultHome"].."\\tools\\SessionManager\\SessionManager.lua")

----[[ R E A D   O N L Y ]]-------------------------------------------------

-- ������ ����������� ������� "Read-Only"
-- ������ ��� �������� �� ��������� ��� �������������� � ���������� �������� � ��������� ������
dofile (props["SciteDefaultHome"].."\\tools\\ReadOnly.lua")

-- ��� �������� ReadOnly, Hidden, System ������ �������� ����� ReadOnly � SciTE
dofile (props["SciteDefaultHome"].."\\tools\\ROCheck.lua")

-- ��������� ���������� RO ������
dofile (props["SciteDefaultHome"].."\\tools\\ROWrite.lua")

----[[ � � � � � �   � � � � � � � � � � � ]]-------------------------------

-- ������������ ������
--~ dofile (props["SciteDefaultHome"].."\\tools\\braces_autoclose.lua")

-- ������������ ������
dofile (props["SciteDefaultHome"].."\\tools\\smartbraces.lua")

-- ������������ HTML �����
dofile (props["SciteDefaultHome"].."\\tools\\html_tags_autoclose.lua")

-- ������������� ��������������� � ������ ������������ (�� Ctrl+Q)
dofile (props["SciteDefaultHome"].."\\tools\\xComment.lua")

----[[ � � � � � � �  � � � � ]]----------------------------------------------

-- ������ ����������� ������� SciTE "������� ���������� ����"
dofile (props["SciteDefaultHome"].."\\tools\\Open_Selected_Filename.lua")

-- ���������� ����������� ������� SciTE "������� ���������� ����" (��������� ��� ���������������� ���������)
-- � ����� ����������� ������� ���� �� ����� ���� �� ��� ����� ��� ������� ������� Ctrl.
dofile (props["SciteDefaultHome"].."\\tools\\Select_And_Open_Filename.lua")

----[[ � � � � � � � � � � � � � ]]-------------------------------------------

-- �������� ����������� ������� SciTE "File|New" (Ctrl+N). ������� ����� ����� � ������� �������� � ����������� �������� �����
dofile (props["SciteDefaultHome"].."\\tools\\new_file.lua")

-- �������� HTML ��������� ��� ������ ��� ����������, ����������� �� ���� "�������� HTML-����" Internet Explorer
dofile (props["SciteDefaultHome"].."\\tools\\set_html.lua")

-- �������������� ������������ ���� ������ ��� �������� ������ ��������� ����
dofile (props["SciteDefaultHome"].."\\tools\\ToggleFoldAll.lua")

-- �������������� �������� �� �������� � ����������
dofile (props["SciteDefaultHome"].."\\tools\\AutocompleteObject.lua")

-- ��� ����� �����, ���� ��� ���������� �� ���������� ������ �����������
--~ dofile (props["SciteDefaultHome"].."\\tools\\abbrevlist.lua")

-- ��������� ������ ����� � HTML
dofile (props["SciteDefaultHome"].."\\tools\\highlighting_paired_tags.lua")

----[[ � � � � � � � � � � � � � �  � � � � ]]--------------------------------

-- ����� ���������� ������� "����� � ������..." ������� ����� � ����������� ���� ������� - "������� ��������� �����"
dofile (props["SciteDefaultHome"].."\\tools\\OpenFindFiles.lua")

-- ������� � ����������� ���� ���� (��������) ������� ��� ������ SVN
--~ dofile (props["SciteDefaultHome"].."\\tools\\svn_menu.lua")

----[[ � � � � � � �  �  � � � � � � � � � � � ]]-----------------------------

-- SciTE_HexEdit: A Self-Contained Primitive Hex Editor for SciTE
dofile (props["SciteDefaultHome"].."\\tools\\HexEdit\\SciTEHexEdit.lua")

-- SciTE Calculator
dofile (props["SciteDefaultHome"].."\\tools\\Calculator\\SciTECalculatorPD.lua")

-- ������� ������������ (�,�,�,�,�) �� ��������������� ������ (��� HTML ����������� �� �����������)
dofile (props["SciteDefaultHome"].."\\tools\\InsertSpecialChar.lua")

-- ��������� / ������ �������� �� ������ (Bookmark) (�� �� ��� � Ctrl+F2)
-- � ������� ����� ���� ��� ������� ������� Ctrl
--~ dofile (props["SciteDefaultHome"].."\\tools\\MarkerToggle.lua")

----[[ � � � � � � � � �   � � � � � � � � � � ]]-----------------------------

-- ��������� ������� ������� ��������� � ���� �������
local tab_width = tonumber(props['output.tabsize'])
if tab_width ~= nil then
	scite.SendOutput(SCI_SETTABWIDTH, tab_width)
end

----------------------------------------------------------------------------

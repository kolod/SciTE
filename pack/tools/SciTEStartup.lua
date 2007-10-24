-- ���� ���� �������� ��� �������� SciTE
-- ����� �� �������� ��� ��� �������� ����������� ������������ ��������, ��������� ��� ���������� ������ ���������, ����������� �� ��� �������� � ������������ ������ � �������� ������ ��� ������ ���������������� ������ ���� Tools.
-- ����� (� ������� dofile) �������� ������ �������, �������������� ������� ���������.
----------------------------------------------------------------------------
-- ����������� ����� � ������ ���������, ��������������� �� ������ ��������
dofile (props["SciteDefaultHome"].."\\tools\\COMMON.lua")

-- ��������� ������ � ��������������� ��������
dofile (props["SciteDefaultHome"].."\\tools\\macro_support.lua")

-- �������������� ������������ ���� ������ ��� �������� ������ ��������� ����
dofile (props["SciteDefaultHome"].."\\tools\\ToggleFoldAll.lua")

-- �������� HTML ��������� ��� ������ ��� ����������, ����������� �� ���� "�������� HTML-����" Internet Explorer
dofile (props["SciteDefaultHome"].."\\tools\\set_html.lua")

-- ������������ ������
--~ dofile (props["SciteDefaultHome"].."\\tools\\braces_autoclose.lua")

-- �������������� �������� ��������� ����� ������������� ������
dofile (props["SciteDefaultHome"].."\\tools\\auto_backup.lua")

-- ��������� / ������ �������� �� ������ (Bookmark) (�� �� ��� � Ctrl+F2)
-- � ������� �������� ����� ���� ��� ������� ������� Ctrl
dofile (props["SciteDefaultHome"].."\\tools\\MarkerToggle.lua")

-- ����� ����� �������� ������� � ��������� ������
dofile (props["SciteDefaultHome"].."\\tools\\lexer_name.lua")

-- ������ ����������� ������� "Read-Only"
-- ������ ��� �������� �� ��������� ��� �������������� � ���������� �������� � ��������� ������
dofile (props["SciteDefaultHome"].."\\tools\\ReadOnly.lua")

-- ������ ����������� ������� SciTE "������� ���������� ����"
dofile (props["SciteDefaultHome"].."\\tools\\Open_Selected_Filename.lua")

-- ����� ��������� Win1251/DOS866
dofile (props["SciteDefaultHome"].."\\tools\\win2dos.lua")

-- ��������� ������� ��������� � ������ ���������
dofile (props["SciteDefaultHome"].."\\tools\\codepage.lua")

-- ��� �������� ReadOnly, Hidden, System ������ �������� ����� ReadOnly � SciTE
dofile (props["SciteDefaultHome"].."\\tools\\ROCheck.lua")

-- ��������� ���������� RO ������
dofile (props["SciteDefaultHome"].."\\tools\\ROWrite.lua")

-- ������������ HTML �����
dofile (props["SciteDefaultHome"].."\\tools\\html_tags_autoclose.lua")

-- ����� ������� ������� (Ctrl+F11)
dofile (props["SciteDefaultHome"].."\\tools\\FontChanger.lua")

-- ������� ������������ (�,�,�,�,�) �� ��������������� ������ (��� HTML ����������� �� �����������)
dofile (props["SciteDefaultHome"].."\\tools\\InsertSpecialChar.lua")

-- SciTE_HexEdit: A Self-Contained Primitive Hex Editor for SciTE
dofile (props["SciteDefaultHome"].."\\tools\\HexEdit\\SciTEHexEdit.lua")

-- SciTE Calculator
dofile (props["SciteDefaultHome"].."\\tools\\Calculator\\SciTECalculatorPD.lua")

-- �������������� �������� �� �������� � ����������
dofile (props["SciteDefaultHome"].."\\tools\\AutocompleteObject.lua")

-- ����� ����������������� ������� ���������� ������� ������� ��� �������� SciTE
-- (���� � SciTEGlobal.properties ����������� ��������� session.manager=1 � save.session.manager.on.quit=1)
dofile (props["SciteDefaultHome"].."\\tools\\SessionManager\\SessionManager.lua")

-- ��� ��������� �������� ������� ������, �������������� � ��������� �� ������� ����� � ���������� � ������ ���������
dofile (props["SciteDefaultHome"].."\\tools\\Zoom.lua")

-- ������� ��������������� ����������� ����, ������������ ������
dofile (props["SciteDefaultHome"].."\\tools\\smartcomment.lua")

-- ��� ����� �����, ���� ��� ���������� �� ���������� ������ �����������
--~ dofile (props["SciteDefaultHome"].."\\tools\\abbrevlist.lua")

-- ���������� ���������� ��������� SciTE, ���������� ����� ����
dofile (props["SciteDefaultHome"].."\\tools\\save_settings.lua")

-- ������� � ����������� ���� ���� (��������) ������� ��� ������ SVN
--~ dofile (props["SciteDefaultHome"].."\\tools\\svn_menu.lua")

-- ��������� ������� ������� ��������� � ���� �������
local tab_width = tonumber(props['output.tabsize'])
if tab_width ~= nil then
	scite.SendOutput(SCI_SETTABWIDTH, tab_width)
end

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
dofile (props["SciteDefaultHome"].."\\tools\\FontChanger.lua")

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
-- ������ ��� ������� �� ��������� ��� �������������� � ���������� �������� � ��������� ������
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
--~ dofile (props["SciteDefaultHome"].."\\tools\\smartcomment.lua")

----[[ � � � � � � �  � � � � ]]----------------------------------------------

-- ������ ����������� ������� SciTE "������� ���������� ����"
dofile (props["SciteDefaultHome"].."\\tools\\Open_Selected_Filename.lua")

-- ���������� ����������� ������� SciTE "������� ���������� ����" (��������� ��� ���������������� ���������)
-- � ����� ����������� ������� ���� �� ����� ���� �� ��� ����� ��� ������� ������� Ctrl.
dofile (props["SciteDefaultHome"].."\\tools\\Select_And_Open_Filename.lua")

----[[ � � � � � � � � � � � � � ]]-------------------------------------------

-- ��� �������� �� �������� ������, ������������ �����, �������� ������� ������� �� ������
dofile (props["SciteDefaultHome"].."\\tools\\goto_line.lua")

-- �������� ����������� ������� SciTE "File|New" (Ctrl+N). ������� ����� ����� � ������� �������� � ����������� �������� �����
dofile (props["SciteDefaultHome"].."\\tools\\new_file.lua")

-- �������� HTML ��������� ��� ������ ��� ����������, ����������� �� ���� "�������� HTML-����" Internet Explorer
dofile (props["SciteDefaultHome"].."\\tools\\set_html.lua")

-- �������������� ������������ ���� ������ ��� �������� ������ ��������� ����
dofile (props["SciteDefaultHome"].."\\tools\\ToggleFoldAll.lua")

-- ������� ��� ��������� ������
dofile (props["SciteDefaultHome"].."\\tools\\FoldText.lua")

-- �������������� �������� �� �������� � ����������
dofile (props["SciteDefaultHome"].."\\tools\\AutocompleteObject.lua")

-- ��� ����� �����, ���� ��� ���������� �� ���������� ������ �����������
--~ dofile (props["SciteDefaultHome"].."\\tools\\abbrevlist.lua")

-- ��������� ������ ����� � HTML
dofile (props["SciteDefaultHome"].."\\tools\\highlighting_paired_tags.lua")

-- ��������� ������ � ������ � �������� �� � �������� ��� ����� � ������� Ctrl
dofile (props["SciteDefaultHome"].."\\tools\\HighlightLinks.lua")

----[[ � � � � � � � � � � � � � �  � � � � ]]--------------------------------

-- ����� ���������� ������� "����� � ������..." ������� ����� � ����������� ���� ������� - "������� ��������� �����"
dofile (props["SciteDefaultHome"].."\\tools\\OpenFindFiles.lua")

-- ������� � ����������� ���� ���� (�������) ������� ��� ������ SVN
dofile (props["SciteDefaultHome"].."\\tools\\svn_menu.lua")

----[[ � � � � � � �  �  � � � � � � � � � � � ]]-----------------------------

-- SideBar: ������������������� ������� ������
dofile (props["SciteDefaultHome"].."\\tools\\SideBar.lua")

-- Color Image Viewer: ������������ ����� � �����������
dofile (props["SciteDefaultHome"].."\\tools\\CIViewer\\CIViewer.lua")

-- SciTE_HexEdit: A Self-Contained Primitive Hex Editor for SciTE
dofile (props["SciteDefaultHome"].."\\tools\\HexEdit\\SciTEHexEdit.lua")

-- SciTE Calculator
dofile (props["SciteDefaultHome"].."\\tools\\Calculator\\SciTECalculatorPD.lua")

-- ������� ������������ (�,�,�,�,�) �� ��������������� ������ (��� HTML ����������� �� �����������)
dofile (props["SciteDefaultHome"].."\\tools\\InsertSpecialChar.lua")

-- ��������� / ������ ����� �� ������ (Bookmark) (�� �� ��� � Ctrl+F2)
-- � ������� ����� ���� ��� ������� ������� Ctrl
--~ dofile (props["SciteDefaultHome"].."\\tools\\BookmarkToggle.lua")

----[[ � � � � � � � � �   � � � � � � � � � � ]]-----------------------------

-- ��������� ������� ������� ��������� � ���� �������
local tab_width = tonumber(props['output.tabsize'])
if tab_width ~= nil then
	scite.SendOutput(SCI_SETTABWIDTH, tab_width)
end

------------------------------------------------------------------------------
-- �������������� ��������� ���������/����������� ���� ������
-- (������������ ��� ������/��������� ����� ��������� � ����)
function SessionSaveChange()
	if tonumber(props['save.session.file']) == 1 then
		props['save.session.file'] = 0
		props['save.session'] = 0
		props['save.recent'] = 0
		props['save.position'] = 0
	else
		props['save.session.file'] = 1
		props['save.session'] = props['default.save.session']
		props['save.recent'] = props['default.save.recent']
		props['save.position'] = props['default.save.position']
	end
end
-- ������������� ���������� ���������� ������
if props['default.save.session'] == '' then
	props['default.save.session'] = props['save.session']
end
if props['default.save.recent'] == '' then
	props['default.save.recent'] = props['save.recent']
end
if props['default.save.position'] == '' then
	props['default.save.position'] = props['save.position']
end
if props['save.session.file'] == '' then
	if tonumber(props['save.session']) == 1 or
		 tonumber(props['save.recent']) == 1 or
		 tonumber(props['save.position']) == 1
	then
		props['save.session.file'] = 1
	else
		props['save.session.file'] = 0
	end
elseif tonumber(props['save.session.file']) == 0 then
	props['save.session'] = 0
	props['save.recent'] = 0
	props['save.position'] = 0
end

------------------------------------------------------------------------------

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
-- ������� ����� ��� �������� (����� ��� ������� ����� ����� ������������ � ��������, ������� �� �� ������)

-- Translate color from RGB to win
local function encodeRGB2WIN(color)
	if string.sub(color,1,1)=="#" and string.len(color)>6 then
		return tonumber(string.sub(color,6,7)..string.sub(color,4,5)..string.sub(color,2,3), 16)
	else
		return color
	end
end

local function InitMarkStyle(style_number, indic_style, color)
	editor.IndicStyle[style_number] = indic_style
	editor.IndicFore[style_number] = encodeRGB2WIN(color)
end

local function style(mark_string)
	local mark_style_table = {
	plain    = INDIC_PLAIN,    squiggle = INDIC_SQUIGGLE,
	tt       = INDIC_TT,       diagonal = INDIC_DIAGONAL,
	strike   = INDIC_STRIKE,   hidden   = INDIC_HIDDEN,
	roundbox = INDIC_ROUNDBOX, box      = INDIC_BOX
	}
	for st,st_num in pairs(mark_style_table) do
		if string.match(mark_string, st) ~= nil then
			return st_num
		end
	end
end

local function EditorInitMarkStyles()
	for i = 0, 31 do
		local mark = props["find.mark."..i]
		if mark ~= "" then
			local mark_color = string.match(mark, "#%x%x%x%x%x%x")
			if mark_color == nil then mark_color = props["find.mark"] end
			if mark_color == "" then mark_color = "#0F0F0F" end
			local mark_style = style(mark)
			if mark_style == nil then mark_style = INDIC_ROUNDBOX end
			InitMarkStyle(i, mark_style, mark_color)
		end
	end
end

-- Add user event handler OnOpen
local old_OnOpen = OnOpen
function OnOpen(file)
	local result
	if old_OnOpen then result = old_OnOpen(file) end
	if props["mark.styles.ready"]=="" then
		EditorInitMarkStyles()
		props["mark.styles.ready"] = "yes"
	end
	return result
end
----------------------------------------------------------------------------

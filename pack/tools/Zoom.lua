-- Zoom.lua
-- Version: 1.1
-- Author: ������� ������
---------------------------------------------------
-- ��������� ����������� ������� Zoom
-- ������ � ������������� ��������, �������������� � ��������� �� ������� �����
-- �������� �������� ���������������� ���������� font.current.size, ������������ ��� ����������� ������� ������� ������ � ������ ���������
---------------------------------------------------
-- ��� ����������� �������� � ���� .properties:
--   statusbar.text.1=$(font.current.size)px
-- � ���� SciTEStartup.lua:
--   dofile (props["SciteDefaultHome"].."\\tools\\Zoom.lua")
---------------------------------------------------

local function ChangeFontSize(zoom)
	props["magnification"] = zoom
	props["print.magnification"] = zoom
	props["output.magnification"] = zoom -- ���������� ���� �� ������ �� SCI_SETZOOM � ���� �������, �� ��� �������� ��� �������?
	local _, _, font_current_size = string.find(props["style.*.32"], "size:(%d+)")
	props["font.current.size"] = font_current_size + zoom -- Used in statusbar
	scite.UpdateStatusBar()
end

-- ��������� ���� ���������� ������� OnSendEditor
local old_OnSendEditor = OnSendEditor
function OnSendEditor(id_msg, wp, lp)
	local result
	if old_OnSendEditor then result = old_OnSendEditor(id_msg, wp, lp) end
	if id_msg == SCI_SETZOOM then
		if ChangeFontSize(lp) then return true end
	end
	return result
end
-- ��������� ����������� ������� Zoom
-- ������ � ������������� ��������, �������������� � ��������� �� ������� �����
-- �������� �������� ���������������� ���������� font.current.size, ������������ ��� ����������� ������� ������� ������ � ������ ���������
-- �����: ������� ������
-------------------------------------------------------------------------
-- ��� ����������� �������� � ���� .properties:
--   statusbar.text.1=$(font.current.size)px
-- � ���� SciTEStartup.lua:
--   dofile (props["SciteDefaultHome"].."\\tools\\Zoom.lua")
-------------------------------------------------------------------------

function ChangeFontSize(zoom)
	props["print.magnification"] = zoom
	props["font.current.size"] = editor.StyleSize[STYLE_DEFAULT] + zoom -- Used in statusbar
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
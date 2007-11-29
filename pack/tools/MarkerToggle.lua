-- MarkerToggle.lua
-- Version: 1.0
-- Author: mozers�, mimir
---------------------------------------------------
-- ��������� / ������ �������� �� ������ (Bookmark) (�� �� ��� � Ctrl+F2)
-- � ������� ����� ���� ��� ������� ������� Ctrl
---------------------------------------------------

local function MarkerToggle(shift, ctrl, alt)
	if (ctrl) then
		local i = editor:LineFromPosition(editor.CurrentPos)
		if editor:MarkerGet(i) == 0 then
			editor:MarkerAdd(i,1)
		else
			editor:MarkerDelete(i,1)
		end
	end
	return false
end

-- ��������� ���� ���������� ������� OnClick
local old_OnClick = OnClick
function OnClick(shift, ctrl, alt)
	local result
	if old_OnClick then result = old_OnClick(shift, ctrl, alt) end
	if MarkerToggle(shift, ctrl, alt) then return true end
	return result
end

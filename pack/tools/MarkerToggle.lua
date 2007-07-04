-- ��������� / ������ �������� �� ������ (Bookmark) (�� �� ��� � Ctrl+F2)
-- � ������� �������� ����� ���� ��� ������� ������� Ctrl
-- mozers�, mimir

local function MarkerToggle(shift, ctrl, alt)
	if (ctrl) then
		local i = editor:LineFromPosition(editor.CurrentPos)
		if editor:MarkerGet(i) == 0 then
			editor:MarkerAdd(i,1)
		else
			editor:MarkerDelete(i,1)
		end
		editor:CharRight() editor:CharLeft()
	end
	return false
end

-- ��������� ���� ���������� ������� OnDoubleClick
local old_OnDoubleClick = OnDoubleClick
function OnDoubleClick(shift, ctrl, alt)
	local result
	if old_OnDoubleClick then result = old_OnDoubleClick(shift, ctrl, alt) end
	if MarkerToggle(shift, ctrl, alt) then return true end
	return result
end

-- ��������� / ������ �������� �� ������ (Bookmark) (�� �� ��� � Ctrl+F2)
-- � ������� �������� ����� ���� ��� ������� ������� Ctrl
-- mozers�, mimir

local function MarkerToggle(key)
	local ctrl = string.find(key, 'Ctrl', 1)
	if (ctrl~=nil) then
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
function OnDoubleClick(key)
	local result
	if old_OnDoubleClick then result = old_OnDoubleClick(key) end
	if MarkerToggle(key) then return true end
	return result
end

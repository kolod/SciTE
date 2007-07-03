-- ������ ��� ��������������� ������������ ���� ������ ��� �������� ������ ��������� ����
-- �����������:
--   �������� � SciTEStartup.lua ������
--     dofile (props["SciteDefaultHome"].."\\tools\\ToggleFoldAll.lua")
--   ������� ��������� ������ � ����� .properties
--     fold.on.open.ext=properties,ini
-- mozers�
-----------------------------------------------
local function CheckExt()
	local toggle_foldall_ext = string.upper(props['fold.on.open.ext'])
	local file_ext = '('..string.upper(props['FileExt'])..')'
	local _, _, toggle_foldall = string.find(toggle_foldall_ext, file_ext)
	if toggle_foldall ~= nil then
		scite.MenuCommand('IDM_TOGGLE_FOLDALL')
	end
end

-- ��������� ���� ���������� ������� OnOpen
local old_OnOpen = OnOpen
function OnOpen(file)
	local result
	if old_OnOpen then result = old_OnOpen(file) end
	if CheckExt() then return true end
	return result
end

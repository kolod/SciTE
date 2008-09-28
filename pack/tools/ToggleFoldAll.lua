--[[-------------------------------------------------
ToggleFoldAll.lua
Version: 1.5
Author: mozers�
-----------------------------------------------------
������ ��� ��������������� ������������ ���� ������ ��� �������� ������ ��������� ����
�����������:
  �������� � SciTEStartup.lua ������
    dofile (props["SciteDefaultHome"].."\\tools\\ToggleFoldAll.lua")
  ������� ��������� ������ � ����� .properties
    fold.on.open.ext=properties,ini
--]]-------------------------------------------------

-- ���� ���� ������� � SciTE.session ���������� true
local function CheckSession()
	local filename = props['FilePath']
	for i = 1, props['buffers'] do
		local path = props['buffer.'..i..'.path']
		if path == '' then return false end
		if path == filename then return true end
	end
	return false
end

-- ���� ���������� ����� ������������� ������ �� �������� � fold.on.open.ext ���������� true
local function CheckExt()
	local toggle_foldall_ext = string.upper(props['fold.on.open.ext'])
	local file_ext = string.upper(props['FileExt'])
	if string.find(toggle_foldall_ext, file_ext) ~= nil then
		return true
	end
	return false
end

local function ToggleFoldAll()
	if not CheckExt() then return end
	if CheckSession() then return end
	scite.MenuCommand (IDM_TOGGLE_FOLDALL)
end

-- Add user event handler OnOpen
local old_OnOpen = OnOpen
function OnOpen(file)
	local result
	if old_OnOpen then result = old_OnOpen(file) end
	if ToggleFoldAll() then return true end
	return result
end

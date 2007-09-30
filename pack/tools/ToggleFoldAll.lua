-- ToggleFoldAll.lua
-- Version: 1.3
-- Autor: mozers�
---------------------------------------------------
-- ������ ��� ��������������� ������������ ���� ������ ��� �������� ������ ��������� ����
-- �����������:
--   �������� � SciTEStartup.lua ������
--     dofile (props["SciteDefaultHome"].."\\tools\\ToggleFoldAll.lua")
--   ������� ��������� ������ � ����� .properties
--     fold.on.open.ext=properties,ini
---------------------------------------------------

local IsSciteStarted = false

local function CheckExt()
	local toggle_foldall_ext = string.upper(props['fold.on.open.ext'])
	local file_ext = string.upper(props['FileExt'])
	if string.find(toggle_foldall_ext, file_ext) ~= nil then
		return true
	end
	return false
end

local function ToggleFoldAll()
	if IsSciteStarted and CheckExt() then
		scite.MenuCommand ("IDM_TOGGLE_FOLDALL")
	end
end

-- Add user event handler OnOpen
local old_OnOpen = OnOpen
function OnOpen(file)
	local result
	if old_OnOpen then result = old_OnOpen(file) end
	if ToggleFoldAll() then return true end
	return result
end

-- Add user event handler OnUpdateUI
local old_OnUpdateUI = OnUpdateUI
function OnUpdateUI ()
	local result
	if old_OnUpdateUI then result = old_OnUpdateUI() end
	IsSciteStarted = true
	return result
end

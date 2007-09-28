-- ToggleFoldAll.lua
-- Version: 1.2
-- Autor: mozers�
---------------------------------------------------
-- ������ ��� ��������������� ������������ ���� ������ ��� �������� ������ ��������� ����
-- �����������:
--   �������� � SciTEStartup.lua ������
--     dofile (props["SciteDefaultHome"].."\\tools\\ToggleFoldAll.lua")
--   ������� ��������� ������ � ����� .properties
--     fold.on.open.ext=properties,ini
---------------------------------------------------

local bToggleFoldAll=false

local function CheckFoldExpanded()
	for i = 1, editor.LineCount-1 do
		if not editor.FoldExpanded[i] then return true end
	end
	return false
end

local function CheckExt()
	local toggle_foldall_ext = string.upper(props['fold.on.open.ext'])
	local file_ext = '('..string.upper(props['FileExt'])..')'
	if string.find(toggle_foldall_ext, file_ext) ~= nil then
		return true
	end
	return false
end

local function ToggleFoldAll()
	if not CheckFoldExpanded() then
		scite.MenuCommand ("IDM_TOGGLE_FOLDALL")
	end
	bToggleFoldAll=false
end

-- Add user event handler OnOpen
local old_OnOpen = OnOpen
function OnOpen(file)
	local result
	if old_OnOpen then result = old_OnOpen(file) end
	if CheckExt() then
		bToggleFoldAll=true
	else
		bToggleFoldAll=false
	end
	return result
end

-- Add user event handler OnUpdateUI
local old_OnUpdateUI = OnUpdateUI
function OnUpdateUI ()
	local result
	if old_OnUpdateUI then result = old_OnUpdateUI() end
	if bToggleFoldAll then
		if ToggleFoldAll() then return true end
	end
	return result
end

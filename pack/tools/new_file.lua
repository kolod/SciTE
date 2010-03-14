--[[--------------------------------------------------
new_file.lua
mozers�, VladVRO
version 3.0.3
----------------------------------------------
�������� ����������� ������� SciTE "File|New" (Ctrl+N)
������� ����� ����� � ������� �������� � ����������� �������� �����
��������� �����, ����� �� ���������� ��� ���� ������� (���������, ��������� � ��.)
----------------------------------------------
�����������:
� ���� SciTEStartup.lua �������� ������:
  dofile (props["SciteDefaultHome"].."\\tools\\new_file.lua")
----------------------------------------------
Replaces SciTE command "File|New" (Ctrl+N)
Creates new buffer in the current folder with current file extension
----------------------------------------------
Connection:
In file SciTEStartup.lua add a line:
  dofile (props["SciteDefaultHome"].."\\tools\\new_file.lua")
--]]----------------------------------------------------
require 'shell'

props["untitled.file.number"] = 0
local not_saved_files = {}

local function CreateUntitledFile()
	local file_ext = "."..props["FileExt"]
	if file_ext == "." then file_ext = props["default.file.ext"] end
	repeat
		local file_path = props["FileDir"].."\\"..scite.GetTranslation('Untitled')..props["untitled.file.number"]..file_ext
		props["untitled.file.number"] = tonumber(props["untitled.file.number"]) + 1
		if not shell.fileexists(file_path) then
			local warning_couldnotopenfile_disable = props['warning.couldnotopenfile.disable']
			props['warning.couldnotopenfile.disable'] = 1
			scite.Open(file_path)
			not_saved_files[file_path] = true
			props['warning.couldnotopenfile.disable'] = warning_couldnotopenfile_disable
			return true
		end
	until false
end
AddEventHandler("OnMenuCommand", function(msg, source)
	if msg == IDM_NEW then
		return CreateUntitledFile()
	end
end)

-- ����, ��������� �������� CreateUntitledFile ����� ���, ������� SciTE ��� ����� �� ������� � ����� ��������� �����
-- ������� ���� ������ ��� ����, ����� ��� ���������� ������ ����� ������� ��������� ������ � ������� ���� � �����
local bypass
local function SaveUntitledFile(file)
	if not_saved_files[file] and not bypass then
		bypass = true
		scite.MenuCommand(IDM_SAVEAS)
		bypass = false
		not_saved_files[file] = nil
		return true
	end
end
AddEventHandler("OnBeforeSave", function(file)
	return SaveUntitledFile(file)
end)

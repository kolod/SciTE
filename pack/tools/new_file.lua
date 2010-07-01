--[[--------------------------------------------------
new_file.lua
mozers�, VladVRO
version 3.1.3
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
local unsaved_files = {}

-- ������� ����� ����� � ������� �������� � ����������� �������� �����
local function CreateUntitledFile()
	local file_ext = "."..props["FileExt"]
	if file_ext == "." then file_ext = props["default.file.ext"] end
	repeat
		local file_path = props["FileDir"].."\\Untitled"..props["untitled.file.number"]..file_ext
		props["untitled.file.number"] = tonumber(props["untitled.file.number"]) + 1
		if not shell.fileexists(file_path) then
			local warning_couldnotopenfile_disable = props['warning.couldnotopenfile.disable']
			props['warning.couldnotopenfile.disable'] = 1
			scite.Open(file_path)
			unsaved_files[file_path:upper()] = true --��������� ���� � ���������� ������ � �������
			props['warning.couldnotopenfile.disable'] = warning_couldnotopenfile_disable
			return true
		end
	until false
end
AddEventHandler("OnMenuCommand", function(msg, source)
	if msg == IDM_NEW then
		return CreateUntitledFile()
	elseif msg == IDM_SAVEAS then
		unsaved_files[props["FilePath"]:upper()] = nil --������� ������ � ������ �� �������
	end
end)

-- ����� �����, ��������� �������� CreateUntitledFile ����� ������ ���, ������� ��� ���������� SciTE ����� ��������� ��� ����� �� ��������� ���� (��� ������ ����������� ���� "SaveAs")
-- ���������� ������� OnBeforeSave ��� ���������� ������ ������ ������� ���������� ���� "SaveAs"
AddEventHandler("OnBeforeSave", function(file)
	if unsaved_files[file:upper()] then -- ���� ��� ��������� ���� ������������� �����
		scite.MenuCommand(IDM_SAVEAS)
		return true
	end
end)

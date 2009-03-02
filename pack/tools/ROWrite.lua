-- ROWrite
-- Version: 1.1
-- �����: Midas, VladVRO
-----------------------------------------------
-- ������ ��� ��������� ���������� RO/Hidden/System ������
-- �����������:
--   �������� � SciTEStartup.lua ������
--     dofile (props["SciteDefaultHome"].."\\tools\\ROWrite.lua")
-----------------------------------------------
require 'shell'

local function iif (expresion, onTrue, onFalse)
	if (expresion) then return onTrue; else return onFalse; end
end

local function BSave(FN)
	-- ������� ��������� �����.
	local FileAttr = props['FileAttr']
	props['FileAttrNumber'] = 0
	if string.find(FileAttr, '[RHS]') then --  ���� � ���� ������ ��������, �� �������
		if shell.msgbox("���� �������� ������ ��� ������. ��� ����� ���������?\n"
			.."��������� �����: "..FileAttr, "SciTE", 65)==1 then
			-- �������� �������, ����� ������ ��� ���������
			local FileAttrNumber, err = shell.getfileattr(FN)
			if (FileAttrNumber == nil) then
				print("> "..err)
				props['FileAttrNumber'] = 32 + iif(string.find(FileAttr,'R'),1,0) + iif(string.find(FileAttr,'H'),2,0) + iif(string.find(FileAttr,'S'),4,0)
			else
				props['FileAttrNumber'] = FileAttrNumber
			end
			shell.setfileattr(FN, 2080)
		end
	end
end

local function AfterSave(FN)
	-- ���� ���� ��������� ������ � �����������, �� ��������� ��
	local FileAttrNumber = tonumber(props['FileAttrNumber'])
	if FileAttrNumber ~= nil and FileAttrNumber > 0 then
		shell.setfileattr(FN, FileAttrNumber)
	end
end

-- ��������� ���� ���������� ������� OnBeforeSave
local old_OnBeforeSave = OnBeforeSave
function OnBeforeSave(file)
	local result
	if old_OnBeforeSave then result = old_OnBeforeSave(file) end
	if BSave(file) then return true end
	return result
end

-- ��������� ���� ���������� ������� OnSave
local old_OnSave = OnSave
function OnSave(file)
	local result
	if old_OnSave then result = old_OnSave(file) end
	if AfterSave(file) then return true end
	return result
end

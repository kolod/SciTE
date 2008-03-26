--[[--------------------------------------------------
AutocompleteObject.lua
mozers�
version 2.02
------------------------------------------------------
���� �����������, ��������� � autocomplete.[lexer].start.characters
�������� ������ ������� � ������� ������� �� ���������������� api �����
���� ������� ��� ����������� �������� ������� �������� � ����� ������� � ������������ � ������� � api �����
(�������� "ucase" ��� ����� ������������� ���������� �� "UCase")
��������: � ������� ������������ ������� IsComment (����������� ����������� COMMON.lua)
props["APIPath"] �������� ������ � SciTE-Ru
------------------------------------------------------
Inputting of the symbol set in autocomplete.[lexer].start.characters causes the popup list of properties and methods of input_object. They undertake from corresponding api-file.
In the same case inputting of a space or a separator changes the case of symbols in input_object's name according to a api-file.
(for example "ucase" is automatically replaced on "UCase".)
Warning: This script needed function IsComment (COMMON.lua)
props["APIPath"] available only in SciTE-Ru
------------------------------------------------------
�����������:
� ���� SciTEStartup.lua �������� ������:
  dofile (props["SciteDefaultHome"].."\\tools\\AutocompleteObject.lua")
������� � ����� .properties ���������������� �����
������, ����� ����� ��������, ����� ��������� ��������������:
  autocomplete.lua.start.characters=.:
------------------------------------------------------
Connection:
In file SciTEStartup.lua add a line:
  dofile (props["SciteDefaultHome"].."\\tools\\AutocompleteObject.lua")
Set in a file .properties:
  autocomplete.lua.start.characters=.:
------------------------------------------------------
��� ��������� ��������� ������ �������, ���������, ��� � ������
azimuth:left;list-style-|type:upper-roman
��� ������ ����� � �������, ���������� ������ "|", �����
list-style  - ����� ���������� "������"
type        - ����� ���������� "�����"
��� ������������� ��������� �� ���� ������ ���������������� (css ��� - ������ ��� �������)
������ ����� ��������� �������� ������ � "�����������" api ������� (��. �������� ������� � ActiveX.api)
------------------------------------------------------
�����:
���� ����� ����� ����������� ������ ������� � ������� �� ������ (���� ��� ������� � api �����)
��, ��������, ������ �� ���� ���������� ��� ������ �������.
�������� ��� � ����, ������� ����� ������� � ������������� ��������:
mydoc = document
��� mydoc - ��� ������ �������
document - ��� ����� �� �������, �������� � api �����
------------------------------------------------------
�� ��� �� ������� ��������:
1. ���������� ������� CreateObjectsTable � CreateAliasTable � ���� (����� ������������ api ����� �� ���� ������)
2. ������� ����� ������� ��������� ������ ����� ������ (������ ��� �������� ��������� ����� ����� �������-�����������)
3. �������� ������� ���� ���������� ��������� (������ ����� ������ ���������� �� �� ���).
   �������� �������� ����� ����������� ����������� (������ ������� fPattern �� ������������).
--]]----------------------------------------------------

local current_pos = 0    -- ������� ������� �������
local sep_char = ''      -- ��������� � ���������� ������ (� ����� ������ - ���� �� ������������ ".:-")
local autocom_chars = '' -- �������, ���������� �������������� ������� �� ��������� autocomplete.lexer.start.characters
local get_api = true     -- ����, ������������ ������������� ������������ api �����
local api_table = {}     -- ��� ������ api ����� (��������� �� �������� ��� ����������)
local objects_table = {} -- ��� "�������", ��������� � api �����
local alias_table = {}   -- ������������� "������� = ������"
local methods_table = {} -- ��� "������" ��������� "�������", ��������� � api �����
local object_names = {}  -- ��� ����� ��������� api ����� "��������", ������� ������������� ��������� � ������� ����� "������"

------------------------------------------------------

-- ���� ��� ���������� ����������� �������� �������
local function prnTable(name)
	print('> ________________')
	for i = 1, table.maxn(name) do
		print(name[i])
	end
	print('> ^^^^^^^^^^^^^^^')
end

-- ��������������� ������ � ������� ��� ������
local function fPattern(str)
	local str_out = ''
	for i = 1, string.len(str) do
		str_out = '%'..string.sub(str, i, i+1)
	end
	return str_out
end

-- ��������� ������� �� �������� � ������� ���������
local function TableSort(table_name)
	table.sort(table_name, function(a, b) return string.upper(a) < string.upper(b) end)
	-- remove duplicates
	for i = table.maxn(table_name)-1, 0, -1 do
		if table_name[i] == table_name[i+1] then
			table.remove (table_name, i+1)
		end
	end
	return table_name
end

------------------------------------------------------

-- ���������� �� api-����� �������� ���� ��������, ������� ������������� ����������
-- �.�. ������ "������" wShort, � ������ ����� ������ ��� WshShortcut � WshURLShortcut
local function GetObjectNames(text)
	local obj_names = {}
	-- ����� �� ������� ���� "��������"
	for i = 1, table.maxn(objects_table) do
		if string.upper(text) == string.upper(objects_table[i]) then
			table.insert(obj_names, objects_table[i])
			return obj_names -- ���� �������, �� ��������� �����
		end
	end
	-- ����� �� ������� ������������� "������ - �������"
	for i = 1, table.maxn(alias_table), 2 do
		if string.upper(text) == string.upper(alias_table[i+1]) then
			table.insert(obj_names, alias_table[i])
		end
	end
	return obj_names
end

-- ����� ���������� ���������� ���������������� ���������� ��������� �������
-- �.�. � ������� ����� ���� ����������� ���� "������� = ������"
local function FindDeclaration()
	local text_all = editor:GetText()
	local _start, _end, sVar, sRightString
	local pattern = '([%w%.%:%-%_]+)%s*=%s*([^%c]+)'
	_start = 1
	while true do
		_start, _end, sVar, sRightString = string.find(text_all, pattern, _start)
		if _start == nil then break end
		if sRightString ~= '' then
			-- ����������� ����� ������ �� ����� "=" (���������, ������ �� ��� ����������)
			for sValue in string.gmatch(sRightString, "[%w%.%:%-%_]+") do
				local objects = GetObjectNames(sValue)
				for i = 1, table.maxn(objects) do
					if objects[i] ~= '' then
						-- ���� �������������, ����� "������" ����������, �� ��������� ��� � ������� ������������� "������ - �������"
						table.insert(alias_table, objects[i])
						table.insert(alias_table, sVar)
					end
				end
			end
		end
		_start = _end + 1
	end
end

-- ������ api ����� � ������� api_table (����� ����� �� ���������� ����, � ��� ������ �� ���)
local function CreateAPITable()
	api_table = {}
	for api_filename in string.gmatch(props["APIPath"], "[^;]+") do
		if api_filename ~= '' then
			local api_file = io.open(api_filename)
			if api_file then
				for line in api_file:lines() do
					line = string.gsub(line,'[%s(].+$','') -- �������� �����������
					if line ~= '' then
						table.insert(api_table, line)
					end
				end
				api_file:close()
			else
				api_table = {}
			end
		end
	end
	get_api = false
	return false
end

-- �������� �������, ���������� ��� ����� "��������" ��������� � api �����
local function CreateObjectsTable()
	objects_table = {}
	for i = 1, table.maxn(api_table) do
		local line = api_table[i]
		local _start, _end, sObj = string.find(line, '^([^#].+)[%'..sep_char..']', 1)
		if _start ~= nil then
			table.insert(objects_table, sObj)
		end
	end
	objects_table = TableSort(objects_table)
end

-- �������� �������, ���������� ��� ������������� "������� = ������" ��������� � api �����
local function CreateAliasTable()
	alias_table = {}
	local sVar_old
	for i = 1, table.maxn(api_table) do
		local line = api_table[i]
		local _start, _end, sVar, sValue = string.find(line, '^#(%w+)=([^%s]+)$', 1)
		if _start ~= nil then
			if sVar ~= sVar_old then
				table.insert(alias_table, sVar)
				table.insert(alias_table, sValue)
			end
			sVar_old = sVar
		end
	end
end

-- �������� ������� "�������" ��������� "�������"
local function CreateMethodsTable(obj)
	for i = 1, table.maxn(api_table) do
		local line = api_table[i]
		-- ���� ������, ������� ���������� � ��������� "�������"
		local _, _end = string.find(line, obj..sep_char, 1, 1)
		if _end ~= nil then
			local _start, _end, str_method = string.find(line, '([^%s%.%:%-]+)', _end)
			if _start ~= nil then
				table.insert (methods_table, str_method)
			end
		end
	end
end

-- ���������� �������������� ������ "�������"
local function ShowUserList()
-- prnTable(methods_table)
	local list_count = table.getn(methods_table)
	if list_count > 0 then
		methods_table = TableSort(methods_table)
		local s = table.concat(methods_table, " ")
		if s ~= '' then
			editor:UserListShow(7, s)
			return true
		else
			return false
		end
	else
		return false
	end
end

-- ��������� ��������� �� ��������������� ������ ����� � ������������� ������
local function InsertMethod(str)
	editor:SetSel(current_pos, editor.CurrentPos)
	editor:ReplaceSel(str)
end

-- �������� ��������� (������������ ������� �� �������)
local function AutocompleteObject(char)
	if IsComment(editor.CurrentPos-2) then return false end  -- ���� ������ ����������������, �� �������

	local autocomplete_start_characters = props["autocomplete."..editor.LexerLanguage..".start.characters"]
	-- ���� ���������� ������� ��� � ��������� autocomplete.lexer.start.characters, �� �������
	if autocomplete_start_characters == '' then return false end
	if string.find(autocomplete_start_characters, char, 1, 1) == nil then return false end

	-- ������� �� �� ������ ��� ��������� ������ - ������ ��� �����������!
	sep_char = char
	autocom_chars = fPattern(autocomplete_start_characters)

	if get_api == true then
		CreateAPITable()
	end
	if table.maxn(api_table) == 0 then return false end
	CreateObjectsTable()
	CreateAliasTable()
	FindDeclaration()
	-- prnTable(objects_table)
	-- prnTable(alias_table)

	current_pos = editor.CurrentPos
	local input_object = editor:textrange(editor:WordStartPosition(current_pos-1),current_pos-1) -- ����� � �������� ������� ����� ����� �� �������
	local object_len = string.len(input_object)
	if object_len < 1 then return '' end
	-- ���� ����� �� ������� ����������� �����, ������� ����� ����������� ��� ��� �������, �� �������
	object_names = GetObjectNames(input_object)
	-- prnTable(object_names)
	if table.maxn(object_names) == 0 then return false end
	methods_table = {}
	for i = 1, table.maxn(object_names) do
		CreateMethodsTable(object_names[i])
	end
	return ShowUserList()
end

------------------------------------------------------

-- Add user event handler OnChar
local old_OnChar = OnChar
function OnChar(char)
	local result
	if old_OnChar then result = old_OnChar(char) end
	if props['macro-recording'] ~= '1' and AutocompleteObject(char) then return true end
	return result
end

-- Add user event handler OnUserListSelection
local old_OnUserListSelection = OnUserListSelection
function OnUserListSelection(tp,sel_value)
	local result
	if old_OnUserListSelection then result = old_OnUserListSelection(tp,sel_value) end
	if tp == 7 then
		if InsertMethod(sel_value) then return true end
	end
	return result
end

-- Add user event handler OnSwitchFile
local old_OnSwitchFile = OnSwitchFile
function OnSwitchFile(file)
	local result
	if old_OnSwitchFile then result = old_OnSwitchFile(file) end
	get_api = true
	return result
end

-- Add user event handler OnOpen
local old_OnOpen = OnOpen
function OnOpen(file)
	local result
	if old_OnOpen then result = old_OnOpen(file) end
	get_api = true
	return result
end

-- Add user event handler OnBeforeSave
local old_OnBeforeSave = OnBeforeSave
function OnBeforeSave(file)
	local result
	if old_OnBeforeSave then result = old_OnBeforeSave(file) end
	get_api = true
	return result
end
--[[--------------------------------------------------
AutocompleteObject.lua
mozers�, Tymur Gubayev
version 3.08
------------------------------------------------------
Inputting of the symbol set in autocomplete.[lexer].start.characters causes the popup list of properties and methods of input_object. They undertake from corresponding api-file.
In the same case inputting of a separator changes the case of symbols in input_object's name according to a api-file.
(for example "ucase" is automatically replaced on "UCase".)
Warning: This script needed function IsComment (COMMON.lua)
props["APIPath"] available only in SciTE-Ru

Connection:
In file SciTEStartup.lua add a line:
  dofile (props["SciteDefaultHome"].."\\tools\\AutocompleteObject.lua")
Set in a file .properties:
  autocomplete.lua.start.characters=.:

------------------------------------------------------
���� �����������, ��������� � autocomplete.[lexer].start.characters
�������� ������ ������� � ������� ������� �� ���������������� api �����
���� ����������� �������� ������� �������� � ����� ������� � ������������ � ������� � api ����� (�������� "ucase" ��� ����� ������������� ���������� �� "UCase")
��������: � ������� ������������ ������� IsComment (����������� ����������� COMMON.lua)
props["APIPath"] �������� ������ � SciTE-Ru

�����������:
� ���� SciTEStartup.lua �������� ������:
  dofile (props["SciteDefaultHome"].."\\tools\\AutocompleteObject.lua")
������� � ����� .properties ���������������� �����
������, ����� ����� ��������, ����� ��������� ��������������:
  autocomplete.lua.start.characters=.:
------------------------------------------------------
��� ��������� ��������� ������ �������, ���������, ��� � ������
azimuth:left;list-style-|type:upper-roman
��� ������ ����� � �������, ���������� ������ "|", � ������ "-" �������� ����� �� ������������, �����
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
History:
3.0 (Tymur):
	- ������ ���� ���� ����� case sensitive �� ��������� �� ������
	* ��������� ������� objects_table, alias_table �� �������� ����� � ������� �� ���������� �������
	* ������� �������� ������ 1 � 2 �� ������ ����
	+ ������� ���� ��� ���: ������������� ��������� ���������� � ���� (������������� � �������� string)
	+ ������� � �������� ������ ������ ��������� ����� ������������� ��� ��������. ��. new_delim_behavior
	* FindDeclaration() ���� ����������� � ������������ � ������: ���������� ������� ������� �� $(word.characters.$(file.patterns.LANGUAGE))$(autocomplete.LANGUAGE.start.characters)
	* � ����� ������ ������ �������� ������� (�������� ����� ������� ������) �� ���� ����������� ���������� ������ CreateObjectsTable() � CreateAliasTable() �� ���� ������, � ������ �� ������������� (get_api == true)
	* �������� ������ ���, ��������� � ��������� VoidVolker: http://forum.ru-board.com/topic.cgi?forum=5&topic=24956&start=840#5
	��������� ������ ��� ���, ���� ��� �������� :)
	+ ���� � api-����� ��� ���������� ������� ����: t["a-b+c"]\n��� ����� ������ ��������
	  �� ����� ����� �������� � autocomplete.lua.start.characters ������ '['
3.01(Tymur):
	+ ������ ����� ���������������� � �������� (��. "-" ������ 3.0)
	+ ������������� ������������ ������� �������� ���������� ����� ������� (����� ����� �� �����������) �� ��������� � api-����� (��� ���: StriNG ������ string), �� ������ ��� ������������� ��������������.
3.05(Tymur):
	* ����������� �������� ���������� ��������������� ����� ����� �����������
	+ �� �������������� �������� ���������� ������ ���� new_delim_behavior ������ props["autocomplete.object.alt"]=="1", ��� ��� �������� ������������ ����� ���������� ������ ��������� �����. ���������.
	* ���������� ������ ������ ���������, ����� �� �� ������� ��� *.css (� �� ������) ������ (��������� mozers). ������ ����� �� word.characters.*.css ������ ������ "-".
	* �������� �������� ������������� ������ ���������: ��� ���������� ������� ��� �������� �������� ����� (����� ��������) ������������ �������� ��� (��� ������������) (������ ��������).
3.06(mozers):
	* �������� autocomplete.object.alt � ���������� new_delim_behavior_better_buggy �������� �� ������ �������� autocomplete.object.method=0|1|2 � ������� �������� ����� ������� ���� �� ���� ���������� ���������.
3.07(mozers):
	- �������� autocomplete.object.method ������ �� ������������. ��� ��������� ������� ����� ����������.
	* ������� GetInputObject ����������. ������������ ��������� [GetWordChars] BioInfo.
3.08(mozers):
	* ����� � ������ ����������� �������� � �������� ������� � ��������� ��������� IsObject � IsString
	* ������ � lua ������ ������� string ��������� ����� �����, � ����������� ������ ��������� ���������� - ����� : (������������� ��������� SciTELua.api)
--]]----------------------------------------------------

local current_pos = 0    -- ������� ������� �������, ����� ��� InsertMethod
local sep_char = ''      -- ��������� � ���������� ������ (� ����� ������ - ���� �� ������������ ".:")
local auto_start_chars_patt = '' -- �������, ���������� �������������� ������� �� ��������� autocomplete.lexer.start.characters
local get_api = true     -- ����, ������������ ������������� ������������ api �����
local api_table = {}     -- ��� ������ api ����� (��������� �� �������� ��� ����������)
local objects_table = {} -- ��� "�������", ��������� � api ����� � ���� objects_table[objname]=true
local alias_table = {}   -- ������������� "������� = ������"
local methods_table = {} -- ��� "������" ��������� "�������", ��������� � api �����
local object_names = {}  -- ��� ����� ��������� api ����� "��������", ������� ������������� ��������� � ������� ����� "������"
local autocomplete_start_characters = '' -- ������� ����������� �������� (�� ��������� autocomplete.lexer.start.characters)
local object_good_name = '' -- "�������" ��� �������, ���, ��� ������� � api-�����, �������� �������
local word_chars_patt = ''

------------------------------------------------------
-- ��������������� ������ � ������� ��� ������
local function fPattern(str)
	-- ������� ��� ����� ����������� ���������� �������� ���:
	local lua_patt_chars = "[%(%)%.%+%-%*%?%[%]%^%$]"
	-- return str:gsub('.','%%%0') -- ����� ������� � ���, �� ����������� �� ������ - ���������.
	return str:gsub(lua_patt_chars,'%%%0')
end

------------------------------------------------------
-- ��������� ������� �� �������� � ������� ���������
local function TableSort(table_name)
	table.sort(table_name, function(a, b) return a:upper() < b:upper() end)
	-- remove duplicates
	for i = #table_name-1, 0, -1 do
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
	text = text:upper()
	local obj_names = {}
	-- ����� �� ������� ���� "��������"
	if objects_table[text] then
		obj_names[#obj_names+1] = objects_table[text]
		return obj_names, objects_table[text] -- ���� �������, �� ��������� �����
	end
	-- ����� �� ������� ������������� "������ - �������"
	if alias_table[text] then
		for _,v in pairs(alias_table[text]) do obj_names[#obj_names+1] = v end
	end
	return obj_names , (alias_table[text] and alias_table[text]())
end

------------------------------------------------------
-- ���������� �� �������� ����� ����� �������, � ������� "��������":
-- ����� "�����" ����� �� �������, ������ ������� ������� autocomplete.start.characters ������ ����� �����
local function GetInputObject()
	local word_chars = editor.WordChars
	-- ��������� ����������� - ��� ������ ���� ����� �����
	editor.WordChars = word_chars..(autocomplete_start_characters or "")
	-- ����� �� ��� ������� ��� ������ editor:WordStartPosition
	local word_start_pos = editor:WordStartPosition(current_pos-1)
	-- ���������� ��������� �����
	editor.WordChars = word_chars
	return editor:textrange(word_start_pos, current_pos-1)
end

------------------------------------------------------
-- ���������� ������ �������-�������, ������� ���������� "����������" ���
local function CreateAliasEntry(obj)
	return setmetatable({}, { __call = function () return obj end })
end

------------------------------------------------------
-- �������� ����� � ������� ������������� "������ - �������"
local function AddAlias(obj, alias)
	local OBJ = obj:upper()
	-- ���� ������� ����� �����, ������ �������
	alias_table[OBJ] = alias_table[OBJ] or CreateAliasEntry(obj)
	-- ��������� ������� alias � ������� obj
	alias_table[OBJ][alias:upper()] = alias
end

------------------------------------------------------
-- �������� �� �������� �� ����� ������������ �������
--@todo: ������ �� ������ ������ _�����_ ������
local function IsString(text)
	if (editor.LexerLanguage == 'lua' or editor.LexerLanguage == 'cpp') and
		(text:match([[^".*"]]) or text:match([[^'.*']]) or text:match("^%[%[.*%]%]")) then
			return true
	else
		return false
	end
end

------------------------------------------------------
-- �������� �� �������� �� ����� ������������ �������
local function IsObject(text)
	for sValue in text:gmatch(word_chars_patt) do
		local objects = GetObjectNames(sValue)
		for i = 1, #objects do
			if #objects[i] ~= 0 then
				return objects[i]
			end
		end
	end
	return ''
end

------------------------------------------------------
-- ����� ���������� ���������� ���������������� ���������� ��������� �������
-- �.�. � ������� ����� ���� ����������� ���� "������� = ������"
local function FindDeclaration()
	local text_all = editor:GetText()
	local _start, _end, sVar, sRightString
	-- ���� ��, ��� �������� �, ��������, word.characters.$(file.patterns.lua)
	word_chars_patt = '['..fPattern(editor.WordChars)..auto_start_chars_patt..']+'

	-- @todo: ������ ����� ����� ������ �� ������ ���������.
	local pattern = '('..word_chars_patt..')%s*=%s*(%C+)'
	_start = 1
	while true do
		_start, _end, sVar, sRightString = text_all:find(pattern, _start)
		if _start == nil then break end
		-- ������� ������� � ������/�����
		sRightString = sRightString:gsub("^%s*(%S*)%s*$", "%1")
		if #sRightString ~= 0 then
			-- ����������� ����� ������ �� ����� "="
				-- ���������, ������ �� ��� ����������?
			if IsString(sRightString) then
				-- ���� �������������, ��� - ��������� ����������, �� ��������� �� � ������� ������������� "������ - �������"
				if editor.LexerLanguage == 'lua' then
					AddAlias(sVar, 'string_value') -- ��������� � lua ������ ��������� ���������� �������� ����� : � �� ����� ����� ��� ��� ���������, �� ���������� � api �� �������� �������� �� ������� ������� string.
				else
					AddAlias(sVar, 'string')
				end
			else
				-- ���������, � �� ���������� �� ��� ��������� � api ������?
				local obj = IsObject(sRightString)
				-- ���� �������������, ����� "������" ����������, �� ��������� ��� � ������� ������������� "������ - �������"
				if #obj ~= 0 then AddAlias(sVar, obj) end
			end
		end
		_start = _end + 1
	end
end

------------------------------------------------------
-- ������ api ����� � ������� api_table (����� ����� �� ���������� ����, � ��� ������ �� ���)
local function CreateAPITable()
	api_table = {}
	for api_filename in props["APIPath"]:gmatch("[^;]+") do
		if api_filename ~= nil then
			local api_file = io.open(api_filename)
			if api_file then
				for line in api_file:lines() do
					-- �������� �����������
					line = line:match('^[^%s%(]+')
					if line ~= nil then
						api_table[#api_table+1] = line
					end
				end
				api_file:close()
			end
		end
	end
	get_api = false
	return false
end

------------------------------------------------------
-- �������� �������, ���������� ��� ����� "��������" ��������� � api �����
-- �������� �������, ���������� ��� ������������� "#������� = ������" ��������� � api �����
local function CreateObjectsAndAliasTables()
	objects_table = {}
	alias_table = {}
	for i = 1, #api_table do
		local line = api_table[i]
		-- ����� ������ �����, ����� � ����� ��� ������ [auto_start_chars_patt], �.�. �������� "[.:]" ��� ���
		-- �.�. ��� ������� �������� ������ ��� api_get, ����� ����� �����.
		local obj_name = line:match('^([^#]+)['..auto_start_chars_patt..']')
		if obj_name then objects_table[obj_name:upper()]=obj_name end
		-- ��� ����� ���� "#a=b" ���������� a,b ��������� � ������� �������
		local sVar, sValue = line:match('^#(%w+)=([^%s]+)$') --@todo: �������� ��� ���������...
		if sVar then
			AddAlias(sValue, sVar)
		end
	end
end

------------------------------------------------------
-- �������� ������� "�������" ��������� "�������"
local function CreateMethodsTable(obj)
	for i = 1, #api_table do
		local line = api_table[i]
		-- ���� ������, ������� ���������� � ��������� "�������"
		local _, _end = line:find(obj..sep_char, 1, 1)
		if _end ~= nil then
			local _start, _end, str_method = line:find('([^'..auto_start_chars_patt..']+)', _end+1)
			if _start ~= nil then
				methods_table[#methods_table+1] = str_method
			end
		end
	end
end

------------------------------------------------------
-- ���������� �������������� ������ "�������"
local function ShowUserList()
	if #methods_table == 0 then return false end
	local s = table.concat(methods_table, " ")
	if s == '' then return false end
	editor:UserListShow(7, s)
	return true
end

------------------------------------------------------
-- ��������� ��������� �� ��������������� ������ ����� � ������������� ������
local function InsertMethod(str)
	-- current_pos ���������, ��� �� ���� ��� ����� �����������, editor.CurrentPos ������ - ��� ������ ����� ����� �� current_pos, str �������� ��� �����+�����������+��� ���� ��������.
	editor:SetSel(current_pos, editor.CurrentPos)
	editor:ReplaceSel(--[[object_good_name..]]str)
end

-- �������� ��������� ��� ������� �� ��� ��� �� api ����� (��������, 'wscript' �� 'WScript'))
local function CorrectRegisterSymbols(object_name)
	editor:SetSel(current_pos - #object_name, current_pos)
	editor:ReplaceSel(object_name)
end

-- �������� ��������� (������������ ������� �� �������)
local function AutocompleteObject(char)
	if IsComment(editor.CurrentPos-2) then return false end  -- ���� ������ ����������������, �� �������

	autocomplete_start_characters = props["autocomplete."..editor.LexerLanguage..".start.characters"]
	-- ���� � �������� autocomplete.lexer.start.characters ������, �� �������
	if autocomplete_start_characters == '' then return false end

	-- workaround ��� �������� ���������� �������
	-- ���� char �� �� autocomplete.lexer.start.characters ��
	if not autocomplete_start_characters:find(char, 1, 1) then
		local word_start = editor:WordStartPosition(editor.CurrentPos)
		local leftchar = editor:textrange(word_start-1, word_start)
		-- ���� ����� �� ������ ����� ��-���� �����������, �� ���������� ������ ������: �������/���������.
		-- �.�., ���� ������������ ������, �� ��� ��������� ����������� OnChar �� �����������.
		return autocomplete_start_characters:find(leftchar, 1, 1) and editor:AutoCActive()
	end

	-- ������� �� �� ������ ��� ��������� ������ - ������ ��� �����������!
	sep_char = char
	auto_start_chars_patt = fPattern(autocomplete_start_characters)

	if get_api then
		CreateAPITable()
		CreateObjectsAndAliasTables()
	end
	-- ���� � api_table ����� - �������.
	if not next(api_table) then return false end

	FindDeclaration()

	-- �����: ���������� ������ ������� ������� (����� "string.b|[Enter]" ������������ � "string.bbyte")
	current_pos = editor.CurrentPos

	-- ����� � �������� ������� ����� ����� �� �������, ��������� current_pos �� ������ ����� ����� �� �������.
	local input_object = GetInputObject(autocomplete_start_characters)

	-- ���� ����� �� ������� ����������� �����, ������� ����� ����������� ��� ��� �������, �� �������
	if input_object == '' then return false end

	object_names, object_good_name = GetObjectNames(input_object)

	if object_good_name and input_object ~= object_good_name then
		CorrectRegisterSymbols(object_good_name..char)
	end
	if not next(object_names) then return false end

	-- ������� ������� ������ �������, ��������� ������
	methods_table = {}
	for i = 1, #object_names do
		CreateMethodsTable(object_names[i])
	end
	methods_table = TableSort(methods_table)
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
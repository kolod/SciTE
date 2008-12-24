--[[--------------------------------------------------
abbrevlist.lua
Authors: Dmitry Maslov, frs, mozers�
version 2.0
------------------------------------------------------
  ���� ��� ������� ����������� ������������ (Ctrl+B) �� ������� ������� ������������,
  �� ��������� ������ ������������ ������������ � ���� ���������� ��������.
  �������� �������������� ����� ������ (��������� ������ ��� ������� �� Ctrl+B).
  �� ���������� ���������� abbrev.lexer.auto=1, ��� lexer - ��� ��������������� �������.
  �����������:
    � ���� SciTEStartup.lua �������� ������:
    dofile (props["SciteDefaultHome"].."\\tools\\abbrevlist.lua")
--]]--------------------------------------------------

local table_expansions = {}   -- ������ ������ ����������� � ����������� � ���
local get_abbrev = true       -- ������� ����, ��� ���� ������ ���� �����������
local abbrev = ''             -- ���������� ������������
local event_IDM_ABBREV = true -- �������, ��������� ������������ ������� (IDM_ABBREV ��� OnChar)
local sep = '�'               -- ����������� ��� ������ ��������������� ������
local typeUserList = 11       -- ������������� ��������������� ������

-- ������ ���� �� ������ abbrev � ������� table_expansions
local function ReadAbbrevFile(file)
	local abbrev_file = io.open(file)
	if abbrev_file then
		for line in abbrev_file:lines() do
			if #line ~= 0 then
				local _abr, _exp = line:match('^([^#].-)=(.+)')
				if _abr ~= nil then
					table_expansions[#table_expansions+1] = {_abr, _exp}
				else
					local import_file = line:match('^import%s+(.+)')
					-- ���� ���������� ������ import �� ���������� �������� ��� �� �������
					if import_file ~= nil then
						ReadAbbrevFile(file:match('.+\\')..import_file)
					end
				end
			end
		end
		abbrev_file:close()
	end
end

-- ������ ��� ������������ ����� abbrev � ������� table_expansions
local function CreateExpansionList()
	table_expansions = {}
	local abbrev_filename = props["AbbrevPath"]
	if #abbrev_filename == 0 then return end
	ReadAbbrevFile(abbrev_filename)
end

-- ������� �������������� ������ �� �����������, ��������������� ��������� ������������
local function ShowExpansionList()
	-- ������� ������������
	local abbr_end = editor.SelectionStart
	local line_start_pos = editor:PositionFromLine(editor:LineFromPosition(abbr_end))
	abbrev = editor:textrange(line_start_pos, abbr_end):match('[^ #]*$')

	-- ���� ����� ������������ ������ 2� �������� �� �������
	if #abbrev < 2 then return false end
	-- ���� �� ������������� �� ������ ����, �� ������ ������� table_expansions ������
	if get_abbrev then
		CreateExpansionList(abbrev)
		get_abbrev = false
	end
	if #table_expansions == 0 then return false end
	-- �������� �� table_expansions ������ ������ ��������������� ��������� ������������
	local table_expansions_select = {}
	local abbrev_match = '' -- ��� �������� ��������� ������������ (������������ ����, ���� ������ ������������ �������)
	for i = 1, #table_expansions do
		local abr = table_expansions[i][1]:match('^'..abbrev)
		if abr ~= nil then
			table_expansions_select[#table_expansions_select+1] = table_expansions[i][2]
			abbrev_match = table_expansions[i][1]
		end
	end
	if #table_expansions_select == 0 then return false end
	-- ���� �� ���������� Ctrl+B (� �� �������������� ������������)
	if (event_IDM_ABBREV)
		-- � ���� ������ ������������ ������� �����������
		and (#table_expansions_select == 1)
		-- � ������������ ��������� ������������ ���������
		and (abbrev == abbrev_match)
			-- �� ������� ���������� ���������� (��� ����� �������� �� ��������� ����������� ������� IDM_ABBREV)
			then return false
	end
	-- ���������� �������������� ������ �� �����������, ��������������� ��������� ������������
	local table_expansions_select_string = table.concat(table_expansions_select, sep)
	local sep_tmp = editor.AutoCSeparator
	editor.AutoCSeparator = string.byte(sep)
	editor:UserListShow(typeUserList, table_expansions_select_string)
	editor.AutoCSeparator = sep_tmp
	return true
end

-- ������� �����������, �� ��������������� ������
local function InsertExpansion(expansion)
	editor:BeginUndoAction()
	-- �������� ��������� ������������ � ����������� ���������
	local sel_start, sel_end = editor.SelectionStart - #abbrev, editor.SelectionEnd - #abbrev
	editor:remove(sel_start, editor.SelectionStart)
	editor:SetSel(sel_start, sel_end)
	-- ������� �����������
	expansion = expansion:gsub('\\r','\r'):gsub('\\n','\n'):gsub('\\t','\t')
	scite.InsertAbbreviation(expansion)
	editor:EndUndoAction()
end
------------------------------------------------------

-- Add user event handler OnMenuCommand
local old_OnMenuCommand = OnMenuCommand
function OnMenuCommand (msg, source)
	local result
	if old_OnMenuCommand then result = old_OnMenuCommand(msg, source) end
	if msg == IDM_ABBREV then
		event_IDM_ABBREV = true
		if ShowExpansionList() then return true end
	end
	return result
end

-- Add user event handler OnChar
local old_OnChar = OnChar
function OnChar(char)
	local result
	if old_OnChar then result = old_OnChar(char) end
	if tonumber(props['abbrev.'..editor.LexerLanguage..'.auto']) == 1
		or tonumber(props['abbrev.*.auto']) == 1 then
			event_IDM_ABBREV = false
			if tonumber(props['macro-recording']) ~= 1
				and ShowExpansionList() then
					return true
			end
	end
	return result
end

-- Add user event handler OnUserListSelection
local old_OnUserListSelection = OnUserListSelection
function OnUserListSelection(tp, sel_value)
	local result
	if old_OnUserListSelection then result = old_OnUserListSelection(tp,sel_value) end
	if tp == typeUserList then
		if InsertExpansion(sel_value) then return true end
	end
	return result
end

-- Add user event handler OnSwitchFile
local old_OnSwitchFile = OnSwitchFile
function OnSwitchFile(file)
	local result
	if old_OnSwitchFile then result = old_OnSwitchFile(file) end
	get_abbrev = true
	return result
end

-- Add user event handler OnOpen
local old_OnOpen = OnOpen
function OnOpen(file)
	local result
	if old_OnOpen then result = old_OnOpen(file) end
	get_abbrev = true
	return result
end

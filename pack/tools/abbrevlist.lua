--[[--------------------------------------------------
abbrevlist.lua
Authors: Dmitry Maslov, frs, mozers�
version 2.1.6
------------------------------------------------------
  ���� ��� ������� ����������� ������������ (Ctrl+B) �� ������� ������� ������������,
  �� ��������� ������ ������������ ������������ � ���� ���������� ��������.
  �������� �������������� ����� ������ (��������� ������ ��� ������� �� Ctrl+B).
  �� ���������� ���������� abbrev.lexer.auto=3,
        ��� lexer - ��� ��������������� �������,
              � 3 - min ����� �������� ������ ��� ������� ��� ����� ��������������� ��� ������������
  �����������:
    � ���� SciTEStartup.lua �������� ������:
    dofile (props["SciteDefaultHome"].."\\tools\\abbrevlist.lua")

------------------------------------------------------
History:
2.1 (mozers)
	* ��� ����� �������� ? * �������� ������ ���� ��������� �����������
	* ������ ��� ������ ������ ������ ���������� ������� ��������� ������������
	* ���������� ���������� ��������� ��� ������������� ������������ (�.�. ������� ������� � # ����������� ������ � �� ������)
	* �������� abbrev.lexer.auto ������ ������ min ����� �������� ������ ��� ������� ��� ����� ��������������� ��� ������������

--]]--------------------------------------------------

local table_expansions = {}   -- ������ ������ ����������� � ����������� � ���
local get_abbrev = true       -- ������� ����, ��� ���� ������ ���� �����������
local abbrev = ''             -- ���������� ������������
local chars_count_min = 0     -- min ����� ��������� ������ ��� ������� ��� ����� ���������������
local event_IDM_ABBREV = true -- �������, ��������� ������������ ������� (IDM_ABBREV ��� OnChar)
local sep = '�'               -- ����������� ��� ������ ��������������� ������
local typeUserList = 11       -- ������������� ��������������� ������

-- ������ ���� �� ������ abbrev � ������� table_expansions
local function ReadAbbrevFile(file)
	local abbrev_file = io.open(file)
	if abbrev_file then
		for line in abbrev_file:lines() do
			if line ~= '' then
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
	if abbrev_filename == '' then return end
	ReadAbbrevFile(abbrev_filename)
end

-- ������� �������������� ������ �� �����������, ��������������� ��������� ������������
local function ShowExpansionList()
	-- ������� ������������
	local abbr_end = editor.SelectionStart
	local line_start_pos = editor:PositionFromLine(editor:LineFromPosition(abbr_end))
	abbrev = editor:textrange(line_start_pos, abbr_end):reverse():match('^.?[^#%s]+')
	if abbrev == nil then return false end
	abbrev = abbrev:reverse()

	-- ���� ����� ������������ ������ ��������� ���-�� �������� �� �������
	if #abbrev < chars_count_min then return false end
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
		local _isfind = table_expansions[i][1]:upper():find(abbrev:upper(), 1, true)
		if _isfind == 1 then
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
	scite.InsertAbbreviation(expansion)
	editor:EndUndoAction()
end
------------------------------------------------------

AddEventHandler("OnMenuCommand", function(msg, source)
	if msg == IDM_ABBREV then
		event_IDM_ABBREV = true
		return ShowExpansionList()
	end
end)

AddEventHandler("OnChar", function(char)
	chars_count_min = tonumber(props['abbrev.'..props['Language']..'.auto']) or 0
	if chars_count_min == 0 then chars_count_min = tonumber(props['abbrev.*.auto']) or 0 end
	if chars_count_min ~= 0 then
		event_IDM_ABBREV = false
		if tonumber(props['macro-recording']) ~= 1 then
			return ShowExpansionList()
		end
	end
end)

AddEventHandler("OnUserListSelection", function(tp, sel_value)
	if tp == typeUserList then
		InsertExpansion(sel_value)
	end
end)

AddEventHandler("OnSwitchFile", function(file)
	get_abbrev = true
end)

AddEventHandler("OnOpen", function(file)
	get_abbrev = true
end)

--[[--------------------------------------------------
abbrevlist.lua
Authors: Dmitry Maslov, frs, mozers�, Tymur Gubayev
version 3.4.2
------------------------------------------------------
  ���� ��� ������� ����������� ������������ (Ctrl+B) �� ������� ������� ������������,
  �� ��������� ������ ������������ ������������ � ���� ���������� ��������.
  �������� �������������� ����� ������ (��������� ������ ��� ������� �� Ctrl+B).
  �� ���������� ���������� abbrev.lexer.auto=3,
        ��� lexer - ��� ���������������� �������,
              � 3 - min ����� ��������� ������ ��� ������� ��� ����� ��������������� ��� ������������

  ���� � ����������� ������������ ������ ��������� ��������� �����, �� ����� ������� ����������� ������ ��������������� �� ������ �� ���.
  �� ��� ��������� ��������������� ��������� �����, ������� �� ������� �������������� �������� Tab.
  ��� ��������� ��������� abbrev.multitab.clear.manual=1 ������ �� ������� ����� ����������� ����� ����������� �� ��� �� Tab. �� ������������ ������� ������� ����������� Ctrl+Tab.
  �������� abbrev.multitab.indic.style=#FF6600,diagonal ��������� ���������� ����� ����������� �������� ������ (�������� �������� ��� �� ��� � ���������� indic.style.number)
  ��������� ��������� abbrev.lexer.ignore.comment=1 ��������� ������� ������������ ������ ����������� � ������ ����������� ��� ��������� �������� (�.�. ��� ������������������ ������ ����� �������������� ��� ������� ������������ � ��������� �������� #)
  ���������� abbrev.list.width ����� ������ ������������ ������ ��������������� ������ ����������� ����������� (� ��������)

  ��������������:
  ���������� ������� SciTE (Ctrl+B, Ctrl+Shift+R), ������� �������� ������, �������� ���������� �����!
  ������� ����� ���������� �� ������������� SciTE �������� ������������� ����������.

  �����������:
    � ���� SciTEStartup.lua �������� ������:
    dofile (props["SciteDefaultHome"].."\\tools\\abbrevlist.lua")
------------------------------------------------------
History:
2.1 (mozers)
	* ��� ����� �������� ? * �������� ������ ���� ��������� �����������
	* ������ ��� ������ ������ ������ ���������� ������� ��������� ������������
	* ���������� ���������� ��������� ��� ������������� ������������ (�.�. ������� ������� � # ����������� ������ � �� ������)
	* �������� abbrev.lexer.auto ������ ������ min ����� ��������� ������ ��� ������� ��� ����� ��������������� ��� ������������
3.2 (Tymur, mozers)
	+ ��������� ����������� �������� �������� � ������������ ����� �� TAB (Issue 240)
	+ ��������� ��������� �������������� �����
3.3 (mozers)
	* ��������� ��������� r1610 (�����:Neo) ���������� ������ �� �������� "������������" (��� UserList) �����������
3.4 (mozers, Tymur)
	* ������������� ��������� ����� �� ����������� ������� ��� ����������� ������(�.�. `(`,`[` ��� `{`) � �� ������ ��������� (��� �� �������).
	- ��������� ��� � ��������� ������ �������� ����� �� ������ ������������.
	+ ��������� ����� ��������� `abbrev.list.width` ��� �������� ������������ ������ ��������������� ������ ����������� �����������.
--]]--------------------------------------------------

local table_abbr_exp = {}     -- ������ ������ ����������� � ����������� � ���
local table_user_list = {}    -- ������ ���������� � �������� ������ ����������� � ����������� � ���
local get_abbrev = true       -- ������� ����, ��� ���� ������ ���� �����������
local chars_count_min = 0     -- min ����� ��������� ������ ��� ������� ��� ����� ���������������
local sep = '�'               -- ����������� ��� ������ ��������������� ������
local typeUserList = 11       -- ������������� ��������������� ������
local smart_tab = 0           -- ���-�� �������������� ������� ��������� (��������� ��������)
local cr = string.char(1)     -- ������ ��� ��������� ������� ����� ������� |
local clearmanual = tonumber(props['abbrev.multitab.clear.manual']) == 1
local abbrev_length = 0       -- ����� ������������

-- ���������� ����� ���������� ������� � ����������� ��� ������� "���������"
local function SetHiddenMarker()
	for indic_number = 0, 31 do
		local mark = props["indic.style."..indic_number]
		if mark == "" then
			local indic_style = props["abbrev.multitab.indic.style"]
			if indic_style == '' then
				props["indic.style."..indic_number] = "hidden"
			else
				props["indic.style."..indic_number] = indic_style
			end
			return indic_number
		end
	end
end
local num_hidden_indic = SetHiddenMarker()   -- ����� ������� ������� ������� (��� ������ �� TAB)

-- ������ ���� ������������ abbrev-������ � ������� table_abbr_exp
local function CreateExpansionList()
	-- ������ ������ �� abbrev-������
	local function ReadAbbrevFile(file)
		local abbrev_file = io.open(file)
		if abbrev_file then
			local ignorecomment = tonumber(props['abbrev.'..props['Language']..'.ignore.comment'])==1
			for line in abbrev_file:lines() do
				if line ~= '' and (ignorecomment or line:sub(1,1) ~= '#' ) then
					local _abr, _exp = line:match('^(.-)=(.+)')
					if _abr then
						table_abbr_exp[#table_abbr_exp+1] = {_abr:upper(), _exp}
					else
						local import_file = line:match('^import%s+(.+)')
						-- ���� ���������� ������ import �� ���������� �������� ��� �� �������
						if import_file then
							ReadAbbrevFile(file:match('.+\\')..import_file)
						end
					end
				end
			end
			abbrev_file:close()
		end
	end

	table_abbr_exp = {}
	local abbrev_filename = props["AbbrevPath"]
	if abbrev_filename == '' then return end
	ReadAbbrevFile(abbrev_filename)
end

-- ������� �����������, �� ��������������� ������
local function InsertExpansion(expansion, abbrev_length)
	if not abbrev_length then abbrev_length = 0 end
	editor:BeginUndoAction()
	-- �������� ��������� ������������ � ����������� ���������
	local sel_start, sel_end = editor.SelectionStart - abbrev_length, editor.SelectionEnd - abbrev_length
	if abbrev_length > 0 then
		editor:remove(sel_start, editor.SelectionStart)
		editor:SetSel(sel_start, sel_end)
		abbrev_length = 0
	end
	-- ������� ����������� c ������� ���� ����� ������� | (����� ������) �� ������ cr
	expansion = expansion:gsub("|", cr):gsub(cr..cr, "|"):gsub(cr, "|", 1)
	local _, tab_count = expansion:gsub(cr, cr) -- ���������� ���-�� �������������� ����� �������
	local before_length = editor.Length
	scite.InsertAbbreviation(expansion)
	--------------------------------------------------
	if tab_count>0 then -- ���� ���� �������������� ����� �������
		local start_pos = editor.CurrentPos
		local end_pos = sel_end + editor.Length - before_length
		if clearmanual then
			EditorMarkText(start_pos-1, 1, num_hidden_indic)
		else
			EditorClearMarks(num_hidden_indic) -- ���� �� ���������� ������� �������� ������� (������������ �������� �� ��� ����) �� ������� ��
		end

		repeat -- ������� ������� # �� �����������, ����� ������ ��� ��������� �������
			local tab_start = editor:findtext(cr, 0, end_pos, start_pos)
			if not tab_start then break end
			editor:GotoPos(tab_start+1)  editor:DeleteBack()
			EditorMarkText(tab_start-1, 1, num_hidden_indic)
			end_pos = tab_start-1
		until false

		editor:GotoPos(start_pos)
		smart_tab = tab_count -- ��������� ������ ��������� ������� �� TAB (�� ������� OnKey)
	end
	--------------------------------------------------
	editor:EndUndoAction()
end
-- export global
scite_InsertAbbreviation = InsertExpansion

-- ����� ������ �� �����������, ��������������� ��������� ������������
local function ShowExpansionList(event_IDM_ABBREV)
	local sel_start = editor.SelectionStart
	local line_start_pos = editor:PositionFromLine(editor:LineFromPosition(sel_start))
	-- ���� ������ ���������� - ������ ���������� ������
	local abbrev_start = editor:findtext('[\\s\\(\\[\\{\\<]', SCFIND_REGEXP, sel_start, line_start_pos)
	abbrev_start = abbrev_start and abbrev_start+1 or line_start_pos
	-- � html �������� ����� ������� � �������� � ������������ ������� ������-����������� < ��� (
	-- (�� ����� ��� �������� �������� ����� ������������� �� ������ �����)
	if props['Language'] == 'hypertext' then
		local prev_char = editor:textrange(abbrev_start-1, abbrev_start)
		if prev_char == '(' or prev_char == '<' then abbrev_start = abbrev_start - 1 end
	end
	local abbrev = editor:textrange(abbrev_start, sel_start)
	abbrev_length = #abbrev
	if abbrev_length == 0 then return event_IDM_ABBREV end
	-- ���� ����� ��������� ������������ ������ ��������� ���-�� �������� �� �������
	if not event_IDM_ABBREV and abbrev_length < chars_count_min then return true end

	-- ���� �� ������������� �� ������ ����, �� ������ ������� table_abbr_exp ������
	if get_abbrev then
		CreateExpansionList()
		get_abbrev = false
	end

	if #table_abbr_exp == 0 then return event_IDM_ABBREV end
	abbrev = abbrev:upper()
	table_user_list = {}
	 -- �������� �� table_abbr_exp ������ ������ ��������������� ���� ������������
	for i = 1, #table_abbr_exp do
		if table_abbr_exp[i][1]:find(abbrev, 1, true) == 1 then
			table_user_list[#table_user_list+1] = {table_abbr_exp[i][1], table_abbr_exp[i][2]}
		end
	end
	if #table_user_list == 0 then return event_IDM_ABBREV end
	-- ���� �� ���������� Ctrl+B (� �� �������������� ������������)
	if (event_IDM_ABBREV)
		-- � ���� ������ ������������ ������� �����������
		and (#table_user_list == 1)
		-- � ������������ ��������� ������������ ���������
		and (abbrev == table_user_list[1][1])
			-- �� ������� ���������� ����������
			then
				InsertExpansion(table_user_list[1][2], abbrev_length)
				return true
	end

	-- ���������� �������������� ������ �� �����������, ��������������� ��������� ������������
	local tmp = {}
	local list_width = tonumber(props['abbrev.list.width']) or -1
	for i = 1, #table_user_list do
		tmp[#tmp+1] = table_user_list[i][2]:sub(1, list_width)
	end
	local table_user_list_string = table.concat(tmp, sep):gsub('%?', ' ')
	local sep_tmp = editor.AutoCSeparator
	editor.AutoCSeparator = string.byte(sep)
	editor:UserListShow(typeUserList, table_user_list_string)
	editor.AutoCSeparator = sep_tmp
	return true
end

------------------------------------------------------
AddEventHandler("OnMenuCommand", function(msg)
	if msg == IDM_ABBREV then
		return ShowExpansionList(true)
	end
end)

AddEventHandler("OnChar", function()
	chars_count_min = tonumber(props['abbrev.'..props['Language']..'.auto']) or tonumber(props['abbrev.*.auto']) or 0
	if chars_count_min ~= 0 then
		return ShowExpansionList(false)
	end
end)

AddEventHandler("OnKey", function(key, shift, ctrl, alt)
	if editor.Focus and smart_tab > 0 and key == 9 then -- TAB=9
		if not (shift or ctrl or alt) then
			for i = editor.CurrentPos, editor.Length do
				if editor:IndicatorValueAt(num_hidden_indic, i)==1 then
					editor:GotoPos(i+1)
					if not clearmanual then
						EditorClearMarks(num_hidden_indic, i, 1) -- ����� �������� �� ������� �������� ��������, ���� ������ �������
						smart_tab = smart_tab - 1
					end
					return true
				end
			end
		elseif ctrl and not (shift or alt) then
			EditorClearMarks(num_hidden_indic)
			smart_tab = 0
			return true
		end
	end
end)

AddEventHandler("OnUserListSelection", function(tp, sel_value, sel_item_id)
	if tp == typeUserList then
		InsertExpansion(table_user_list[sel_item_id][2], abbrev_length)
	end
end)

AddEventHandler("OnSwitchFile", function()
	get_abbrev = true
end)

AddEventHandler("OnOpen", function()
	get_abbrev = true
end)

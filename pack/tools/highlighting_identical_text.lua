--[[--------------------------------------------------
Highlighting Identical Text
Version: 1.1.1
Author: mozers�
------------------------------
���� ��������� ������, ������� ��������� � ������� ������ ��� ����������
� ����� �������� �������� ����� ���������
��������:
� ������� ������������ ������� �� COMMON.lua (EditorMarkText, EditorClearMarks, GetCurrentWord)
------------------------------
�����������:
�������� � SciTEStartup.lua ������:
	dofile (props["SciteDefaultHome"].."\\tools\\highlighting_identical_text.lua")

�������� � ���� �������� ��������:
	highlighting.identical.text=0
� ������������� � ���� Tools:
	command.checked.139.*=$(highlighting.identical.text)
	command.name.139.*=Highlighting Identical Text
	command.139.*=highlighting_identical_text_switch
	command.mode.139.*=subsystem:lua,savebefore:no

������������� ����� ������ ����� ������������� ������� (4):
	find.mark.4=#FF66FF,box

============================================================================
���� �� ������� editor:findtext �� ������ �������� ��� ������ � UTF ��������,
�� ��� ����� ���� �� ����������� �������������� (��. ������ 1.0 ����� �������).
������ ���� ����� � 2 ���� ������ � ����� ������� ���� � UTF �� �������� (������ ���������� �����) :(
============================================================================
--]]----------------------------------------------------

local table_limit = 50 -- max ���-�� ����������� ������ (�� ������������� ������� �����)
local store_pos    -- ���������� ��� �������� ����������� ������� �������
local store_text   -- ���������� ��� �������� ������������ ������
local mark_num = 4 -- ����� ������������� �������
local all_text     -- ����� �������� ���������
local chars_count  -- ���-�� �������� � ������� ���������

-- ������������� ��������� (���/����) ����������� �� ���� Tools
function highlighting_identical_text_switch()
	local prop_name = 'highlighting.identical.text'
	props[prop_name] = 1 - tonumber(props[prop_name])
	EditorClearMarks(mark_num)
end

local function IdenticalTextFinder()
	local match_table = {}
	local word_pattern

	-- ����� ����, ���������� �������� (���� ������ �� ��������)
	function WordsMatch(find_word) -- ������� �������� ��� ���������� ������ � ������� match_table
		local find_start = 1
		repeat
			local ident_word_start, ident_word_end, ident_word = all_text:find(word_pattern, find_start)
			if ident_word_start == nil then return end
			if ident_word == find_word then
				match_table[#match_table+1] = {ident_word_start-1, ident_word_end}
				if #match_table > table_limit then -- ���� ����������� ������, ��� ��������� �����, �� �� ���������� ��
					match_table = {}
					return
				end
			end
			find_start = ident_word_end + 1
		until false
	end

	-- ����� ����������� ������ (���� ������� �����)
	function TextMatch(find_text) -- ������� �������� ��� ���������� ������ � ������� match_table
		local find_start = 1
		repeat
			local ident_text_start, ident_text_end = all_text:find(find_text, find_start, true)
			if ident_text_start == nil then return end
			match_table[#match_table+1] = {ident_text_start-1, ident_text_end}
			if #match_table > table_limit then -- ���� ����������� ������, ��� ��������� �����, �� �� ���������� ��
				match_table = {}
				return
			end
			find_start = ident_text_end + 1
		until false
	end

	----------------------------------------------------------
	local current_pos = editor.CurrentPos
	if current_pos == store_pos then return end
	store_pos = current_pos

	local wholeword = false
	local cur_text = editor:GetSelText()
	if cur_text == '' then
		cur_text = GetCurrentWord()
		wholeword = true
	end
	if cur_text == store_text then return end
	store_text = cur_text

	EditorClearMarks(mark_num)
	if wholeword then
		word_pattern = '([' .. editor.WordChars .. ']+)'
		WordsMatch(cur_text)
	else
		TextMatch(cur_text)
	end
	if #match_table > 1 then
		for i = 1, #match_table do
			-- �������� ��� �����, ���� ������ �� ������� match_table
			EditorMarkText(match_table[i][1], match_table[i][2]-match_table[i][1], mark_num)
		end
	end

end

-- Add user event handler OnUpdateUI
local old_OnUpdateUI = OnUpdateUI
function OnUpdateUI ()
	local result
	if old_OnUpdateUI then result = old_OnUpdateUI() end
	if props['FileName'] ~= '' then
		if tonumber(props["highlighting.identical.text"]) == 1 then
			if editor.Length ~= chars_count then
				all_text = editor:GetText()
				chars_count = editor.Length
			end
			IdenticalTextFinder()
		end
	end
	return result
end

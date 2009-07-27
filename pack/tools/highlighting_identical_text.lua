--[[--------------------------------------------------
Highlighting Identical Text
Version: 1.0
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
--]]----------------------------------------------------

local store_pos    -- ���������� ��� �������� ����������� ������� �������
local mark_num = 4 -- ����� ������������� �������

-- ������������� ��������� (���/����) ����������� �� ���� Tools
function highlighting_identical_text_switch()
	local prop_name = 'highlighting.identical.text'
	props[prop_name] = 1 - tonumber(props[prop_name])
	EditorClearMarks(mark_num)
end

local function IdenticalTextFinder()
	local current_pos = editor.CurrentPos
	if current_pos == store_pos then return end
	store_pos = current_pos

	local match_table = {}
	function WordsMatch() -- ������� �������� ��� ���������� ������ � ������� match_table
		local cur_text = editor:GetSelText()
		local find_flags = SCFIND_MATCHCASE
		if cur_text == '' then
			cur_text = GetCurrentWord()
			find_flags = find_flags + SCFIND_WHOLEWORD
		end
		local find_start = 0
		repeat
			local eq_word_start, eq_word_end = editor:findtext(cur_text, find_flags, find_start, editor.Length)
			if eq_word_start == nil then return match_table end
			match_table[#match_table+1] = {eq_word_start, eq_word_end}
			find_start = eq_word_end + 1
		until false
	end

	EditorClearMarks(mark_num)
	WordsMatch()
	if #match_table > 1 then
		local current_mark_number = scite.SendEditor(SCI_GETINDICATORCURRENT)
		for i = 1, #match_table do
			-- �������� ��� �����, ���� ������ �� ������� match_table
			EditorMarkText(match_table[i][1], match_table[i][2]-match_table[i][1], mark_num)
		end
		scite.SendEditor(SCI_SETINDICATORCURRENT, current_mark_number)
	end

end

-- Add user event handler OnUpdateUI
local old_OnUpdateUI = OnUpdateUI
function OnUpdateUI ()
	local result
	if old_OnUpdateUI then result = old_OnUpdateUI() end
	if props['FileName'] ~= '' then
		if tonumber(props["highlighting.identical.text"]) == 1 then
			IdenticalTextFinder()
		end
	end
	return result
end

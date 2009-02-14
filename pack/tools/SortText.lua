--[[--------------------------------------------------
SortText.lua
Authors: Tugarinov Sergey & mozers�
version 2.0
------------------------------------------------------
Sorting selected lines_tbl alphabetically and vice versa
���������� ���������� ����� �� �������� � ��������

Connection:
	Set in a file .properties:
		command.name.37.*=Sorting of lines_tbl A� z / z� A
		command.37.*=dofile $(SciteDefaultHome)\tools\SortText.lua
		command.mode.37.*=subsystem:lua,savebefore:no
--]]--------------------------------------------------

local lines_tbl = {} -- ������� �� �������� ������ ������
local sort_direction_decreasing = false -- �������� ������� ����������

-- ���������� ��� ������
local function CompareTwoLines(line1, line2)
	line1 = line1:gsub('^%s*', '')
	line2 = line2:gsub('^%s*', '')
	if sort_direction_decreasing then
		return (line1:lower() > line2:lower())
	else
		return (line1:lower() < line2:lower())
	end
end

-- ������������� ���������� ����������� ���������� ��������� ��� ������ �������� ������
local function GetSortDirection()
	local prev_line = lines_tbl[1]
	for _, current_line in pairs(lines_tbl) do
		if current_line:gsub('^%s*', '') ~= prev_line:gsub('^%s*', '') then
			return not CompareTwoLines(current_line, prev_line)
		end
	end
end

local sel_text = editor:GetSelText()
local sel_start = editor.SelectionStart
local sel_end = editor.SelectionEnd
if sel_text ~= '' then
	local current_line = ''
	-- ��������� �� ������ � �������� �� � �������
	for current_line in sel_text:gmatch('[^\n]+') do
		lines_tbl[#lines_tbl+1] = current_line
	end
	if #lines_tbl > 2 then
		sort_direction_decreasing = GetSortDirection()
		-- ��������� ������ � �������
		table.sort(lines_tbl, CompareTwoLines)
		-- ��������� ��� ������ �� ������� ������
		local out_text = table.concat(lines_tbl, '\n')..'\n'
		editor:ReplaceSel(out_text)
	end
end
-- ��������������� ���������
editor:SetSel(sel_start, sel_end)
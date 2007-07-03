-- ������� ������������ (�,�,�,�,�) �� ��������������� ������ (��� HTML ����������� �� �����������)
-- mozers� icq#256106175
-- version 0.3
-----------------------------------------------

local char2html = {
	' ', "&nbsp;",
	'&', "&amp;",
	'"', "&quot;",
	'<', "&lt;",
	'>', "&gt;",
	'�', "&lsquo;",
	'�', "&rsquo;",
	'�', "&ldquo;",
	'�', "&rdquo;",
	'�', "&lsaquo;",
	'�', "&rsaquo;",
	'�', "&laquo;",
	'�', "&raquo;",
	'�', "&bdquo;",
	'�', "&sbquo;",
	'�', "&middot;",
	'�', "&hellip;",
	'�', "&sect;",
	'�', "&copy;",
	'�', "&reg;",
	'�', "&trade;",
	'�', "&brvbar;",
	'�', "&dagger;",
	'�', "&Dagger;",
	'�', "&not;",
	'�', "&shy;",
	'�', "&plusmn;",
	'�', "&micro;",
	'�', "&permil;",
	'�', "&deg;",
	'�', "&euro;",
	'�', "&curren;",
	'�', "&bull;",
}

local function f_char2html (char)
	function f(index,value)
		if (value == char) then
			html = char2html[index+1]
		end
	end
	table.foreachi (char2html, f)
	return html
end

local function InsertSpecialChar(sel_value)
	local pos = editor.CurrentPos
	if editor.Lexer == SCLEX_HTML then
		sel_value = f_char2html(sel_value)
	end
	editor:InsertText(pos, sel_value)
	pos = pos + string.len(sel_value)
	editor:SetSel(pos, pos)
	return true
end

function SpecialChar()
	local user_list = ''
	local sep = ';'
	local n = table.getn(char2html)
	for i = 1,n-2,2 do
		user_list = user_list..char2html[i]..sep
	end
	user_list = user_list..char2html[n-1]
	editor.AutoCSeparator = string.byte(sep)
	editor:UserListShow(12,user_list)
	editor.AutoCSeparator = string.byte(' ')
end

-- ��������� ���� ���������� ������� OnUserListSelection
local old_OnUserListSelection = OnUserListSelection
function OnUserListSelection(tp,sel_value)
	local result
	if old_OnUserListSelection then result = old_OnUserListSelection(tp,sel_value) end
	if tp == 12 then
		if InsertSpecialChar(sel_value) then return true end
	end
	return result
end
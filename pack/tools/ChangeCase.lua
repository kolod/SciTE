-- ChangeCase
-- ��������� ���������� � ��������� ����� � ������� (Ctrl+Shift+U), ������ ������� (Ctrl+U)
-- ��� ������ ��� ��������� ����������� ������� ��������
-- � ������� �� ���������� ������� ��������� �������� � ����������
-- mozers�
-------------------------------------------------------------------------
function ChangeCase(case)
	local str = editor:GetSelText()
	local res = ''
	if str ~= nil then
		for i = 1, string.len(str) do
			local strS = string.sub(str,i,i)
			local strB = string.byte(strS,1)
			if case ~= 'U' and (strB > 191 and strB < 224) then --// [�-�]
				res = res..string.char(strB + 32)
			elseif case ~= 'U' and (strB == 161 or strB == 178) then -- // � �
				res = res..string.char(strB + 1)
			elseif case ~= 'L' and (strB > 223 and strB <= 255) then --// [�-�]
				res = res..string.char(strB - 32)
			elseif case ~= 'L' and (strB == 162 or strB == 179) then -- // � �
				res = res..string.char(strB - 1)
			elseif case ~= 'U' and (strB > 64 and strB < 91) then --// [A-Z]
				res = res..string.lower(strS)
			elseif case ~= 'L' and (strB > 96 and strB < 123) then --// [a-z]
				res = res..string.upper(strS)
			else
				res = res..strS
			end
		end
	end
	local ss, se = editor.SelectionStart, editor.SelectionEnd
	editor:ReplaceSel(res)
	editor:SetSel(ss, se)
end

-- ��������� ���� ���������� �������, ����������� ��� ������ ������� ���� "upperCase" � "LowerCase"
local old_OnSendEditor = OnSendEditor
function OnSendEditor(id_msg, wp, lp)
	local result
	if old_OnSendEditor then result = old_OnSendEditor(id_msg, wp, lp) end
	if id_msg == SCI_UPPERCASE then
		if ChangeCase("U") then return true end
	elseif id_msg == SCI_LOWERCASE then
		if ChangeCase("L") then return true end
	end
	return result
end
--[[----------------------------------------------------------------------------
UTF8_check.lua
Author: VladVRO
version 1.0

�������������� ������������ ��������� � UTF-8
��� html ������ ���������� "Content-Type: text/html; charset=UTF-8"
� ��� ������ ���������� ������� �������� �������� � UTF-8 ���������

�����������:
� ���� SciTEStartup.lua �������� ������:
	dofile ("UTF8_check.lua")
� ����� �������� ��������:
	utf8.check=1

�������������:
���� ����������� ���������� ���� ������ � ����� ��������� ������ ����� � ����������:
	utf8.check.max=<���-�� ����>
��� �������� ������� ��������� ������� �� ������� �����, �� ������ �����������
����������� ����������� ���������.
--]]----------------------------------------------------------------------------

local function utf8_check ()
	if props["utf8.check"] == "1" then
		local maxpos = tonumber(props["utf8.check.max"])
		if not maxpos then maxpos = editor.Length end
		-- html content-type
		if string.find(props["file.patterns.html"], props["FileExt"]) ~= nil then
			if editor:findtext("Content-Type: text/html; charset=UTF-8", SCFIND_POSIX, 0, maxpos) then
				scite.MenuCommand(IDM_ENCODING_UCOOKIE)
				return
			end
		end
		-- by russian alphabet
		local pattern = "[��]"
		local pos = editor:findtext(pattern, SCFIND_REGEXP, 0)
		while pos do
			local c0 = editor.CharAt[pos]
			if c0 < 0 then c0 = c0 + 256 end
			local c1 = editor.CharAt[pos+1]
			if c1 < 0 then c1 = c1 + 256 end
			if (c0 == 208 and c1 >= 144 and c1 <= 175) or
				 (c0 == 209 and c1 >= 128 and c1 <= 145)
			then
				scite.MenuCommand(IDM_ENCODING_UCOOKIE)
				return
			end
			pos = editor:findtext(pattern, SCFIND_REGEXP, pos+1, maxpos)
		end
	end
end

-- Add user event handler OnOpen
local old_OnOpen = OnOpen
function OnOpen (filename)
	local result
	if old_OnOpen then result = old_OnOpen(filename) end
	
	utf8_check()
	
	return result
end

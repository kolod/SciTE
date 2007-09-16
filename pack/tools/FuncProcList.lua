-- FuncProcList.lua
-- Version: 1.2
-- mozers� , Maximka (�������� ��������� ALeXkRU ��� �������� ������������ mimir)
-- ������������ ����: Grisper � gansA
---------------------------------------------------
-- ����� ������ ������� / ��������, ��������� � ����
-- ��� ����������� �������� � ���� ���� .properties ��������� ������:
--   command.name.17.*=List of Functions / Procedures
--   command.17.*=dofile $(SciteDefaultHome)\tools\FuncProcList.lua 
--   command.mode.17.*=subsystem:lua,savebefore:no
--   command.shortcut.17.*=Alt+Shift+F
---------------------------------------------------

local function IsComment(pos)
	local style = editor.StyleAt[pos]
	local lexer = editor.LexerLanguage
	local comment = ""
	if     lexer == 'cpp' then comment = "1,2,3"
	elseif lexer == 'lua' then comment = "1,2,3"
	elseif lexer == 'sql' then comment = "1,2,3"
	elseif lexer == 'pascal' then comment = "1,2,3"
	elseif lexer == 'ruby' then comment = "2"
	elseif lexer == 'perl' then comment = "2"
	elseif lexer == 'hypertext' then comment = "9,42,43,44,57,58,59,72,82,92,107,124,125"
	elseif lexer == 'xml' then comment = "9,29"
	elseif lexer == 'css' then comment = "9"
	else comment = "1"
	end
	if string.find(comment, '[^%d]'..style..'[^%d]') ~= nil then return true end
	return false
end

-- �������� ��� ������ ������ ���������������� (�������������, ����������)
-- ����� ���� �������� �� <mozers@mail.ru>
local findRegExp = {
--~ 	['cxx']="\n[^,.<>=\n]-([^%s,.<>=\n]+[(][^.<>=\n)]-[)])%s-%b{}",
	['cxx']="([^.,<>=\n]-[ :][^.,<>=\n%s]+[(][^.<>=)]-[)])[%s\/}]-%b{}",
	  ['h']="([^.,<>=\n]-[ :][^.,<>=\n%s]+[(][^.<>=)]-[)])[%s\/}]-%b{}",
	['js']="(\n[^,<>\n]-function[^(]-%b())[^{]-%b{}",
	['vbs']="(\n[SsFf][Uu][BbNn][^\r]-)\r",
	['css']="([%w.#-_]+)[%s}]-%b{}",
	['pas']="\nprocedure[^ ]* ([^(]*%b());"
}
local findPattern = findRegExp [props["FileExt"]]
if findPattern == nil then
-- ������������� ������� ��� ���� ��������� ������ ����������������
	findPattern = "\n[local ]*[SsFf][Uu][BbNn][^ ]* ([^(]*%b())"
end

-- ������ - ��������� ����� �������� �������� �� ����� ������
--~ editor:MarkerDeleteAll(1)
local textAll = editor:GetText()
local startPos, endPos, findString
local count = 0
startPos = 1
print("> ������ ������� / ��������:")
while true do
	startPos, endPos, findString = string.find(textAll, findPattern, startPos)
	if startPos == nil then break end
	-- ������� �������� ����� � ������ �������
	findString = string.gsub (findString, "\r\n", "")
	findString = string.gsub (findString, "%s+", " ")
	-- ���� ������� �� ����������������, �� ������� �� � ������
	if not IsComment(startPos) then
		local line = editor:LineFromPosition(startPos)
		--~ editor:MarkerAdd(line,1)
		print(props['FileNameExt']..':'..(line+1)..':\t'..findString) 
		count = count + 1
	end
	startPos = endPos + 1
end
if count > 0 then
	trace("> �������: "..count.." ������� / ��������\n������� ������ �� ������ � ����������� ��������� ������ �� ������������ ������")
else
	trace("> ������� / �������� �� �������!")
end

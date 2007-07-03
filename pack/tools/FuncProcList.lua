-- ����� ������ ������� / ��������, ��������� � ����
-- mozers� , Maximka (�������� ��������� ALeXkRU ��� �������� ������������ mimir)
-- ������������ ����: Grisper � gansA
-----------------------------------------------------------------------

local function IsComment(pos)
	local style = editor.StyleAt[pos]
	local ext = props["FileExt"]
	if ext == 'css' then
		if style == 9 then return true end
	else
		if (style >= 1 and style <= 3) then return true end
	end
end

-- �������� ��� ������ ������ ���������������� (�������������, ����������)
-- ����� ���� �������� �� <mozers@mail.ru>
local findRegExp = {
--~ 	['cxx']="\n[^,.<>=\n]-([^%s,.<>=\n]+[(][^.<>=\n)]-[)])%s-%b{}",
	['cxx']="([^.,<>=\n]-[ :][^.,<>=\n%s]+[(][^.<>=)]-[)])[%s\/}]-%b{}",
	  ['h']="([^.,<>=\n]-[ :][^.,<>=\n%s]+[(][^.<>=)]-[)])[%s\/}]-%b{}",
	['js']="(\n[^,<>\n]-function[^(]-%b())[^{]-%b{}",
	['css']="([%w.#-_]+)[%s}]-%b{}",
	['pas']="\nprocedure[^ ]* ([^(]*%b());"
}
local findPattern = findRegExp [props["FileExt"]]
if findPattern == nil then
-- ������������� ������� ��� ���� ��������� ������ ����������������
	findPattern = "\n[local ]*[SsFf][Uu][BbNn][^ ]* ([^(]*%b())"
end

-- ������ - ��������� ����� �������� �������� �� ����� ������
editor:MarkerDeleteAll(1)
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
		editor:MarkerAdd(line,1)
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

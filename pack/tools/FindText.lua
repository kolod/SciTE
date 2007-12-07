-- FindText v6.0
-- �����: ��������� <http://forum.ruteam.ru/index.php?action=vthread&forum=22&topic=175>
-- �������������: mozers�, mimir, �������
-- ����� ����������� � ���� ��������� (��� �������) ������ � ������� ���������� ��� ����� � �������

-- ��� ����������� �������� � ���� ���� .properties ��������� ������:
--    command.name.22.*=����� ������
--    command.22.*=dofile $(SciteDefaultHome)\tools\FindText.lua
--    command.mode.22.*=subsystem:lua,savebefore:no
-----------------------------------------------

local function RemoveFindMarks()
	scite.SendEditor(SCI_SETINDICATORCURRENT, INDIC_CONTAINER)
	scite.SendEditor(SCI_INDICATORCLEARRANGE, 0, editor.Length)
end

local function MarkText(start, length)
	scite.SendEditor(SCI_INDICATORFILLRANGE, start, length)
end

local sText = props['CurrentSelection']
local flag = 0
if (sText == '') then
	sText = props['CurrentWord']
	flag = SCFIND_WHOLEWORD
end
if string.len(sText) > 0 then
	editor:MarkerDeleteAll(1)
	RemoveFindMarks()
	if flag == SCFIND_WHOLEWORD then
		print('> ����� �����: "'..sText..'"')
	else
		print('> ����� ������: "'..sText..'"')
	end
	local s,e = editor:findtext(sText,flag,0)
	local count = 0
	if(s~=nil)then
		local m = editor:LineFromPosition(s) - 1
		while s do
			local l = editor:LineFromPosition(s)
			MarkText(s, e-s)
			count = count + 1
			if l ~= m then
				local str = string.gsub(' '..editor:GetLine(l),'%s+',' ')
				editor:MarkerAdd(l,1)
				print(props['FileNameExt']..':'..(l + 1)..':\t'..str)
				m = l
			end
			s,e = editor:findtext(sText,flag,e+1)
		end
		print('> �������: '..count..' ���������\n������� ������ �� ������ � ����������� ��������� ������ �� ������������ ������')
	else
		print('> ��������� ['..sText..'] �� �������!')
	end
else
	editor:MarkerDeleteAll(1)
	RemoveFindMarks()
	print('> ������� �������� � ��������� �����, ������� ���������� �����! (����� ������)\n> ����� ������ ���������� ������ �� ������ ����� (����� �����)\n> ��� �� ����� �������� ����� � ���� �������')
end
--~ editor:CharRight() editor:CharLeft() --������� ��������� � ��������� ������
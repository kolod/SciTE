--[[--------------------------------------------------
FindText v6.9
������: mozers�, mimir, �������, codewarlock1101

* ���� ����� ������� - ������ ���������� ���������
* ���� ����� �� ������� - ������ ������� �����
* ����� �������� ��� � ���� ��������������, ��� � � ���� �������
* ������, ���������� ���������� ������, ��������� � �������
* ����������� �� ���������� - F3 (������), Shift+F3 (�����)
* ������ ����� ����� ��������� ������� ������ �����
* ������� �� �������� ������ - Ctrl+Alt+C

��������:
� ������� ������������ ������� �� COMMON.lua (EditorMarkText, EditorClearMarks)
-----------------------------------------------
��� ����������� �������� � ���� ���� .properties ��������� ������:
    command.name.130.*=Find String/Word
    command.130.*=dofile $(SciteDefaultHome)\tools\FindText.lua
    command.mode.130.*=subsystem:lua,savebefore:no
    command.shortcut.130.*=Ctrl+Alt+F

    command.name.131.*=Clear All Marks
    command.131.*=dostring EditorClearMarks() scite.SendEditor(SCI_SETINDICATORCURRENT, 27)
    command.mode.131.*=subsystem:lua,savebefore:no
    command.shortcut.131.*=Ctrl+Alt+C

������������� ���������� ������ � ����� �������� ����� ������������ �������� (� ���� ������� ������������ 5 ��������):
    find.mark.27=#CC00FF
    find.mark.28=#0000FF
    find.mark.29=#00CC66
    find.mark.30=#CCCC00
    find.mark.31=#336600
--]]----------------------------------------------------

local sText = props['CurrentSelection']
local flag = 0
if (sText == '') then
	sText = props['CurrentWord']
	flag = SCFIND_WHOLEWORD
end
local current_mark_number = scite.SendEditor(SCI_GETINDICATORCURRENT)
if current_mark_number < 27 then current_mark_number = 27 end
if string.len(sText) > 0 then
	local msg
	if flag == SCFIND_WHOLEWORD then
		msg = '> '..scite.GetTranslation('Search for current word')..': "'
	else
		msg = '> '..scite.GetTranslation('Search for selected text')..': "'
	end
	props['lexer.errorlist.findtitle.begin'] = msg
	scite.SendOutput(SCI_SETPROPERTY, 'lexer.errorlist.findtitle.begin', msg)
	props['lexer.errorlist.findtitle.end'] = '"'
	scite.SendOutput(SCI_SETPROPERTY, 'lexer.errorlist.findtitle.end', '"')
	print(msg..sText..'"')
	local s,e = editor:findtext(sText,flag,1)
	local count = 0
	if(s~=nil)then
		local m = editor:LineFromPosition(s) - 1
		while s do
			local l = editor:LineFromPosition(s)
			EditorMarkText(s, e-s, current_mark_number)
			count = count + 1
			if l ~= m then
				local str = string.gsub(' '..editor:GetLine(l),'%s+',' ')
				print(props['FileNameExt']..':'..(l + 1)..':\t'..str)
				m = l
			end
			s,e = editor:findtext(sText,flag,e+1)
		end
		print('> '..string.gsub(scite.GetTranslation('Found: @ results'), '@', count))
		if props['findtext.no.tutorial'] ~= '1' then
			print('F3 (Shift+F3) - '..scite.GetTranslation('Jump by markers')..
				'\nF4 (Shift+F4) - '..scite.GetTranslation('Jump by lines')..
				'\nCtrl+Alt+C - '..scite.GetTranslation('Erase all markers'))
		end
	else
		print('> '..string.gsub(scite.GetTranslation("Can't find [@]!"), '@', sText))
	end
	current_mark_number = current_mark_number + 1
	if current_mark_number > 31 then current_mark_number = 27 end
	scite.SendEditor(SCI_SETINDICATORCURRENT, current_mark_number)
		-- ������������ ����������� �������� �� ���������� � ������� F3 (Shift+F3)
		if flag == SCFIND_WHOLEWORD then
			editor:GotoPos(editor:WordStartPosition(editor.CurrentPos))
		else
			editor:GotoPos(editor.SelectionStart)
		end
		scite.Perform('find:'..sText)
else
	EditorClearMarks()
	scite.SendEditor(SCI_SETINDICATORCURRENT, 27)
	print('> '..scite.GetTranslation('Select text for search! (search for selection)'))
	print('> '..scite.GetTranslation('Or put cursor on the word for search. (search for word)'))
	print('> '..scite.GetTranslation('You can also select text in console.'))
end
--~ editor:CharRight() editor:CharLeft() --������� ��������� � ��������� ������

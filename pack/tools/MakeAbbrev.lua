-- MakeAbbrev.lua
-- Version: 1.1
-- Autor: frs
-- http://forum.ru-board.com/topic.cgi?forum=5&topic=3215&start=1940#15
---------------------------------------------------
-- add selected text to SciTE Abbreviation, enter the abbreviature in a dialog
-- ��������� ���������� ����� � ������������ ������� �����, ������ ������������ ����� � ���������� ����
---------------------------------------------------
-- ��� ����������� �������� � ���� ���� .properties ��������� ������:
--  command.parent.96=9
--  command.name.96.*=Add to Abbreviation
--  command.96.*=dofile $(SciteDefaultHome)\tools\MakeAbbrev.lua
--  command.mode.96.*=subsystem:lua,savebefore:no
---------------------------------------------------
-- ������ ���������:
-- ���� ������������ ��������� � ������ �������� ������� � ����������� .abbrev � ����������� \abbrev.
-- ��� ������ � ��� ��� ���������� ��������� ����������. ��������, ���:
--   abbreviations.*.html;*.htm;*.asp;*.shtml=$(SciteDefaultHome)\abbrev\hypertext.abbrev
---------------------------------------------------
local function MakeAbbrev()
    local sel_text = editor:GetSelText()
    if string.len(sel_text)>=10 then --��������� ������� ����� ������ ��� ������������
        local x1,x2=string.find(sel_text,"%w+%S")
        if x1 and x2 then
            local key=string.sub(sel_text,x1,x2)
            props["1"] = key
            if scite.ShowParametersDialog("Enter abbr for code:") then
                key=props["1"]
           else
                return
            end
            sel_text=string.gsub(sel_text,"\\","\\\\")
            --~ sel_text=string.gsub(sel_text,"\r\n","\\r\\n")
            sel_text=string.gsub(sel_text,"\n","\\n")
            sel_text=string.gsub(sel_text,"\r","\\r")
            sel_text=string.gsub(sel_text,"\t","\\t")
            local file=(props["SciteDefaultHome"].."\\abbrev\\"..editor.LexerLanguage..".abbrev")
            local abb_file =io.open(file)
            if abb_file~=nil then
                abb_file:close()
                io.input(file)
                t=io.read('*a').."\r\n"
            end
            io.output(file)
            if t==nil then t="" end
            io.write(t..key.."="..sel_text)
            io.close()
        end
    end
end

MakeAbbrev()
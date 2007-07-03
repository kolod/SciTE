-- ������ ��������
-- �����: ��������� ������ / ����: 25.04.2006
-- ������ ������ ��������� �������� ������ �������� "TODO, FIXME, BUG" ��� �������� �����. �������� �������� ������������� �� ������ ������� � ���� �������.
-----------------------------------------------

--~ ������ ������� ��������
local find_table = { "@BUG:", "@FIXME:", "@TODO:" }
--~ ������� �������� ���������� ��������
local remove_comment = { "//", "*" }
local flag = 0

function TrimString (sss)
    -- ������� ������� ������� � ������ ������
    local str1 = sss
    -- ������� ������� �������
    while string.find(str1,"  ") do str1 = string.gsub(str1,"  "," ") end
    -- ������� ������� � ������ ������
    while (string.sub (str1,1,1)==" ") and (string.len(str1)>1) do str1 = string.sub(str1, 2) end
    return str1
end

function SkipSubStrings (ss)
    --~ ������� �� ������ ������� ��������
    local ss1 = ss
    for i,v in pairs (find_table) do
        ss1 = string.gsub(ss1,v," ")
    end

    --~ ������� ������� ���������� ��������
    for i,v in pairs (remove_comment) do
        ss1 = string.gsub(ss1,v," ")
    end
    ss1 = TrimString (ss1)

    return ss1
end


--~ output:ClearAll()
local count = 0
trace(">������ ��������:\n")
trace("������  ��� � �������� ���������\n")
for i,v in pairs (find_table) do
    local s,e = editor:findtext(v, flag, 0)
    if(s ~= nil)
    then
        local m = editor:LineFromPosition(s) - 1
        while s do
            local l = editor:LineFromPosition(s)
            if (l ~= m)
            then
                count = count + 1
                local str = string.gsub(" "..editor:GetLine(l), "%s+", " ")
                trace(":"..(l + 1)..":\t"..v.."\t"..SkipSubStrings(str).."\n")
                m = l
            end
            s,e = editor:findtext(v, flag, e+1)
        end
    else
        trace("> "..v.." �� �������!\n")
    end
end
trace("������� "..count.." ��������\n")
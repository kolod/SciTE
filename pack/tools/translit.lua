-- ������ translit.lua ������������ ��� �������������� ���������� ���� � �������
-- Version: 1.01
-- Autor: HSolo
-- ����������� ����� ������� ������� �������:
---------------------------------------------------------------------------------
--~ command.name.84.*=Translitiration
--~ command.84.*=dofile $(SciteDefaultHome)\tools\translit.lua
--~ command.mode.84.*=subsystem:lua,savebefore:no
--~ command.shortcut.84.*=Alt+T
---------------------------------------------------
local translit = {['shh']="�",
  ['jo']="�", ['yo']="�", ['zh']="�", ['ii']="�", ['jj']="�", ['sh']="�",
  ['ch']="�", ['je']="�", ['ju']="�", ['yu']="�", ['ja']="�", ['ya']="�",
  ['a'] ="�", ['b'] ="�", ['v'] ="�", ['w'] ="�", ['g'] ="�",
  ['d'] ="�", ['e'] ="�", ['z'] ="�", ['i'] ="�", ['j'] ="�",
  ['k'] ="�", ['l'] ="�", ['m'] ="�", ['n'] ="�", ['o'] ="�", ['~']="�",
  ['p'] ="�", ['r'] ="�", ['s'] ="�", ['t'] ="�", ['u'] ="�", ['\"']="�",
  ['f'] ="�", ['h'] ="�", ['x'] ="�", ['c'] ="�", ['y'] ="�", ['\'']="�",
  ['Shh']="�",
  ['Jo']="�", ['Yo']="�", ['Zh']="�", ['Ii']="�", ['Jj']="�", ['Sh']="�",
  ['Ch']="�", ['Je']="�", ['Ju']="�", ['Yu']="�", ['Ja']="�", ['Ya']="�",
  ['A'] ="�", ['B'] ="�", ['V'] ="�", ['W'] ="�", ['G'] ="�",
  ['D'] ="�", ['E'] ="�", ['Z'] ="�", ['I'] ="�", ['J'] ="�",
  ['K'] ="�", ['L'] ="�", ['M'] ="�", ['N'] ="�", ['O'] ="�",
  ['P'] ="�", ['R'] ="�", ['S'] ="�", ['T'] ="�", ['U'] ="�",
  ['F'] ="�", ['H'] ="�", ['X'] ="�", ['C'] ="�", ['Y'] ="�"
  }

local function TranslitIT(s)
  local pos = 1
  local outstr = ""
  local res
  local toFind

  if string.len(s) == 0 then
    return outstr
  end

  while (pos <= string.len(s)) do
    for i = 3, 1, -1 do
      toFind = string.sub(s, pos, pos + i - 1)
      res = translit[toFind]
      if res ~= nil then
        outstr = outstr..res
        pos = pos + string.len(toFind)
        break
      end
    end
    if res == nil then
      outstr = outstr..toFind
      pos = pos + 1
    end
  end
  return outstr
end

local str = props['CurrentSelection']
if (str == '') then
    str = editor:GetSelText()
end
if (str == '') then
  str = editor:GetCurLine()
end

local result = TranslitIT(str)
editor:CharRight()
editor:LineEnd()
local sel_start = editor.SelectionStart + 1
local sel_end = sel_start + string.len(result)
editor:AddText('\n'..result)
editor:SetSel(sel_start, sel_end)
print(result)
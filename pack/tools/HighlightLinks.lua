--[[----------------------------------------------------------------------------
HighlightLinks v1.3
�����: VladVRO

��������� ������ � ������ � �������� �� � �������� ��� ����� � ������� Ctrl

��������:
������ �������� ������ � ������ SciTE-Ru.
� ������� ������������ ������� �� COMMON.lua (EditorMarkText, EditorClearMarks)
� ������� ���������� shell (shell.exec)
-----------------------------------------------

�����������:
�������� � SciTEStartup.lua ������:
  dofile (props["SciteDefaultHome"].."\\tools\\HighlightLinks.lua")
���������:
������� ����� ����:
  command.name.137.*=Highlight Links
  command.137.*=HighlightLinks
  command.mode.137.*=subsystem:lua,savebefore:no
������ ����� ������� ��� ��������� �����:
  find.mark.3=#0000FF,plain
������ ����� ��� ������� ��� �������� � ��� ���������� ����� ����� �������������
����������� ���������:
� ���� ������ ���� �������� ����� ������� (��� ������ ��� ������� ��� null)
  highlight.links.lexers=null
��� ������ ���������� ������ ����� �������:
  highlight.links.exts=txt,htm
--]]----------------------------------------------------------------------------

local mark_number = 3
local link_mask = "https*://[^ \t\r\n\"\']+"
-- local link_mask = "https?://[%w_&%%%?%.%-%$%+%*]+"

function HighlightLinks()
	EditorClearMarks(mark_number)
	local flag = SCFIND_REGEXP
	local s,e = editor:findtext(link_mask, flag, 1)
	while s do
		EditorMarkText(s, e-s, mark_number)
		s,e = editor:findtext(link_mask, flag, e+1)
	end
end

local browser
local function select_highlighted_link(is_browse)
	local p = editor.CurrentPos
	if scite.SendEditor(SCI_INDICATORVALUEAT, mark_number, p) == 1 then
		local s = scite.SendEditor(SCI_INDICATORSTART, mark_number, p)
		local e = scite.SendEditor(SCI_INDICATOREND, mark_number, p)
		if s and e then
			editor:SetSel(s,e)
			if is_browse then
				browser = editor:GetSelText()
			end
			return true
		end
	end
end

local function launch_browse()
	if browser then
		shell.exec(browser)
		browser = nil
	end
end

local function auto_highlight()
	local list_lexers = props['highlight.links.lexers']
	local list_exts = props['highlight.links.exts']
	if (list_lexers ~= '' and string.find(','..list_lexers..',', ','..editor.LexerLanguage..',')) or
	   (list_exts ~= '' and string.find(','..list_exts..',', ','..props['FileExt']..','))
	then
		HighlightLinks()
	end
end

-- Add user event handler OnClick
local old_OnClick = OnClick
function OnClick(shift, ctrl, alt)
	local result
	if ctrl and editor.Focus then
		if select_highlighted_link(true) then return true end
	end
	if old_OnClick then result = old_OnClick(shift, ctrl, alt) end
	return result
end

-- Add user event handler OnMouseButtonUp
local old_OnMouseButtonUp = OnMouseButtonUp
function OnMouseButtonUp()
	local result
	if old_OnMouseButtonUp then result = old_OnMouseButtonUp() end
	launch_browse()
	return result
end

-- Add user event handler OnDoubleClick
local old_OnDoubleClick = OnDoubleClick
function OnDoubleClick(shift, ctrl, alt)
	local result
	select_highlighted_link(false)
	if old_OnDoubleClick then result = old_OnDoubleClick(shift, ctrl, alt) end
	return result
end

-- Add user event handler OnOpen
local old_OnOpen = OnOpen
function OnOpen(file)
	local result
	if old_OnOpen then result = old_OnOpen(file) end
	auto_highlight()
	return result
end

-- Add user event handler OnSave
local old_OnSave = OnSave
function OnSave(file)
	local result
	if old_OnSave then result = old_OnSave(file) end
	auto_highlight()
	return result
end

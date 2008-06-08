--[[--------------------------------------------------
CIViewer (Color Image Viewer) v1.0
�����: mozers�

* Preview of color or image under mouse cursor
* ������������ �����, ��������� ��������� � ���� "#6495ED" ��� "red" ��� ������� �� ��� URL
* ������ ������ ������ ��� ����������� ����������������� ��������� ���������� CIViewer.hta
-----------------------------------------------
��� ����������� �������� � ���� ���� .properties ��������� ������:
    command.parent.112.*=9
    command.name.112.*=Color Image Viewer
    command.112.*="$(SciteDefaultHome)\tools\CIViewer\CIViewer.hta"
    command.mode.112.*=subsystem:shellexec

�������� � SciTEStartup.lua ������
    dofile (props["SciteDefaultHome"].."\\tools\\CIViewer\\CIViewer.lua")
--]]----------------------------------------------------

local function FileExist(path)
	if (os.rename (path,path)) then
		return true
	else
		return false
	end
end

-- ���������� ����� ��� �������� ����
local function GetWText(pos, word)
	if pos==0 then return end

	-- ��������, �� �������� �� ����� ��� �������� ������ URL
	local url = ""
	if string.len(word) > 4 then
		local cur_line = editor:LineFromPosition(pos)
		local line_start_pos = editor:PositionFromLine(cur_line)
		local line_end_pos = editor:PositionFromLine(cur_line + 1) - 2
		local s, e
		repeat
			s, e = editor:findtext ('[^"|= ]+', SCFIND_REGEXP, line_start_pos, line_end_pos)
			if s == nil then break end
			line_start_pos = e + 1
		until (pos >= s and pos < e)
		if s ~= nil then
			url = props["FileDir"].."\\"..editor:textrange(s, e)
			if not FileExist(url) then
				url = ""
			end
		end
	end

	-- ��������� ��������� �������� � ����������
	-- (CIViewer.hta ����� ������������ ��������� ��� ��������)
	if url ~= "" then
		props["civiewer.value"] = "@"..url
	else
		props["civiewer.value"] = word
	end
end

-- Add user event handler OnDwellStart
local old_OnDwellStart = OnDwellStart
function OnDwellStart(pos, word)
	local result
	if old_OnDwellStart then result = old_OnDwellStart(pos, word) end
	if GetWText(pos, word) then return true end
	return result
end

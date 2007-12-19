-- SessionManager
-- �����: mozers�
-----------------------------------------------
local function LoadSession()
	os.run('mshta "'..props['SciteDefaultHome']..'\\tools\\SessionManager\\SessionManager.hta"',1,false)
end

local function SaveSession()
	os.run('mshta "'..props['SciteDefaultHome']..'\\tools\\SessionManager\\SessionManager.hta" '..props['FileName'],1,false)
end

local function SaveSessionOnQuit()
	props['save.session']=1
	os.run('mshta "'..props['SciteDefaultHome']..'\\tools\\SessionManager\\SessionManager.hta" '..'QUIT '..props['FileName'],1,false)
end

local function FileExist(path)
	if (os.rename (path,path)) then
		return true
	else
		return false
	end
end

local function SaveSessionOnQuitAuto()
	local path = ""
	local i = 0
	repeat
		local filename = props['FileName']..'_'..string.sub('0'..i, -2)
		filename = string.gsub(filename,' ','_')
		path = props['scite.userhome']..'\\'..filename..'.session'
		i = i + 1
	until not FileExist(path)
	path = string.gsub(path, '\\', '\\\\')
	scite.Perform('savesession:'..path)
end

-- ��������� ���� ���������� ������� OnMenuCommand
local old_OnMenuCommand = OnMenuCommand
function OnMenuCommand (msg, source)
	local result
	if old_OnMenuCommand then result = old_OnMenuCommand(msg, source) end
	if tonumber(props['session.manager'])==1 then
		if (msg == 140 --IDM_QUIT
		and tonumber(props['save.session.manager.on.quit'])==1) then
			if tonumber(props['save.session.on.quit.auto'])==1 then
				SaveSessionOnQuitAuto()
			else
				SaveSessionOnQuit()
			end
			return false
		elseif msg == 133 then --IDM_SAVESESSION
			SaveSession()
			return true
		elseif msg == 132 then --IDM_LOADSESSION
			LoadSession()
			return true
		end
	end
	return result
end


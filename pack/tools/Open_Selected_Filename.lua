--[[--------------------------------------------------
Open_Selected_Filename.lua
Authors: mozers™, VladVRO
Version: 1.3.1
------------------------------------------------------
Замена команды "Открыть выделенный файл"
В отличии от встроенной команды SciTE, понимающей только явно заданный путь и относительные пути
обрабатывает переменные SciTE, переменные окружения, конструкции LUA
-------------------------------------
Подключение:
Добавьте в SciTEStartup.lua строку
dofile (props["SciteDefaultHome"].."\\tools\\Open_Selected_Filename.lua")
-------------------------------------
Connection:
In file SciTEStartup.lua add a line:
dofile (props["SciteDefaultHome"].."\\tools\\Open_Selected_Filename.lua")
--]]--------------------------------------------------
require 'shell'
------------------------------------------------------
local function GetOpenFilePath(text)
	-- Example: $(SciteDefaultHome)\tools\RestoreRecent.js
	local pattern_sci = '^$[(](.-)[)]'
	local _, _, scite_var = string.find(text,pattern_sci)
	if scite_var then
		return string.gsub(text, pattern_sci, props[scite_var])
	end

	-- Example: %APPDATA%\Opera\Opera\profile\opera6.ini
	local pattern_env = '^[%%](.-)[%%]'
	local _, _, os_env = string.find(text, pattern_env)
	if os_env ~= nil then
		return string.gsub(text, pattern_env, os.getenv(os_env))
	end

	-- Example: props["SciteDefaultHome"].."\\tools\\Zoom.lua"
	local pattern_props = '^props%[%p(.-)%p%]%.%.%p(.*)%p'
	local _, _, scite_prop1, scite_prop2 = string.find(text, pattern_props)
	if scite_prop1 ~= nil then
		return props[scite_prop1]..scite_prop2
	end
end

local function GetSelText()
	local pane = editor.Focus and editor or output
	local text = pane:GetSelText()
	return text:to_utf8(editor:codepage())
end

local function OpenSelectedFilename()
	local text = GetSelText()
	if #text < 5 then return end
	local filename = GetOpenFilePath(text)
	if not filename then return end
	filename = string.gsub(filename, '\\\\', '\\')
	scite.Open (filename)
	return true
end

AddEventHandler("OnMenuCommand", function(msg, source)
	if msg == IDM_OPENSELECTED then
		return OpenSelectedFilename()
	end
end)

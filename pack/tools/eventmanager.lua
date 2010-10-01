--[[-----------------------------------------------------------------
eventmanager.lua
Authors: Tymur Gubayev
version: 1.0.0
---------------------------------------------------------------------
  Description:
	simple event manager realization for SciTE.
	exported functions (self-descriptive):
	  * AddEventHandler ( EventName, Handler[, RunOnce] )
	  * RemoveEventHandler ( EventName, Handler )
	
	���������� �������� ������� ��� SciTE
	������������ ��� ������� (��. ����)
  
  �����������:
	�� ��������� (����������� �� COMMON.lua).
  ���� �� �� �����-���� �������� ���������� ����������� �������, ��:
    � ���� SciTEStartup.lua �������� ������:
    dofile (props["SciteDefaultHome"].."\\tools\\eventmanager.lua")
	(����� ������������ ��������, ������������ AddEventHandler)

---------------------------------------------------------------------
History:
	* 1.0 initial release

--]]-----------------------------------------------------------------


local events  = {}
local _remove = {}

--- ������� �����������, ���������� ��� ��������
-- � ����� �������� ������ "� ��������"
local function RemoveAllOutstandingEventHandlers()
	for i = 1, #_remove do
		local t_rem, h_rem = events[_remove[i].EventName], _remove[i].Handler
		for j = 1, #t_rem do
			if t_rem[j]==h_rem then
				table.remove(h_rem, j)
				break -- remove only one handler instance
			end
		end
	end -- @todo: feel free to optimize this cycle
	_remove = {} -- clear it
end

--- ��������� ��������� ������� �������� /scite-ru/wiki/SciTE_Events
-- ���������� ��, ��� ������ ����������, � �� ������ ������ �������� (���� ���������)
local function Dispatch (name, ...)
	RemoveAllOutstandingEventHandlers() -- first remove all from _remove
	local event = events[name]
	local res
	for i = 1, #event do
		res = { event[i](...) } -- store whole handler return in a table
		if res[1] then -- first returned value is a interruption flag
			return unpack(res)
		end
	end
	return unpack(res) -- just for the case of error-handling
end

--- ������ ����� ���������� ��� ������ ����� ���������
-- � ������, ���� ����� ������� ��� ������� (�.�. ���� ������� ��� ������������� AddEventHandler),
-- �� ��� �������� ������ � �������
local function NewDispatcher(EventName)
	
	local dispatch = function (...) -- `shortcut`
		return Dispatch(EventName, ...)
	end
	
	-- just for the case some handler was defined in other way before
	local old_handler = _G[EventName]
	if old_handler then
		AddEventHandler(EventName, old_handler) -- @todo: can this recurse?
	end
	
	_G[EventName] = dispatch
end

--- ���������� ���������������� ���������� � ������� SciTE (��������� �� �����)
-- �������� `RunOnce` ����������, ��-��������� `false`
function AddEventHandler(EventName, Handler, RunOnce)
	local event = events[EventName]
	if not event then
		-- create new event array
		events[EventName] = {}
		event = events[EventName]
		-- register base event dispatcher
		NewDispatcher(EventName)
	end
	
	if not RunOnce then
		event[#event+1] = Handler
	else
		event[#event+1] = function(...)
			RemoveEventHandler(EventName, Handler)
			return Handler(...)
		end
	end
	
end -- AddEventHandler

--- ��������� ���������� �� �������
-- ���� ���� ���������� ��������� � ������ ������� ������, �� � ������� ��� ���� ������
function RemoveEventHandler(EventName, Handler)
	_remove[#_remove+1]={EventName=EventName, Handler=Handler}
end

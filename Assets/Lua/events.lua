--[[
Auth:Chiuan
like Unity Brocast Event System in lua.
]]

local _tostr = tostring
local str_format = string.format
local _lfse = select
local EventLib = require "eventlib"

local Event = {}
local events = {}
local _hds = {}

function Event.AddListener(event,func,obj)
	if not event then
		error("event parameter in addlistener function has to be string, " .. type(event) .. " not right.")
	end
	if not func or type(func) ~= "function" then
		error("handler parameter in addlistener function has to be function, " .. type(func) .. " not right")
	end

	event = _tostr(event)
	if not events[event] then
		--create the Event with name
		events[event] = EventLib:new(event)
	end

	--conn this handler
	local _func = func
	if obj then
		local _k = str_format("%s_%s_%s",event,func,obj)
		_func = _hds[_k] or handler(obj,func)
		_hds[_k] = _func
	end
	events[event]:connect(_func)
end

function Event.Brocast(event,...)
	event = _tostr(event)
	if events[event] then
		events[event]:fire(...)
	end
end

function Event.RemoveListener(event,func,obj)
	event = _tostr(event)
	if events[event] then
		local _func = func
		if obj then
			local _k = str_format("%s_%s_%s",event,func,obj)
			_func = _hds[_k] or func
			_hds[_k] = nil
		end
		events[event]:disconnect(_func)
	end
end

function Event.AddListeners( handler,obj,... )
	local _func = Event.AddListener
	for i = 1, _lfse( '#', ... ) do
		_func(_lfse( i, ... ),handler,obj)
	end
end

return Event
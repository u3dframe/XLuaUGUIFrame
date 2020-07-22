--[[
Auth:Chiuan
like Unity Brocast Event System in lua.
]]

local _tostr = tostring
local _lfse = select
local EventLib = require "eventlib"

local Event = {}
local events = {}

function Event.AddListener(event,handler)
	if not event then
		error("event parameter in addlistener function has to be string, " .. type(event) .. " not right.")
	end
	if not handler or type(handler) ~= "function" then
		error("handler parameter in addlistener function has to be function, " .. type(handler) .. " not right")
	end

	event = _tostr(event)
	if not events[event] then
		--create the Event with name
		events[event] = EventLib:new(event)
	end

	--conn this handler
	events[event]:connect(handler)
end

function Event.Brocast(event,...)
	event = _tostr(event)
	if events[event] then
		events[event]:fire(...)
	end
end

function Event.RemoveListener(event,handler)
	event = _tostr(event)
	if events[event] then
		events[event]:disconnect(handler)
	end
end

function Event.AddListeners( handler, ... )
	local _func = Event.AddListener
	for i = 1, _lfse( '#', ... ) do
		_func(_lfse( i, ... ),handler)
	end
end

return Event
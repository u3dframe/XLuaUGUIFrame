--[[
	-- PrefabBasic
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local super = LUComonet
local M = class( "lua_GobjLifeListener",super )

function M:ctor( obj,component )
	if true == component then
		component = CGobjLife.Get(obj)
	end
	super.ctor(self,obj,component or "GobjLifeListener")
end

return M
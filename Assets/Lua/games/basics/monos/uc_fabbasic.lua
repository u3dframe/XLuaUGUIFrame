--[[
	-- PrefabBasic
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local super = LUComonet
local M = class( "lua_PrefabBasic",super )

function M:ctor( obj,component )
	super.ctor(self,obj,component or "PrefabBasic")
end

return M
--[[
	-- PrefabElement
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local super = LuCFabBasic
local M = class( "lua_PrefabElement",super )

function M:ctor( obj )
	super.ctor(self,obj,"PrefabElement")
end

return M
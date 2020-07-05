--[[
	-- ui base 基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-05 09:25
	-- Desc : 
]]
local super = LuaFab
local M = class( "ui_base",super )

function M:ctor(assetCfg)
	super.ctor( self,assetCfg )
end

return M
--[[
	-- ugui的基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local super = LUComonet
local M = class( "ugui_base",super )

function M:ctor( gobj, component )
	super.ctor(self,gobj,component)
end

return M
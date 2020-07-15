--[[
	-- ui cell 基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-05 09:25
	-- Desc : 单元格Cell的父对象
]]

local super,super2 = LCFabElement,UIPubs
local M = class( "uicell_base",super,super2 )

function M:ctor(gobj,comp)
	super.ctor( self,gobj,comp )
	super2.ctor( self )
end

return M
--[[
	-- ui 模型对象
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-20 15:35
	-- Desc : 
]]

local LES_Object = LES_Object

local super = SceneHero
local M = class( "ui_model",super )

function M:ctor(nCursor,resCfg)
	super.ctor( self,LES_Object.UIModel,nCursor,resCfg )
end

return M
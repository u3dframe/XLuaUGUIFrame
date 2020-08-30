--[[
	-- 场景对象 - 怪兽
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local LES_Object = LES_Object

local super = SceneCreature
local M = class( "scene_monster",super )

function M:InitBase(sobjType,nCursor,resCfg)
	return super.InitBase( self,(sobjType or LES_Object.Monster),nCursor,resCfg )
end

return M
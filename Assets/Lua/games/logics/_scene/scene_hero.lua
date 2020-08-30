--[[
	-- 场景对象 - 英雄
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local LES_Object = LES_Object

local super = SceneMonster
local M = class( "scene_hero",super )

function M:InitBase(sobjType,nCursor,resCfg)
	return super.InitBase( self,(sobjType or LES_Object.Partner),nCursor,resCfg )
end

return M
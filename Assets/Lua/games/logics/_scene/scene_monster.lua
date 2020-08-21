--[[
	-- 场景对象 - 怪兽
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local LES_Object = LES_Object

local super = SceneCreature
local M = class( "scene_monster",super )

function M:ctor(objType,nCursor,...)
	objType = objType or LES_Object.Monster
	super.ctor( self,objType,nCursor,... )
end

return M
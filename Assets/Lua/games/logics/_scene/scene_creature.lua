--[[
	-- 场景对象 - 生物
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local LES_Object = LES_Object

local super = SceneObject
local M = class( "scene_creature",super )

function M:ctor(objType,nCursor,...)
	objType = objType or LES_Object.Creature
	super.ctor( objType,nCursor,... )
end

return M
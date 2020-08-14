--[[
	-- 场景对象
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local LES_Object = LES_Object

local super = SceneBase
local M = class( "scene_object",super )

function M:ctor(objType,nCursor,...)
	self:SetObjType( objType )
	self:SetCursor( nCursor )
end

function M:SetObjType(objType)
	self.objType = objType or LES_Object.Object
end

function M:SetCursor(nCursor)
	self.nCursor = nCursor
end

return M
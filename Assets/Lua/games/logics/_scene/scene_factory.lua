--[[
	-- 场景对象 - 工厂
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 创建场景对象用的
]]

local E_Object = LES_Object

local fdir = "games/logics/_scene/"
local _req = reimport or require

SceneObject = _req (fdir .. "scene_object") -- 场景对象
local SceneMap = _req (fdir .. "scene_map") -- 场景Map
SceneCreature = _req (fdir .. "scene_creature") -- 生物
SceneMonster = _req (fdir .. "scene_monster") -- 怪兽
SceneHero = _req (fdir .. "scene_hero") -- 英雄、伙伴
local UIModel = _req (fdir .. "ui_model") -- UI模型
SceneTrigger = _req (fdir .. "scene_trigger") -- 机关，陷进
local UIRawModel = _req (fdir .. "uiraw_model") -- UI RawImage 模型

objsPool:AddClassBy( SceneObject )
objsPool:AddClassBy( SceneMap )
objsPool:AddClassBy( SceneCreature )
objsPool:AddClassBy( SceneMonster )
objsPool:AddClassBy( SceneHero )
objsPool:AddClassBy( UIModel )
objsPool:AddClassBy( SceneTrigger )
objsPool:AddClassBy( UIRawModel )

local _lbCls_ = {
	[E_Object.Object]    = SceneObject,
	[E_Object.MapObj]    = SceneMap,
	[E_Object.Creature]  = SceneCreature,
	[E_Object.Monster]   = SceneMonster,
	[E_Object.Hero]      = SceneHero,
	[E_Object.UIModel]   = UIModel,
	[E_Object.Trigger]   = SceneTrigger,
	[E_Object.UIRawModel]= UIRawModel,
}

local max_cursor = 9999999
local M = {}
local this = M

function M.Init()
	this.cursor = 0
end

function M.AddCursor()
	this.cursor = this.cursor + 1
	if max_cursor < this.cursor then
		this.cursor = 1
	end
	return this.cursor
end

function M.Create(objType,resid,uuid,...)
	local _cls,_ret = _lbCls_[objType]
	if _cls then
		_ret = _cls.Builder((uuid or this.AddCursor()),resid,...)
	end
	return _ret
end

function M.CreateUIRaw(trsfParent)
	return this.Create( E_Object.UIRawModel,nil,nil,trsfParent )
end

return M
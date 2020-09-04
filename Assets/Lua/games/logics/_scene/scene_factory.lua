--[[
	-- 场景对象 - 工厂
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 创建场景对象用的
]]

local E_Object = LES_Object

local fdir = "games/logics/_scene/"
local _req = reimport or require

ClsEffect = require ("games/logics/_effects/effect_object") -- 特效

SceneObject = _req (fdir .. "scene_object") -- 场景对象
local SceneMap = _req (fdir .. "scene_map") -- 场景Map
SceneCreature = _req (fdir .. "scene_creature") -- 生物
SceneMonster = _req (fdir .. "scene_monster") -- 怪兽
SceneHero = _req (fdir .. "scene_hero") -- 英雄、伙伴
local UIModel = _req (fdir .. "ui_model") -- UI模型

objsPool:AddClassBy( ClsEffect )
objsPool:AddClassBy( SceneObject )
objsPool:AddClassBy( SceneMap )
objsPool:AddClassBy( SceneCreature )
objsPool:AddClassBy( SceneMonster )
objsPool:AddClassBy( SceneHero )
objsPool:AddClassBy( UIModel )

local _lbCls_ = {
	[E_Object.Object]    = SceneObject,
	[E_Object.MapObj]    = SceneMap,
	[E_Object.Creature]  = SceneCreature,
	[E_Object.Monster]   = SceneMonster,
	[E_Object.Hero]      = SceneHero,
	[E_Object.UIModel]   = UIModel,
}

local super,_evt = MgrBase,Event
local M = class( "scene_factory",super )
local this = M

function M.Init()
	this.cursor = 0
end

function M.AddCursor()
	this.cursor = this.cursor + 1
	return this.cursor
end

function M.Create(objType,resid,uuid)
	local _cls,_ret = _lbCls_[objType]
	if _cls then
		_ret = _cls.Builder((uuid or this.AddCursor()),resid)
	end
	return _ret
end

return M
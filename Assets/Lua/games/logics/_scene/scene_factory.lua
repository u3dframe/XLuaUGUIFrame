--[[
	-- 场景对象 - 工厂
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 创建场景对象用的
]]

local fdir = "games/logics/_scene/"
local _req = reimport or require

SceneObject = _req (fdir .. "scene_object") -- 场景对象
local SceneMap = _req (fdir .. "scene_map") -- 场景Map
SceneCreature = _req (fdir .. "scene_creature") -- 生物
SceneMonster = _req (fdir .. "scene_monster") -- 怪兽
local SceneHero = _req (fdir .. "scene_hero") -- 英雄、伙伴
    
local LES_Object = LES_Object

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

function M.GetCursor()
	return this.cursor
end

function M.Create(objType,cfgAsset)
	if objType == LES_Object.Object then
		return SceneObject.New(objType,this.AddCursor(),cfgAsset)
	elseif objType == LES_Object.MapObj then
		return SceneMap.New(this.AddCursor(),cfgAsset)
	elseif objType == LES_Object.Creature then
		return SceneCreature.New(objType,this.AddCursor(),cfgAsset)
	elseif objType == LES_Object.Monster then
		return SceneMonster.New(objType,this.AddCursor(),cfgAsset)
	elseif objType == LES_Object.Partner or objType == LES_Object.Hero then
		return SceneHero.New(objType,this.AddCursor(),cfgAsset)
	end
end

return M
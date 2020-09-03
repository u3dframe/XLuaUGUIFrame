--[[
	-- 场景对象 - 工厂
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 创建场景对象用的
]]

local fdir = "games/logics/_scene/"
local _req = reimport or require

ClsEffect = require ("games/logics/_effects/effect_object") -- 特效

SceneObject = _req (fdir .. "scene_object") -- 场景对象
local SceneMap = _req (fdir .. "scene_map") -- 场景Map
SceneCreature = _req (fdir .. "scene_creature") -- 生物
SceneMonster = _req (fdir .. "scene_monster") -- 怪兽
SceneHero = _req (fdir .. "scene_hero") -- 英雄、伙伴
UIModel = _req (fdir .. "ui_model") -- UI模型

objsPool:AddClassBy( ClsEffect )

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

function M.Create(objType,resid,uuid)
	local _cfgRes,_ret = MgrData:GetCfgRes(resid)
	if not _cfgRes then
		error("=== no res in resource config , resid = [%s]",resid)
		return
	end
	if objType == LES_Object.Object then
		_ret = SceneObject.New(objType,(uuid or this.AddCursor()),_cfgRes)
	elseif objType == LES_Object.MapObj then
		_ret = SceneMap.New((uuid or this.AddCursor()),_cfgRes)
	elseif objType == LES_Object.Creature then
		_ret = SceneCreature.New(objType,(uuid or this.AddCursor()),_cfgRes)
	elseif objType == LES_Object.Monster or objType == LES_Object.MPartner then
		_ret = SceneMonster.New(objType,(uuid or this.AddCursor()),_cfgRes)
	elseif objType == LES_Object.Hero or objType == LES_Object.Partner then
		_ret = SceneHero.New(objType,(uuid or this.AddCursor()),_cfgRes)
	elseif objType == LES_Object.UIModel then
		_ret = UIModel.New((uuid or this.AddCursor()),_cfgRes)
	end

	if _ret then _ret.resid = resid end

	return _ret
end

return M
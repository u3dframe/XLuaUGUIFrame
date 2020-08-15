--[[
	-- 场景对象 - 工厂
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 创建场景对象用的
]]

local LES_Object = LES_Object

local super,_evt = MgrBase,Event
local M = class( "scene_factory",super )
local this = M

function M.Init()
	this.cursor = 0
end

function M.ClsSObj()
    if not this._clsSObj then
        this._clsSObj = SceneObject
    end
    return this._clsSObj
end

function M.ClsSCrt()
    if not this._clsCrt then
        this._clsCrt = SceneCreature
    end
    return this._clsCrt
end

function M.ClsSMost()
    if not this._clsMost then
        this._clsMost = SceneMonster
    end
    return this._clsMost
end

function M.ClsSHero()
    if not this._clsHero then
        this._clsHero = SceneHero
    end
    return this._clsHero
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
		return this.ClsSObj().New(objType,this.AddCursor(),cfgAsset)
	elseif objType == LES_Object.Creature then
		return this.ClsSCrt().New(objType,this.AddCursor(),cfgAsset)
	elseif objType == LES_Object.Monster then
		return this.ClsSMost().New(objType,this.AddCursor(),cfgAsset)
	elseif objType == LES_Object.Partner or objType == LES_Object.Hero then
		return this.ClsSHero().New(objType,this.AddCursor(),cfgAsset)
	end
end

return M
--[[
	-- 管理 - 场景
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-13 09:25
	-- Desc : 
]]

local MgrData = MgrData
local _mgrInput,_mgrCamera,_csMgr = MgrInput,MgrCamera
local super,_evt = MgrBase,Event
local M = class( "mgr_scene",super )
local this = M

function M.Init()
	this.cursor = 0
	this.Defenses = {}
	this.Offenses = {}
	_evt.AddListener(Evt_MapLoad,this.LoadMap)
end

function M.AddCursor()
	this.cursor = this.cursor + 1
	return this.cursor
end

function M.LoadMap(mapid)
	if not mapid then return end
	if mapid == this.mapid then return end
	local _cfgMap = MgrData:GetCfgMap(mapid)
	if not _cfgMap then return end
	this.cfgMap = _cfgMap
	this.mapid = mapid

	-- 显示Loading
	_evt.Brocast(Evt_Show_Loading,0)

end

function M._ClearMap(mapid)
	if not mapid then return end
	if mapid == this.mapid then return end
	this.mapid = mapid

	-- 显示Loading
	_evt.Brocast(Evt_Show_Loading,0)

end

return M
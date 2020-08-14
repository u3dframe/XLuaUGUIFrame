--[[
	-- 管理 - 场景
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-13 09:25
	-- Desc : 
]]

local MgrData,MgrRes,SceneObject = MgrData,MgrRes,SceneObject

local _mgrInput,_mgrCamera,_csMgr = MgrInput,MgrCamera
local super,_evt = MgrBase,Event
local M = class( "mgr_scene",super )
local this = M

function M.Init()
	this.cursor = 0
	this.Defenses = {}
	this.Offenses = {}
	this:ReEvent4OnUpdate(true)
	_evt.AddListener(Evt_MapLoad,this.LoadMap)
end

function M.AddCursor()
	this.cursor = this.cursor + 1
	return this.cursor
end

function M:OnUpdate(dt)
end

function M.LoadMap(mapid)
	if not mapid then return end
	if mapid == this.mapid then return end
	local _cfgMap = MgrData:GetCfgMap(mapid)
	if not _cfgMap then return end
	local _cfgRes = MgrData:GetCfgRes(_cfgMap.resid)

	this.abname = this:ReSBegEnd( _cfgRes.rsaddress,"prefabs/",".fab" )
	this.preMapid = this.mapid
	this.mapid = mapid
	this.cfgMap = _cfgMap
	this.cfgRes = _cfgRes

	-- 显示Loading
	_evt.Brocast(Evt_Show_Loading,0,this._Loading_Begin)
end

function M._Loading_Begin()
	this:_Destroy_PreScene()
	this:_Load_CurScene()
end

function M:_Destroy_PreScene()
	if not self.lbScene then return end
	self.lbScene:OnUnLoad()
	sefl.lbScene = nil
end

function M:_Load_CurScene()
	if self.lbScene then return end
	self.lbScene = SceneObject.New({
		abName = this.cfgRes.rsaddress,
	})
	self.lbScene:View(true)
end

function M._Loading_End()
	_evt.Brocast(Evt_Hide_Loading)

	local _arrs = MgrRes.GetDependences(this.abname2)
	cs_foreach_arrs(_arrs,function(v,k) 
		printInfo("k == [%s] , v = [%s]",k,v)
	end)
end

function M._ClearMap()
end

return M
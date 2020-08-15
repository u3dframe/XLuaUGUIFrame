--[[
	-- 管理 - 场景
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-13 09:25
	-- Desc : 
]]

local mmax = math.max
local MgrData,MgrRes,SceneObject = MgrData,MgrRes,SceneObject
local LES_State = LES_State
local _mgrInput,_mgrCamera,_csMgr = MgrInput,MgrCamera

local super,_evt = MgrBase,Event
local M = class( "mgr_scene",super )
local this = M

function M.Init()
	this.cursor = 0
	this.state = LES_State.None
	this.progress = 0
	this.eveRegion = this:TF((1 / (LES_State.Complete - LES_State.Wait_Vw_Loading)),4)

	this.defenses = {}
	this.offenses = {} -- 
	this.mapObjs = {} -- [mapid] = {obj1,obj2}

	this:ReEvent4OnUpdate(true)
	_evt.AddListener(Evt_MapLoad,this.LoadMap)
end

function M.AddCursor()
	this.cursor = this.cursor + 1
	return this.cursor
end

function M:OnUpdate(dt)
	if this.state == LES_State.Clear_Pre_Map_Objs then
		this._ST_PreObjs()
	elseif this.state == LES_State.Clear_Pre_Map_Scene then
		this._ST_PreScene()
	elseif this.state == LES_State.Load_Map_Scene then
		this._ST_CurScene(dt)
	elseif this.state == LES_State.Load_Map_Objs then
		this._ST_CurObjs()
	elseif this.state == LES_State.Complete then
		this._ST_End()
	end
end

function M.LoadMap(mapid)
	if not mapid then return end
	if mapid == this.mapid then return end
	local _cfgMap = MgrData:GetCfgMap(mapid)
	if not _cfgMap then return end
	local _cfgRes = MgrData:GetCfgRes(_cfgMap.resid)
	this.isUping = false
	this.abname = this:ReSBegEnd( _cfgRes.rsaddress,"prefabs/",".fab" )
	this.preMapid = this.mapid
	this.mapid = mapid
	this.cfgMap = _cfgMap
	this.cfgRes = _cfgRes
	this.progress = 0

	-- 显示Loading
	this.state = LES_State.Wait_Vw_Loading
	_evt.Brocast(Evt_Loading_Show,this.progress,this._ST_Begin)
end

function M._Up_Progress()
	this.progress = (this.state - 1) * this.eveRegion;
	_evt.Brocast(Evt_Loading_UpPlg,this.progress)
end

function M._ST_Begin()
	this._Up_Progress()
	this.state = LES_State.Clear_Pre_Map_Objs
	this.isUping = true
end

function M._ST_PreObjs()
	this._Up_Progress()
	this.state = LES_State.Clear_Pre_Map_Scene
end

function M._ST_PreScene()
	this._Up_Progress()
	if not this.lbScene then
		this.state = LES_State.Load_Map_Scene
		return 
	end
	this.lbScene.lfAssetLoaded = nil
	this.lbScene:OnUnLoad()
	this.lbScene = nil
	this._cd1,this.csAbInfo = nil
	this.state = LES_State.Load_Map_Scene
end

local function _LF_LoadedScene(isNoObj,Obj)
	this.state = LES_State.Load_Map_Objs
end

function M._ST_CurScene(dt)
	if this.lbScene then
		this._ST_OnUp_LoadScene(dt)
		return 
	end
	this._Up_Progress()
	this.lbScene = SceneObject.New({
		abName = this.cfgRes.rsaddress,
	})
	this.lbScene.lfAssetLoaded = _LF_LoadedScene
	this.lbScene:View(true)
end

function M._ST_OnUp_LoadScene(dt)
	this._cd1 = this._cd1 or 0.5
	this._cd1 = this._cd1 - dt
	if this._cd1 <= 0 then
		this._cd1 = this._cd1 + 0.5
		this.csAbInfo = this.lbScene:GetAbInfo()
		if this.csAbInfo then
			local _n1 = this.csAbInfo.m_depNeedLoaded
			local _n2 = this.csAbInfo.m_depNeedCount
			local _v = mmax(_n2 + 1,1)
			_v = this:TF2(this.progress + (_n1 * this.eveRegion / _v))
			_evt.Brocast(Evt_Loading_UpPlg,_v)
		end
	end
end

function M._ST_CurObjs()
	this._Up_Progress()
	this.state = LES_State.Complete
end

function M._ST_End()
	this._Up_Progress()
	_evt.Brocast(Evt_Loading_Hide)

	local _arrs = MgrRes.GetDependences(this.abname)
	cs_foreach_arrs(_arrs,function(v,k) 
		printInfo("k == [%s] , v = [%s]",k,v)
	end)
end

return M
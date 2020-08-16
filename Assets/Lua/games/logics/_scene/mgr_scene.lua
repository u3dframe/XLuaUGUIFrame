--[[
	-- 管理 - 场景
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-13 09:25
	-- Desc : 
]]

local mmax = math.max
local MgrData,MgrRes,SceneFactory = MgrData,MgrRes,SceneFactory
local LES_State = LES_State
local _mgrInput,_mgrCamera,_csMgr = MgrInput,MgrCamera

local super,_evt = MgrBase,Event
local M = class( "mgr_scene",super )
local this = M

function M.Init()	
	this.state = LES_State.None
	this.progress = 0
	this.eveRegion = this:TF((1 / (LES_State.Complete - LES_State.Wait_Vw_Loading)),4)

	this.defenses = {}
	this.offenses = {} -- 
	this.mapObjs = {} -- [mapid] = {obj1,obj2}

	this:ReEvent4OnUpdate(true)
	_evt.AddListener(Evt_MapLoad,this.LoadMap)
end

function M:ReEvent4Self(isBind)
	_evt.RemoveListener(Evt_SceneChanged,this._ST_LoadedScene)
	if isBind == true then
		_evt.AddListener(Evt_SceneChanged,this._ST_LoadedScene)
	end
end

function M:OnUpdate(dt)
	if this.state == LES_State.Clear_Pre_Map_Objs then
		this._ST_PreObjs()
	elseif this.state == LES_State.Clear_Pre_Map_Scene then
		this._ST_PreMap()
	elseif this.state == LES_State.Load_Scene then
		this._ST_LoadScene()
	elseif this.state == LES_State.Wait_Loading_Scene then
	elseif this.state == LES_State.Load_Map_Scene then
		if this.lbScene then
			this._ST_OnUp_LoadMap(dt)
		else
			this._ST_CurMap()
		end
	elseif this.state == LES_State.Load_Map_Objs then
		this._ST_CurObjs()
	elseif this.state == LES_State.Complete then
		this._ST_Complete()
	end
end

function M.GetState()
	return this.state
end

function M.LoadMap(mapid)
	if not mapid then return end
	if mapid == this.mapid then return end
	local _cfgMap = MgrData:GetCfgMap(mapid)
	if not _cfgMap then return end
	local _cfgRes = MgrData:GetCfgRes(_cfgMap.resid)
	
	this.isUping = false
	this.isUpingLoadMap = false
	this:ReEvent4Self(false)

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

function M._ST_PreMap()
	this._Up_Progress()
	if not this.lbScene then
		this.state = LES_State.Load_Scene
		return 
	end
	this.lbScene.lfAssetLoaded = nil
	this.lbScene:OnUnLoad()
	this.lbScene = nil
	this._cd1,this.csAbInfo = nil
	this.state = LES_State.Load_Scene
end

function M._ST_LoadScene()
	this._Up_Progress()
	this.state = LES_State.Wait_Loading_Scene
	this:ReEvent4Self(true)
	_evt.Brocast(Evt_ToChangeScene)
end

function M._ST_LoadedScene()
	this._Up_Progress()
	this.state = LES_State.Load_Map_Scene
end

local function _LF_LoadedScene(isNoObj,Obj)
	if not this.isUpingLoadMap then return end
	this.state = LES_State.Load_Map_Objs
end

function M._ST_CurMap()
	if this.lbScene then
		return 
	end
	this._Up_Progress()
	this.lbScene = SceneFactory.Create(LES_Object.MapObj,{
		abName = this.cfgRes.rsaddress,
	})
	this.isUpingLoadMap = true
	this.lbScene.lfAssetLoaded = _LF_LoadedScene
	this.lbScene:View(true)
end

function M._ST_OnUp_LoadMap(dt)
	if not this.isUpingLoadMap then return end
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

function M._ST_Complete()
	this._Up_Progress()
	this.state = LES_State.FinshedEnd
	_evt.Brocast(Evt_Loading_Hide)

	-- local _arrs = MgrRes.GetDependences(this.lbScene:GetAbName())
	-- cs_foreach_arrs(_arrs,function(v,k) 
	-- 	printInfo("k == [%s] , v = [%s]",k,v)
	-- end)
	printTable("已经结束了")
end

return M
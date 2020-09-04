--[[
	-- 管理 - 场景
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-13 09:25
	-- Desc : defenses,offenses
]]

local tb_remove,tb_insert,tb_contain = table.remove,table.insert,table.contains

local mmax = math.max
local MgrData,SceneFactory = MgrData,SceneFactory
local LES_State,LES_Object = LES_State,LES_Object

local super,_evt = MgrBase,Event
local M = class( "mgr_scene",super )
local this = M

function M.Init()	
	this.state = LES_State.None
	this.progress = 0
	this.mapWorld_Y  = 0
	this.eveRegion = this:TF((1 / (LES_State.Complete - LES_State.Wait_Vw_Loading)),4)

	this:ReEvent4OnUpdate(true)

	_evt.AddListener(Evt_Map_Load,this.OnLoadMap)
	_evt.AddListener(Evt_Map_AddObj,this.OnAdd_Map_Obj)
	_evt.AddListener(Evt_Map_GetObj,this.OnGet_Map_Obj)
	_evt.AddListener(Evt_Map_Reback_Obj,this.OnReback_Map_Obj)
end

function M:ReEvent4Self(isBind)
	_evt.RemoveListener(Evt_SceneChanged,this._On_LoadedScene)
	if isBind == true then
		_evt.AddListener(Evt_SceneChanged,this._On_LoadedScene)
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
		if this.lbMap then
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

function M.OnLoadMap(mapid)
	if mapid == this.mapid then return end
	this.isUping = false
	this.isUpingLoadMap = false
	this:ReEvent4Self(false)

	this.preMapid = this.mapid
	this.mapid = mapid
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
	if not this.lbMap then
		this.state = LES_State.Load_Scene
		return 
	end
	this.lbMap.lfAssetLoaded = nil
	this.lbMap:OnUnLoad()
	this.lbMap = nil
	this._cd1,this.csAbInfo = nil
	this.state = LES_State.Load_Scene
end

function M._ST_LoadScene()
	this._Up_Progress()
	this.state = LES_State.Wait_Loading_Scene
	this:ReEvent4Self(true)
	_evt.Brocast(Evt_ToChangeScene)
end

function M._On_LoadedScene()
	this._Up_Progress()
	this.state = LES_State.Load_Map_Scene
end

local function _LF_LoadedScene(isNoObj,Obj)
	if not this.isUpingLoadMap then return end
	this.mapWorld_Y  = this.lbMap:GetWorldY()
	this.state = LES_State.Load_Map_Objs

end

function M._ST_CurMap()
	if not this.mapid then
		this.state = LES_State.Complete
		return
	end

	if this.lbMap then
		return 
	end
	this._Up_Progress()

	local _cfgMap = MgrData:GetCfgMap(this.mapid)
	this.lbMap = this.GetOrNew_SObj(LES_Object.MapObj,_cfgMap.resid)
	if this.lbMap == nil then
		this.state = LES_State.None
		printError("=========load map is null")
		return
	end
	this.lbMap.lfAssetLoaded = _LF_LoadedScene
	this.isUpingLoadMap = true
	this.lbMap:View(true)
end

function M._ST_OnUp_LoadMap(dt)
	if not this.isUpingLoadMap then return end
	
	this._cd1 = this._cd1 or 0.1

	if this._cd1 and this._cd1 > 0 then
		this._cd1 = this._cd1 - dt
		if this._cd1 > 0 then
			return 
		end
		this._cd1 = this._cd1 + 0.1
	end
	
	this.csAbInfo = this.csAbInfo or this.lbMap:GetAbInfo()
	if this.csAbInfo then
		local _n1 = this.csAbInfo.m_depNeedLoaded
		local _n2 = this.csAbInfo.m_depNeedCount
		local _v = mmax(_n2 + 1,1)
		_v = this:TF2(this.progress + (_n1 * this.eveRegion / _v))
		_evt.Brocast(Evt_Loading_UpPlg,_v)
	end
end

function M._ST_CurObjs()
	this._cd1,this.csAbInfo = nil
	this._Up_Progress()
	this.state = LES_State.Complete
end

function M._ST_Complete()
	this.isUping = false
	
	this._Up_Progress()
	this.state = LES_State.FinshedEnd
	_evt.Brocast(Evt_Loading_Hide)
	if this.mapid then
		_evt.Brocast(Evt_Map_Loaded, this.mapid);
	else
		_evt.Brocast(Evt_ToView_Main)
	end

	-- local _arrs = MgrRes.GetDependences(this.lbMap:GetAbName())
	-- cs_foreach_arrs(_arrs,function(v,k) 
	-- 	printInfo("k == [%s] , v = [%s]",k,v)
	-- end)
end

function M.AddCurrMapObj(lbSObj)
	local _cursor = lbSObj:GetCursor()
	local _lb = this[this.mapid] or {}
	this[this.mapid] = _lb
	
	_lb[_cursor] = lbSObj
	return _cursor
end

function M.GetCurrMapObj(cursor)
	if not cursor then return end
	local _lb = this[this.mapid]
	if not _lb then return end
	return _lb[cursor]
end

function M.RemoveCurrMapObj(cursor)
	if not cursor then return end
	local _v = this.GetCurrMapObj(cursor)
	if not _v then return end
	this[this.mapid][cursor] = nil
end

function M.GetOrNew_SObj(objType,resid,uuid)
	return SceneFactory.Create(objType,resid,uuid)
end

function M.Add_SObj(objType,resid,uuid)
	local _ret = this.GetOrNew_SObj( objType,resid,uuid )
	this.AddCurrMapObj(_ret)
	if _ret.SetWorldY then
		_ret:SetWorldY( this.mapWorld_Y )
	end
	return _ret
end

function M.OnAdd_Map_Obj(objType,resid,lfunc,lbObject,...)
	local _ret = this.Add_SObj( objType,resid )
	this.DoCallFunc( lfunc,lbObject,_ret,... )
	return _ret,...
end

function M.OnGet_Map_Obj(uniqueID,lfunc,lbObject)
	local _ret = nil
	if uniqueID == "mapobj" then
		_ret = this.lbMap
	elseif uniqueID == "map.gbox" then
		if this.lbMap then
			_ret = this.lbMap.lbGBox
		end
	else
		_ret = this.GetCurrMapObj( uniqueID )
	end
	this.DoCallFunc( lfunc,lbObject,_ret )
	return _ret
end

function M.OnReback_Map_Obj(lbSObj)
	if not lbSObj then return end
	this.RemoveCurrMapObj( lbSObj:GetCursor() )
end

return M
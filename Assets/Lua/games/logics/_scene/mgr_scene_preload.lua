--[[
	-- 管理 - 场景 - 预加载管理
	-- Author : canyon / 龚阳辉
	-- Date : 2021-05-06 17:21
	-- Desc : 
]]

local tonumber,type,tostring = tonumber,type,tostring
local tb_remove,tb_insert = table.remove,table.insert
local tb_rm_val,tb_keys = table.removeValues,table.keys
local MgrData,E_Type = MgrData,LE_Effect_Type

MgrScene = require( "games/logics/_scene/mgr_scene" )
local ClsCG = require( "games/logics/story/storyplaychild" )

local super = MgrBase
local M = class( "mgr_scene_preload",super )
local this = M

function M.Init()
	MgrScene:Init()
	this.ReInitParams()
	this:ReEvent4OnUpdate( true )

	local _evt = this._fevt()
	_evt.AddListener( Evt_PreLoad_FightObj,this._PreAddOrRmv )	
end

function M.ReInitParams()
	-- this._deLObjSec = 0.03
	this.isUping = false
	this._need_load_obj,this._loaded_obj = 0,0
	this._dic_add,this._queue_adds = nil
end

function M.OnClear()
	this.RemoveAll()
	MgrScene.OnClear()
	this.ReInitParams()
end

function M:OnUpdate(dt)
	this._ST_LoadObjs( dt )
end

function M._IsDelayLoadObj(dt)
	if this._deLObjSec and this._deLObjSec >= 0.02 then
		this._cd1 = this._cd1 or 0
		while (this._cd1 <= 0) do
			this._cd1 = this._cd1 + this._deLObjSec
		end
		this._cd1 = this._cd1 - dt
		if this._cd1 > 0 then
			return true
		end
	end
end

function M._ST_LoadObjs(dt)
	if not this._queue_adds then
		return
	end
	if this._IsDelayLoadObj(dt) then
		return
	end

	if #this._queue_adds <= 0 then
		return
	end

	local _lf = tb_remove( this._queue_adds,1 )
	if _lf then
		_lf()
	end
end

local function _pre_load_obj()
	this._loaded_obj = this._loaded_obj + 1
end

function M._AddPreObj( lObj )
	if not lObj or not lObj.resid then
		return
	end
	local _lb = this._dic_preobjs or {}
	this._dic_preobjs = _lb

	local resid = lObj.resid
	_lb[resid] = lObj
end

function M._AddNeedLoadResid( resid,isCG )
	if not resid then
		return this
	end

	local _lb = this._dic_add or {}
	this._dic_add = _lb

	local _func_ = _lb[resid]
	if _func_ then
		return this
	end
	if isCG == true then
		_func_ = function()
			local _t = ClsCG.PreLoad( resid,_pre_load_obj )
			this._AddPreObj( _t )
		end
	else
		_func_ = function()
			local _t = EffectFactory.Make( E_Type.Pre_Effect,nil,nil,resid,_pre_load_obj )
			this._AddPreObj( _t )
		end
	end
	
	_lb[resid] = _func_
	_lb = this._queue_adds or {}
	this._queue_adds = _lb
	tb_insert(_lb,_func_)

	this._need_load_obj = this._need_load_obj + 1
	return this
end

function M._PreAddOrRmv(cfgid,otp,isRmv)
	this.isUping = true
	isRmv = (isRmv == true)
	if otp == "CG" then
		if isRmv then
			this.RemoveCurr( cfgid )
		else
			this._AddNeedLoadResid( cfgid,true )
		end
	elseif otp == "Effect" then
		if isRmv then
			this.RemoveCurr( cfgid )
		else
			this._AddNeedLoadResid( cfgid )
		end
	else
		local _cfg_ = cfgid
		if type(cfgid) == "number" then
			_cfg_ = this:GetCfgData( "hero",cfgid )
		end

		if type(_cfg_) == "table" then	
			if _cfg_.resid_fs then
				this._PreAddOrRmv( _cfg_.resid_fs,"Effect",isRmv )
			end

			if _cfg_.resids then
				for _, resid in ipairs(_cfg_.resids) do
					this._PreAddOrRmv( resid,"Effect",isRmv )
				end
			end

			if _cfg_.resid_cg then
				this._PreAddOrRmv( _cfg_.resid_cg,"CG",isRmv )
			end
		end
	end
end

function M.GetCurrNeed()
	return this._loaded_obj , this._need_load_obj
end

function M.IsPreLoaded()
	return this._loaded_obj >= this._need_load_obj
end

function M.RemoveCurr( id )
	if (not id) or (not this._dic_add) then
		return
	end

	local _func = this._dic_add[id]
	this._dic_add[id] = nil
	if _func then
		local _,_n = tb_rm_val( this._queue_adds,_func )
		if _n > 0 then
			this._need_load_obj = this._need_load_obj - 1
		end
		local _lb = (this._dic_preobjs or TB_EMPTY)[id]
		if _lb then
			_lb:DestroyObj()
		end
	end
end

function M.RemoveAll()
	if (not this._dic_add) then
		return
	end
	local _keys = tb_keys( this._dic_add )
	for _, k in ipairs(_keys) do
		this.RemoveCurr( k )
	end
end

return M
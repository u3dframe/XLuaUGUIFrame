--[[
	-- 管理 - 前置引导(创角和首次)
	-- Author : canyon / 龚阳辉
	-- Date : 2021-02-06 16:35
	-- Desc : 
]]

local tonumber,type,tostring = tonumber,type,tostring
local str_format = string.format
local str_contains = string.contains
local tb_insert = table.insert
local LGCache = _G.LGCache
local super,_evt = MgrBase,Event
local M = class( "mgr_pre_guide", super)
local this = M

function M.InitCfg()
	if not this.cfg then
		local _cfg =  MgrData:GetConfig("guide@@before")
		if _cfg then
			local _t,_it = {}
			for _, v in pairs(_cfg) do
				_it = _t[v.big] or {}
				_t[v.big] = _it
				tb_insert(_it,v)
			end
			this.cfg = _t
		end
	end
	return this.cfg
end

function M.GetSid()
	return MgrLogin:GetCurrSidSname()
end

function M.DriveCreateRole(callEnd)
	if not this.last_ui then
		this.last_ui = MgrUI.last_vw_ui
	end
	local _sid = this.GetSid()
	local _lgid = MgrLogin:GetCacheUid()
	local _k = str_format( "pg_sid_%s_lgid_%s",_sid,_lgid )
	local _isDo = LGCache.GetCacheBool( _k )
	if _isDo then
		this.DoCallFunc( callEnd )
		return
	end

	local _cfg = this.InitCfg()
	if not _cfg then
		this.DoCallFunc( callEnd )
		return
	end

	_cfg = _cfg[1]
	if not _cfg then
		this.DoCallFunc( callEnd )
		return
	end

	this._callEnd = callEnd
	local _st = sortArrayByField( _cfg,"step" )
	this._DoDrive( _k,_st )
end

function M.DriveEnterGame(uid,callEnd)
	if not this.last_ui then
		this.last_ui = MgrUI.last_vw_ui
	end

	this._CacheEnd()

	local _sid = this.GetSid()
	local _k = str_format( "pg_sid_%s_uid_%s",_sid,uid )
	local _isDo = LGCache.GetCacheBool( _k )
	if not _isDo then
		_isDo = (MgrGuide ~= nil) and MgrGuide:ByteGuideType( 99 )
		if _isDo then
			LGCache.SetCacheBool( _k,true )
		end
	end
	if _isDo then
		this.DoCallFunc( callEnd )
		return
	end
	local _cfg = this.InitCfg()
	if not _cfg then
		this.DoCallFunc( callEnd )
		return
	end

	_cfg = _cfg[2]
	if not _cfg then
		this.DoCallFunc( callEnd )
		return
	end

	this._callEnd = callEnd
	local _st = sortArrayByField( _cfg,"step" )
	this._DoDrive( _k,_st )
end


function M._DoDrive(curKey,curCfg)
	this._bigKey = curKey
	this._guideCfg = curCfg
	this._allLens = table.lens( curCfg )
	this._curIndex = 1

	this._OnDrive()
end

function M._OnDrive()
	if this._curIndex > this._allLens then
		this._DriveEnd()
		return
	end
	local _cfg = this._guideCfg[this._curIndex]
	if _cfg then
		this._curIndex = this._curIndex + 1
		local _k = str_format("%s_jump",this._bigKey)
		local _isJump = LGCache.GetCacheBool( _k )
		if _cfg.mv then
			_evt.Brocast(Evt_Loading_Show,0,function()
				_evt.Brocast( Evt_View_Vdo,true,_cfg.mv,this._OnDrive,this._CacheJump,_isJump )
			end,this.last_ui)
		else
			_evt.Brocast(Evt_Loading_Show,0,function()
				MgrStoryChats:PlayChatsByID( true,_cfg.chatid,this._OnDrive,nil,_isJump )
			end,this.last_ui)
		end
	end
end

function M._DriveEnd()
	this.last_ui = nil
	local _cf = this._callEnd
	this._callEnd = nil
	this.DoCallFunc( _cf )

	if this._bigKey and str_contains( this._bigKey,"_uid_" ) then
		this:SendRequest("guide_set", {id = 99});
		this._CacheEnd()
		_evt.Brocast( Evt_View_Vdo,2 )
	end
end

function M._CacheJump()
	local _k = this._bigKey
	if not _k then
		return
	end
	_k = _k .. "_jump"
	local _isDo = LGCache.GetCacheBool( _k )
	if not _isDo then
		LGCache.SetCacheBool( _k,true )
	end
end

function M._CacheEnd()
	local _k = this._bigKey
	if not _k then
		return
	end
	this._bigKey,this._guideCfg = nil
	LGCache.SetCacheBool( _k,true )
end

return M
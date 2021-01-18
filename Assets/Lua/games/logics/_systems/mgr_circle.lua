--[[
	-- 管理 - 遮罩界面 - 加载，请求，单击等
	-- Author : canyon / 龚阳辉
	-- Date : 2020-12-24 13:25
	-- Desc : 
]]

local super,_evt = MgrBase,Event
local M = class("mgr_circle", super)
local this = M
local _def_duration = 30

function M.Init()
	this._InitUI()
	this._nShowCount = 0
	_evt.AddListener(Evt_Circle_Show,ShowCircle)
	_evt.AddListener(Evt_Circle_Hide,HideCircle)
end

function M._InitUI()
	local ui = UIBase.New({
		abName = "commons/ui_circle",
		isStay = true,
		hideType = LE_UI_Mutex.None,
		layer = LE_UILayer.Top,
		isNoCircle = true,
		isUpdate = true,
	})
	this.ui = ui

	ui.OnSetData = function(_s,lfCallShow)
		_s.lfCallShow = lfCallShow
	end

	ui.OnInit = function(_s)
	end

	ui.OnShow = function(_s)
		_evt.Brocast( Evt_Circle_Showing )
		
		local _lf = _s.lfCallShow
		_s.lfCallShow = nil
		if _lf then
			_lf()
		end
	end

	ui.OnUpdateLoaded = function(_s,_dt)
		if not _s.data or _s.data < 0 then
			return
		end
		_s.data = _s.data - _dt
		if _s.data <= 0 then
			this._nShowCount = this._nShowCount - 1
			if (this._nShowCount > 0) then
				_s.data = _s.data + _def_duration
				return
			end
			_s:View(false)
		end
	end

	ui.OnEnd = function(_s,isDestroy)
		_evt.Brocast( Evt_Circle_Hided )
	end
end

function _ShowCircle(lfCallShow)
	this.ui:View( true,_def_duration,lfCallShow )
end

function ShowCircle(lfCallShow,isImmediate)
	if this._nShowCount <= 0 then
		this._nShowCount = 0
	end
	this._nShowCount = this._nShowCount + 1

	if (not isImmediate) then
		LTimer.AddDelayFunc1( "DELAY_SHOW_CIRCLE",0.9,_ShowCircle,lfCallShow )
	else
		_ShowCircle( lfCallShow )
	end
end

function HideCircle(isImmediate)
	if isImmediate == true then
		this._nShowCount = 1
	end
	this._nShowCount = this._nShowCount - 1
	if (this._nShowCount > 0) then
		return
	end
	LTimer.RemoveDelayFunc( "DELAY_SHOW_CIRCLE" )
	this.ui:View(false)
end

return M
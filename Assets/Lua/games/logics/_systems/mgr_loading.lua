--[[
	-- 管理 - 场景切换全屏遮罩界面
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-09 08:25
	-- Desc : 
]]

local super,_evt = MgrBase,Event
local M = class( "mgr_loading", super)
local this = M

function M.Init()
	this._InitUI()
	_evt.AddListener(Evt_Show_Loading,this.ShowLoading)
	_evt.AddListener(Evt_Hide_Loading,this.HideLoading)
end

function M._InitUI()
	local ui = UIBase.New({
		abName = "commons/ui_loading",
		isStay = true,
		hideType = LE_UI_Mutex.None,
		isUpdate = true,
		-- layer = LE_UILayer.Pop,
	})
	this.ui = ui

	ui.OnSetData = function(_s,lfCallShow)
		_s.lfCallShow = lfCallShow
	end

	ui.OnInit = function(_s)
	end

	ui.OnShow = function(_s)
		local _lf = _s.lfCallShow
		_s.lfCallShow = nil
		if _lf then
			_lf()
		end
	end

	ui.OnUpdateLoaded = function(_s,_dt)
	end
end

function M.ShowLoading(progress,lfCallShow)
	this.ui:View(true,(progress or 0),lfCallShow)
end

function M.HideLoading()
	this.ui:View(false)
end

return M
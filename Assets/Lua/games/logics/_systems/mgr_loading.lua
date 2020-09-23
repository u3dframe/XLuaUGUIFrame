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
	_evt.AddListener(Evt_Loading_Show,this.ShowLoading)
	_evt.AddListener(Evt_Loading_Hide,this.HideLoading)
end

function M._InitUI()
	local ui = UIBase.New({
		abName = "commons/ui_loading",
		isStay = true,
		hideType = LE_UI_Mutex.None,
		layer = LE_UILayer.Pop,
		-- isUpdate = true,
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
		_s:Refresh(_s.data)
	end

	ui.ReEvent4Self = function(_s,isBind)
		_evt.RemoveListener(Evt_Loading_UpPlg,_s.Refresh,_s)
		if isBind == true then
			_evt.AddListener(Evt_Loading_UpPlg,_s.Refresh,_s)
		end
	end

	ui.Refresh = function(_s,progress)
		-- printTable(progress)
	end
end

function M.ShowLoading(progress,lfCallShow)
	MgrUI.HideAll( nil,this.ui )
	this.ui:View(true,(progress or 0),lfCallShow)
end

function M.HideLoading()
	this.ui:View(false)
end

return M
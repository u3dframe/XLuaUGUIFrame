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
	_evt.AddListener(Evt_Hide_Loading,this.ViewLoading)
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

	ui.OnInit = function(_s)
	end

	ui.OnShow = function(_s)
	end

	ui.OnUpdateLoaded = function(_s,_dt)
	end
end

function M.ShowLoading(progress)
	this.ui:View(true,progress or 0)
end

function M.HideLoading()
	this.ui:View(false)
end

return M
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
	_evt.AddListener(Evt_ToView_Loading,this.ViewLoading)
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

function M.ViewLoading(isView)
	this.ui:View(isView == true)
end

return M
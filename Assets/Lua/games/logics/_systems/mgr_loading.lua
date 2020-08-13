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
		-- layer = LE_UILayer.Pop,
		-- isUpdate = true,
	})
	this.ui = ui

	ui.OnInit = function(_s)
	end

	ui.OnShow = function(_s)
	end
end

function M.ViewLoading()
	this.ui:View(true)
end

return M
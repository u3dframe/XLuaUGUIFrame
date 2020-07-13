--[[
	-- 登录界面管理脚本
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]

local super,_evt = MgrBase,Event
local M = class( "mgr_login",super )

function M:Init()
	_evt.AddListener(Evt_ToView_Login,handler(self,self.ToLoginView));
end

function M:ToLoginView()
	printInfo("======1")
	local ui = UIBase.New({
		abName = "prefabs/ui/login/uilogin.ui",
		-- assetName = "updateui.prefab",
	});
	-- ui.lfLoaded = function() UIRoot.singler() end
	ui:View(true)
	-- coroutine.wait(20)
	-- printInfo("======2")
end

return M
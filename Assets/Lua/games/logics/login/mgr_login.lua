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
	local ui = UIBase.New({
		abName = "login/uilogin",
	});

	ui.OnInit = function(_s)
		_s.lbBtn01 = _s:NewBtn("button",function()
			printInfo("click buttion")
		end,2)
	end

	ui.OnShow = function(_s)
		_s.lbBtn01:SetText(4)
	end
	ui:View(true)
	-- coroutine.wait(20)
	-- printInfo("======2")
end

return M
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
	LTimer.ReLocTime()

	local ui = UIBase.New({
		abName = "login/uilogin",
	});

	ui.OnInit = function(_s)
		_s.lbBtn01 = _s:NewBtn("button",function()
			printInfo("click buttion")
		end,2)

		_s.lbCDDown = LCDown.New(function(_lb) 
			printTable("===isEnd")
			_lb:SetText(4)
		end,LE_TmType.A_D_H_M_S,_s.lbBtn01.lbTxt)
	end

	ui.OnShow = function(_s)
		-- _s.lbBtn01:SetText(4)
		_s.lbCDDown:Start(10)
	end
	ui:View(true)
	-- coroutine.wait(20)
	-- printInfo("======2")
end

return M
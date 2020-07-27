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
		isStay = true,
	});

	ui.OnInit = function(_s)
		_s.lbBtn01 = _s:NewBtn("button",function()
			printInfo("click buttion")
		end,2)

		_s.lbCDDown = LCDown.New(function(_lb) 
			printTable("===isEnd")
			-- _lb:SetText(4)
			ui:View(false)
		end,LE_TmType.A_D_H_M_S,_s.lbBtn01.lbTxt)

		if ui:IsGLife() then
			ui.m_callShow = function() printTable("-----show") end
			ui.m_callHide = function() printTable("-----hide") end
		end

		_s.lbCDShow = LCDown.New(function(_lb) ui:View(true) end,LE_TmType.UTC_S)
	end

	ui.OnShow = function(_s)
		-- _s.lbBtn01:SetText(4)
		_s.lbCDDown:Start(10)
	end

	ui.OnEnd = function(_s,isDestroy)
		if not isDestroy then
			printInfo("== OnEnd")
			_s.lbCDShow:Start(5)
		end
	end

	ui:View(true)
end

return M
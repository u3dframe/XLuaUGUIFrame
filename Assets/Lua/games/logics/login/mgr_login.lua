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

	ui.count = 1
	ui.OnInit = function(_s)
		_s.lbBtn01 = _s:NewBtn("button",function()
			printInfo("click buttion")
		end,2)

		_s.lbCDDown = LCDown.New(function(_lb) 
			printTable("===isEnd")
			-- _lb:SetText(4)
			if ui.count <= 0 then
				ui:Hiding(true)
				ui.cfgAsset.isStay = nil
				printTable(LTimer.GetSvTime())
				LUtils.Wait(3,function(p1)
					printInfo(p1)
					printTable(LTimer.GetSvTime())
					ui:View(false)	
				end,"abcd")
			else
				ui.count = ui.count -1
				ui:View(false)
			end
		end,LE_TmType.A_D_H_M_S,_s.lbBtn01.lbTxt)

		if ui:IsGLife() then
			printInfo("=====isGilfe")
			ui:SetCF4OnShow( function() printTable("-----show") end )
			ui:SetCF4OnHide( function() printTable("-----hide") end )
		end

		_s.lbCDShow = LCDown.New(function(_lb) ui:View(true) end,LE_TmType.UTC_S)

		_s.lbScl = _s:NewUScl("scl_test",{
			clsLua = UIItem,--- function(go) return {gobj = go} end,
			cfClick = nil,
			cfShow = function(lbCell,nRow)
				-- printTable(lbCell,nRow)
				-- printTable(nRow)
			end,
			isVertical = true
		})
	end

	ui.OnShow = function(_s)
		-- _s.lbBtn01:SetText(4)
		-- _s.lbCDDown:Start(4)
		local _listSv = {
			{1,2,3},
			{4,5,6},
			{7,8,9},
		}
		_s.lbScl:ShowScroll(_listSv)

		LUtils.Wait(3,function()
			printTable(_s.lbScl,"lbScl")
		end)
	end

	ui.OnEnd = function(_s,isDestroy)
		if not isDestroy then
			printInfo("== OnEnd")
			_s.lbCDShow:Start(2)
		end
	end

	ui.OnCF_Destroy = function (_s)
		printError("== OnCF_Destroy")
		local lbBtn01 = ui.lbBtn01
		local lbCDDown = ui.lbCDDown
		local lbCDShow = ui.lbCDShow

		printTable(ui,"login 1")
		printTable(lbBtn01,"lbBtn01 1")
		printTable(lbCDDown,"lbCDDown 1")
		printTable(lbCDShow,"lbCDShow 1")

		UIBase.OnCF_Destroy(_s)

		printTable(ui,"login 2")
		printTable(lbBtn01,"lbBtn01 2")
		printTable(lbCDDown,"lbCDDown 2")
		printTable(lbCDShow,"lbCDShow 2")
		
		CGameFile.AppQuit()
	end

	ui:View(true)
end

return M
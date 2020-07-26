--[[
	-- 管理脚本 - 模版
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]

local _clsUI = require("games/logics/xxx/ui_xxx")
local super,_evt = MgrBase,Event
local M = class( "mgr_xxx",super )

function M:Init()
	-- self.lbUI = _clsUI.New()
	-- _evt.AddListener(Evt_ToView_Login,handler(self,self.xxxxFunc));
	-- self:SendRequest( cmd,data,func)
	-- self:AddPCall( cmd,func)
	-- self:RemovePCall( cmd,func)
end

function M:GetUI()
	return self.lbUI
end

return M
--[[
	-- 游戏入口脚本
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-05 13:25
	-- Desc : 
]]

local _mgrUI,_evt = MgrUI,Event

local M = {}

function M:Init()
	_evt.AddListener(Evt_GameEntryAfterUpRes,handler(self,self.EntryAfterUpRes))
end

function M:EntryAfterUpRes()
	LTimer.ReLocTime()
	_mgrUI.URoot()
	_evt.Brocast(Evt_ToChangeScene)
	_evt.Brocast(Evt_View_MainCamera,true)
	_evt.Brocast(Evt_ToView_Login)
end

return M
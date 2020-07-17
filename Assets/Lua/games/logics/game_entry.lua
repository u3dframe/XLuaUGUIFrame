--[[
	-- 游戏入口脚本
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-05 13:25
	-- Desc : 
]]

local _urt,_evt = UIRoot,Event

local M = {}

function M:Init()
	_evt.AddListener(Evt_GameEntryAfterUpRes,handler(self,self.EntryAfterUpRes))
end

function M:EntryAfterUpRes()
	_urt.singler()
	_evt.Brocast(Evt_ToChangeScene)
	_evt.Brocast(Evt_View_MainCamera)
	_evt.Brocast(Evt_ToView_Login)
end

return M
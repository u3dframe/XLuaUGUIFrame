--[[
	-- 游戏入口脚本
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-05 13:25
	-- Desc : 
]]

local _MG = _G;

local M = {}

function M:Init()
	Event.AddListener(Evt_GameEntryAfterUpRes,handler(self,self.EntryAfterUpRes));
end

function M:EntryAfterUpRes()
	UIRoot.singler()
	Event.Brocast(Evt_ToView_Login);
end

return M
--[[
	-- 场景点击事件处理
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-14 13:35
	-- Desc : 
]]

local _csMgr

local super,_evt = MgrBase,Event
local M = class( "mgr_input",super )

function M:Init()
	_csMgr = CInpMgr.instance
end

return M
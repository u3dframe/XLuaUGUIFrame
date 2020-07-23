--[[
	-- 游戏定时操作
	-- Author : canyon / 龚阳辉
	-- Date   : 2020-07-23 12:20
	-- Desc   : 延迟执行,定点通知
]]

local tb_insert = table.insert
local _tEx = TimeEx

local super,_evt = LuaObject,Event
local M = class( "lua_timer",super )
local this = M

function M.Init()
end

return M
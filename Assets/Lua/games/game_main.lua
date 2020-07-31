--[[
	-- 游戏 main 对象
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-23 20:26
	-- Desc : 
]]

local M = {}

function M.Init()
	-- 初始manager
	require("games/game_manager").Init()
	setPTabFunc(printInfo); -- 设置打印table的公共外部函数
	setPErrorFunc(printError); -- 设置Error打印函数
	LOG_VIEW_USE_TIME = GM_IsEditor
	-- 按键控制 发布真机包时 会移除
	if GM_IsEditor then
		require("keycode").Init()
	end
	Evt_No_Use_Coroutine = false
	Event.Brocast(Evt_GameEntryAfterUpRes);
end

return M
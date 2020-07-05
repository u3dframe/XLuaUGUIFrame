-- 游戏入口

local M = {}

function M.Init()
	-- 初始manager
	require("games/game_manager").Init()
	setPTabFunc(printInfo); -- 设置打印table的公共外部函数
	-- 按键控制 发布真机包时 会移除
	-- if GM_IsEditor then
	--	require("manager.keycodecallback").Init()
	-- end
	Event.Brocast(Evt_ToView_Login);
end

return M
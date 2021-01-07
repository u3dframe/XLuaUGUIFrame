--[[
	-- 游戏 main 对象
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-23 20:26
	-- Desc : 
]]

CELog2Net =  CELog2Net or CS.LogToNetHelper.shareInstance
-- 最多支持6对 key,val 参数
function FLog2Net(url,proj,...)
	if GM_IsEditor then
		return
	end
	if not proj then
		CELog2Net:SendKvsByDefUProj( ... )
	else
		CELog2Net:SendKvs( url or "",proj,... )
	end
end

function UserLog2Net(...)
	FLog2Net(nil,"client_log_user",...)
end

function UserProcessLog2Net(step,child,...)
	step = tonumber(step) or 0
	FLog2Net(nil,"client_log_user_process","p_step",step,"p_step_2",child,...)
end

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
	Event.AddListener( Evt_UserLog2Net,UserLog2Net );
	Event.AddListener( Evt_UserProcessLog2Net,UserProcessLog2Net );
	Event.Brocast(Evt_LoadAllShaders);
end

return M
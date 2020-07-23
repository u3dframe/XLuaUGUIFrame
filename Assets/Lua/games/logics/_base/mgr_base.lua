--[[
	-- 管理 基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-12 09:25
	-- Desc : 
]]

local super,_mNet = LuaObject,MgrNet
local M = class( "mgr_base",super )

function M:SendRequest( cmd,data,callback )
	_mNet.SendRequest( cmd,data,callback )
end

function M:AddPCall( cmd,callback )
	_mNet.AddPushCall( cmd,callback )
end

function M:RemovePCall( cmd,callback )
	_mNet.RmPushCall( cmd,callback )
end
return M
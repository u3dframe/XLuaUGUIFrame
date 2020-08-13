--[[
	-- 管理 - 网络请求 WWW/Http/Https
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-22 17:45
	-- Desc : 
]]

local _csMgr
local type = type

local super,_evt = LuaObject,Event
local M = class( "mgr_net",super )
local this = M

function M.Init()
	_csMgr = CWWWMgr.instance
end

function M.SendWWW(url,callback,ext_1)
	_csMgr.StartUWR( url,function(isState,uwr,pars)
		if callback then
			local _d = nil
			if isState == true then
				_d = uwr.downloadHandler.text
			end
			callback(isState,_d,pars)
		end
	end,ext_1)
end

return M
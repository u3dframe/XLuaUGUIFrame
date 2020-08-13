--[[
	-- 工具类脚本
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-27 19:35
	-- Desc : 封装函数用 . 号
]]

local _x_util = require 'games/tools/xlua_util'
local _c_yield,_csMgr = coroutine.yield

local M = {}
M.__index = M
local this = M

local function csMgr()
	if not _csMgr then _csMgr = CLuaMgr.instance end
	return _csMgr
end

function M.StartCor( func,... )
	return csMgr():StartCoroutine( _x_util.cs_generator( func,... ) )
end

function M.StoptCor( coroutine )
	csMgr():StopCoroutine( coroutine )
end

function M.Wait( sec,func,... )
	local _args = { ... }
	return this.StartCor(function()
		_c_yield(UWaitForSeconds(sec))
		if func then func ( unpack(_args) ) end
	end)
end

return M
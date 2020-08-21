--[[
	-- 工具类脚本
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-27 19:35
	-- Desc : 封装函数用 . 号
]]

local _x_util = require 'games/tools/xlua_util'
local _c_yield = coroutine.yield

local M = {}
M.__index = M
local this = M

function M.csLuaMgr()
	this._csLMgr = this._csLMgr or CLuaMgr.instance
	return this._csLMgr
end

function M.StartCor( func,... )
	return this.csLuaMgr():StartCoroutine( _x_util.cs_generator( func,... ) )
end

function M.StoptCor( coroutine )
	this.csLuaMgr():StopCoroutine( coroutine )
end

function M.Wait( sec,func,... )
	local _args = { ... }
	return this.StartCor(function()
		_c_yield(UWaitForSeconds(sec))
		if func then func ( unpack(_args) ) end
	end)
end

function M.csLocz()
	this._csLocz = this._csLocz or CLocliz
	return this._csLocz
end

function M.GetOrFmtLoczStr(val,...)
	local _lens = lensPars( ... )
	if (_lens > 0) then return this.csLocz().Format( val,... ) end
	return this.csLocz().Get( val )
end

return M
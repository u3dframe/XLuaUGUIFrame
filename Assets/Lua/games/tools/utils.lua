--[[
	-- 工具类脚本
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-27 19:35
	-- Desc : 封装函数用 . 号
]]

local _csCache,CHelper = UPlayerPrefs,CHelper
local _sfmt = string.format
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

function M.HasCache( key )
	key = _sfmt( "%s_%s",key,CRC_DPath )
	return _csCache.HasKey( key )
end

function M.ClearCache( key )
	if key == true then
		_csCache.DeleteAll()
	else
		key = _sfmt( "%s_%s",key,CRC_DPath )
		_csCache.DeleteKey( key )
	end
end

function M.SetCacheStr( key,val,isImmSave )
	key = _sfmt( "%s_%s",key,CRC_DPath )
	_csCache.SetString( key,val )
	if isImmSave == true then
		_csCache.Save()
	end
end

function M.GetCacheStr( key )
	key = _sfmt( "%s_%s",key,CRC_DPath )
	return _csCache.GetString( key )
end

function M.SetCacheInt( key,val,isImmSave )
	key = _sfmt( "%s_%s",key,CRC_DPath )
	_csCache.SetInt( key,val )
	if isImmSave == true then
		_csCache.Save()
	end
end

function M.GetCacheInt( key )
	key = _sfmt( "%s_%s",key,CRC_DPath )
	return _csCache.GetInt( key )
end

function M.SetCacheFloat( key,val,isImmSave )
	key = _sfmt( "%s_%s",key,CRC_DPath )
	_csCache.SetFloat( key,val )
	if isImmSave == true then
		_csCache.Save()
	end
end

function M.GetCacheFloat( key )
	key = _sfmt( "%s_%s",key,CRC_DPath )
	return _csCache.GetFloat( key )
end

function M.SetCacheNum( key,val,isImmSave )
	this.SetCacheFloat( key,val,isImmSave )
end

function M.GetCacheNum( key )
	return this.GetCacheFloat( key )
end

return M
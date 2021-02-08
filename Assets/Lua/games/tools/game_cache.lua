--[[
	-- 游戏缓存数据
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-27 19:35
	-- Desc : 缓存到本地
]]

local _csCache = UPlayerPrefs
local _sfmt = string.format

local M = {}
M.__index = M
local this = M

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

function M.SetCacheBool( key,val,isImmSave )
	val = (val == true) and 1 or 0
	this.SetCacheInt( key,val,isImmSave )
end

function M.GetCacheBool( key )
	local _v = this.GetCacheInt( key )
	return 1 == _v
end

return M
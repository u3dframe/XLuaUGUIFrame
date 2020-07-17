--[[
	-- 场景对象 基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-13 09:25
	-- Desc : 
]]

local _str_beg = string.starts
local _str_end = string.ends
local _str_fmt = string.format

local super = LuaFab
local M = class( "scene_base",super )

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.assetLType = LE_AsType.Fab
	return _cfg;
end

function M:onMergeConfig( _cfg )
	_cfg = super.onMergeConfig( self,_cfg )
	if not _str_beg(_cfg.abName,"prefabs/") then
		_cfg.abName = _str_fmt("%s%s","prefabs/",_cfg.abName)
	end
	if not _str_end(_cfg.abName,".fab") then
		_cfg.abName = _str_fmt("%s.fab",_cfg.abName)
	end
	return _cfg;
end

return M
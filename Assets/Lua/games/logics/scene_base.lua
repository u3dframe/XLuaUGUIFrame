--[[
	-- 场景对象 基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-13 09:25
	-- Desc : 
]]

local super = LuaFab
local M = class( "scene_base",super )

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.assetLType = LE_AsType.Fab
	return _cfg;
end

function M:onMergeConfig( _cfg )
	_cfg = super.onMergeConfig( self,_cfg )
	_cfg.abName = self:ReSBegEnd( _cfg.abName,"prefabs/",".fab" )
	return _cfg;
end

return M
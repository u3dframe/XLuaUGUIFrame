--[[
	-- 资源 prefab 基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-13 09:25
	-- Desc : 
]]

local super,super2 = LuaFab,UIPubs
local M = class( "fab_base",super,super2 )

function M:ctor(assetCfg)
	super.ctor( self,assetCfg )
	super2.ctor( self )
end

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
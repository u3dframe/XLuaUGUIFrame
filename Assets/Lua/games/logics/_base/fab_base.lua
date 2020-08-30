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

	if self.cfgRes then
		_cfg.abName = self.cfgRes.rsaddress
	end
	return _cfg;
end

function M:onMergeConfig( _cfg )
	_cfg = super.onMergeConfig( self,_cfg )
	if self:IsEnd(_cfg.abName,".ui") then return end
	_cfg.abName = self:ReSBegEnd( _cfg.abName,"prefabs/",".fab" )
	return _cfg;
end

function M:InitAsset4Resid( resid )
	local _cfgRes = MgrData:GetCfgRes(resid)
	if not _cfgRes then
		error("=== fab_base = no res in resource config, resid = [%s]",resid)
		return self
	end
	self.resid = resid
	self.cfgRes = _cfgRes

	self:InitAsset( self.cfgAsset )

	return self
end

return M
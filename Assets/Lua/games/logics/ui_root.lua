--[[
	-- ui base 基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-05 09:25
	-- Desc : 
]]
local super = UIBase
local M = class( "ui_root",super )

function M:ctor()
	super.ctor( self )
end

function M:onAssetConfig( assetCfg )
	local _cfg = super.onAssetConfig( self,assetCfg )
	_cfg.abName = "prefabs/uiroot.fab"
	_cfg.assetName = "uiroot.prefab"
	_cfg.isStay = true
	_cfg.isUpdate = true
	return _cfg;
end

function M:OnUpdate(dt)
	if not self.uptime or self.uptime <= 0 then
		self.uptime = 1;
		if not self.objdd then
			self.objdd = MgrRes.GetAsset(self.cfgAsset.abName,self.cfgAsset.assetName,self.cfgAsset.assetLType);
		end
		printTable(self.objdd,"obj");
		-- printInfo(self.assetCfg.abName)
	end
	self.uptime = self.uptime - dt;
end

function M.Singler()
	local _t = M.__single
	if not _t then
		local _t = M.New()
		_t:ReShow()
		M.__single = _t;
	end
	return _t
end

return M
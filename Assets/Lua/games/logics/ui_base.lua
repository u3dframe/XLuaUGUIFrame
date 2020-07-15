--[[
	-- ui base 基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-05 09:25
	-- Desc : 
]]


local super,super2 = LuaFab,UIPubs
local M = class( "ui_base",super,super2 )

function M:ctor(assetCfg)
	super.ctor( self,assetCfg )
	super2.ctor( self )
end

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.assetLType = LE_AsType.UI
	_cfg.layer = LE_UILayer.Normal
	return _cfg;
end

function M:GetLayer()
	return self.cfgAsset.layer
end

function M:OnCF_Fab( obj )
	super.OnCF_Fab( self,obj )
	self:_SetSelfLayer()
	if self.lfLoaded then
		self.lfLoaded()
	end
end

function M:_SetSelfLayer()
	local _lay = self:GetLayer()
	if LE_UILayer.URoot == _lay then
		self:SetParent(nil,true)
		self:DonotDestory()
	elseif LE_UILayer.UpRes ~= _lay then
		UIRoot.singler():SetUILayer(self)
	end
end

return M
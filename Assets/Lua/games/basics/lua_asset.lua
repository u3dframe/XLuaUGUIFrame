--[[
	-- lua_asset 的基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-03 22:25
	-- Desc : 
]]
local tb = table
local super = LCFabElement
local M = class( "lua_asset",super )

function M:ctor(assetCfg)
	self.cfgAsset = {
		abName = nil,
		assetName = nil,
		assetLType = LE_AsType.Fab,
	}	
	self:onAssetConfig(assetCfg or self.cfgAsset)
	self._lfLoadAsset = handler(self,self._OnCFLoadAsset);
	self.stateLoad = LE_StateLoad.None;
end

function M:onAssetConfig( assetCfg )
	return tb.merge(self.cfgAsset, assetCfg)
end

function M:IsInitAsset()
	local _isInit = self:CfgAssetInfo()
	return _isInit;
end

function M:CfgAssetInfo()
	local _abName = self.cfgAsset.abName
	local _assetName = self.cfgAsset.assetName
	local _isInit = (type(_abName) == "string") and (type(_assetName) == "string");
	return _isInit,_abName,_assetName,(self.cfgAsset.assetLType or LE_AsType.Fab);
end

function M:LoadAsset()
	local _isBl,_abName,_assetName,_ltp = self:CfgAssetInfo();
	if _isBl then
		self.stateLoad = LE_StateLoad.Loading;
		MgrRes.LoadAsset(_abName,_assetName,_ltp,self._lfLoadAsset);
	else
		error("=== LoadAsset asset info not init = [%s] = [%s] = [%s] = [%s]",_isBl,_abName,_assetName,_ltp)
	end
end

function M:_OnCFLoadAsset( obj )
	self.stateLoad = LE_StateLoad.Loaded;
	local _tp = self.cfgAsset.assetLType
	if not obj then
		local _isBl,_abName,_assetName,_ltp = self:CfgAssetInfo();
		error("=== Not has asset init = [%s] = [%s] = [%s] = [%s]",_isBl,_abName,_assetName,_ltp);
	end
	if LE_AsType.Fab == _tp or LE_AsType.UI == _tp then
		super.ctor(self,obj)
		self:OnCF_Fab(obj)
	elseif LE_AsType.Sprite == _tp then
		self:OnCF_Sprite(obj);
	elseif LE_AsType.Texture == _tp then
		self:OnCF_Texture(obj);
	end
end

function M:OnCF_Fab( obj )
end

function M:OnCF_Sprite( obj )
end

function M:OnCF_Texture( obj )
end

function M:OnUnLoad()
	local _isBl,_abName,_assetName,_ltp = self:CfgAssetInfo();
	if _isBl then
		self.stateLoad = LE_StateLoad.UnLoad;
		MgrRes.UnLoad(_abName,_assetName,_ltp);
	else
		error("=== OnUnLoad asset = [%s] = [%s] = [%s] = [%s]",_isBl,_abName,_assetName,_ltp)
	end
end

function M:ReturnObj4Pool()
	local _,_abName,_assetName = self:CfgAssetInfo();
	MgrRes.ReturnObj(_abName,_assetName,self.gobj)
end

function M:pre_clean()
	super.pre_clean( self )
	self:OnUnLoad()
end

return M
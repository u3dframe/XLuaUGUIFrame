--[[
	-- lua_asset 的基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-03 22:25
	-- Desc : 
]]

local tb,_mRes = table,MgrRes
local str_format = string.format

local function m_res()
	if not _mRes then _mRes = MgrRes end
	return _mRes
end

local super = LCFabElement
local M = class( "lua_asset",super )

function M:ctor(assetCfg)
	self.cfgAsset = {
		abName = nil,
		assetName = nil,
		assetLType = LE_AsType.Fab,
	}	
	assetCfg = self:onAssetConfig(assetCfg)
	self:onMergeConfig(assetCfg)
	self._lfLoadAsset = handler(self,self._OnCFLoadAsset);
	self.stateLoad = LE_StateLoad.None;
end

function M:onAssetConfig( assetCfg )
	return assetCfg or self.cfgAsset;
end

function M:onMergeConfig( cfg )
	if cfg ~= self.cfgAsset and type(cfg) == "table" then
		return tb.merge(self.cfgAsset, cfg)
	end
	return self.cfgAsset
end

function M:IsInitAsset()
	local _isInit = self:CfgAssetInfo()
	return _isInit;
end

function M:CfgAssetInfo()
	local _abName = self.cfgAsset.abName
	local _assetName = self.cfgAsset.assetName
	local _ltp = (self.cfgAsset.assetLType or LE_AsType.Fab)
	local _isAb = (type(_abName) == "string")
	local _isAs = (type(_assetName) == "string")
	if _isAb and not _isAs then
		_assetName = CGameFile.GetFileNameNoSuffix(_abName)
		_assetName = str_format("%s.%s",_assetName,LE_AsType[_ltp])
		_isAs = true
	end
	self.cfgAsset.assetName = _assetName
	self.cfgAsset.assetLType = _ltp
	return (_isAb and _isAs),_abName,_assetName,_ltp;
end

function M:LoadAsset()
	local _isBl,_abName,_assetName,_ltp = self:CfgAssetInfo();
	if _isBl then
		self.stateLoad = LE_StateLoad.Loading;
		m_res().LoadAsset(_abName,_assetName,_ltp,self._lfLoadAsset);
	else
		printError("=== LoadAsset asset info not init = [%s] = [%s] = [%s] = [%s]",_isBl,_abName,_assetName,_ltp)
	end
end

function M:_OnCFLoadAsset( obj )
	if self.stateLoad ~= LE_StateLoad.Loading then return end
	self.stateLoad = LE_StateLoad.Loaded;
	if not obj then
		local _isBl,_abName,_assetName,_ltp = self:CfgAssetInfo();
		printError("=== Not has asset init = [%s] = [%s] = [%s] = [%s]",_isBl,_abName,_assetName,_ltp);
	end
	local _tp = self.cfgAsset.assetLType
	if LE_AsType.Fab == _tp or LE_AsType.UI == _tp then
		local _comp = self.cfgAsset.strComp
		super.ctor(self,obj,_comp)
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

function M:_OnUnLoad()
	local _isBl,_abName,_assetName,_ltp = self:CfgAssetInfo();
	if _isBl then
		self.stateLoad = LE_StateLoad.UnLoad;
		local _isPool = self:IsInitGobj() and (_ltp == LE_AsType.Fab)
		if _isPool then
			m_res().ReturnObj(_abName,_assetName,self.gobj)
		else
			m_res().UnLoad(_abName,_assetName,_ltp);
		end
	else
		printError("=== _OnUnLoad asset = [%s] = [%s] = [%s] = [%s]",_isBl,_abName,_assetName,_ltp)
	end
end

function M:OnUnLoad()
	local _isBl,_abName,_assetName,_ltp = self:CfgAssetInfo();
	if _isBl then
		m_res().UnLoad(_abName,_assetName,_ltp);
	else
		printError("=== OnUnLoad asset = [%s] = [%s] = [%s] = [%s]",_isBl,_abName,_assetName,_ltp)
	end
end

function M:pre_clean()
	super.pre_clean( self )
	self:_OnUnLoad()
end

return M
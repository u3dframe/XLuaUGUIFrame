--[[
	-- lua_asset 的基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-03 22:25
	-- Desc : 
]]

local _E_SLoad,_E_AType = LE_StateLoad,LE_AsType
local tb,_mRes,type = table,MgrRes,type

local function m_res()
	if not _mRes then _mRes = MgrRes end
	return _mRes
end

local super = LCFabElement
local M = class( "lua_asset",super )

M.AddNoClearKeys( "cfgAsset","strABAsset" )

function M:ctor(assetCfg)
	self:InitBase( assetCfg )
end

function M:InitBase(assetCfg)
	self.cfgAsset = {
		abName = nil,
		assetName = nil,
		assetLType = _E_AType.Fab,
		strComp = nil,
		isUpdate = nil,
		isVwCircle = nil,
		isStay = nil,
		isLogVTime = nil,

		layer = nil,
		hideType = nil,
	}	
	assetCfg = self:onAssetConfig(assetCfg)
	self:onMergeConfig(assetCfg)
	self:ReCheckCfgAsset()
	self._lfLoadAsset = handler(self,self._OnCFLoadAsset);
	self.stateLoad = _E_SLoad.None;
	return self
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

function M:ReCheckCfgAsset()
	local _abName = self:GetAbName()
	local _assetName = self:GetAssetName()
	local _ltp = (self.cfgAsset.assetLType or _E_AType.Fab)
	local _isAb = (type(_abName) == "string" and "" ~= _abName )
	local _isAs = (type(_assetName) == "string")
	if _isAb and not _isAs then
		_assetName = CGameFile.GetFileNameNoSuffix(_abName)
		_assetName = self:SFmt("%s.%s",_assetName,_E_AType[_ltp])
		_isAs = true
	end
	self.cfgAsset.assetName = _assetName
	self.cfgAsset.assetLType = _ltp

	self.strABAsset = self:SFmt("%s_%s",_abName,_assetName)

	return self.cfgAsset,self
end

function M:_CfgAssetInfo()
	local _abName = self:GetAbName()
	local _assetName = self:GetAssetName()
	local _isAb = (type(_abName) == "string")
	local _isAs = (type(_assetName) == "string")
	return (_isAb and _isAs),_abName,_assetName,self.cfgAsset.assetLType;
end

function M:GetAbName()
	return self.cfgAsset.abName
end

function M:GetAssetName()
	return self.cfgAsset.assetName
end

function M:IsNoStateLoad(state)
	return self.stateLoad ~= state
end

function M:IsStateLoad(state)
	return self.stateLoad == state
end

function M:IsNoLoaded()
	return self:IsNoStateLoad(_E_SLoad.Loaded)
end

function M:IsLoaded()
	return self:IsStateLoad(_E_SLoad.Loaded)
end

function M:LoadAsset()
	local _isBl,_abName,_assetName,_ltp = self:_CfgAssetInfo();
	if _isBl then
		self.stateLoad = _E_SLoad.Loading;
		m_res().LoadAsset(_abName,_assetName,_ltp,self._lfLoadAsset);
	else
		printError("=== LoadAsset asset info not init = [%s] = [%s] = [%s] = [%s]",_isBl,_abName,_assetName,_ltp)
	end
	return self
end

function M:_OnCFLoadAsset( obj )
	if self:IsNoStateLoad(_E_SLoad.Loading) then return end
	self.stateLoad = _E_SLoad.Loaded;
	local _isNoObj,_tp = (not obj)
	if _isNoObj then
		local _isBl,_abName,_assetName,_ltp = self:_CfgAssetInfo();
		printError("=== Not has asset init = [%s] = [%s] = [%s] = [%s]",_isBl,_abName,_assetName,_ltp);
	end
	_tp = self.cfgAsset.assetLType
	if _E_AType.Fab == _tp or _E_AType.UI == _tp then
		if not _isNoObj then
			local _comp = self.cfgAsset.strComp
			super.ctor(self,obj,_comp)
		end
		self:OnCF_Fab(obj)
	elseif _E_AType.Sprite == _tp then
		self:OnCF_Sprite(obj);
	elseif _E_AType.Texture == _tp then
		self:OnCF_Texture(obj);
	end
	if self.lfAssetLoaded then
		self.lfAssetLoaded(_isNoObj,obj)
	end
	self.lfAssetLoaded = nil
end

function M:OnCF_Fab( obj )
end

function M:OnCF_Sprite( obj )
end

function M:OnCF_Texture( obj )
end

function M:GetAbInfo()
	if self:IsNoStateLoad(_E_SLoad.Loading) and self:IsNoStateLoad(_E_SLoad.Loaded) then return end
	if self.csABInfo then
		self.csABInfo = m_res().GetAB(self:GetAbName())
	end
	return self.csABInfo
end

function M:_OnUnLoad()
	self:OnUnLoad();
end

function M:OnUnLoad()
	local _isBl,_abName,_assetName,_ltp = self:_CfgAssetInfo();
	if _isBl then
		self.stateLoad = _E_SLoad.UnLoad;
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
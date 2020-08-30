--[[
	-- ui base 基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-05 09:25
	-- Desc : 
]]

local _E_Layer,_E_AType,_E_HType,__mgr = LE_UILayer,LE_AsType,LE_UI_Mutex
local function _mgr()
	if not __mgr then __mgr = MgrUI end
	return __mgr
end

local super,_evt = FabBase,Event
local M = class( "ui_base",super )

function M:ctor(assetCfg)
	super.ctor( self,assetCfg )
end

function M:InitBase(assetCfg)
	super.InitBase( self,assetCfg )
	if self:GetLayer() == _E_Layer.Normal then
		local hideType = self:GetMutexType()
		hideType = hideType or _E_HType.MainAndSelf
		self.cfgAsset.hideType = hideType
	end

	return self
end

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.assetLType = _E_AType.UI
	_cfg.layer = _cfg.layer or _E_Layer.Normal
	return _cfg;
end

function M:onMergeConfig( _cfg )
	_cfg = super.onMergeConfig( self,_cfg )
	_cfg.abName = self:ReSBegEnd( _cfg.abName,"prefabs/ui/",".ui" )
	return _cfg;
end

function M:GetLayer()
	return self.cfgAsset.layer
end

function M:GetMutexType()
	return self.cfgAsset.hideType
end

function M:OnCF_Fab( obj )
	super.OnCF_Fab( self,obj )
	if self.lfLoaded then
		self.lfLoaded()
	end
	self.lfLoaded = nil
end

function M:OnViewBeforeOnInit()
	self:_SetSelfLayer()
	self:HideOtherExcludeSelf()
end

function M:_SetSelfLayer()
	local _lay = self:GetLayer()
	if _E_Layer.URoot == _lay then
		self:SetParent(nil,true)
		self:DonotDestory()
	elseif _E_Layer.UpRes ~= _lay then
		_mgr().URoot():SetUILayer(self)
	end
end

function M:View(isShow,data,...)
	super.View( self,isShow,data,... )
	if true == isShow then
		_mgr().AddViewUI(self)
	else
		_mgr().RmViewUI(self)
	end
end

-- 互斥其他界面
function M:HideOtherExcludeSelf()
	_mgr().HideOther(self)
end

function M:OnClickCloseSelf( isShowMain )
	self:Set4NotClear("isCloseSelf",true)
	isShowMain = (isShowMain == true)
	local _isNml = _E_Layer.Normal == self:GetLayer()
	local _isBackSelf = _isNml and (not isShowMain)
	local _isPNUI = _isBackSelf and _mgr().GetIsOpenPreUI()
	self:Set4NotClear("isShowMain",isShowMain)
	self:Set4NotClear("isBackSelf",_isBackSelf)
	self:Set4NotClear("isPreNormalUI",_isPNUI)
	self:View(false)
end

function M:OnExit(isInited)
	local _isClose = self:Get4NotClear("isCloseSelf")
	local _isMain = self:Get4NotClear("isShowMain")
	local _isPre = self:Get4NotClear("isPreNormalUI")
	local _isBack = self:Get4NotClear("isBackSelf")
	self:Clear4NotClear("isCloseSelf","isShowMain","isPreNormalUI","isBackSelf")

	if (not isInited) then return end

	if (_isPre == true) then
		_mgr().OpenPreUI()
	end

	if (_isClose == true) then
		if _isMain then
			_mgr().ClearPreInfo()
			_evt.Brocast(Evt_ToView_Main);
		else
			_mgr().SetIsOpenPreUI(_isBack)
		end
	end
end

return M
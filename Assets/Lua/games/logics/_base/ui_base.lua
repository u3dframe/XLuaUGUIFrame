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

local super,super2 = LuaFab,UIPubs
local M = class( "ui_base",super,super2 )

function M:ctor(assetCfg)
	super.ctor( self,assetCfg )
	super2.ctor( self )

	self.strABAsset = self:SFmt("%s_%s",self.cfgAsset.abName,self.cfgAsset.assetName)
	if self:GetLayer() == _E_Layer.Normal then
		local hideType = self:GetMutexType()
		hideType = hideType or _E_HType.MainAndSelf
		self.cfgAsset.hideType = hideType
	end
end

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.assetLType = _E_AType.UI
	_cfg.layer = _E_Layer.Normal
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
	self:_SetSelfLayer()
	if self.lfLoaded then
		self.lfLoaded()
	end
	self.lfLoaded = nil
end

function M:OnViewBeforeOnInit()
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

function M:View(isShow)
	super.View( self,isShow )
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

return M
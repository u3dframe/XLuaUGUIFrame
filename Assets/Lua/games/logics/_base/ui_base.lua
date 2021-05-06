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
	local _isNoC = nil
	if _cfg then
		_isNoC = _cfg.isNoCircle
	end
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.assetLType = _E_AType.UI
	_cfg.layer = _cfg.layer or _E_Layer.Normal
	_cfg.isNoCircle = _isNoC
	return _cfg;
end

function M:onMergeConfig( _cfg )
	_cfg = super.onMergeConfig( self,_cfg )
	_cfg.abName = self:ReSBegEnd( _cfg.abName,"prefabs/ui/",".ui" )
	return _cfg;
end

function M:URoot()
	return _mgr().URoot()
end

function M:GetLayer()
	return self.cfgAsset.layer
end

function M:GetCurrUILayer()
	local _lay = self:GetLayer()
	return self:URoot():GetUILayer(_lay)
end

function M:GetMutexType()
	return self.cfgAsset.hideType
end

function M:OnCF_Fab( obj )
	super.OnCF_Fab( self,obj )
	local _lf = self.lfLoaded
	self.lfLoaded = nil
	if _lf then
		_lf()
	end
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
	elseif _E_Layer.UTemp ~= _lay then
		self:URoot():SetUILayer(self)
	end
end

function M:SelfIsRoot()
	local _lay = self:GetLayer()
	if _E_Layer.URoot == _lay then
		return true
	end
end

function M:SelfIsCanHideLoading()
	local _lay = self:GetLayer()
	if _E_Layer.Main == _lay or _E_Layer.Normal == _lay then
		return true
	end
end

function M:OnInitEnd()
	self._objTopBanner = self:GetElement("ui_topbanner")
	local _lbBtns = self:GetLbBtns()
	if _lbBtns then		
		local _btnName,_btn = nil
		for _,vv in ipairs(_lbBtns) do
			_btnName = self:ReSEnd( "lbBtn",vv.name )
			if vv.ntype == 1 then
				_btn = self:NewBtnBy( vv.gobj,vv.func,vv.val,vv.isNoScale )
			elseif vv.ntype == 2 then
				_btn = self:NewBtn4UEvt( vv.name,vv.func,vv.val,vv.isNoScale,vv.isNoPrint )
			else
				_btn = self:NewBtn( vv.name,vv.func,vv.val,vv.isNoScale,vv.isNoPrint )
			end
			self[_btnName] = _btn
		end
	end
end

function M:OnShowEnd()
	self.lastShowTime = Time.time
	if self._objTopBanner then
		local resources
		if type(self.__TopResources__) == "table" then
			resources = self.__TopResources__
		elseif type(self.__TopResources__) == "function" then
			resources = self:__TopResources__()
		else
			--todo:从配置文件读取
		end
		MgrTopBanner:ShowResources(self._objTopBanner, resources)
	end

	if self:SelfIsCanHideLoading() then
		_evt.Brocast(Evt_Loading_Hide)
	end

	_evt.Brocast( Evt_UI_Showing,self:GetAbName(),self )
end

function M:View(isShow,data,...)
	self:_ReMgrView( isShow )
	super.View( self,isShow,data,... )
end

function M:_ReMgrView(isShow)
	if self:SelfIsRoot() then
		return
	end
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
	isShowMain = (isShowMain == true)
	if self.lastShowTime and isShowMain then
		local _diff = Time.time - self.lastShowTime
		if _diff <= 0.1 then
			_evt.Brocast(Evt_Popup_Tips,"Click Too fast,Please Slowly")
			return
		end
	end
	self:Set4NotClear("isCloseSelf",true)
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

	_evt.Brocast( Evt_UI_Closed,self:GetAbName(),self );

	if (not isInited) then return end

	if (_isPre == true) then
		_mgr().OpenPreUI()
	end

	if (_isClose == true) then
		if _isMain then
			_mgr().ClearPreInfo()
			if (MgrCScene:IsInCScene())then
				_evt.Brocast(Evt_OpenCSBase);--如果在公共场景不打开主界面
			else
				_evt.Brocast(Evt_ToView_Main);
			end
		else
			_mgr().SetIsOpenPreUI(_isBack)
		end
	end
end

return M
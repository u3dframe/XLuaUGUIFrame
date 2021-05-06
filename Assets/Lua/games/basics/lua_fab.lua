--[[
	-- lua_fab 的类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-04 09:25
	-- Desc : 
]]

local _func_time = os.clock
local super = LuaAsset
local M = class( "lua_fab",super )

M.AddNoClearKeys("cfgNotClear")

function M:InitBase(assetCfg)
	super.InitBase( self,assetCfg )
	self.stateView = LE_StateView.None
	self:ReEvent4OnUpdate(true)
	return self
end

function M:IsLoadedAndShow()
	return (self.isInited == true) and (self.isVisible == true) and (self.isActive == true)
end

function M:ReEvent4OnUpdate(isBind)
	isBind = (isBind == true) and (self.cfgAsset.isUpdate == true)
	super.ReEvent4OnUpdate(self,isBind)
end

function M:IsCanCircle()
	return not (self.cfgAsset.isNoCircle == true)
end

function M:VwCircle(isShow)
	if not self:IsCanCircle() then
		return
	end
	super.VwCircle( self,isShow )
end

function M:_SetVisible(state)
	if self.stateView ==  state then return end
	self.isVisible = (state == LE_StateView.Show)
	self.stateView = state

	if self.isVisible then
		self:Showing()
	elseif state == LE_StateView.Hide then
		self:Hiding()
	else
		self:Destroying()
	end
end

function M:Show()
	self:_SetVisible(LE_StateView.Show)
end

function M:Hide()
	self:_SetVisible(LE_StateView.Hide)
end

function M:Destroy()
	self:_SetVisible(LE_StateView.Destroy)
end

function M:ReShow()
	if self:IsLoadedAndShow() then
		self:_OnShow()
	else
		self:Show()
	end
end

function M:View(isShow,data,...)
	isShow = isShow == true
	if isShow then
		self.os_start_time = _func_time()
		self:SetData( data,... )
	end
	-- 显示转圈
	self:VwCircle( isShow )
	self:ShowView( isShow )
end

function M:ShowView(isShow)
	isShow = isShow == true
	if isShow then
		self:ReShow()
	else
		local _isStay = self.cfgAsset.isStay == true
		if _isStay then
			self:Hide()
		else
			self:Destroy()
		end
	end
end

function M:Showing()	
	self:OnPreShow()
	self.enabled = true
	if self._isPreLoad then
		self:_JudgeLoad()
	else
		self:_PreLoadUI()
	end
end

function M:OnPreShow()
end

function M:_PreLoadUI()
	if self._isPreLoad then return end
	self._isPreLoad = true
	self.stateLoad = LE_StateLoad.PreLoad
	self:LoadAsset()
end

function M:OnCF_Fab( obj )
	self:_JudgeLoad()
end

function M:_JudgeLoad()
	if self:IsNoLoaded() or not self:IsInitGobj() then
		return
	end

	if not self.isVisible then return end
	self:SetActive(self.enabled)

	if self.enabled then
		self:_OnView() -- 初始化
	end
end

function M:_IsLogViewTime()
	return (self.cfgAsset.isLogVTime == true) and (LOG_VIEW_USE_TIME == true)
end

function M:_OnView()
	self:ReEvent4OnUpdate(true)
	local _t1,_t2,_t3,_t4 = nil
	local _isLog = self:_IsLogViewTime()
	if _isLog then
		_t1 = _func_time()
	end

	self:OnViewBeforeOnInit() -- 初始化之前

	if _isLog then
		_t2 = _func_time()
	end

	self:_OnInit() -- 初始化

	if _isLog then
		_t3 = _func_time()
	end

	self:_OnShow() -- 显示刷新

	if _isLog then
		_t4 = _func_time()
		logMust("=== view [%s],use time , Load = [%s] ms , Before = [%s] ms , OnInit = [%s] ms , OnShow = [%s] ms , Total = [%s] ms , TotalAll = [%s] ms",self:GetAssetName(),(_t1 - self.os_start_time) * 1000,(_t2 - _t1) * 1000,(_t3 -_t2) * 1000,(_t4 -_t3) * 1000,(_t4 -_t1) * 1000,(_t4 -self.os_start_time) * 1000)
	end
end

function M:OnViewBeforeOnInit()
end

function M:OnInit()
end

function M:_OnShow()
	self:VwCircle(false)
	self:OnShowBeg()
	self:OnShow()
	self:OnShowEnd()
	self:ReEvent4Self(true)
	local _lf = self.lfOnShowOnce
	self.lfOnShowOnce = nil
	if _lf then
		_lf()
	end
end

function M:OnShowBeg()
end

function M:OnShow()
end

function M:OnShowEnd()
end

function M:Hiding(isMus)
	local _isBl = (isMus == true) or (self.enabled == true)
	if not _isBl then return end
	self:_OnHideOrDestroy(false)
end

function M:Destroying(isMus)
	local _isBl = (isMus == true) or (self._isPreLoad == true)
	if not _isBl then return end
	self:_OnHideOrDestroy(true)
end

function M:_OnHideOrDestroy(isDestroy)
	isDestroy = isDestroy == true
	self:_PreOnEnd(isDestroy)
	if isDestroy then
		self:_OnDestroy()
	else
		self:_OnHide()
	end
	self:_OnEnd(isDestroy)
end

function M:_OnHide()
	self:OnHide()
end

function M:OnHide()
end

function M:_OnDestroy()
	self:OnDestroy()
end

function M:OnDestroy()
end

function M:_PreOnEnd(isDestroy)
	self:RemoveEvents()
	self.enabled = false
	self.isVisible = false
	isDestroy = isDestroy == true
	local _tmp = self.lfPrefEnd1
	self.lfPrefEnd1 = nil
	if _tmp then
		_tmp(self.isInited)
	end

	local _tmp = self.lfPrefEnd2
	self.lfPrefEnd2 = nil
	if _tmp then
		_tmp(self.isInited)
	end

	self:PreOnEnd(isDestroy)
end

function M:PreOnEnd(isDestroy)
end

function M:_OnEnd(isDestroy)
	-- 隐藏转圈
	self:VwCircle(false)
	self:OnEnd(isDestroy)
	self:_OnExit(isDestroy)
end

function M:OnEnd(isDestroy)
end

function M:_OnExit(isDestroy)
	local _isInit = self.isInited
	if isDestroy then
		if not self:DestroyObj() then
			self:clean()
		end
	else
		self:SetActive(false)
	end

	self:OnExit(_isInit)
end

function M:OnExit(isInited)
end

function M:OnActive(isActive)
	super.OnActive( self,isActive )
	if not isActive then
		self:OnEnd(false)
	end
end

function M:OnCF_OnDestroy()
	self:_OnHideOrDestroy(true)
end

function M:pre_clean()
	self.lfPrefEnd1,self.lfPrefEnd2,self.lfOnShowOnce = nil
	super.pre_clean( self )
end

function M:Set4NotClear(kk,vv)
	self.cfgNotClear = self.cfgNotClear or {}
	self.cfgNotClear[kk] = vv
end

function M:Get4NotClear(kk)
	if self.cfgNotClear then
		return self.cfgNotClear[kk]
	end
end

function M:Clear4NotClear( ... )
	if not self.cfgNotClear then return end
	local nLens = self:Lens4Pars( ... )
	if nLens <= 0 then return end
	local _args = { ... }
	for _, v in ipairs(_args) do
		self.cfgNotClear[v] = nil
	end
end

function M:ClearAll4NotClear()
	self.cfgNotClear = {}
end

return M
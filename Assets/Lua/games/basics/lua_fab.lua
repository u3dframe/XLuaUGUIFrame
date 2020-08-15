--[[
	-- lua_fab 的类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-04 09:25
	-- Desc : 
]]

local _func_time = nil
local super = LuaAsset
local M = class( "lua_fab",super )

function M:ctor(assetCfg)
	super.ctor( self,assetCfg )
	self.stateView = LE_StateView.None
	self:ReEvent4OnUpdate(true)
end

function M:IsLoadedAndShow()
	return (self.isInited == true) and (self.isVisible == true) and (self.isActive == true)
end

function M:ReEvent4OnUpdate(isBind)
	isBind = (isBind == true) and (self.cfgAsset.isUpdate == true)
	super.ReEvent4OnUpdate(self,isBind)
end

function M:IsVwCircle4Load()
	return (self.cfgAsset.isVwCircle == true)
end

function M:VwCircle(isShow)
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
		self:SetData( data,... )
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
	if self.PreShow then
		self:PreShow()
	end

	if self:IsVwCircle4Load() then
		-- 显示转圈
		self:VwCircle(true)
	end

	self.enabled = true
	self:_PreLoadUI()
	self:_JudgeLoad()
end

function M:_PreLoadUI()
	if self._isPreLoad then return end
	self._isPreLoad = true
	self.stateLoad = LE_StateLoad.PreLoad
	self:LoadAsset()
end

function M:OnCF_Fab( obj )
	if self:IsInitGobj() then
		self:_JudgeLoad()
	else
		local _isBl,_abName,_assetName,_ltp = self:CfgAssetInfo()
		error("=== asset not exit = [%s] = [%s] = [%s] = [%s]",_isBl,_abName,_assetName,_ltp)
	end
end

function M:_JudgeLoad()
	if self:IsNoLoaded() then return end
	if self:IsVwCircle4Load() then
		-- 隐藏转圈
		self:VwCircle(false)
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
		_func_time = _func_time or os.clock
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
		logMust("=== view [%s],use time,Before = [%s],OnInit = [%s], OnShow = [%s]",self:GetAssetName(),(_t2 - _t1),(_t3 -_t2),(_t4 -_t3))
	end
end

function M:OnViewBeforeOnInit()
end

function M:OnInit()
end

function M:_OnShow()
	self:OnShow()
	self:ReEvent4Self(true)
end

function M:OnShow()
end

function M:Hiding(isMus)
	local _isBl = (isMus == true) or (self.enabled == true)
	if not _isBl then return end
	self:_PreOnEnd(false)
	self:_OnHide()
	self:_OnEnd(false)
end

function M:_OnHide()
	self:OnHide()
end

function M:OnHide()
end

function M:Destroying(isMus)
	local _isBl = (isMus == true) or (self._isPreLoad == true)
	if not _isBl then return end
	self:_PreOnEnd(true)
	self:_OnDestroy()
	self:_OnEnd(true)
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

M.AddNoClearKeys("cfgAsset","cfgNotClear")

return M
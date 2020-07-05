--[[
	-- lua_fab 的类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-04 09:25
	-- Desc : 
]]
local cfg_backup = {}
local str_format = string.format

local super = LuaAsset
local M = class( "lua_fab",super )

function M:ctor(assetCfg)
	super.ctor( self,assetCfg )
	self.stateLoad = LE_StateLoad.None;
	self.stateView = LE_StateView.None;
end

function M:IsLoadedAndShow()
	return (self.isInited == true) and (self.isVisible == true) and (self.isActive == true)
end

function M:IsVwCircle4Load()
	return (self.cfgAsset.isVwCircle == true)
end

function M:VwCircle(isShow)
end

function M:SetVisible(state)
	if self.stateView ==  state then return end
	self.isVisible = (state == LE_StateView.Show);
	self.stateView = state;

	if self.isVisible then
		self:Showing()
	elseif state == LE_StateView.Hide then
		self:Hiding()
	else
		self:Destroying()
	end
end

function M:Show()
	self:SetVisible(LE_StateView.Show)
end

function M:Hide()
	self:SetVisible(LE_StateView.Hide)
end

function M:Destroy()
	self:SetVisible(LE_StateView.Destroy)
end

function M:ReShow()
	if self:IsLoadedAndShow() then
		self:_OnShow()
	else
		self:Show()
	end
end

function M:View(isShow)
	isShow = isShow == true;
	if isShow then
		self:ReShow()
	else
		local _isStay = self.cfgAsset.isStay == true;
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
	self._isPreLoad = true;
	self.stateLoad = LE_StateLoad.PreLoad;
	self:LoadAsset()
end

function M:OnCF_Fab( obj )
	if self:IsInitGobj() then
		self:_JudgeLoad()
	else
		local _isBl,_abName,_assetName,_ltp = self:CfgAssetInfo();
		error("=== asset not exit = [%s] = [%s] = [%s] = [%s]",_isBl,_abName,_assetName,_ltp)
	end
end

function M:_JudgeLoad()
	if self.stateLoad ~= LE_StateLoad.Loaded then return end
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

function M:_OnView()
	self:_OnInit() -- 初始化
	self:_OnShow() -- 显示刷新
end

function M:_OnInit()
	if self.isInited then return end
	self.isInited = true
	self:OnInit();
end

function M:OnInit()
end

function M:_OnShow()
	self:OnShow();
end

function M:OnShow()
end

function M:Hiding(isMus)
	local _isBl = (isMus == true) or (self.enabled == true and self.isVisible == true);
	if not _isBl then return end
	self.enabled = false
	self:_OnHide()
	self:OnEnd(false)
end

function M:_OnHide()
	self:OnHide();
end

function M:OnHide()
end

function M:Destroying(isMus)
	local _isBl = (isMus == true) or (self._isPreLoad == true);
	if not _isBl then return end
	self.enabled = false
	self.isVisible = false
	self:_OnDestroy()
	self:OnEnd(true);
end

function M:_OnDestroy()
	self:OnDestroy();
end

function M:OnDestroy()
end

function M:OnEnd(isDestroy)
	isDestroy = isDestroy == true;
	local _tmp = self.prefFuncEnd;
	self.prefFuncEnd = nil
	local _isInit = self.isInited
	if _tmp then
		_tmp(_isInit)
	end

	if isDestroy then
		if not self:DestroyObj() then
			self:clean()
		end
	end
end

function M:pre_clean()
	super.pre_clean( self )
	
	local _key = str_format("%s",self)
	cfg_backup[_key] = self.cfgAsset;
	self.cfgAsset = nil
end

function M:clean_end()
	super.clean_end( self )

	local _key = str_format("%s",self)
	local _cfgAsset = cfg_backup[_key];
	self.cfgAsset = _cfgAsset
	cfg_backup[_key] = nil
end

return M
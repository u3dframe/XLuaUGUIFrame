--[[
	-- 组件 component
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local super = LUTrsf
local M = class( "lua_component",super )
local this = M

function M.CsIsGLife(comp)
	if comp ~= nil then
		return CHelper.IsGLife(comp)
	end
	return false
end

function M:makeComp( gobj,component )
	return M.New( gobj,component )
end

function M:ctor( obj,component )
	super.ctor(self,obj)
	self._cf_ondestroy = self._cf_ondestroy or handler(self,self.OnCF_Destroy)
	self:InitComp(component)
end

function M:IsInitComp()
	return self.comp ~= nil;
end

function M:IsInitGLife()
	return self.compGLife ~= nil;
end

function M:InitComp( component )
	if not component then
		return
	end

	if not self.comp then
		local com = component;
		if type(component) == "string" then
			com = self:GetComponent( component )
		end
		self.comp = com
		self.strComp = tostring(component)

		local _islife = self:IsGLife()
		if _islife then
			self.compGLife = self.comp
		else
			self.compGLife = CGobjLife.Get(self.gobj)
		end
		self:ReEvtDestroy(true)
	end
end

function M:DestroyObj()
	self.comp = nil
	return super.DestroyObj(self)
end

function M:OnCF_Destroy()
	self:OnCF_BegOnDestroy()
	self:clean()
	self:OnCF_OnDestroy()
end

function M:OnCF_BegOnDestroy()
end

function M:OnCF_OnDestroy()
end

function M:ReEvtDestroy(isBind)
	return pcall(self._ReEvtDestroy,self,isBind)
end

function M:IsGLife()
	if not self.comp then
		return false
	end
	local _k = self:SFmt("__isGLife_%s",self.strComp)
	local _v = self[_k]
	if _v == nil then
		_v = this.CsIsGLife(self.comp)
		self[_k] = _v
	end
	return _v
end

function M:_ReEvtDestroy(isBind)
	if not self._cf_ondestroy or not self:IsInitGLife() then
		return
	end
	self.compGLife:m_onDestroy("-",self._cf_ondestroy);
	if isBind == true then
		self.compGLife:m_onDestroy("+",self._cf_ondestroy);
	end
end

function M:SetCF4OnShow( cfShow )
	if not self:IsInitGLife() then
		return
	end
	self.isSetCFOnShow = (cfShow ~= nil)
	self.compGLife.m_callShow = cfShow;
end

function M:SetCF4OnHide( cfHide )
	if not self:IsInitGLife() then
		return
	end
	self.isSetCFOnHide = (cfHide ~= nil)
	self.compGLife.m_callHide = cfHide;
end

function M:SetEnabled( isBl )
	if self:IsInitComp() then
		self.comp.enabled = (isBl == true);
	end
end

function M:_OnUpdate(dt)
	super._OnUpdate( self,dt )
	if self:IsNoLoaded() then return end
	self:OnUpdateLoaded(dt)
end

function M:IsNoLoaded() return (not self:IsInitTrsf()) end
function M:OnUpdateLoaded(dt) end

function M:pre_clean()
	super.pre_clean( self )
	self:ReEvtDestroy(false)
	if self.isSetCFOnShow then self:SetCF4OnShow() end
	if self.isSetCFOnHide then self:SetCF4OnHide() end
end

return M
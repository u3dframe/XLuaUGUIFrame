--[[
	-- 组件 component
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local type,tostring = type,tostring
local super = LUTrsf
local M = class( "lua_component",super )
local this = M

function M:ctor( obj,component )
	super.ctor(self,obj)
	self._cf_ondestroy = self._cf_ondestroy or handler(self,self.OnCF_Destroy)
	self._cf_onshow = self._cf_onshow or handler(self,self.OnCF_Show)
	self._cf_onhide = self._cf_onhide or handler(self,self.OnCF_Hide)
	self:InitComp(component)
end

function M:IsInitComp()
	return self.comp ~= nil;
end

function M:InitComp( component )
	if not component then
		return
	end

	if not self.comp then
		if self:IsNeedGetComp() then
			component = self:GetComponent( component )
		end
		self.csEDComp:InitComp( component,self._cf_ondestroy,self._cf_onshow,self._cf_onhide )
		self.comp = self.csEDComp.m_comp
	end
end

function M:OnCF_Destroy()
	self:OnCF_BegOnDestroy()
	self:OnCF_OnDestroy()
	self:clean()
	self:OnCF_EndOnDestroy()
end

function M:OnCF_BegOnDestroy()
end

function M:OnCF_OnDestroy()
end

function M:OnCF_EndOnDestroy()
end

function M:OnCF_Show()
end

function M:OnCF_Hide()
end

function M:SetEnabled( isBl )
	if self:IsInitGobj() then
		self.csEDComp:SetEnabled(isBl == true)
	end
end

function M:OnUpdateAll(dt,unscaledDt)
	super.OnUpdateAll( self,dt,unscaledDt )
	if self:IsNoLoaded() then return end
	self:OnUpdateLoaded( dt,unscaledDt )
end

function M:IsNoLoaded() return (not self:IsInitGobj()) end
function M:OnUpdateLoaded(dt,unscaledDt) end

return M
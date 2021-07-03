--[[
	-- 组件 component
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local tonumber,type,tostring = tonumber,type,tostring
local tb_contains = table.contains

local _not_cf_comp = { "UGUICanvasAdaptive","MainCameraManager","RectTransform","CtrlCamera" }

local super = LUTrsf
local M = class( "lua_component",super )
local this = M

function M:ctor( obj,component )
	super.ctor(self,obj)
	self:InitComp(component)
end

function M:IsInitComp()
	return self.comp ~= nil;
end

function M:_GetCFComp()
	if tb_contains( _not_cf_comp,self.compStr ) then
		return
	end
	self._cf_onlife = self._cf_onlife or handler(self,self.OnCF_Life)
	return self._cf_onlife
end

function M:InitComp( component )
	if not component then
		return
	end

	if not self.comp then
		if self:IsNeedGetComp() then
			component = self:GetComponent( component )
		end
		self.compStr = tostring( component )

		local _flife = self:_GetCFComp()
		self.csEDComp:InitComp( component,_flife )
		self.comp = self.csEDComp.m_comp
	end
end

function M:OnCF_Life(valInt)
	valInt = tonumber(valInt) or 0
	self.nLife = valInt
	if self.nLife == 1 then
		self:OnCF_Show()
	elseif self.nLife == 2 then
		self:OnCF_Destroy()
	else
		self:OnCF_Hide()
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
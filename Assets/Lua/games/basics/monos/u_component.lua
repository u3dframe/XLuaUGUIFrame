--[[
	-- 组件 component
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local super = LUTrsf
local M = class( "lua_component",super )

function M:makeComp( gobj,component )
	return M.New( gobj,component )
end

function M:ctor( obj,component )
	super.ctor(self,obj)
	self._cf_ondestroy = self._cf_ondestroy or handler(self,self.OnCF_Destroy)
	self:InitComp(component)
end

function M:IsInitComp( )
	return self.comp ~= nil;
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
		if com then
			self:ReEvtDestroy(true)
		else
			printError( "=== can't find compnent by [%s] , gname = [%s]", component,self.g_name )
		end
	end
end

function M:DestroyObj()
	self.comp = nil
	return super.DestroyObj(self)
end

function M:OnCF_Destroy()
	self:clean()
end

function M:ReEvtDestroy(isBind)
	return pcall(self._ReEvtDestroy,self,isBind)
end

function M:IsGLife(comp)
	comp = comp or self.comp
	if not comp then
		return false
	end
	return CHelper.IsGLife(comp)
end

function M:_ReEvtDestroy(isBind)
	if not self._cf_ondestroy or not self:IsGLife() then
		return
	end
	self.comp:m_onDestroy("-",self._cf_ondestroy);
	if isBind == true then
		self.comp:m_onDestroy("+",self._cf_ondestroy);
	end
end

function M:SetEnabled( isBl )
	if self:IsInitComp() then
		self.comp.enabled = (isBl == true);
	end
end

function M:SetActive( isActive )
	super.SetActive( self,isActive )
	self:SetEnabled( self.isActive )
end

function M:_OnUpdate(dt)
	super._OnUpdate( self,dt )
	if self:IsNoLoaded() then return end
	self:OnUpdateLoaded(dt)
end

function M:IsNoLoaded() return (not self:IsInitTrsf()) end
function M:OnUpdateLoaded(dt) end

return M
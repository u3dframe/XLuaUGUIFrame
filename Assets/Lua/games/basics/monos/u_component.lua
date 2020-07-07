--[[
	-- 组件 component
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local super = LUTrsf
local M = class( "lua_component",super )

function M:ctor( obj, component )
	super.ctor(self,obj)
	self._cf_ondestroy = self._cf_ondestroy or handler(self,self.OnCF_Destroy)
	local com = self:GetComponent( component )
	if com then
		self:ReEvtDestroy(true)
	else
		printError( "can't find compnent by %s", component )
	end
	self.comp = com
end

function M:IsInitComp( )
	return self.comp ~= nil;
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

function M:_ReEvtDestroy(isBind)
	if not self._cf_ondestroy then
		return
	end
	self.comp:m_onDestroy("-",self._cf_ondestroy);
	if isBind == true then
		self.comp:m_onDestroy("+",self._cf_ondestroy);
	end
end

return M
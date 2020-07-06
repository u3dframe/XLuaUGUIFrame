--[[
	-- gameObject
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local super = LuaObject
local M = class( "lua_gobj",super )

function M:ctor( obj )
	assert( obj )
	super.ctor(self)
	self.obj = obj
	self.objType = type(obj)
	self.gobj = obj.gameObject or obj.gobj
end

function M:IsInitGobj()
	return self.gobj ~= nil;
end

function M:IsActive( )
	return self.isActive == true;
end

function M:GetComponent( com )
	return self.gobj:GetComponent( com )
end

function M:SetActive( isActive )
	isActive = isActive == true
	if self.isActive == nil or isActive ~= self.isActive then
		self.isActive = isActive
		self.gobj:SetActive( self.isActive )
	end
end

function M:IsActiveInView( )
	if self:IsInitGobj() then
		return self:IsActive() and self.gobj.activeInHierarchy;
	end
end

function M:DestroyObj()
	local _gobj = self.gobj
	self.gobj = nil
	if _gobj ~= nil then
		UGameObject.Destroy(_gobj);
		return true
	end
end

return M
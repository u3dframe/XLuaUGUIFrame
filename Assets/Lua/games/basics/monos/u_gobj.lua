--[[
	-- gameObject
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local str_format = string.format

local super = LuaObject
local M = class( "lua_gobj",super )
local this = M

function M.Destroy(gobj)
	if gobj ~= nil then
		UGameObject.Destroy(gobj);
		return true;
	end
end

function M.DontDestroyOnLoad(gobj)
	if gobj ~= nil then
		UGameObject.DontDestroyOnLoad(gobj);
		return true;
	end
end

function M:makeGobj( gobj )
	return M.New( gobj )
end

function M:ctor( obj )
	assert( obj,"gobj is null" )
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
	local _k = str_format("__com_%s",com)
	if not self[_k] then 
		self[_k] = self.gobj:GetComponent( com )
	end
	return self[_k]
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
	return this.Destroy(_gobj)
end

function M:DonotDestory( )
	this.DontDestroyOnLoad(self.gobj)
end

return M
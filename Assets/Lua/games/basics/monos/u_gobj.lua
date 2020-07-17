--[[
	-- gameObject
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]

local super = LuaObject
local M = class( "lua_gobj",super )
local this = M

function M.CsDestroy(gobj)
	if gobj ~= nil then
		UGameObject.Destroy(gobj);
		return true;
	end
end

function M.CsDontDestroyOnLoad(gobj)
	if gobj ~= nil then
		UGameObject.DontDestroyOnLoad(gobj);
		return true;
	end
end

function M.CsClone(gobj)
	if gobj ~= nil then
		return CHelper.Clone(gobj);	
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
	self.g_name = self.gobj.name
end

function M:IsInitGobj()
	return self.gobj ~= nil;
end

function M:IsActive( )
	return self.isActive == true;
end

function M:GetComponent( com )
	local _k = self:SFmt("__com_%s",com)
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

function M:Clone()
	return this.CsClone(self.gobj)
end

function M:DestroyObj()
	local _gobj = self.gobj
	self.gobj = nil
	return this.CsDestroy(_gobj)
end

function M:DonotDestory( )
	this.CsDontDestroyOnLoad(self.gobj)
end

return M
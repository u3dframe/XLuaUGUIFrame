--[[
	-- gameObject
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]

local super = LuaObject
local M = class( "lua_gobj",super )
local this = M

function M.CsDestroy(gobj,isImmediate)
	if gobj ~= nil then
		if isImmediate == true then
			UGameObject.DestroyImmediate( gobj,true )
		else
			UGameObject.Destroy(gobj);
		end
		return true;
	end
end

function M.CsFindGobj(name)
	if name ~= nil then
		return UGameObject.Find( name );
	end
end

function M.CsNewGobj(name)
	if name ~= nil then
		return UGameObject( name );
	end
	return UGameObject();
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

function M.CsCloneP2(gobj,parent)
	if gobj ~= nil then
		return CHelper.Clone(gobj,parent);
	end
end

function M:ctor( obj )
	assert( obj,"gobj is null" )
	super.ctor(self)
	self.obj = obj
	self.objType = type(obj)
	self.gobj = obj.gameObject or obj.gobj
	self.g_name = self.gobj.name
	self.isActive = self.gobj.activeSelf

	self:_ExecuteAsync_Gobj()
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
	self._async_active = nil
	if self:IsInitGobj() then
		if self.isActive == nil or isActive ~= self.isActive then
			self.isActive = isActive
			self.gobj:SetActive( self.isActive )
		end
		self:OnActive(self.isActive)
	else
		self._async_active = isActive
	end
end

function M:OnActive(isActive)
end

function M:SetGName(gname)
	if (not gname) or ("" == gname) or (gname == self.g_name) then
		return
	end
	self.g_name = gname
	self.gobj.name = gname
end

function M:SetLayer( layer,isAll )
	isAll = isAll == true
	self._async_layer,self._async_layer_all = nil
	if self:IsInitGobj() then
		CHelper.SetLayerBy( self.gobj,layer,isAll )
	else
		self._async_layer,self._async_layer_all = layer,isAll
	end
end

function M:IsActiveInView( )
	if self:IsInitGobj() then
		return self:IsActive() and self.gobj.activeInHierarchy;
	end
end

function M:Clone(parent)
	if parent then
		parent = ("nil" ~= parent and "null" ~= parent) and parent or nil
		return this.CsCloneP2(self.gobj,parent)
	end
	return this.CsClone(self.gobj)
end

function M:DestroyObj()
	local _gobj = self.gobj
	self.gobj = nil
	return this.CsDestroy( _gobj,true )
end

function M:DonotDestory( )
	this.CsDontDestroyOnLoad(self.gobj)
end

function M:_ExecuteAsync_Gobj()
	if self._async_layer ~= nil then
		self:SetLayer( self._async_layer,self._async_layer_all )
	end

	if self._async_active ~= nil then
		self:SetActive( self._async_active )
	end
end

return M
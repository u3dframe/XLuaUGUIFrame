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
	local _isTab = self.objType == "table"
	local _gobj,_csEDComp,_trsf = obj
	if _isTab then
		_csEDComp = obj.csEDComp
		_trsf = obj.trsf
		_gobj = obj.gobj
	end
	_csEDComp = _csEDComp or self:BuilderUObj( _gobj )
	self.csEDComp = _csEDComp
	self.gobj = _isTab and _gobj or _csEDComp.m_gobj
	self.trsf = _trsf or _csEDComp.m_trsf
	self:_ExecuteAsync_Gobj()
end

function M:BuilderUObj( uobj )
	return CEDComp.Builder( uobj )
end

function M:IsInitGobj()
	return self.csEDComp ~= nil;
end

function M:IsActive( )
	return self.isActive == true;
end

function M:IsNeedGetComp()
	return false
end

function M:GetComponent( com )
	local _k = self:SFmt("__com_%s",com)
	if not self[_k] then 
		self[_k] = self.csEDComp:GetComponent( com )
	end
	return self[_k]
end

function M:SetActive( isActive )
	isActive = isActive == true
	self._async_active = nil
	if self:IsInitGobj() then
		if self.isActive == nil or isActive ~= self.isActive then
			self.isActive = isActive
			self.csEDComp:SetActive( self.isActive )
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
	self.csEDComp:SetGName(gname)
end

function M:SetLayer( layer,isAll )
	isAll = isAll == true
	self._async_layer,self._async_layer_all = nil
	if self:IsInitGobj() then
		self.csEDComp:SetLayer( layer,isAll )
	else
		self._async_layer,self._async_layer_all = layer,isAll
	end
end

function M:IsActiveInView( )
	if self:IsInitGobj() then
		return self.csEDComp.m_isActiveInView;
	end
end

function M:Clone(parent)
	if self:IsInitGobj() then
		return self.csEDComp:Clone(parent)
	end
end

function M:DestroyObj()
	if self:IsInitGobj() then
		return self.csEDComp:DestroyObj();
	end
end

function M:DonotDestory( )
	if self:IsInitGobj() then
		return self.csEDComp:DonotDestory()
	end
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
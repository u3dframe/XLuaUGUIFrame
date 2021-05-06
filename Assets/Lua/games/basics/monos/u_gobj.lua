--[[
	-- gameObject
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]

local tonumber,type,tostring = tonumber,type,tostring
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
	if Is_GNMRelative then
		self.g_name = CHelper.RelativeName( self.gobj )
	end
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
			self:OnActive(self.isActive)
		end
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

function M:DestroyObj(isImmediate)
	if self:IsInitGobj() then
		isImmediate = (isImmediate == true)
		return self.csEDComp:DestroyObj( isImmediate );
	end
end

function M:on_clean_comp()
	super.on_clean_comp( self )
	if self:IsInitGobj() then
		return self.csEDComp:Destroy4NoLife();
	end
end

function M:DonotDestory( )
	if self:IsInitGobj() then
		return self.csEDComp:DonotDestory()
	end
end

function M:AddAnimationEvent(stateName,...)
	if self:IsInitGobj() then
		local _lens = self:Lens4Pars(...)
		if _lens >= 2 then
			local _t,_k,_v = { ... }
			for i = 1,_lens,2 do
				_k,_v = tonumber(_t[i]),tonumber(_t[i+1])
				if _k and _v then
					self.csEDComp:AddAnimationEvent( stateName,_k,_v )
				end
			end
		end
	end
end

function M:RmvAnimationEvent(stateName)
	if self:IsInitGobj() then
		if stateName then
			self.csEDComp:RmvAnimationEvent( stateName )
		else
			self.csEDComp:RmvAllRmvAnimationEvent()
		end
	end
end

function M:PlayAnimator(stateName,isOrder,callEnd,speed,unique)
	isOrder = isOrder == true
	unique = (unique or LE_Anim_Unique[stateName]) or 0
	speed = tonumber(speed) or 1
	self._async_anim = nil
	if self:IsInitGobj() then
		self.csEDComp:PlayAnimator( stateName,isOrder,speed,unique,callEnd )
	else
		self._async_anim = { stateName,isOrder,speed,unique,callEnd }
	end
end

function M:ReAnimator()
	self._async_anim = nil
	if self:IsInitGobj() then
		self.csEDComp:ReAnimator()
	end
end

function M:_ExecuteAsync_Gobj()
	if self._async_layer ~= nil then
		self:SetLayer( self._async_layer,self._async_layer_all )
	end

	if self._async_active ~= nil then
		self:SetActive( self._async_active )
	end

	if self._async_anim ~= nil then
		local _a = self._async_anim
		self:PlayAnimator( _a[1],_a[2],_a[5],_a[3],_a[4] )
	end
end

return M
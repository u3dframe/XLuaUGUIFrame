--[[
	-- transform
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]

local _vec3,_vec2,type = Vector3,Vector2,type

local super = LUGobj
local M = class( "lua_transform",super )

function M:ctor( obj,isInitVecs )
	super.ctor(self,obj)
	self:_CreateVecs()
	if isInitVecs == true then
		self:_InitVecs()
	end
	self:_ExecuteAsync_Trsf()
end

function M:_CreateVecs()
	self.v3Pos = self.v3Pos or _vec3.zero
	self.v2AncPos = self.v2AncPos or _vec2.zero
end

function M:_InitVecs()
	self:GetPosition()
	self:GetAnchoredPosition()
end

function M:IsInitTrsf()
	return self:IsInitGobj();
end

function M:_ReXYZ( vec,x,y,z )
	self:ReVec_XYZ( vec,x,y,z,9 )
end

function M:GetChildCount( )
	return self.csEDComp.m_childCount;
end

function M:GetChild( nIndex )
	nIndex = self:TInt( nIndex )
	return self.csEDComp:GetChild( nIndex )
end

function M:GetPosition()
	if self:IsInitTrsf() then
		local _tmp = self.csEDComp:GetPosition()
		self.v3Pos:Set(_tmp.x,_tmp.y,_tmp.z)
	end
	return self.v3Pos
end

function M:SetPosition( x,y,z )
	self._async_px,self._async_py,self._async_pz = nil
	if self:IsInitTrsf() then
		self:_ReXYZ(self.v3Pos,x,y,z)
		x,y,z = self.v3Pos:Get()
		self.csEDComp:SetPosition( x,y,z )
	else
		self._async_px,self._async_py,self._async_pz = x,y,z
	end
end

function M:SetLocalPosition( x,y,z )
	self._async_lpx,self._async_lpy,self._async_lpz = nil
	if self:IsInitTrsf() then
		x,y,z = self:ReXYZ( x,y,z,6 )
		self.csEDComp:SetLocalPosition( x,y,z )
	else
		self._async_lpx,self._async_lpy,self._async_lpz = x,y,z
	end
end

function M:SetLocalScale( x,y,z )
	self._async_lsx,self._async_lsy,self._async_lsz = nil
	if self:IsInitTrsf() then
		y = y or x
		z = z or x
		x,y,z = self:ReXYZ( x,y,z,6 )
		self.csEDComp:SetLocalScale( x,y,z )
	else
		self._async_lsx,self._async_lsy,self._async_lsz = x,y,z
	end
end

function M:SetEulerAngles( x,y,z )
	self._async_ax,self._async_ay,self._async_az = nil
	if self:IsInitTrsf() then
		x,y,z = self:ReXYZ( x,y,z,6 )
		self.csEDComp:SetEulerAngles( x,y,z )
	else
		self._async_ax,self._async_ay,self._async_az = x,y,z
	end
end

function M:GetEulerAngles( isVec )
	isVec = (isVec == true)
	local _x,_y,_z,_v = 0,0
	if self:IsInitTrsf() then
		_v = self.csEDComp:GetEulerAngles()
		_x,_y,_z = _v.x,_v.y,_v.z
	end
	if isVec then
		self.v3Angle = self.v3Angle or _vec3.zero
		self:_ReXYZ( self.v3Angle,_x,_y,_z )
		return self.v3Angle
	end
	return _x,_y,_z
end

function M:SetLocalEulerAngles( x,y,z )
	self._async_lax,self._async_lay,self._async_laz = nil
	if self:IsInitTrsf() then
		x,y,z = self:ReXYZ( x,y,z,6 )
		self.csEDComp:SetLocalEulerAngles( x,y,z )
	else
		self._async_lax,self._async_lay,self._async_laz = x,y,z
	end
end

function M:SetForward( x,y,z )
	self._async_fx,self._async_fy,self._async_fz = nil
	if self:IsInitTrsf() then
		x,y,z = self:ReXYZ( x,y,z,6 )
		self.csEDComp:SetForward( x,y,z )
	else
		self._async_fx,self._async_fy,self._async_fz = x,y,z
	end
end

function M:GetForward()
	local _fwd = self.csEDComp:GetForward()
	return _fwd.x,_fwd.y,_fwd.z
end

function M:SetAnchoredPosition3D( x,y,z )
	self._async_ap3x,self._async_ap3y,self._async_ap3z = nil
	if self:IsInitTrsf() then
		x,y,z = self:ReXYZ( x,y,z,6 )
		self.csEDComp:SetAnchoredPosition3D( x,y,z )
	else
		self._async_ap3x,self._async_ap3y,self._async_ap3z = x,y,z
	end
end

function M:GetAnchoredPosition()
	local _tmp = self.csEDComp:GetAnchoredPosition()
	self.v2AncPos:Set(_tmp.x,_tmp.y)
	return self.v2AncPos
end

function M:SetAnchoredPosition( x,y )
	self._async_apx,self._async_apy = nil
	if self:IsInitTrsf() then
		self:_ReXYZ(self.v2AncPos,x,y)
		x,y = self.v2AncPos:Get()
		self.csEDComp:SetAnchoredPosition( x,y )
	else
		self._async_apx,self._async_apy = x,y
	end
end

function M:SetAnchorMin( x,y )
	self._async_aminx,self._async_aminy = nil
	if self:IsInitTrsf() then
		x,y = self:ReXYZ( x,y,0,6 )
		self.csEDComp:SetAnchorMin( x,y )
	else
		self._async_aminx,self._async_aminy = x,y
	end
end

function M:SetAnchorMax( x,y )
	self._async_amaxx,self._async_amaxy = nil
	if self:IsInitTrsf() then
		x,y = self:ReXYZ( x,y,0,6 )
		self.csEDComp:SetAnchorMax( x,y )
	else
		self._async_amaxx,self._async_amaxy = x,y
	end
end

function M:SetPivot( x,y )
	self._async_pix,self._async_piy = nil
	if self:IsInitTrsf() then
		x,y = self:ReXYZ( x,y,0,6 )
		self.csEDComp:SetPivot( x,y )
	else
		self._async_pix,self._async_piy = x,y
	end
end

function M:GetPivot( isV2 )
	isV2 = (isV2 == true)
	local _x,_y,_v = 0,0
	if self:IsInitTrsf() then
		_v = self.csEDComp:GetPivot()
		_x,_y = _v.x,_v.y
	end
	if isV2 then
		self.v2Pivot = self.v2Pivot or _vec2.zero
		self:_ReXYZ( self.v2Pivot,_x,_y )
		return self.v2Pivot
	end
	return _x,_y
end

function M:SetSizeDelta( x,y )
	self._async_sdx,self._async_sdy = nil
	if self:IsInitTrsf() then
		x,y = self:ReXYZ( x,y,0,6 )
		self.csEDComp:SetSizeDelta( x,y )
	else
		self._async_sdx,self._async_sdy = x,y
	end
end

function M:GetRectSize( )
	if not self:IsInitTrsf() then return 0,0 end
	local w,h = self.csEDComp:GetRectSize(0,0);
	return w,h;
end

function M:SetParent( parent,isLocal,isSyncLayer )
	isLocal = (isLocal == true)
	self._async_parent,self._async_isLocal = nil
	if self:IsInitTrsf() then
		self.csEDComp:SetParent( parent,isLocal,isSyncLayer == true )
	else
		self._async_parent,self._async_isLocal = parent,isLocal
	end
end

function M:LookAt( x,y,z )
	self._async_look_x,self._async_look_y,self._async_look_z = nil
	if self:IsInitTrsf() then
		x,y,z = self:ReXYZ( x,y,z,6 )
		self.csEDComp:LookAt( x,y,z )
	else
		self._async_look_x,self._async_look_y,self._async_look_z = x,y,z
	end
end

function M:TranslateWorld( x,y,z )
	x,y,z = self:ReXYZ( x,y,z,6 )
	self.csEDComp:TranslateWorld( x,y,z )
end

function M:AddLocalPosByV3( vec3 )
	local x,y,z = self:ReXYZ( vec3.x,vec3.y,vec3.z,6 )
	self.csEDComp:AddLocalPos( x,y,z )
end

function M:GetSiblingIndex()
	return self.csEDComp:GetSiblingIndex()
end

function M:SetSiblingIndex( bIndex )
	bIndex = tonum(bIndex) or 0
	self.csEDComp:SetSiblingIndex( bIndex )
end

function M:SetAsFirstSibling()
	self.csEDComp:SetAsFirstSibling()
end

function M:SetAsLastSibling()
	self.csEDComp:SetAsLastSibling()
end

function M:SmoothPos( x,y,z,stime,isLocal )
	if not (x and y and z) then
		return
	end

	if self:IsInitGobj() then
		isLocal = isLocal == true
		stime = tonumber(stime) or 0.1
		self.csEDComp:ToSmoothPos( x,y,z,isLocal,stime )
	end
end

function M:_ExecuteAsync_Trsf()
	if self._async_isLocal ~= nil then
		self:SetParent( self._async_parent,self._async_isLocal )
	end

	if self._async_px ~= nil or self._async_py ~= nil or self._async_pz ~= nil then
		self:SetPosition( self._async_px,self._async_py,self._async_pz )
	end

	if self._async_lpx ~= nil or self._async_lpy ~= nil or self._async_lpz ~= nil then
		self:SetLocalPosition( self._async_lpx,self._async_lpy,self._async_lpz )
	end

	if self._async_lsx ~= nil or self._async_lsy ~= nil or self._async_lsz ~= nil then
		self:SetLocalScale( self._async_lsx,self._async_lsy,self._async_lsz )
	end

	if self._async_ax ~= nil or self._async_ay ~= nil or self._async_az ~= nil then
		self:SetEulerAngles( self._async_ax,self._async_ay,self._async_az )
	end

	if self._async_lax ~= nil or self._async_lay ~= nil or self._async_laz ~= nil then
		self:SetLocalEulerAngles( self._async_lax,self._async_lay,self._async_laz )
	end

	if self._async_fx ~= nil or self._async_fy ~= nil or self._async_fz ~= nil then
		self:SetForward( self._async_fx,self._async_fy,self._async_fz )
	end

	if self._async_ap3x ~= nil or self._async_ap3y ~= nil or self._async_ap3z ~= nil then
		self:SetAnchoredPosition3D( self._async_ap3x,self._async_ap3y,self._async_ap3z )
	end

	if self._async_apx ~= nil or self._async_apy ~= nil then
		self:SetAnchoredPosition( self._async_apx,self._async_apy )
	end

	if self._async_aminx ~= nil or self._async_aminy ~= nil then
		self:SetAnchorMin( self._async_aminx,self._async_aminy )
	end

	if self._async_amaxx ~= nil or self._async_amaxy ~= nil then
		self:SetAnchorMax( self._async_amaxx,self._async_amaxy )
	end

	if self._async_pix ~= nil or self._async_piy ~= nil then
		self:SetPivot( self._async_pix,self._async_piy )
	end

	if self._async_sdx ~= nil or self._async_sdy ~= nil then
		self:SetSizeDelta( self._async_sdx,self._async_sdy )
	end

	if self._async_look_x ~= nil or self._async_look_y ~= nil or self._async_look_z ~= nil then
		self:LookAt( self._async_look_x,self._async_look_y,self._async_look_z )
	end
end

function M:Find(childName)
	return self.csEDComp:Find( childName )
end

function M:FindGobj(childName)
	return self.csEDComp:FindGobj( childName )
end

return M
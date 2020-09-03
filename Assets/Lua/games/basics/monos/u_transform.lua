--[[
	-- transform
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]

local _vec3,_vec2,type = Vector3,Vector2,type

local super = LUGobj
local M = class( "lua_transform",super )

function M:makeTrsf( gobj )
	return M.New( gobj )
end

function M:ctor( obj )
	super.ctor(self,obj)
	self.trsf = self.gobj.transform
	self.rectTrsf = CHelper.ToRectTransform(self.trsf)

	self.parent = self.trsf.parent
	if self.parent then
		self.parentGobj = self.parent.gameObject
	end

	self:_CreateVecs()
	self:_InitVecs()

	self:_ExecuteAsync_Trsf()
end

function M:_CreateVecs()
	self.v3Pos = _vec3.zero
	self.v3Temp = _vec3.zero

	if not self.rectTrsf then return end

	self.v2AncPos = _vec2.zero
	self.v2Temp = _vec2.zero
end

function M:_InitVecs()
	self:GetPosition()
	if not self.rectTrsf then return end
	self:GetAnchoredPosition()
end

function M:IsInitTrsf()
	return self.trsf ~= nil;
end

function M:_ReXYZ( vec,x,y,z )
	self:ReVec_XYZ( vec,x,y,z )
end

function M:GetChildCount( )
	return self.trsf.childCount;
end

function M:GetChild( nIndex )
	nIndex = self:TInt( nIndex )
	local _nc = self:GetChildCount()
	if _nc > 0 and nIndex >= 0 and _nc > nIndex then
		return self.trsf:GetChild(nIndex)
	end
end

function M:GetPosition()
	if self:IsInitTrsf() then
		local _tmp = self.trsf.position
		self.v3Pos:Set(_tmp.x,_tmp.y,_tmp.z)
	end
	return self.v3Pos
end

function M:SetPosition( x,y,z )
	self._async_px,self._async_py,self._async_pz = nil
	if self:IsInitTrsf() then
		self:_ReXYZ(self.v3Pos,x,y,z)
		self.trsf.position = self.v3Pos
	else
		self._async_px,self._async_py,self._async_pz = x,y,z
	end
end

function M:SetLocalPosition( x,y,z )
	self._async_lpx,self._async_lpy,self._async_lpz = nil
	if self:IsInitTrsf() then
		self:_ReXYZ(self.v3Temp,x,y,z)
		self.trsf.localPosition = self.v3Temp
	else
		self._async_lpx,self._async_lpy,self._async_lpz = x,y,z
	end
end

function M:SetLocalScale( x,y,z )
	self._async_lsx,self._async_lsy,self._async_lsz = nil
	if self:IsInitTrsf() then
		y = y or x
		z = z or x
		self:_ReXYZ(self.v3Temp,x,y,z)
		self.trsf.localScale = self.v3Temp
	else
		self._async_lsx,self._async_lsy,self._async_lsz = x,y,z
	end
end

function M:SetEulerAngles( x,y,z )
	self._async_ax,self._async_ay,self._async_az = nil
	if self:IsInitTrsf() then
		self:_ReXYZ(self.v3Temp,x,y,z)
		self.trsf.eulerAngles = self.v3Temp
	else
		self._async_ax,self._async_ay,self._async_az = x,y,z
	end
end

function M:SetLocalEulerAngles( x,y,z )
	self._async_lax,self._async_lay,self._async_laz = nil
	if self:IsInitTrsf() then
		self:_ReXYZ(self.v3Temp,x,y,z)
		self.trsf.localEulerAngles = self.v3Temp
	else
		self._async_lax,self._async_lay,self._async_laz = x,y,z
	end
end

function M:SetForward( x,y,z )
	self._async_fx,self._async_fy,self._async_fz = nil
	if self:IsInitTrsf() then
		self:_ReXYZ(self.v3Temp,x,y,z)
		self.trsf.forward = self.v3Temp
	else
		self._async_fx,self._async_fy,self._async_fz = x,y,z
	end
end

function M:SetAnchoredPosition3D( x,y,z )
	self._async_ap3x,self._async_ap3y,self._async_ap3z = nil
	if self:IsInitTrsf() then
		self:_ReXYZ(self.v3Temp,x,y,z)
		self.rectTrsf.anchoredPosition3D = self.v3Temp
	else
		self._async_ap3x,self._async_ap3y,self._async_ap3z = x,y,z
	end
end

function M:GetAnchoredPosition()
	local _tmp = self.rectTrsf.anchoredPosition
	self.v2AncPos:Set(_tmp.x,_tmp.y)
	return self.v2AncPos
end

function M:SetAnchoredPosition( x,y )
	self._async_apx,self._async_apy = nil
	if self:IsInitTrsf() then
		self:_ReXYZ(self.v2AncPos,x,y)
		self.rectTrsf.anchoredPosition = self.v2AncPos
	else
		self._async_apx,self._async_apy = x,y
	end
end

function M:SetAnchorMin( x,y )
	self._async_aminx,self._async_aminy = nil
	if self:IsInitTrsf() then
		self:_ReXYZ(self.v2Temp,x,y)
		self.rectTrsf.anchorMin = self.v2Temp
	else
		self._async_aminx,self._async_aminy = x,y
	end
end

function M:SetAnchorMax( x,y )
	self._async_amaxx,self._async_amaxy = nil
	if self:IsInitTrsf() then
		self:_ReXYZ(self.v2Temp,x,y)
		self.rectTrsf.anchorMax = self.v2Temp
	else
		self._async_amaxx,self._async_amaxy = x,y
	end
end

function M:SetPivot( x,y )
	self._async_pix,self._async_piy = nil
	if self:IsInitTrsf() then
		self:_ReXYZ(self.v2Temp,x,y)
		self.rectTrsf.pivot = self.v2Temp
	else
		self._async_pix,self._async_piy = x,y
	end
end

function M:SetSizeDelta( x,y )
	self._async_sdx,self._async_sdy = nil
	if self:IsInitTrsf() then
		self:_ReXYZ(self.v2Temp,x,y)
		self.rectTrsf.sizeDelta = self.v2Temp
	else
		self._async_sdx,self._async_sdy = x,y
	end
end

function M:GetRectSize( )
	if not self:IsInitTrsf() then return 0,0 end
	local w,h = CHelper.GetRectSize(self.trsf,0,0);
	return w,h;
end

function M:SetParent( parent,isLocal,isSyncLayer )
	isLocal = (isLocal == true)
	self._async_parent,self._async_isLocal = nil
	if self:IsInitTrsf() then
		if isSyncLayer == true then
			CHelper.SetParentSyncLayer( self.trsf,parent,isLocal )
		else
			CHelper.SetParent( self.trsf,parent,isLocal )
		end
	else
		self._async_parent,self._async_isLocal = parent,isLocal
	end
end

function M:LookAt( x,y,z )
	self._async_look_x,self._async_look_y,self._async_look_z = nil
	if self:IsInitTrsf() then
		self:_ReXYZ( self.v3Temp,x,y,z )
		self.trsf:LookAt( self.v3Temp )
	else
		self._async_look_x,self._async_look_y,self._async_look_z = x,y,z
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

function M:DestroyObj()
	self.trsf = nil
	self.rectTrsf = nil
	return super.DestroyObj(self)
end

return M
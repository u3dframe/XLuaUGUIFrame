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
	self:_CreateVecs()
	self:_InitVecs()
end

function M:_CreateVecs()
	self.v3locPos = _vec3.zero
	self.v3locScale = _vec3.zero
	self.v3locAngles = _vec3.zero
	self.v3Pos = _vec3.zero
	self.v3Forward = _vec3.zero
	self.v3Angles = _vec3.zero
	
	if not self.rectTrsf then return end
	
	self.v3AncPos = _vec3.zero
	self.v2AncPos = _vec2.zero
	self.v2AncMin = _vec2.zero
	self.v2AncMax = _vec2.zero
	self.v2Pivot = _vec2.zero
	self.v2SizeDelta = _vec2.zero
end

function M:_InitVecs()
	local _tmp = self.trsf.localPosition
	self.v3locPos:Set(_tmp.x,_tmp.y,_tmp.z)

	_tmp = self.trsf.localScale
	self.v3locScale:Set(_tmp.x,_tmp.y,_tmp.z)

	_tmp = self.trsf.localEulerAngles
	self.v3locAngles:Set(_tmp.x,_tmp.y,_tmp.z)

	_tmp = self.trsf.position
	self.v3Pos:Set(_tmp.x,_tmp.y,_tmp.z)

	_tmp = self.trsf.forward
	self.v3Forward:Set(_tmp.x,_tmp.y,_tmp.z)

	_tmp = self.trsf.eulerAngles
	self.v3Angles:Set(_tmp.x,_tmp.y,_tmp.z)

	if not self.rectTrsf then return end

	_tmp = self.rectTrsf.anchoredPosition3D
	self.v3AncPos:Set(_tmp.x,_tmp.y,_tmp.z)

	_tmp = self.rectTrsf.anchoredPosition
	self.v2AncPos:Set(_tmp.x,_tmp.y)

	_tmp = self.rectTrsf.anchorMin
	self.v2AncMin:Set(_tmp.x,_tmp.y)

	_tmp = self.rectTrsf.anchorMax
	self.v2AncMax:Set(_tmp.x,_tmp.y)

	_tmp = self.rectTrsf.pivot
	self.v2Pivot:Set(_tmp.x,_tmp.y)

	_tmp = self.rectTrsf.sizeDelta
	self.v2SizeDelta:Set(_tmp.x,_tmp.y)
end

function M:IsInitTrsf( )
	return self.trsf ~= nil;
end

function M:ReXYZ( x,y,z )
	if type(x) == "table" then
		y = x.y;
		z = x.z;
		x = x.x;
	end

	x = self:TF2( x,0,true )
	y = self:TF2( y,0,true )
	z = self:TF2( z,0,true )
	return x,y,z
end

function M:_ReXYZ( vec,x,y,z )
	x,y,z = self:ReXYZ( x,y,z )
	vec:Set( x,y,z )
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

function M:SetPosition( x,y,z )
	self:_ReXYZ(self.v3Pos,x,y,z)
	self.trsf.position = self.v3Pos
end

function M:SetLocalPosition( x,y,z )
	self:_ReXYZ(self.v3locPos,x,y,z)
	self.trsf.localPosition = self.v3locPos
end

function M:SetLocalScale( x,y,z )
	self:_ReXYZ(self.v3locScale,x,y,z)
	self.trsf.localScale = self.v3locScale
end

function M:SetEulerAngles( x,y,z )
	self:_ReXYZ(self.v3Angles,x,y,z)
	self.trsf.eulerAngles = self.v3Angles
end

function M:SetLocalEulerAngles( x,y,z )
	self:_ReXYZ(self.v3locAngles,x,y,z)
	self.trsf.localEulerAngles = self.v3locAngles
end

function M:SetForward( x,y,z )
	self:_ReXYZ(self.v3Forward,x,y,z)
	self.trsf.forward = self.v3Forward
end

function M:SetAnchoredPosition3D( x,y,z )
	self:_ReXYZ(self.v3AncPos,x,y,z)
	self.rectTrsf.anchoredPosition3D = self.v3AncPos
end

function M:SetAnchoredPosition( x,y )
	self:_ReXYZ(self.v2AncPos,x,y)
	self.rectTrsf.anchoredPosition = self.v2AncPos
end

function M:SetAnchorMin( x,y )
	self:_ReXYZ(self.v2AncMin,x,y)
	self.rectTrsf.anchorMin = self.v2AncMin
end

function M:SetAnchorMax( x,y )
	self:_ReXYZ(self.v2AncMax,x,y)
	self.rectTrsf.anchorMax = self.v2AncMax
end

function M:SetPivot( x,y )
	self:_ReXYZ(self.v2Pivot,x,y)
	self.rectTrsf.pivot = self.v2Pivot
end

function M:SetSizeDelta( x,y )
	self:_ReXYZ(self.v2SizeDelta,x,y)
	self.rectTrsf.sizeDelta = self.v2SizeDelta
end

function M:GetRectSize( )
	if not self:IsInitTrsf() then return 0,0 end
	local w,h = CHelper.GetRectSize(self.trsf,0,0);
	return w,h;
end

function M:SetParent( parent,isLocal )
	local isWorld = not (isLocal == true)
	self.trsf:SetParent(parent,isWorld);
end

function M:DestroyObj()
	self.trsf = nil
	self.rectTrsf = nil
	return super.DestroyObj(self)
end

return M
--[[
	-- transform
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local _tn = tonum10

local super = LUGobj
local M = class( "lua_transform",super )

function M:makeTrsf( gobj )
	return M.New( gobj )
end

function M:ctor( obj )
	super.ctor(self,obj)
	self.trsf = self.gobj.transform
	-- self.rectTrsf = self:GetComponent("RectTransform")
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

	x = _tn( x,0 )
	y = _tn( y,0 )
	z = _tn( z,0 )
	return x,y,z
end

function M:GetChildCount( )
	return self.trsf.childCount;
end

function M:GetChild( nIndex )
	nIndex = _tn( nIndex,0 )
	local _nc = self:GetChildCount()
	if _nc > 0 and nIndex > 0 and _nc > nIndex then
		return self.trsf:GetChild(nIndex)
	end
end

function M:SetPostion( x,y,z )
	x,y,z = self:ReXYZ(x,y,z)
	self.trsf.position = {x = x, y = y, z = z}
end

function M:SetLocalPosition( x,y,z )
	x,y,z = self:ReXYZ(x,y,z)
	self.trsf.localPosition = {x = x, y = y, z = z}
end

function M:SetLocalScale( x,y,z )
	x,y,z = self:ReXYZ(x,y,z)
	self.trsf.localScale = {x = x, y = y, z = z}
end

function M:SetEulerAngles( x,y,z )
	x,y,z = self:ReXYZ(x,y,z)
	self.trsf.eulerAngles = {x = x, y = y, z = z}
end

function M:SetLocalEulerAngles( x,y,z )
	x,y,z = self:ReXYZ(x,y,z)
	self.trsf.localEulerAngles = {x = x, y = y, z = z}
end

function M:SetForward( x,y,z )
	x,y,z = self:ReXYZ(x,y,z)
	self.trsf.forward = {x = x, y = y, z = z}
end

function M:SetAnchoredPosition3D( x,y,z )
	x,y,z = self:ReXYZ(x,y,z)
	self.trsf.anchoredPosition3D = {x = x, y = y, z = z}
end

function M:SetAnchoredPosition( x,y )
	x,y = self:ReXYZ(x,y)
	self.trsf.anchoredPosition3D = {x = x, y = y}
end

function M:SetAnchorMin( x,y )
	x,y = self:ReXYZ(x,y)
	self.trsf.anchorMin = {x = x, y = y}
end

function M:SetAnchorMax( x,y )
	x,y = self:ReXYZ(x,y)
	self.trsf.anchorMax = {x = x, y = y}
end

function M:SetPivot( x,y )
	x,y = self:ReXYZ(x,y)
	self.trsf.pivot = {x = x, y = y}
end

function M:SetSizeDelta( x,y )
	x,y = self:ReXYZ(x,y)
	self.trsf.sizeDelta = {x = x, y = y}
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
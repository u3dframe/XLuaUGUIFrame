--[[
	-- transform
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local super = LUGobj
local M = class( "lua_transform",super )

function M:ctor( obj )
	super.ctor(self,obj)
	self.trsf = self.gobj.transform
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

	x = tonumber(x) or 0
	y = tonumber(y) or 0
	z = tonumber(z) or 0
	return x,y,z
end

function M:SetPostion( x,y,z )
	x,y,z = self:ReXYZ(x,y,z)
	self.trsf.position = {x = x, y = y, z = z}
end

function M:SetLocalPostion( x,y,z )
	x,y,z = self:ReXYZ(x,y,z)
	self.trsf.localPostion = {x = x, y = y, z = z}
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

function M:SetPivot( x,y )
	x,y = self:ReXYZ(x,y)
	self.trsf.pivot = {x = x, y = y}
end

function M:SetSizeDelta( x,y )
	x,y = self:ReXYZ(x,y)
	self.trsf.sizeDelta = {x = x, y = y}
end

function M:SetParent( parent,isLocal )
	local isWorld = not (isLocal == true)
	self.trsf:SetParent(parent,isWorld);
end

function M:DestroyObj()
	self.trsf = nil
	return super.DestroyObj(self)
end

return M
--[[
	-- Camera
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-09 13:25
	-- Desc : 
]]

local _vec3,_vec2,type = Vector3,Vector2,type
local CHelper = CHelper

local super = LUComonet
local M = class( "u_camera",super )

function M:ctor( obj,component )
	super.ctor(self,obj,component or "Camera")
	self:_Init_Cmr()
	self:_Init_Cmr_Vecs()
end

function M:_Init_Cmr()
	local _c = self.comp
	self.depth = _c.depth
	self.clearFlags = _c.clearFlags
	self.fieldOfView = _c.fieldOfView
	self.farClipPlane = _c.farClipPlane
	self.backgroundColor = _c.backgroundColor
	self.orthographic = _c.orthographic
	self.nearClipPlane = _c.nearClipPlane
	self.pixelHeight = _c.pixelHeight
end

function M:_Init_Cmr_Vecs()
	self.v2ScreenPoint = _vec2.zero
end

function M:GetCamera()
	return self.comp
end

function M:SetOrthographic(isBl)
	self.orthographic = isBl == true
	self.comp.orthographic = self.orthographic
end

function M:GetOrthographic()
	return (self.orthographic == true)
end

function M:ScreenToViewportPoint(sV3)
	return self.comp:ScreenToViewportPoint(sV3)
end

function M:ScreenToWorldPoint(sV3)
	return self.comp:ScreenToWorldPoint(sV3)
end

function M:WorldToScreenPoint(wV3)
	return self.comp:WorldToScreenPoint(wV3)
end

function M:WorldToViewportPoint(wV3)
	return self.comp:WorldToViewportPoint(wV3)
end

function M:ViewportToScreenPoint(vV3)
	return self.comp:ViewportToScreenPoint(vV3)
end

function M:ViewportToWorldPoint(vV3)
	return self.comp:ViewportToWorldPoint(vV3)
end

function M:ToWorldPoint(cameraFm,v3Pos)
	local _pos = cameraFm:WorldToViewportPoint(v3Pos)
	return self:ViewportToWorldPoint(_pos)
end

function M:ToUIWorldPointByEventPos(gobjParent,x,y)
	self:ReVec_XYZ(self.v2ScreenPoint,x,y)
	local _z
	x,y,_z = CHelper.ScreenPointToWorldPointInRectangle(gobjParent,self.comp,self.v2ScreenPoint.x,self.v2ScreenPoint.y,0)
	return _vec3.New( x,y,_z ) 
end

function M:ToUILocalPointByEventPos(gobjParent,x,y)
	self:ReVec_XYZ(self.v2ScreenPoint,x,y)
	x,y = CHelper.ScreenPointToLocalPointInRectangle(gobjParent,self.comp,self.v2ScreenPoint.x,self.v2ScreenPoint.y)
	return _vec2.New( x,y )
end

function M:ToWorldPointByUIEventPos(lbUICamera,gobjParent,x,y)
	local _pos = lbUICamera:ToUIWorldPointByEventPos(gobjParent,x,y)
	return self:ToWorldPoint(lbUICamera,_pos)
end

return M
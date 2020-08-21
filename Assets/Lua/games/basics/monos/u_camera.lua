--[[
	-- Camera
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-09 13:25
	-- Desc : 
]]

local _vec3 = Vector3

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
	self.v3S2P = _vec3.zero
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

function M:UIEventPosToWorld(uiEvtPos)
	self.v3S2P.x = uiEvtPos.x
	self.v3S2P.y = self.pixelHeight - uiEvtPos.y
	self.v3S2P.z = self.nearClipPlane
	return self:ScreenToWorldPoint(self.v3S2P)
end

function M:ToWorldPoint(cameraFm,v3Pos)
	local _pos = cameraFm:WorldToViewportPoint(v3Pos)
	return self:ViewportToWorldPoint(_pos)
end

function M:ToWorldPointByUIEventPos(lbUICamera,uiEvtPos)
	local _pos = lbUICamera:UIEventPosToWorld(uiEvtPos)
	return self:ToWorldPoint(lbUICamera,_pos)
end

return M
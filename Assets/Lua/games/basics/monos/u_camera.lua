--[[
	-- Camera
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-09 13:25
	-- Desc : 
]]
local super = LUComonet
local M = class( "u_camera",super )

function M:ctor( obj,component )
	super.ctor(self,obj,component or "Camera")
	self:_Init_Cmr()
end

function M:_Init_Cmr()
	local _c = self.comp
	self.depth = _c.depth
	self.clearFlags = _c.clearFlags
	self.fieldOfView = _c.fieldOfView
	self.farClipPlane = _c.farClipPlane
	self.backgroundColor = _c.backgroundColor
	self.orthographic = _c.orthographic
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

return M
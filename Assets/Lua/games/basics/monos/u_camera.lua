--[[
	-- Camera
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-09 13:25
	-- Desc : 
]]

local _vec3,_vec2,type = Vector3,Vector2,type
local CHelper = CHelper
local tonumber = tonumber

local super = LUComonet
local M = class( "u_camera",super )

function M:ctor( obj,component )
	super.ctor(self,obj,component or "Camera")
	self:_Init_Cmr()
	self:_Init_Cmr_Vecs()
end

function M:BuilderUObj( uobj )
	return CEDCamera.Builder( uobj )
end

function M:_GetCFComp()
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
	self.v2ScreenPoint = self.v2ScreenPoint or _vec2.zero
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

function M:SetOrthographicSize(size)
	size = tonumber(size) or 5
	self.comp.orthographicSize = size
end

function M:SetFieldOfView(size)
	size = tonumber(size) or 60
	self.csEDComp:SetFieldOfView( size )
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

function M:GetUILocPos(uobj,uiCmr,uiUObj,ofX,ofY)
	ofX = tonumber(ofX) or 0
	ofY = tonumber(ofY) or 0
	local _x,_y = self.csEDComp:GetUILocPos( uobj,uiCmr,uiUObj,ofX,ofY )
	return _vec2.New( _x,_y )
end

function M:ToSmooth4Local(x,y,z,fieldOfView,smoothTime,callFunc,smoothPos)
	x = tonumber(x) or 0
	y = tonumber(y) or 0
	z = tonumber(z) or 0
	fieldOfView = (tonumber(fieldOfView) or self.fieldOfView) or 60
	smoothTime = tonumber(smoothTime) or 0
	smoothPos = tonumber(smoothPos) or smoothTime
	self.csEDComp:ToSmooth4Local( x,y,z,fieldOfView,smoothTime,smoothPos,callFunc )
end

function M:ToSmooth4LocXYZ(toVal,fieldOfView,smoothTime,callFunc,nXYZ,isStartAdd,smoothPos)
	toVal = tonumber(toVal) or 0
	fieldOfView = (tonumber(fieldOfView) or self.fieldOfView) or 60
	smoothTime = tonumber(smoothTime) or 0
	smoothPos = tonumber(smoothPos) or smoothTime
	local _XYZ = 0
	if nXYZ == "y" then
		_XYZ = 1		
	elseif nXYZ == "z" then
		_XYZ = 2
	end
	if isStartAdd == true then
		self.csEDComp:ToSmooth4LocXYZStartAdd( toVal,fieldOfView,smoothTime,smoothPos,_XYZ,callFunc )
	else
		self.csEDComp:ToSmooth4LocXYZ( toVal,fieldOfView,smoothTime,smoothPos,_XYZ,callFunc )
	end
end

function M:RebackStart(smoothTime,callFunc,smoothPos)
	smoothTime = tonumber(smoothTime) or 0
	smoothPos = tonumber(smoothPos) or smoothTime
	self.csEDComp:RebackStart( smoothTime,smoothPos,callFunc )
end

function M:StopSmooth()
	if self.csEDComp then
		self.csEDComp:StopAllUpdate()
	end
end

return M
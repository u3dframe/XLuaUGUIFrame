--[[
	-- 主摄像头
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-13 09:25
	-- Desc : 
]]

local super,_evt,_base = MgrBase,Event,SceneBase
local M = class( "mgr_camera",super )

function M:Init()
	self:_InitFab()
	_evt.AddListener(Evt_View_MainCamera,self.ViewMainCamera,self);
	_evt.AddListener(Evt_Vw_MainCamera,self.VwMainCamera,self);
end

function M:_InitFab()
	self.lbCamera = _base.New({
		abName = "m_camera",
		strComp = "MainCameraManager",
		isStay = true,
	})
	self.lbCamera.OnInit = function(_s)
		local _c = _s.comp.m_camera
		_s.mainCamera = UIPubs:NewCmrBy(_c,_c)
		_s:SetParent(nil,true)
		_s:DonotDestory()
		_s:SetEulerAngles(0,0,0)
	end
end

function M:ViewMainCamera(isShow)
	self.lbCamera:View(isShow == true)
end

function M:VwMainCamera(isShow,mainCamera)
	self:ViewMainCamera( isShow )
	self.otherCamera = mainCamera
end

function M:GetLuaCamera()
	return self.lbCamera
end

function M:GetMainCamera()
	if self.otherCamera then return self.otherCamera end
	return self.lbCamera.mainCamera
end

return M
--[[
	-- 摄像机 管理
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-13 09:25
	-- Desc : ui的,默认的,场景的
]]

local super,_evt,_base = MgrBase,Event,FabBase
local M = class( "mgr_camera",super )

function M:Init()
	self:_InitFab()
	_evt.AddListener(Evt_Vw_Def3DCamera,self.ViewMainCamera,self);
	_evt.AddListener(Evt_Brocast_UICamera,self.SetLBUICamera,self);
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
		_c = _s.comp.m_target
		_s.lbTarget = UIPubs:NewTrsfBy( _c )
		_c = _s.comp.m_follower
		_s.lbFlower = UIPubs:NewFollowerBy( _c,_c )
		_s:SetParent(nil,true)
		_s:DonotDestory()
		_s:SetEulerAngles(0,0,0)
	end
end

function M:GetFollower()
	return self.lbCamera.lbFlower
end

function M:SetLBUICamera(lbUICamera)
	self.lbUICamera = lbUICamera
end

function M:ViewMainCamera(isShow,lb3DCamera)
	self.lbCamera:View(isShow == true)
	self.otherCamera = lb3DCamera
end

function M:GetLBCamera()
	return self.lbCamera
end

function M:GetCur3DLBCamera()
	if self.otherCamera then return self.otherCamera end
	return self.lbCamera.mainCamera
end

function M:GetMainCamera()
	return self:GetCur3DLBCamera() -- .comp
end

function M:UIEvtPos2Cur3DPos(gobjParent,evt_x,evt_y)
	return self:GetCur3DLBCamera():ToWorldPointByUIEventPos( self.lbUICamera,gobjParent,evt_x,evt_y );
end

function M:UIEvtPos2UILocalPos(gobjParent,evt_x,evt_y)
	return self.lbUICamera:ToUILocalPointByEventPos( gobjParent,evt_x,evt_y );
end

return M
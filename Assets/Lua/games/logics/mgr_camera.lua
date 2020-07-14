--[[
	-- 主摄像头
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-13 09:25
	-- Desc : 
]]

local super,_evt,_base = MgrBase,Event,SceneBase
local M = class( "mgr_camera",super )

function M:Init()
	self._lfVwCamera = handler(self,self.GetCamera)
	_evt.AddListener(Evt_View_MainCamera,self._lfVwCamera);
end

function M:GetCamera()
	if self.lbCamera then return self.lbCamera end
	self.lbCamera = SceneBase.New({
		abName = "prefabs/m_camera.fab",
		strComp = "MainCameraManager",
		isStay = true,
	});
	self.lbCamera:View(true)
	return self.lbCamera
end

return M
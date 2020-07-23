--[[
	-- 场景管理
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-13 09:25
	-- Desc : 
]]

local _mgrInput,_mgrCamera,_csMgr = MgrInput,MgrCamera
local _scene1,_scene2 = "Loading01","Loading02"
local super,_evt = MgrBase,Event
local M = class( "mgr_scene",super )

function M:Init()
	self.sname = _scene2
	_csMgr = CLoadSceneMgr.instance
	_evt.AddListener(Evt_ToChangeScene,handler(self,self.ChangeScene));
end

function M:_LoadScene(name)
	if self.sname == name then
		return
	end
	self.sname = name
	_csMgr:LoadScene(name)
end

function M:ChangeScene()
	local _name = (_scene2 == self.sname) and _scene1 or _scene2
	self:_LoadScene(_name)
end

return M
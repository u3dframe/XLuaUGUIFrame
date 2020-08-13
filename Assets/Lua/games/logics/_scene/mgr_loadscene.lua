--[[
	-- 管理 - 加载场景
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-13 09:25
	-- Desc : 
]]

local _scene1,_scene2,_csMgr = "Loading01","Loading02"
local super,_evt = MgrBase,Event
local M = class( "mgr_loadscene",super )

function M:Init()
	self.sname = _scene2
	_csMgr = CLoadSceneMgr.instance
	_evt.AddListener(Evt_SceneLoaded,self._SceneLoaded,self);
	_evt.AddListener(Evt_ToChangeScene,self.ChangeScene,self);
end

function M:_SceneLoaded(level)
	self.slevel = level
end

function M:_LoadScene(name,lfLoaded)
	if self.sname == name then
		return
	end
	self.sname = name
	_csMgr:LoadScene(name,lfLoaded)
end

function M:LoadScene(name)
	self:_LoadScene(name,function()
		_evt.Brocast(Evt_ChangedScene)
	end)
end

function M:ChangeScene()
	local _name = (_scene2 == self.sname) and _scene1 or _scene2
	self:LoadScene(_name)
end

return M
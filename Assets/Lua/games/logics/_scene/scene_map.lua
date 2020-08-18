--[[
	-- 场景Map
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-16 09:25
	-- Desc : 
]]

local _clsGBox = require( "games/logics/_scene/scene_map_gbox" )

local LES_Object = LES_Object

local super,_evt = SceneObject,Event
local M = class( "scene_map",super )

function M:ctor(nCursor,resCfg,...)
	super.ctor( self,LES_Object.MapObj,nCursor,resCfg )
end

function M:OnViewBeforeOnInit()
	self:SetParent(nil,true)
end

function M:OnInit()
	self.lbCamera = self:NewCmr("MainCamera")
	self.lbGBox = _clsGBox.New(self:GetElement("gbox"))

	_evt.Brocast(Evt_Vw_MainCamera,false,self.lbCamera.comp)
end

function M:OnDestroy()
	_evt.Brocast(Evt_Vw_MainCamera,true)
end

function M:GetGBoxUnit(nIndex)
	if (not self.lbGBox) then return end
	return self.lbGBox:GetUnit(nIndex)
end

return M
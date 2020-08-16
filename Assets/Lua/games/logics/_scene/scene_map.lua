--[[
	-- 场景Map
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-16 09:25
	-- Desc : 
]]

local LES_Object = LES_Object

local super,_evt = SceneObject,Event
local M = class( "scene_map",super )

function M:ctor(nCursor,assetCfg,...)
	super.ctor( self,LES_Object.MapObj,nCursor,assetCfg )
end

function M:OnViewBeforeOnInit()
	self:SetParent(nil,true)
end

function M:OnInit()
	self.lbCamera = self:NewCmr("MainCamera")
	_evt.Brocast(Evt_Vw_MainCamera,false,self.lbCamera.comp)
end

function M:OnDestroy()
	_evt.Brocast(Evt_Vw_MainCamera,true)
end

return M
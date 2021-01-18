--[[
	-- 场景Map
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-16 09:25
	-- Desc : 
]]

local _clsGBox = require( "games/logics/_scene/scene_map_gbox" )

local E_Object = LES_Object

local super,_evt = SceneObject,Event
local M = class( "scene_map",super )
local this = M

this.nm_pool_cls = "p_cls_sobj_" .. tostring(E_Object.MapObj)

function M.Builder(nCursor,resid)
	this:GetResCfg( resid )
	local _p_name,_ret = this.nm_pool_cls .. "@@" .. resid

	_ret = this.BorrowSelf( _p_name,E_Object.MapObj,nCursor,resid )
	return _ret
end

function M:OnViewBeforeOnInit()
	self:SetParent(nil,true)
end

function M:OnInit()
	self.lbCamera = self:NewCmr("MainCamera",true)
	self.isHasCamera = self.lbCamera ~= nil
	local _gbox = self:GetElement("gbox")
	if _gbox then
		self.lbGBox = _clsGBox.New(_gbox)
	end
	self.compPPLayer = self:GetElementComponent( "MainCamera","PostProcessLayer" )
	if self.compPPLayer then
		self.compPPLayer.enabled = Is_PPLayer_Enabled
	end

	if self.isHasCamera then
		_evt.Brocast(Evt_Vw_Def3DCamera,false,self.lbCamera)
	end
end

function M:OnDestroy()
	if self.isHasCamera then
		_evt.Brocast(Evt_Vw_Def3DCamera,true)
	end
end

function M:GetGBoxUnit(nIndex)
	if (not self.lbGBox) then return end
	return self.lbGBox:GetUnit(nIndex)
end

function M:GetWorldY()
	if (not self.lbGBox) then return 0 end
	return self.lbGBox.posY or 0
end

return M
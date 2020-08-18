--[[
	-- 场景Map - gobx
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-18 10:39
	-- Desc : 
]]

local LES_Object = LES_Object

local super,_evt = UICell,Event
local M = class( "scene_map_gbox",super )

function M:OnInit()
	self.comp:ForeachElement(function(index,gobj)
		self["n_" .. (index + 1)] = self:NewTrsfBy(gobj)
	end)	
end

function M:GetUnit(nIndex)
	if (not nIndex) then return end
	return self["n_" .. nIndex]
end

function M:SetUnitActive(nIndex,isActive)
	local _unit = self:GetUnit(nIndex)
	if _unit then
		_unit:SetActive( isActive == true )
	end
end

function M:SetParentInUnit(nIndex,lbScene)
	local _unit = self:GetUnit(nIndex)
	if _unit then
		lbScene:SetParent( _unit.trsf,true )
	end
end

return M
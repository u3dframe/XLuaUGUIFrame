--[[
	-- 场景Map - gobx
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-18 10:39
	-- Desc : 
]]

local _Vec3,Mathf = Vector3,Mathf
local LES_Object = LES_Object

local super,_evt = UICell,Event
local M = class( "scene_map_gbox",super )

function M:OnInit()
	self.comp:ForeachElement(function(_,gobj)
		self["n_" .. (gobj.name)] = self:NewTrsfBy(gobj)
	end)

	-- 目前没考虑旋转，缩放的情况下
	local _u1 = self:GetUnit(1)
	local _u2 = self:GetUnit(2)

	self.edge = 1
	local _dv3 = _u2.v3Pos - _u1.v3Pos
	local _edge = _dv3.magnitude / (Mathf.Sin(60 * Mathf.Deg2Rad) * 2)
	local _diff = _edge - 1
	if _diff > 1e-3 then
		self.edge = _edge
	end

	self.posY = _u1.v3Pos.y
	self.posF_X = _u1.v3Pos.x
	self.posF_Z = _u1.v3Pos.z
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

-- x,z,y
function M:SvPos2MapPos(svX,svY)
	local pX,pZ = (svX * self.edge),(svY * self.edge * -1)
	-- 目前没考虑旋转，缩放的情况下
	return (pX + self.posF_X),(pZ + self.posF_Z),self.posY
end

return M
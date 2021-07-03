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
	self.comp:ForeachElement(function(nIndex,gobj)
		local _nm = "n_" .. (gobj.name)
		self[_nm] = self:NewTrsfBy(gobj,true)
		self.nMaxIndex = nIndex + 1
	end)

	-- 目前没考虑旋转，缩放的情况下
	local _u1 = self:GetUnit(1)
	local _u2 = self:GetUnit(2)

	local _dv3 = _u2.v3Pos - _u1.v3Pos
	local _edge = _dv3.magnitude / (Mathf.Sin(60 * Mathf.Deg2Rad) * 2)	
	self.edge = _edge
	self.edge_f1 = _edge * -1
	self.edge_o1 = 1 / _edge

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

function M:GetCenterXYZ(selfIsEnemy)
	local _index = (selfIsEnemy == true) and 155 or 35
	local _pos = self:GetUnit(_index).v3Pos
	return _pos.x,_pos.y,_pos.z
end

-- x,z,y
function M:SvPos2MapPos(svX,svY)
	local pX,pZ = (svX * self.edge),(svY * self.edge_f1)
	-- 目前没考虑旋转，缩放的情况下
	return (pX + self.posF_X),(pZ + self.posF_Z),self.posY
end

function M:MapPos2SvPos(x,z)
	local _x,_y = (x - self.posF_X),(z - self.posF_Z)
	-- 目前没考虑旋转，缩放的情况下
	return (_x * self.edge_o1),(_y * -1 * self.edge_o1)
end

function M:GetUnitPos(nIndex)
	local util = self:GetUnit(nIndex);
	if (util)then
		local _pos = util.v3Pos;
		return _pos.x,_pos.y,_pos.z
	end
end

function M:GetUnitMinMaxPosXZ(min, max)
	local _p1x,_,_p1z  = self:GetUnitPos(min or 1)
	local _p2x,_,_p2z  = self:GetUnitPos(max or self.nMaxIndex)
	if _p1x and _p2x then
		local _mmin = Mathf.Min
		local _minx = _mmin( _p1x,_p2x )
		local _minz = _mmin( _p1z,_p2z )
		return _minx,_minz,(_minx == _p1x and _p2x or _p1x),(_minz == _p1z and _p2z or _p1z)
	end
end
return M
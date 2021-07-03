--[[
	-- 场景对象 - 英雄
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local E_Object = LES_Object

local super = SceneMonster
local M = class( "scene_hero",super )
local this = M

this.nm_pool_cls = "p_cls_sobj_" .. tostring(E_Object.Hero)

function M.Builder(nCursor,resid)
	this:GetResCfg( resid )
	local _p_name,_ret = this.nm_pool_cls .. "@@" .. resid

	_ret = this.BorrowSelf( _p_name,E_Object.Hero,nCursor,resid )
	return _ret
end

function M:IsEnemy()
	return (self.n_camp) and (self.n_camp == 1)
end

return M
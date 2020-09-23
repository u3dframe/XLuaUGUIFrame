--[[
	-- 场景对象 - 怪兽
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local E_Object,ET_SE = LES_Object,LET_Shader_Effect

local super = SceneCreature
local M = class( "scene_monster",super )
local this = M

this.nm_pool_cls = "p_cls_sobj_" .. tostring(E_Object.Monster)

function M.Builder(nCursor,resid)
	this:GetResCfg( resid )
	local _p_name,_ret = this.nm_pool_cls .. "@@" .. resid

	_ret = this.BorrowSelf( _p_name,E_Object.Monster,nCursor,resid )
	return _ret
end

function M:OnShow()
	if self.isSeparation then
		local _e_id_sep = self:GetCfgEID4Separation()
		self:ExcuteEffectByEid( _e_id_sep )
	end
end

function M:On_SEByCCType(preType)
	self:SetPause( self.prePause )
	self.prePause = self.isPause
	if preType == ET_SE.Stone then
		self.prePause = nil
		self:CsAniSpeed()
	end

	if self.ccType == ET_SE.Stone then
		self:SetPause( true )
		self:CsAniSpeed(0)
	end
end

return M
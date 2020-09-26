--[[
	-- 场景对象 - 怪兽
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local E_Object,ET_SE = LES_Object,LET_Shader_Effect
local E_State = LES_C_State
local E_CEType = LES_Ani_Eft_Type

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

function M:GetActionState()
	local _a_state
	if self.state == E_State.Attack then
		_a_state = self.cfgSkill_Action.action_state
	elseif self.state == E_State.BeHit then
		_a_state = self.behit_action_state
	else
		_a_state = super.GetActionState( self )
	end
	return _a_state
end

function M:GetCfgEID4Die()
	if self.data then
		return self.data.die
	end
end

function M:GetCfgEID4Separation()
	if self.data then
		return self.data.separation
	end
end

function M:GetCfgEIDByEType(e_type)
	if self.data then
		if e_type == E_CEType.HitFly then
			return self.data.hit_fly
		elseif e_type == E_CEType.HitBack then
			return self.data.hit_back
		elseif e_type == E_CEType.HitFall then
			return self.data.hit_fall
		end
	end
end

function M:IsBigSkill()
	if self.cfgSkill_Action then
		return self.cfgSkill_Action.type == 1
	end
end

return M
--[[
	-- 场景对象 - 怪兽
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local E_Object,ET_SE = LES_Object,LET_Shader_Effect
local E_State = LES_C_State
local E_CEType = LES_Ani_Eft_Type
local MgrData,LTimer = MgrData,LTimer
local tostring = tostring

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

function M:OnEnd(isDestroy)
	super.OnEnd( self,isDestroy )
	self:EndChgBody()
	self:EndStopSAction()
end

function M:EndAction()
	super.EndAction( self )
	self:EndStopSAction()
end

function M:Pause()
	if not super.Pause( self ) then
		return
	end
	
	LTimer.PauseDelayFunc( self.strCmd,true )
	LTimer.PauseDelayFunc( self.strCmdEnd,true )
	LTimer.PauseDelayFunc( self.strCmdSAct,true )
	return true
end

function M:Regain()
	super.Regain( self )

	LTimer.PauseDelayFunc( self.strCmd,false )
	LTimer.PauseDelayFunc( self.strCmdEnd,false )
	LTimer.PauseDelayFunc( self.strCmdSAct,false )
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

function M:GetCfgEftByEType(e_type)
	local _e_id_,_e_tmp_ = self:GetCfgEIDByEType( e_type )
	if _e_id_ then
		_e_tmp_ = MgrData:GetCfgSkillEffect( _e_id_ )
	end
	return _e_tmp_,_e_id_
end

function M:IsBigSkill()
	if self.cfgSkill_Action then
		return self.cfgSkill_Action.type == 1
	end
end

function M:GetSkillTimeOut()
	return self.timeOut4Skill or 0
end

function M:_ExcuteSpecialEffect( e_id,cfgEft,idCaster,idTarget )
	local _obj = self:GetSObjBy( idTarget )
	if not _obj then
		return
	end	
	local _ccType = AET_2_SE[cfgEft.type]
	_obj:ExcuteSEByCCType( _ccType )

	_obj:ChangeBody( e_id )
	_obj:StopSelfActionByEffect( cfgEft )
end

local function _chg_bodying(_s)
	if _s.size >= _s.toSize then
		return
	end
	local _size = _s.size + _s.chg_speed
	if _size > _s.toSize then
		_size = _s.toSize
	end
	_s:SetSize( _size )
end

local function _chg_bodyend(_s)
	_s:EndChgBody(  )
end

function M:EndChgBody()
	local _cmd1,_cmd2 = self.strCmdEnd,self.strCmd
	self.strCmdEnd,self.strCmd = nil
	if _cmd1 or _cmd2 then
		LTimer.RemoveDelayFunc(_cmd1)
		LTimer.RemoveDelayFunc(_cmd2)
		self:SetSize( 1 )
	end
end

function M:ChangeBody( e_id )
	local cfgEft = MgrData:GetCfgSkillEffect( e_id )
	if not cfgEft then
		return
	end

	if (cfgEft.type ~= E_CEType.ChgBody) or (not cfgEft.size) then
		return
	end

	self.toSize = cfgEft.size * 0.01
	self:EndChgBody()
	self.size = self.size or 1
	
	if cfgEft.chg_time then
		local _t_t = cfgEft.chg_time * 0.001
		local _delay = 0.02
		local _loop = self:MCeil( _t_t / _delay )
		self.chg_speed = (self.toSize - self.size) / _loop
		local _id_ = tostring(self:GetCursor())
		self.strCmd = "chg_body" .. _id_
		self.strCmdEnd = "chg_body_end" .. _id_
		LTimer.AddDelayFunc(self.strCmd,_delay,_chg_bodying,_loop,nil,self)
		LTimer.AddDelayFunc1(self.strCmdEnd,cfgEft.effecttime,_chg_bodyend,self)
	else
		self:SetSize( self.toSize )
	end
	return true
end

local function _chg_sact_end(_s)
	_s:EndStopSAction(  )
end

function M:EndStopSAction()
	local _cmd = self.strCmdSAct
	self.strCmdSAct = nil
	if _cmd then
		self:CsAniSpeed()
		LTimer.RemoveDelayFunc( _cmd )
	end
end

function M:StopSelfActionByEffect( cfgEft )
	if (not cfgEft) or (cfgEft.type ~= E_CEType.SelfStayAction) or (not cfgEft.chg_time) then
		return
	end
	self:EndStopSAction()
	self:CsAniSpeed(0)
	self.strCmdSAct = "s_s_a" .. tostring(self:GetCursor())
	LTimer.AddDelayFunc1(self.strCmdSAct,cfgEft.chg_time * 0.001 ,_chg_sact_end,self)
	return true
end

return M
--[[
	-- 场景对象 - 怪兽
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local E_Object,ET_SE = LES_Object,LET_Shader_Effect
local E_State,E_CEType = LES_C_State,LES_Ani_Eft_Type
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
	self:EndChgMat()
end

function M:EndAction()
	super.EndAction( self )
	self:EndStopSAction()
end

function M:OnUpdate_Child(dt,undt)
	if self.chgBodyDuration then
		self:ChgBodying()
		self.chgBodyDuration = self.chgBodyDuration - dt
		if self.chgBodyDuration <= 0 then
			self:EndChgBody()
		end
	end

	if self.sactDuration then
		self.sactDuration = self.sactDuration - dt
		if self.sactDuration <= 0 then
			self:EndStopSAction()
		end
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

function M:_ExcuteSpecialEffect( e_id,cfgEft,idCaster,idTarget,svData )
	local _obj = self:GetSObjBy( idTarget )
	if not _obj then
		return
	end	
	local _ccType = AET_2_SE[cfgEft.type]
	_obj:ExcuteSEByCCType( _ccType )

	_obj:ChangeBody( e_id,cfgEft )
	_obj:StopSelfActionByEffect( cfgEft )
	_obj:ShiftTeleporting( cfgEft,svData )
	_obj:ChgMat( cfgEft )
end

function M:ChangeBody( e_id,cfgEft )
	cfgEft = cfgEft or MgrData:GetCfgSkillEffect( e_id )
	if (not cfgEft) or (not cfgEft.size) or (cfgEft.type ~= E_CEType.ChgBody) then
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
		self.chgBodyFpsLoop = _loop
		self.chgBodyDuration = cfgEft.effecttime	
	else
		self:SetSize( self.toSize )
	end
	return true
end

function M:ChgBodying()
	local _s = self
	if (not _s.chgBodyFpsLoop) or (_s.chgBodyFpsLoop <= 0) or (_s.size >= _s.toSize) then
		return
	end
	_s.chgBodyFpsLoop =  _s.chgBodyFpsLoop - 1
	local _size = _s.size + _s.chg_speed
	if (_s.chg_speed > 0 and _size > _s.toSize) or (_s.chg_speed < 0 and _size < _s.toSize) then
		_size = _s.toSize
	end
	_s:SetSize( _size )
end

function M:EndChgBody()
	local _tmp_ = self.chgBodyDuration
	self.chgBodyFpsLoop,self.chgBodyDuration = nil
	if _tmp_ ~= nil then
		self:SetSize( 1 )
	end
end

function M:StopSelfActionByEffect( cfgEft )
	if (not cfgEft) or (not cfgEft.chg_time) or (cfgEft.type ~= E_CEType.SelfStayAction) then
		return
	end
	self:EndStopSAction()
	self:CsAniSpeed(0)
	self.sactDuration = cfgEft.chg_time * 0.001
	return true
end

function M:EndStopSAction()
	local _tmp_ = self.sactDuration
	self.sactDuration = nil
	if _tmp_ ~= nil then
		self:CsAniSpeed()
	end
end

function M:ShiftTeleporting( cfgEft,svData )
	if (not cfgEft) or (not svData) or (cfgEft.type ~= E_CEType.Teleporting) then
		return
	end
	if (not svData.args2) or (not svData.args3) then
		return
	end
	local _x,_y = svData.args2 * 0.01,svData.args3 * 0.01
	self:SetPos_SvPos( _x,_y )
	local _sd = self.svDataCast
	if _sd then
		self:LookTarget( _sd.target,_sd.targetx,_sd.targety )
	end
end

function M:ChgMat( cfgEft )
	if (not cfgEft) or (cfgEft.type ~= E_CEType.MatAdd and cfgEft.type ~= E_CEType.MatReplace) then
		return
	end
	local _ntype = (cfgEft.type == E_CEType.MatReplace) and 1 or 2
	local _resid = cfgEft.resid
	local _cfgRes = self:GetResCfg( _resid )
	local _abname = self:ReSBegEnd( _cfgRes.rsaddress,"materials/special_effects/",Mat_End )
	local _lb = self.lbNewMat or {}
	self.lbNewMat = _lb
	_lb[_resid] = self:NewAssetABName(_abname,LE_AsType.Mat,function(isNo,obj)
		if not isNo then
			local _lb2 = self.unMat or {}
			self.unMat = _lb2
			local _unMat = CHelper.NewMat(obj)
			_lb2[_resid] = _unMat
			self.comp:ChgSkinMat(_unMat,_ntype)
		end
	end)
	return _resid
end

function M:EndChgMat(resid)
	local _isAll,_tmp_ = not resid
	_tmp_ = self.lbNewMat
	if _isAll then
		self.lbNewMat = nil
	end
	if _tmp_ then
		for _k, _v in pairs(_tmp_) do
			if _isAll or resid == _k then
				_v:OnUnLoad()
			end 
		end
		if resid then
			_tmp_[resid] = nil
		end
	end

	_tmp_ = self.unMat
	if _isAll then
		self.unMat = nil
	end
	if _tmp_ then
		for _k, _v in pairs(_tmp_) do
			if _isAll or resid == _k then
				self.comp:ChgSkinMat(_v,0)
			end 
		end
		if resid then
			_tmp_[resid] = nil
		end
	end
end

return M
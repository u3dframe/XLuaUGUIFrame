--[[
	-- buff 效果
	-- Author : canyon / 龚阳辉
	-- Date : 2020-09-16 09:25
	-- Desc : 
]]

local tb_lens = table.lens
local E_CEType = LES_Ani_Eft_Type

local MgrData = MgrData
local tb_append = table.append

local super,super2 = ClsEftBase,ClsObjBasic
local M = class( "buff",super,super2 )
local this = M
this.nm_pool_cls = "p_buff"

function M.Builder(idMarker,idTarget,b_id,duration,speed)
	local _isOkey,_cfg_buff = MgrData:CheckCfg4Buff( b_id )
	if not _isOkey then return end
	local _p_name,_ret = this.nm_pool_cls .. "@@" .. b_id
	duration = duration or ((_cfg_buff.duration or 0) / 1000)
	_ret = this.BorrowSelf( _p_name,idMarker,idTarget,b_id,duration,speed,_cfg_buff )
	return _ret
end

function M:ctor()
	super.ctor( self )
	super2.ctor( self )
	self.isDelayTime = true
end

function M:Reset(idMarker,idTarget,b_id,duration,speed,cfgBuff)
	self.isUping = false
	self:SetData( b_id,idMarker,idTarget,duration,speed,cfgBuff )
end

function M:OnSetData(idMarker,idTarget,duration,speed,cfgBuff)
	self:_DisappearTarget()
	self:_DisappearEffect()
	
	self.idCaster = idMarker
	self.idTarget = idTarget or idMarker
	self.timeOut = duration
	self:SetSpeed( speed )
	self.cfgBuff = cfgBuff

	self.e_id = cfgBuff.cast_effect
	self.e_ids = cfgBuff.cast_effects
end

function M:OnUpdate(dt)
	super.OnCurrUpdate( self,dt )
end

function M:Jugde4Disappear()
	self.isNotUpPos = true
	local _curr = self.currEft
	if _curr then
		local cfgEft = _curr:GetCurrCfgEft()
		self:_DisappearEffect()
		if cfgEft and cfgEft.nextid then
			self:_DoEffect( cfgEft.nextid )
			if self.isUping then
				return
			end
		end
	end
	super.Jugde4Disappear( self )
end

function M:OnPreDisappear()
	super.OnPreDisappear( self )
	self.cfgBuff = nil
	self:_DisappearEffect()
	self:_DisappearTarget()
end

function M:_DisappearEffect()
	local _lbs = self.lbEfcts
	self.lbEfcts,self.currEft,self.flytime = nil

	if _lbs then
		for _, v in ipairs(_lbs) do
			v:Disappear()
		end
	end
end

function M:_DisappearTarget()
	local _set = self.shaderType
	self.shaderType = nil
	local _isPA = self.isPlayAction
	self.isPlayAction = nil
	local _isChgBd = self.isChgBody
	self.isChgBody = nil
	local _matResId = self.matResId
	self.matResId = nil

	local _lbTarget = this.GetSObj4Battle( self.idTarget )
	if _lbTarget then
		if _set then
			_lbTarget:ExcuteSEByCCType( 0 )
		end
		if _isPA then
			_lbTarget:PlayAction( 0 )
		end

		if _isChgBd then
			_lbTarget:EndChgBody()
		end

		if _matResId then
			_lbTarget:EndChgMat( _matResId )
		end
	end
end

function M:GetCasterID()
	return self.idCaster
end

function M:Start( speed )
	self.curr_time = 0
	self.mileAge = 0
	self:SetSpeed( speed or self.speed )
	self:_StartEffect()
	self:_StartShaderEffect()
	self:ReEvent4OnUpdate(self.isUping)
	self:ReEvent4Self(self.isUping)
end

function M:_StartEffect()
	self:_DoEffect( self.e_id )
	if self.e_ids then
		for _, eid in ipairs(self.e_ids) do
			self:_DoEffect( eid )
		end
	end
end

function M:_DoEffect( e_id )
	if (not e_id) then
		return
	end
	local _cfg = MgrData:GetCfgSkillEffect( e_id )
	if (not _cfg) then
		return
	end
	if _cfg and _cfg.type then
		self.shaderType = AET_2_SE[_cfg.type]
	end

	local _lbTarget = this.GetSObj4Battle( self.idTarget )
	if (not _lbTarget) then
		return
	end
	local _e_id = _lbTarget:GetCfgEIDByEType( _cfg.type )
	if _e_id then
		_cfg = MgrData:GetCfgSkillEffect( _e_id )
		if (not _cfg) then
			return
		end
	else
		_e_id = e_id
	end

	local _idCaster,_idTarget = self.idCaster,self.idTarget
	local _isFly = (_cfg.chg_time and _cfg.chg_time > 0) and (_idCaster ~= _idTarget)
	if _isFly then
		_idTarget = _idCaster
	end
	local _lbs = EffectFactory.CreateEffect( _idCaster,_idTarget,_e_id )
	local _lens = tb_lens( _lbs )
	local _isUping = (_lens > 0) or (_cfg.action_state)
	
	self.isPlayAction = (_cfg.action_state ~= nil)
	if self.isPlayAction then
		_lbTarget:PlayAction( _cfg.action_state )
	end
	if _lens > 0 and _isUping then
		self.lbEfcts = self.lbEfcts or {}
		tb_append(self.lbEfcts, _lbs)

		-- 设置buff的飞行
		if _isFly then
			local _flytime,_sobj = _cfg.chg_time
			self.currEft = self.lbEfcts[1]
			self.currEft.maxtime = _flytime * 0.001
			self.currEft:SetIsNoCurve( true )
			local _,_mvSpeed,_diff = this.CalcSpeedAndDis( self.idCaster,self.idTarget,_flytime,_cfg.min_mv_speed )
			self:SetMoveDir( _diff )
			self:SetMvSpeed( _mvSpeed )
			self.isNotUpPos = nil
		end
	end
	self.isChgBody = _lbTarget:ChangeBody( _e_id )
	self.matResId  = _lbTarget:ChgMat( _cfg )
	EffectFactory.ShowEffects( _lbs )
	if not _isUping then
		_isUping = self.isChgBody or self.matResId ~= nil
	end
	self.isUping = _isUping
end

function M:_StartShaderEffect()
	if not self.shaderType then
		return
	end
	local _lbTarget = this.GetSObj4Battle( self.idTarget )
	if _lbTarget then
		_lbTarget:ExcuteSEByCCType( self.shaderType )
		self.isUping = true
	end
end

return M

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

local super,super2,_evt = LuaObject,ClsObjBasic,Event
local M = class( "buff",super,super2 )
local this = M
this.nm_pool_cls = "p_buff"

function M.GetSObj4Battle(id)
	return MgrScene.OnGet_Map_Obj( id )
end

function M.Builder(idMarker,idTarget,b_id,duration,speed)
	local _isOkey,_cfg_buff = MgrData:CheckCfg4Buff( b_id )
	if not _isOkey then return end
	local _p_name,_ret = this.nm_pool_cls .. "@@" .. b_id
	duration = duration or (_cfg_buff.duration / 1000)
	_ret = this.BorrowSelf( _p_name,idMarker,idTarget,b_id,duration,_cfg_buff.cast_effect,speed,_cfg_buff.cast_effects )
	return _ret
end

function M:ctor()
	super.ctor( self )
	super2.ctor( self )
end

function M:Reset(idMarker,idTarget,b_id,duration,e_id,speed,e_ids)
	self.isUping = false
	self:SetData( b_id,idMarker,idTarget,duration,e_id,speed,e_ids )
end

function M:OnSetData(idMarker,idTarget,duration,e_id,speed,e_ids)
	self:_DisappearTarget()
	self:_DisappearEffect()
	
	self.idCaster = idMarker
	self.idTarget = idTarget or idMarker
	self.timeOut = duration
	self.e_id = e_id
	self.e_ids = e_ids
	self.speed = speed or 1
end

function M:ReEvent4Self(isbind)
	_evt.RemoveListener(Evt_Map_SV_Skill_Pause, self.Pause, self)
	_evt.RemoveListener(Evt_Map_SV_Skill_GoOn, self.Regain, self)
	if (isbind)then
		_evt.AddListener(Evt_Map_SV_Skill_Pause, self.Pause, self)
		_evt.AddListener(Evt_Map_SV_Skill_GoOn, self.Regain, self)
	end
end

function M:OnUpdate(dt)
	if self.isPause then
		return
	end

	if (self.isDisappear == true) then
		self:Disappear()
	end

	self.curr_time = self.curr_time + dt * self.speed
	if self.timeOut and self.timeOut > 0  then
		self.isDisappear = (self.timeOut <= self.curr_time)
	end
end

function M:OnPreDisappear()
	self.isUping,self.isDisappear,self.timeOut = nil
	self:_DisappearEffect()
	self:_DisappearTarget()
	self:ReEvent4OnUpdate(false)
end

function M:_DisappearEffect()
	local _lbs = self.lbEfcts
	self.lbEfcts = nil

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

	local _lbTarget = this.GetSObj4Battle( self.idTarget )
	if _lbTarget then
		if _set then
			_lbTarget:ExcuteSEByCCType( 0 )
		end
		if _isPA then
			_lbTarget:PlayAction( 0 )
		end

		if _isChgBd then
			_lbTarget:StopChgBody()
		end
	end
end

function M:GetCasterID()
	return self.idCaster
end

function M:Start( speed )
	speed = speed or self.speed
	self.speed = speed
	self:_StartEffect()
	self:_StartShaderEffect()
	if self.isUping then
		self.curr_time = 0
	end
	self:ReEvent4OnUpdate(self.isUping)
	self:ReEvent4Self(self.isUping)
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

	local _lbs = EffectFactory.CreateEffect( self.idCaster,self.idTarget,_e_id )
	local _lens = tb_lens( _lbs )
	self.isUping = (_lens > 0) or (_cfg.action_state)
	
	self.isPlayAction = (_cfg.action_state ~= nil)
	if self.isPlayAction then
		_lbTarget:PlayAction( _cfg.action_state )
	end
	if _lens > 0 and self.isUping then
		self.lbEfcts = self.lbEfcts or {}
		tb_append(self.lbEfcts, _lbs)
	end
	self.isChgBody = _lbTarget:ChangeBody( _e_id )
	EffectFactory.ShowEffects( _lbs )
end

return M

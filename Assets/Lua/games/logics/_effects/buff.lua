--[[
	-- buff 效果
	-- Author : canyon / 龚阳辉
	-- Date : 2020-09-16 09:25
	-- Desc : 
]]

local tb_lens = table.lens
local E_CEType = LES_Ani_Eft_Type

local MgrData = MgrData

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
	_ret = this.BorrowSelf( _p_name,idMarker,idTarget,b_id,duration,_cfg_buff.cast_effect,speed )
	return _ret
end

function M:ctor()
	super.ctor( self )
	super2.ctor( self )
end

function M:Reset(idMarker,idTarget,b_id,duration,e_id,speed)
	self.isUping = false
	self:SetData( b_id,idMarker,idTarget,duration,e_id,speed )
end

function M:OnSetData(idMarker,idTarget,duration,e_id,speed)
	self:_DisappearSEft()
	self:_DisappearEffect()
	
	self.idCaster = idMarker
	self.idTarget = idTarget or idMarker
	self.timeOut = duration
	self.e_id = e_id
	self.speed = speed or 1

	local _,cfgEft = MgrData:CheckCfg4Effect( self.e_id )
	if cfgEft and cfgEft.type then
		self.shaderType = AET_2_SE[cfgEft.type]
	end
	self.cfgEft = cfgEft
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
	self:_DisappearSEft()
	self:ReEvent4OnUpdate(false)
end

function M:_DisappearEffect()
	local _lbs = self.lbEfcts
	self.lbEfcts,self.currEft = nil

	if _lbs then
		for _, v in ipairs(_lbs) do
			v:Disappear()
		end
	end
end

function M:_DisappearSEft()
	local _set = self.shaderType
	self.shaderType = nil

	if _set then
		local _lbTarget = this.GetSObj4Battle( self.idTarget )
		if _lbTarget then
			_lbTarget:ExcuteSEByCCType( 0 )
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
	if (not self.cfgEft) or (not self.cfgEft.resid) then
		return
	end
	self.lbEfcts = EffectFactory.CreateEffect( self.idCaster,self.idTarget,self.e_id )
	self.isUping = tb_lens(self.lbEfcts) > 0	
	if self.isUping then
		self.currEft = self.lbEfcts[1]
	end
	EffectFactory.ShowEffects( self.lbEfcts )
end

return M

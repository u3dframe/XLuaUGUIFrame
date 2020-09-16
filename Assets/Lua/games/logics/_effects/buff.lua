--[[
	-- buff 效果
	-- Author : canyon / 龚阳辉
	-- Date : 2020-09-16 09:25
	-- Desc : 
]]

local tb_lens = table.lens

local MgrData = MgrData

local super,super2,_evt = LuaObject,ClsObjBasic,Event
local M = class( "buff",super,super2 )
local this = M
this.nm_pool_cls = "p_buff"

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
	self.idMarker = idMarker
	self.idTarget = idTarget
	self.timeOut = duration
	self.e_id = e_id
	self.speed = speed or 1

	self:_DisappearEffect()
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

	self.currt_time = self.currt_time + dt * self.speed
	if self.timeOut and self.timeOut > 0  then
		if self.timeOut <= self.currt_time then
			self.isDisappear = true			
		end
	end
end

function M:OnPreDisappear()
	self.isUping,self.isDisappear,self.timeOut = nil
	self:_DisappearEffect()
	self:ReEvent4OnUpdate(false)
end

function M:_DisappearEffect()
	if self.lbEfcts then
		for _, v in ipairs(self.lbEfcts) do
			v:Disappear()
		end
	end
	self.lbEfcts = nil
end

function M:Start( speed )
	speed = speed or self.speed
	self.speed = speed
	local _idCaster = self.idMarker or self.idTarget
	local _idTarget = self.idTarget or self.idMarker
	self.lbEfcts = EffectFactory.ViewEffect( _idCaster,_idTarget,self.e_id )
	self.isUping = tb_lens(self.lbEfcts) > 0
	self.currt_time = 0
	self:ReEvent4OnUpdate(self.isUping)
	self:ReEvent4Self(self.isUping)
end

return M

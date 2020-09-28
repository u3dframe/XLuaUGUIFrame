--[[
	-- 子弹
	-- Author : canyon / 龚阳辉
	-- Date : 2020-09-16 15:06
	-- Desc : 
]]

local E_Eft_Type = LES_Ani_Eft_Type
local tb_lens = table.lens

local MgrData,_vec3 = MgrData,Vector3
local _v3_zero = _vec3.zero

local super,super2,_evt = LuaObject,ClsObjBasic,Event
local M = class( "bullet",super,super2 )
local this = M
this.nm_pool_cls = "p_bullet"

function M.GetSObj4Battle(id)
	return MgrScene.OnGet_Map_Obj( id )
end

function M.Builder(idMarker,idTarget,e_id)
	local _isOkey,cfgEft = MgrData:CheckCfg4Effect( e_id )
	if (not _isOkey) or (cfgEft.type ~= E_Eft_Type.FlyPosition and cfgEft.type ~= E_Eft_Type.FlyTarget) then return end
	local _lbCaster = this.GetSObj4Battle( idMarker )
	local _lbTarget = this.GetSObj4Battle( idTarget )
	if not _lbCaster or not _lbTarget then return end
	local _pos1 = _lbCaster:GetPosition()
	local _pos2 = _lbTarget:GetPosition()
	local _diff = _pos2 - _pos1
	local range = _diff.magnitude
	local _t_out = cfgEft.effecttime * 0.001
	local _mvSpeed,_v3Target = (range / _t_out),_vec3.New( _pos2.x,_pos2.y,_pos2.z)
	local isMv2Pos = cfgEft.type == E_Eft_Type.FlyPosition
	local _p_name,_ret = this.nm_pool_cls .. "@@" .. e_id

	if cfgEft.min_mv_speed and (_mvSpeed * 100) < cfgEft.min_mv_speed then
		_mvSpeed = cfgEft.min_mv_speed * 0.01
	end
	
	_ret = this.BorrowSelf( _p_name,idMarker,idTarget,e_id,range,_mvSpeed,_diff,(_t_out + 0.06),_v3Target,isMv2Pos )
	return _ret
end

function M:ctor()
	super.ctor( self )
	super2.ctor( self )
end

function M:Reset(idMarker,idTarget,e_id,range,mvSpeed,dir,timeOut,targetPos,isMv2Pos)
	self.isUping = false
	self:SetData( e_id,idMarker,idTarget,range,mvSpeed,dir,timeOut,targetPos,isMv2Pos )
end

function M:OnSetData(idMarker,idTarget,range,mvSpeed,dir,timeOut,targetPos,isMv2Pos)
	self.idMarker = idMarker
	self.idTarget = idTarget
	self.range = range
	self.mvSpeed = mvSpeed
	self.timeOut = timeOut
	self.v3Target = targetPos
	self.isMoveToPos = isMv2Pos
	self.maxDistance = self.range or 0
	self:SetMoveDir( dir )
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

	self.curr_time = self.curr_time + dt
	if self.timeOut and self.timeOut > 0  then
		self.isDisappear = (self.timeOut <= self.curr_time)
	end

	self:_OnUpPos(dt)
end

function M:OnPreDisappear()
	self.isUping,self.isDisappear,self.timeOut = nil
	self:_DisappearEffect()
	self:ReEvent4OnUpdate(false)
	self:ReEvent4Self(false)
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

function M:GetMvSpeed()
	return self.mvSpeed or 1
end

function M:_OnUpPos(dt)
	if (self.isDisappear == true) or (not self.currEft) or (not self.currEft:IsInitTrsf()) then
		return
	end
	
	if self.isMoveToPos then
		self:_OnPos( dt )
	else
		self:_OnTarget( dt )
	end
end

function M:_OnPos(dt)
	if self.mileAge >= self.maxDistance then
		self.isDisappear = true
		return
	end
	local _speed = dt * self:GetMvSpeed()
	local _v3Mov = self.movement * _speed
	local _distance = _v3Mov.magnitude
	self.mileAge = self.mileAge + _distance

	local _curr = self.currEft
	if self.mileAge >= self.maxDistance then
		local _pos = _curr:GetPosition()
		_v3Mov = self.v3Target - _pos
	end

	if _v3_zero:Equals(_v3Mov) then
        return
    end
	_curr:TranslateWorld( _v3Mov.x,_v3Mov.y,_v3Mov.z )
end

function M:_OnTarget(dt)
	local _lbTarget = this.GetSObj4Battle( self.idTarget )
	if not _lbTarget then
		self.isDisappear = true
		-- local _pos1 = self.currEft:GetPosition()
		-- local _diff = self.v3Target - _pos1
		-- self.maxDistance = _diff.magnitude
		return
	end
	local _pos2 = _lbTarget:GetPosition()
	self.v3Target:Set( _pos2.x,_pos2.y,_pos2.z)
	local _pos1 = self.currEft:GetPosition()
	local _diff = self.v3Target - _pos1
	self.maxDistance = _diff.magnitude
	self.mileAge = 0
	self:SetMoveDir( _diff )
	self:_OnPos( dt )
end

function M:Start()
	self.lbEfcts = EffectFactory.CreateEffect( self.idMarker,self.idMarker,self.data )
	self.isUping = tb_lens(self.lbEfcts) > 0
	self.curr_time = 0
	self.mileAge = 0
	self:ReEvent4OnUpdate(self.isUping)
	self:ReEvent4Self(self.isUping)
	if self.isUping then
		self.currEft = self.lbEfcts[1]
	end
	EffectFactory.ShowEffects( self.lbEfcts )
end

return M

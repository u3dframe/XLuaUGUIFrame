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

function M.Builder(idMarker,idTarget,e_id)
	local _isOkey,cfgEft = MgrData:CheckCfg4Effect( e_id )
	if (not _isOkey) or (cfgEft.type ~= E_Eft_Type.FlyPosition and cfgEft.type ~= E_Eft_Type.FlyTarget) then return end
	local _lbCaster = MgrScene.OnGet_Map_Obj( idMarker )
	local _lbTarget = MgrScene.OnGet_Map_Obj( idTarget )
	if not _lbCaster or not _lbTarget then return end
	local _pos1 = _lbCaster:GetPosition()
	local _pos2 = _lbTarget:GetPosition()
	local _diff = _pos2 - _pos1
	local range = _diff.magnitude
	local _mvSpeed,_v3OrgTarget = range / cfgEft.effecttime
	if cfgEft.type == E_Eft_Type.FlyPosition then
		_v3OrgTarget = _vec3.New( _pos2.x,_pos2.y,_pos2.z)
	end
	local _p_name,_ret = this.nm_pool_cls .. "@@" .. e_id
	local _t_out = (cfgEft.effecttime or 1000) * 0.001 + 0.06
	_ret = this.BorrowSelf( _p_name,idMarker,idTarget,e_id,range,_mvSpeed,_diff,_t_out,_v3OrgTarget )
	return _ret
end

function M:ctor()
	super.ctor( self )
	super2.ctor( self )
end

function M:Reset(idMarker,idTarget,e_id,range,mvSpeed,dir,timeOut,targetPos)
	self.isUping = false
	self:SetData( e_id,idMarker,idTarget,range,mvSpeed,dir,timeOut,targetPos )
end

function M:OnSetData(idMarker,idTarget,range,mvSpeed,dir,timeOut,targetPos)
	self.idMarker = idMarker
	self.idTarget = idTarget
	self.range = range
	self.mvSpeed = mvSpeed
	self.timeOut = timeOut
	self.v3OrgTarget = targetPos
	self.isMoveToPos = targetPos ~= nil
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

	self.currt_time = self.currt_time + dt
	if self.timeOut and self.timeOut > 0  then
		if self.timeOut <= self.currt_time then
			self.isDisappear = true			
		end
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

function M:SetMoveDir( dir )
	self.movement = self.movement or _vec3.zero
	if dir then
		dir.y = 0
		local mY = self.movement.y
		self.movement.y = 0
		local _dn = dir.normalized
		if not _dn:Equals(self.movement) then
			self.movement = _dn
		end
		self.movement.y = mY
	else
		self.movement:Set( 0,0,0)
	end
end

function M:GetMvSpeed()
	return self.mvSpeed or 1
end

function M:Start()
	self.lbEfcts = EffectFactory.CreateEffect( self.idMarker,self.idMarker,self.e_id )
	self.isUping = tb_lens(self.lbEfcts) > 0
	self.currt_time = 0
	self.mileAge = 0
	self:ReEvent4OnUpdate(self.isUping)
	self:ReEvent4Self(self.isUping)
	if self.isUping then
		self.currEft = self.lbEfcts[1]
	end
	EffectFactory.ShowEffects( self.lbEfcts )
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
	if self.mileAge >= self.range then
		self.isDisappear = true
		return
	end
	local _speed = dt * self:GetMvSpeed()
	local _v3Mov = self.movement * _speed
	local _distance = _v3Mov.magnitude
	self.mileAge = self.mileAge + _distance

	local _curr = self.currEft
	if self.mileAge >= self.range then
		local _pos = _curr:GetPosition()
		_v3Mov = self.v3OrgTarget - _pos
	end

	if _v3_zero:Equals(_v3Mov) then
        return
    end
	_curr:TranslateWorld( _v3Mov.x,_v3Mov.y,_v3Mov.z )
end

function M:_OnTarget(dt)
end

return M

--[[
	-- 效果de父类
	-- Author : canyon / 龚阳辉
	-- Date : 2021-04-16 15:25
	-- Desc :  抽取 共同 部分
]]
local type,tostring,tonumber = type,tostring,tonumber
local OneFrameSec,FrameRate = OneFrameSec,FrameRate
local _vec3,_hkpoint = Vector3,LES_Ani_Eft_Point
local _v3_zero = _vec3.zero

local super = LuaObject
local M = class( "effect_base",super )
local this = M

function M.GetSObj4Battle(id)
	return MgrScene.OnGet_Map_Obj( id )
end

function M.CalcSpeedAndDis( idMarker,idTarget,t_out,min_mv_speed )
	local _lbCaster = this.GetSObj4Battle( idMarker )
	local _lbTarget = this.GetSObj4Battle( idTarget )
	if not _lbCaster or not _lbTarget then
		return
	end
	local _pos1 = _lbCaster:GetPosition()
	local _pos2 = _lbTarget:GetPosition()
	local _diff = _pos2 - _pos1
	_diff.y = 0
	local range = _diff.magnitude
	local _t_out = t_out * 0.001
	local _mvSpeed,_v3Target = (range / _t_out),_vec3.New( _pos2.x,_pos2.y,_pos2.z)
	if min_mv_speed and (_mvSpeed * 100) < min_mv_speed then
		_mvSpeed = min_mv_speed * 0.01
		_t_out = range / _mvSpeed
	end
	return range,_mvSpeed,_diff,_t_out,_v3Target
end

function M:ctor()
	super.ctor( self )
end

function M:ReEvent4Self(isbind)
	local _evt = self._fevt()
	_evt.RemoveListener(Evt_Map_SV_Skill_Pause, self.Pause, self)
	_evt.RemoveListener(Evt_Map_SV_Skill_GoOn, self.Regain, self)
	if (isbind)then
		_evt.AddListener(Evt_Map_SV_Skill_Pause, self.Pause, self)
		_evt.AddListener(Evt_Map_SV_Skill_GoOn, self.Regain, self)
	end
end

function M:OnCurrUpdate(dt)
	if self.isPause then
		return
	end
	
	if (self.isDisappear == true) then
		self:Disappear()
	end

	local _speed = self:GetSpeed()
	self.curr_time = self.curr_time + dt * _speed
	if self.timeOut and self.timeOut > 0  then
		self.isDisappear = (self.timeOut <= self.curr_time)
	end
	
	self:_OnUpPos(dt)

	local _cmax = self.maxtime or self.timeout
	if _cmax and _cmax > 0  then
		local _obj = self.currEft or self
		_obj:SetCurve( dt,_cmax,self.currEft ~= nil )
	end

	return true
end

function M:SetMvSpeed( speed )
	self.mvSpeed = speed or 1
end

function M:GetMvSpeed()
	return self.mvSpeed or 1
end

function M:SetMoveDir( dir )
	super.SetMoveDir( self,dir )
	if dir then
		local _obj = self.currEft or self
		if type(_obj.SetForward) == "function" then
			_obj:SetForward( dir.x,0,dir.z )
		end
	end
end

function M:_IsNotCanUpPos()
	if (self.isDisappear == true) or (not self.movement) or (not self.currEft) or (not self.currEft:IsInitTrsf()) then
		return true
	end
	return (self.isNotUpPos == true)
end

function M:_OnUpPos(dt)
	if (self:_IsNotCanUpPos()) then
		return
	end
	
	if self.isMoveToPos then
		self:_OnPos( dt )
	else
		self:_OnTarget( dt )
	end
end

function M:_OnPos(dt)
	if (self:_IsNotCanUpPos()) then
		return
	end
	
	if (not self.mileAge) or (not self.maxDistance) then
		return
	end

	if self.mileAge >= self.maxDistance then
		self:Jugde4Disappear()
		return
	end
	local _curr = self.currEft
	local _speed = self:GetMvSpeed() * dt
	local _v3Mov = self.movement * _speed

	local _pos = _curr:GetPosition()
	local _diffY = (self.toY and self.toY ~= 0) and (_pos.y - self.toY) or 0
    if _diffY ~= 0 then
		self.gravityPosY = (self.gravity or 1) * dt
		_v3Mov.y = _v3Mov.y + self.gravityPosY 
	end

	local _distance = _v3Mov.magnitude
	self.mileAge = self.mileAge + _distance

	if self.mileAge >= self.maxDistance then
		local _pos = _curr:GetPosition()
		_v3Mov = self.v3Target - _pos
	end
	if _v3_zero:Equals(_v3Mov) then
        return
    end
	_curr:TranslateWorld( _v3Mov.x,_v3Mov.y,_v3Mov.z )
	return true
end

function M:_OnTarget(dt)
	if (self:_IsNotCanUpPos()) then
		return
	end
	local _lbTarget = this.GetSObj4Battle( self.idTarget )
	if not _lbTarget then
		self:Jugde4Disappear()
		return
	end
	local _s_1 = _lbTarget:GetHookPoint( _hkpoint[5] )
	_lbTarget = _s_1 or _lbTarget
	local _pos2 = _lbTarget:GetPosition()
	if self.v3Target then
		self.v3Target:Set( _pos2.x,_pos2.y,_pos2.z )
	else
		self.v3Target = _vec3.New( _pos2.x,_pos2.y,_pos2.z )
	end
	local _pos1 = self.currEft:GetPosition()
	local _diff = self.v3Target - _pos1
	_diff.y = (_diff.y > 0.5) and _diff.y or 0
	self.toY = _diff.y
	self.maxDistance = self:TF( _diff.magnitude,4 )
	self.mileAge = 0

	local _lmtDis = 1
    if dt > OneFrameSec then
        _lmtDis = self:MCeil( dt * FrameRate )
    end
	_lmtDis = _lmtDis * 0.08 * self:GetMvSpeed() * dt
	if self.maxDistance <= _lmtDis then
		self:Jugde4Disappear()
		return
	end
	
	self:SetMoveDir( _diff )
	return self:_OnPos( dt )
end

function M:OnUp_Link(dt)
	local _obj = self.currEft or self
	if not _obj._link2id or not _obj.isInited then
		return
	end
	local _sobj_ = _obj:GetSObjBy( _obj._link2id )
	if not _sobj_ then
		return
	end
	local _s_1 = _sobj_:GetHookPoint( _hkpoint[5] )
	_sobj_ = _s_1 or _sobj_
	local _curPos = _obj:GetPosition()
	local _toPos = _sobj_:GetPosition()
	local _dis = _vec3.Distance(_toPos, _curPos) - 0.382
	_dis = (_dis <= 0.1) and 0.1 or _dis
	local _obj = _obj.lbTrsfOffset or _obj
	_obj:SetLocalScale(1,1,_dis)
	_obj:LookAt( _toPos.x,_toPos.y,_toPos.z  )
end

function M:Jugde4Disappear()
	self.isNotUpPos = true
	self.isDisappear = true
end

-- 消失
function M:OnPreDisappear()
	self.isUping,self.isDisappear,self.timeOut = nil
	self.isNotUpPos = nil
	self:RemoveEvents()

	local _lfunc = self.lfDisappear
	self.lfDisappear = nil
	if _lfunc then
		_lfunc()
	end
end

function M:SetIsNoCurve( isBl )
	self.isNoCurve = (isBl == true)
end

function M:SetCurve( dt,maxtime,force )
	force = (force == true) or (not self.isNoCurve)
	if (not force) or (not self.csCurve) or (not maxtime) or (maxtime <= 0) then
		return
	end
	self.curex_time = self.curex_time or 0
	self.curex_time = self.curex_time  + (dt * self.speed)	
	self.csCurve:ReVal(self.curex_time,maxtime)
end

function M:ResetTimeOut( time_out_sec )
	self.timeOut = time_out_sec
	if self.timeOut and self.timeOut > 0 then
		self.curr_time = 0
	end
end

function M:SetSpeed( speed )
	self.speed = speed or 1
end

function M:GetSpeed()
	if not self.speed then
		self:SetSpeed(1)
	end
	return self.speed
end

return M
--[[
	-- 场景对象 - 生物 单元
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-26 21:25
	-- Desc : 
]]

local ActionFactory = require ("games/logics/_scene/actions/action_factory")
local type,tostring,tonumber = type,tostring,tonumber
local _vec3,NumEx = Vector3,NumEx
local tb_insert = table.insert
local E_State,E_Flag,E_State2Action = LES_C_State,LES_C_Flag,LES_C_State_2_Action_State
local ET_SE,E_AiState = LET_Shader_Effect,LES_C_Action_State

local _dis_max_sync_pos = (0.8)^2
local super,_evt = SceneObject,Event
local M = class( "scene_c_unit",super )

function M:InitCUnit(worldY,mvSpeed)
	self:SetWorldY( worldY or 0 )
	self:SetMoveSpeed( mvSpeed or 100 ) -- 比例 1:100
end

function M:OnActive(isActive)
	super.OnActive( self,isActive )
	if not isActive then
		self:RmvFunc("_a_up_" .. tostring(self.enter_a_state))
		self.enter_a_state,self.lfOnceMvOver = nil
	end
end

function M:IsNeedGetComp()
	return true
end

function M:OnInit()
	self:_Init_CU_Vecs()
	self._lf_On_Up = handler_pcall(self,self.OnUpdate_CUnit)
	self._lf_On_A_Enter = handler_pcall(self,self.OnUpdate_A_Enter)
	self._lf_On_A_Up = handler_pcall(self,self.OnUpdate_A_Up)
	self._lf_On_A_Exit = handler_pcall(self,self.OnUpdate_A_Exit)
	
	self.comp:InitCCEx(self._lf_On_Up,self._lf_On_A_Enter,self._lf_On_A_Up,self._lf_On_A_Exit)
	if self._async_isUsePhysics ~= nil then
		self:SetIsUsePhysics( self._async_isUsePhysics )
	end

	self:_InitVecs()
	self:OnInit_Child()
end

function M:OnInit_Child()
end

function M:OnShowBeg()
	self:SetGName(self:GetCursor())
	self:_LookAtOther()
end

function M:_Init_CU_Vecs()
	self.v3M_Temp = _vec3.zero
	self.v3MoveTo = _vec3.zero
end

function M:OnUpdate_CUnit(dt,undt)
	if self.isPause or not self:IsLoadedAndShow() then
		return
	end

	if self._async_n_action ~= nil then
		self:PlayAction( self._async_n_action )
	end
	
	local _machine = self.machine
	if _machine then
		_machine:On_Update( dt * self:GetCurrAniSpeed() )
	end
	self:OnUpdate_Child( dt,undt )
end

function M:OnUpdate_Child(dt,undt)
end

function M:PlayAction(n_action)
	n_action = n_action or 0
	if n_action == self.n_action then
		return
	end
	self._async_n_action = nil
	if self.comp then
		-- printInfo("======= [%s] PlayAction = pre = [%s] , cur = [%s]",self:GetCursor(),self.n_action,n_action)
		self.n_action = n_action
		self.comp:SetActionAndASpeed(self.n_action,self:GetCurrAniSpeed())
	else
		self._async_n_action = n_action
	end
end

function M:OnUpdate_A_Enter(_,_,_,a_state)
	self.enter_a_state = a_state
end

function M:OnUpdate_A_Up(ani,info,layer,a_state)
	self:ExcFunc("_a_up_" .. tostring(a_state),ani,info,layer,a_state)
end

function M:OnUpdate_A_Exit(_,info,_,a_state)
	-- if info.loop then return end
	self:RmvFunc("_a_up_" .. tostring(self.enter_a_state))
end

function M:Add_AUpFunc( a_state,func,obj )
	self:AddFunc( "_a_up_" .. tostring(a_state),func,obj )
end

function M:GetState()
	return self.state,self.preState
end

function M:SetStateAndPre(state,preState)
	self.preState = preState
	self.state = state
end

function M:SetIsUsePhysics( isUsePhysics )
	isUsePhysics = isUsePhysics == true
	if isUsePhysics == self.isUsePhysics then
		return
	end
	self._async_isUsePhysics = nil
	if self.comp then
		self.isUsePhysics = isUsePhysics
		self.comp.m_isUsePhysics = isUsePhysics
	else
		self._async_isUsePhysics = isUsePhysics
	end
end

function M:SetState(state,force,...)
	force = (force == true) or (self.state == nil)  or (state ~= self.state)
	if not force then
		if not self.machine then
			self:SetMachine( ... )
		end
		return
	end
	self:SetStateAndPre( state,self.state )
	-- printInfo("======= [%s] SetState = pre =  [%s] = cur =  [%s]",self:GetCursor(),self.preState,self.state)
	self:SetMachine( ... )
end

function M:State2Idle( force )
	self:SetState( E_State.Idle,force )
end

function M:_LookAtOther()
	local _lb = self:GetSObjMapBox()
	if not _lb then return end

	local _selfIsEnemy = self:IsEnemy()
	local _x,_y,_z = _lb:GetCenterXYZ( _selfIsEnemy )
	self:LookAt( _x,_y,_z )
end

function M:SetCurrPos(x,y)
	self.comp:SetCurrPos( x,self.worldY,y )
end

function M:IsGrounded(c_y)
	c_y = c_y or 0
	return self.comp.isGrounded or ( self.worldY - c_y <= 0.001 )
end

function M:SetMoveSpeed(speed)
	self.move_speed = speed or 0
end

-- 瞬移速度
function M:SetMoveSpeedShift(speed)
	self.speedShift = speed
end

function M:GetMoveSpeed()
	return ((self.speedShift ~= nil) and (self.speedShift ~= 0)) and self.speedShift or (self.move_speed or 1)
end

function M:GetCurrMoveSpeed()
	local _speed_,_rate_ = self:GetMoveSpeed(),1
	self.speedShift = nil
	local _lb = self:GetSObjMapBox()
	if _lb then
		_rate_ = _lb.edge
	end
	return _speed_ * _rate_
end

function M:SetAtkSpeed(speed)
	self.atk_speed = speed
end

function M:SetAniSpeed(speed)
	self.ani_speed = speed
end

function M:GetCurrAniSpeed()
	if self.state == E_State.Attack then
		return self.atk_speed or 1
	end
	return self.ani_speed or 1
end

function M:CsAniSpeed( ani_speed )
	if not self.comp then
		return
	end
	ani_speed = ani_speed or self:GetCurrAniSpeed()
	self.cur_aniSpeed = ani_speed
	self.comp:SetSpeed( ani_speed )
end

function M:SetUpMovement(yVal,isAddWY)
	if isAddWY == true then
		yVal = yVal + self.worldY
	end
	self.movement.y = yVal
end

function M:MoveTo(to_x,to_y,cur_x,cur_y,...)
	self._async_m_x,self._async_m_y,self._async_c_x,self._async_c_y = nil
	if self.comp then
		self:SetIsUsePhysics( false )
		self:SetState( E_State.Run,false,... )
		local _pos,_diff = self:GetPosition()
		if cur_x and cur_y then
			self.v3M_Temp:Set(cur_x,self.worldY,cur_y)
			_diff = self.v3M_Temp - _pos
			if _diff.sqrMagnitude > _dis_max_sync_pos then
				self:SetPos( cur_x,cur_y )
				_pos = self.v3Pos
			end
		end

		to_x,to_y = self:ReXYZ( to_x,to_y )
		self.v3MoveTo:Set(to_x,self.worldY,to_y)
		_diff = self.v3MoveTo - _pos
		self:SetMoveDir( _diff )
	else
		self._async_m_x,self._async_m_y,self._async_c_x,self._async_c_y = to_x,to_y,cur_x,cur_y
	end
end

function M:MoveEnd(x,y)
	self:Move_Over()
	self:SmoothPos( x,y )
end

function M:SmoothPos( x,y,isLocal )
	if self:IsInitGobj() then
		if x and y then
			isLocal = isLocal == true
			self.csEDComp:ToSmoothPos( x,self.worldY,y,isLocal,0.01 )
		end
	else
		self:SetPos( x,y )
	end
end

function M:SetOnceFunc4MoveOver( funcMvOver )
	self.lfOnceMvOver = funcMvOver
end

function M:Move_Over(isNot2Idle)
	self._async_m_x,self._async_m_y = nil
	if not isNot2Idle then
		self:State2Idle()
	end
	self:SetMoveDir()
	local _lfc = self.lfOnceMvOver
	self.lfOnceMvOver = nil
	if _lfc then
		_lfc()
	end
end

function M:Move_Info()
	local _speed = self:GetCurrMoveSpeed()
	return self.comp,_speed,self.movement,self.v3MoveTo
end

function M:IsInStiff()
	return ET_SE.Stone == self.ccType
end

-- 暂停
function M:Pause()
	if not super.Pause( self ) then
		return
	end
	self.pre_aniSpeed = self.cur_aniSpeed
	self:CsAniSpeed(0)
	return true
end

-- 恢复
function M:Regain()
	if self:IsInStiff() then
		self.prePause = nil
		return
	end
	super.Regain( self )
	
	local _as = self.pre_aniSpeed
	self.pre_aniSpeed = nil
	self:CsAniSpeed( _as )
end

function M:HaveFlag(flagid)
	if self.flag then
		local _v = self.flag[flagid]
		return _v and _v > 0
	end
end

function M:AddFlag(flagid, sub)
	self.flag = self.flag or {}
	sub = sub or 1
	local _v = self.flag[flagid] or 0
	_v = NumEx.bitOr(_v, sub)
	self.flag[flagid] = NumEx.bitOr(self.flag[flagid], sub)
end

function M:DelFlag(flagid, sub)
	self.flag = self.flag or {}
	local _v = self.flag[flagid] or 0
	sub = NumEx.bitNot(sub or 1)
	self.flag[flagid] = NumEx.bitAnd(_v,sub)
end

function M:CheckDead()
	return self:HaveFlag(E_Flag.Dead)
end

function M:CheckIdle()
	return not (self:HaveFlag(E_Flag.No_Idle))
end

function M:CheckRun()
	return not (self:HaveFlag(E_Flag.No_Run))
end

function M:CheckAttack()
	return not (self:HaveFlag(E_Flag.No_Attack))
end

function M:GetActionState()
	return E_State2Action[self.state]
end

function M:SetMachine( ... )
	ActionFactory.MakeMachine( self,... )
end

function M:EndAction()
	local _machine = self.machine
	self.machine = nil
	if _machine and _machine.isDoned then
		local _m_astate = _machine.action_state
		if _m_astate ~= E_AiState.Idle and (not _machine.isNot2Idle) then
			self:State2Idle()
		end
	end
end

return M
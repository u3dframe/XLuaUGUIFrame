--[[
	-- 场景对象 - 生物 单元
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-26 21:25
	-- Desc : 
]]

local ActionFactory = require ("games/logics/_scene/actions/action_factory")

local _vec3,NumEx,type,tostring = Vector3,NumEx,type,tostring

local tb_insert = table.insert
local _v3_zero = _vec3.zero

local E_State,E_Flag,E_State2Action = LES_C_State,LES_C_Flag,LES_C_State_2_Action_State

local super = SceneObject
local M = class( "scene_creature",super )

function M:InitCUnit(worldY,mvSpeed)
	self:SetWorldY( worldY or 0 )
	self:SetMoveSpeed( mvSpeed or 1 )
end

function M:OnActive(isActive)
	super.OnActive( self,isActive )
	if not isActive then
		self:RmvFunc("_a_up_" .. tostring(self.enter_a_state))
		self.enter_a_state = nil
	end
end

function M:OnInit()
	self:_Init_CU_Vecs()

	self._lf_On_Up = handler_pcall(self,self.OnUpdate_CUnit)
	self._lf_On_A_Enter = handler_pcall(self,self.OnUpdate_A_Enter)
	self._lf_On_A_Up = handler_pcall(self,self.OnUpdate_A_Up)
	self._lf_On_A_Exit = handler_pcall(self,self.OnUpdate_A_Exit)

	self.comp:InitCCEx(self._lf_On_Up,self._lf_On_A_Enter,self._lf_On_A_Up,self._lf_On_A_Exit)

	self:OnInit_Unit()
end

function M:OnInit_Unit()
end

function M:_Init_CU_Vecs()
	self.v3MoveTo = _vec3.zero
	self.v3Move = _vec3.zero
end

function M:OnUpdate4Moving( dt )
	if not self.comp then return end
	if not self.movement then return end

	--注意，这里需要修改movement的y轴
	local movement = self.movement

	self.groundPosY =  self.groundPosY or 0
	self.gravityPosY = self.gravityPosY or 0

	local _posY = self.trsf.position.y
	if self.comp.isGrounded then
		self.groundPosY = _posY
		self.gravityPosY = 0
	else
		if _posY > self.groundPosY then
			self.gravityPosY = self.gravity * _evtime
			movement.y =  movement.y - self.gravityPosY
		end
	end
	
	if _v3_zero:Equals(movement) then return end

	local speed = self.move_speed
	-- 瞬移速度
	if self.speedShift and self.speedShift ~= 0 then
		speed = self.speedShift
	end
	
	speed = speed * dt * 0.01
	
	self.v3Move.x = movement.x * speed
	self.v3Move.y = movement.y
	self.v3Move.z = movement.z * speed

	if _v3_zero:Equals(self.v3Move) then return end
	self.comp:Move(self.v3Move.x,self.v3Move.y,self.v3Move.z)
end

function M:OnUpdate_CUnit(dt,undt)
	if not self:IsLoadedAndShow() then return end

	if self._async_n_action ~= nil then
		self:PlayAction( self._async_n_action )
	end

	self:OnUpdate4Moving( dt )
	
	local _machine = self.machine
	if _machine then
		_machine:On_Update(dt)
	end
end

function M:GetActionStr()
	return tostring(LES_Ani_Layer[0]) .. "." .. tostring(LES_Ani_State[self.n_action or 0])
end

function M:OnUpdate_A_Enter(_,_,_,a_state)
	self.enter_a_state = a_state
end

function M:OnUpdate_A_Up(ani,info,layer,a_state)
	self:ExcFunc("_a_up_" .. tostring(a_state),ani,info,layer,a_state)
	if not info.loop and info.normalizedTime > 1 then		
		if self.enter_a_state == a_state then
			if self.state == E_State.Show_1 then
				self:SetState( E_State.Idle )
			end
		end
	end 
end

function M:OnUpdate_A_Exit(_,info,_,a_state)
	-- if info.loop then return end
	self:RmvFunc("_a_up_" .. tostring(self.enter_a_state))
end

function M:Add_AUpFunc( a_state,func,obj )
	self:AddFunc( "_a_up_" .. tostring(a_state),func,obj )
end

function M:SetState(state,isReplace)
	isReplace = (isReplace == true) or (self.state == nil)  or (state ~= self.state)
	if not isReplace then return end
	self.preState = self.state
	self.state = state
	self:SetMachine()
end

function M:SvPos2MapPos( svX,svY )
	local _lb = self:GetSObjBy( "map.gbox" )
	if not _lb then return svX,svY end
	return _lb:SvPos2MapPos( svX,svY )
end

function M:SetPos(x,y)
	self:SetPosition ( x,self.worldY,y )
end

function M:LookPos(x,y)
	self:LookAt ( x,self.worldY,y )
end

function M:SetWorldY(w_y)
	self.worldY = w_y or 0
end

function M:SetMoveSpeed(speed)
	self.move_speed = speed or 0
end

function M:SetMoveDir( dir )
	if dir then
		local _dn = dir.normalized
		local _isSet = (self.movement == nil) or (not _dn:Equals(self.movement))
		if _isSet then
			self.movement = _dn
		end
	else
		self.movement = nil
	end
end

-- 瞬移速度
function M:SetMoveSpeedShift(speed)
	self.speedShift = speed
end

function M:MoveTo(to_x,to_y,cur_x,cur_y)
	if cur_x and cur_y then
		self:SetPos( cur_x,cur_y )
	end
	self._async_m_x,self._async_m_y = nil
	if self.comp then
		self:SetState( E_State.Run )
		to_x,to_y = self:ReXYZ( to_x,to_y )
		self.v3MoveTo:Set(to_x,self.worldY,to_y)
		local _diff = self.v3MoveTo - self.v3Pos
		self:SetMoveDir( _diff )
	else
		self._async_m_x,self._async_m_y = to_x,to_y
	end
end

function M:MoveEnd(x,y)
	self:SetPos( x,y )
	self:Move_Over()
end

function M:Move_Over()
	self._async_m_x,self._async_m_y = nil
	self:SetMoveDir()
	self:SetState( E_State.Idle )
end

-- 暂停
function M:Pause()
	if self.isPause then
		return false
	end
	self.isPause = true
	return true
end

-- 恢复
function M:Regain()
	if not self.isPause then
		return
	end
	self.isPause = nil
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

function M:GetState()
	return self.state
end

function M:GetActionState()
	return E_State2Action[self.state]
end

function M:SetMachine()
	ActionFactory.MakeMachine( self )
end

function M:EndAction()
	if self.machine.isDoned then
		self.machine = nil
	end
end

return M
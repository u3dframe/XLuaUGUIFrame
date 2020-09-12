--[[
	-- 行为动作 - 父类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-27 14:15
	-- Desc : 
]]

local E_Action = LES_C_Action

local super = LuaObject
local M = class( "action_basic",super )

function M:ctor(lbObj)
	assert( lbObj,"owner is null in state.idle " )
	super.ctor( self )
	self.lbOwner = lbObj
	self.ownerCursor = lbObj:GetCursor()
	self.isDoned = false
	self.a_state = E_Action.Create
	self.isBreakSelf = true -- 能否被自身 jugde_state 相同的 状态打断
	self.isBreakOther = true -- 能否被其他 jugde_state 状态打断
	-- self.action_state = 0
	-- self.jugde_state = 0
	self.up_sec = 0
	self.time_out = 0
	self.isAi_Up = false

	self:_On_A_Init()
end

function M:on_clean()
	self.lbOwner = nil
end

function M:_On_A_Init()
end

function M:_AEnter()
	if self:_IsAEnter() then
		self.isDoned = true
		self.action_state = self.action_state or self.lbOwner:GetActionState()
		self.up_sec = 0
		self.time_out = 0
		self.isDisappear = false

		if self:_On_AEnter() then
			self.start_sec = Time.time
			self:_Enter_Ai_State()
			self.lbOwner:PlayAction( self.action_state )
			self:SetState( E_Action.Update )
		end
	end
end

function M:_IsAEnter() 
	return true 
end

function M:_On_AEnter()
	return true
end

function M:_Enter_Ai_State()
	if self.isAi_Up == true then
		self.lbOwner:Add_AUpFunc( self.action_state,self._On_Ani_Update,self )
	end
end

function M:_On_Ani_Update(ani,info,layer)
	if info.normalizedTime >= 1.0 then
		self.lbOwner:RmvFunc("_a_up_" .. tostring(self.action_state))
		self:Exit()
	end
end

function M:_On_AUpdate(dt)
end

function M:_On_Up4Exit(dt)
	if (self.isDisappear == true) then
		self.isDisappear,self.time_out = nil
		self:Exit()
	end

	if self.time_out and self.time_out > 0 and self.up_sec >= self.time_out then
		self.isDisappear = true
	end
end

function M:_On_AExit()
	if self.a_state == E_Action.End then
		return
	end
	self.a_state = E_Action.End
	local _lb = self.lbOwner
	if not _lb then return end
	self.lbOwner,self.isPause = nil
	_lb:RmvFunc("_a_up_" .. tostring(self.action_state))
	_lb:EndAction()
	return _lb
end

function M:On_Update(dt)
	if self.isPause then
		return
	end
	if self.a_state == E_Action.Enter then
		self:_AEnter()
	elseif self.a_state == E_Action.Update then
		if self.pre_a_state == E_Action.Enter or self.pre_a_state == E_Action.Update then
			self.up_sec = self.up_sec + dt
			self:_On_AUpdate(dt)
			self:_On_Up4Exit(dt)
		end
	elseif self.a_state == E_Action.Exit then
		self:_On_AExit()
	end
end

-- 暂停
function M:Pause()
	if self.isPause then
		return
	end
	self.isPause = true
end

-- 恢复
function M:Regain()
	if not self.isPause then
		return
	end
	self.isPause = nil
end

function M:SetState(state,force)
	force = (force == true) or (state ~= self.a_state)
	if not force then return end
	
	self.pre_a_state = self.a_state
	self.a_state = state
end

function M:Enter()
	self:SetState( E_Action.Enter )
	self:On_Update()
	return self
end

function M:Exit()
	if self.a_state == E_Action.End then return end
	self:SetState( E_Action.Exit )
	self:On_Update()
end


return M
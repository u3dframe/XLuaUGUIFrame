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
	self.a_state = E_Action.End
	if not self.lbOwner then return end
	local _lb = self.lbOwner
	_lb:EndAction()
	self.lbOwner = nil
	return _lb
end

function M:On_Update(dt)
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
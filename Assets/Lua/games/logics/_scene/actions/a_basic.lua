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
	self.isDoned = false
	self.a_state = E_Action.Create
	self.isBreakSelf = true -- 能否被自身 jugde_state 相同的 状态打断
	self.isBreakOther = true -- 能否被其他 jugde_state 状态打断
	-- self.action_state = 0
	-- self.jugde_state = 0

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

		if self:_On_AEnter() then
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

function M:_On_AExit()
	self.lbOwner:EndAction()
end

function M:On_Update(dt)
	if self.a_state == E_Action.Enter then
		self:_AEnter()
	elseif self.a_state == E_Action.Update then
		if self.pre_a_state == E_Action.Enter or self.pre_a_state == E_Action.Update then
			self:_On_AUpdate(dt)
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
	self:SetState( E_Action.Exit )
	self:On_Update()
end


return M
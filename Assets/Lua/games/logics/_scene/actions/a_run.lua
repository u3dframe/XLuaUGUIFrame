--[[
	-- 行为动作 - 移动 Run
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-27 17:44
	-- Desc : 
]]

local E_Action = LES_C_Action
local E_AniState = LES_C_Action_State
local E_State = LES_C_State

local super = ActionBasic
local M = class( "action_run",super )

function M:_On_A_Init()
	self.jugde_state = E_State.Run
	self.action_state = E_AniState.Run
	self.isBreakSelf = false
end

function M:_IsAEnter()
	local _isBl = self.lbOwner:CheckRun()
	if _isBl then
		if self.lbOwner._async_m_x ~= nil or self.lbOwner._async_m_y ~= nil then
			self.lbOwner:MoveTo( self.lbOwner._async_m_x,self.lbOwner._async_m_y )
			return false
		end
	end
	return _isBl
end

function M:_On_AExit()
	super._On_AExit( self )
	self.lbOwner:Move_Over()
end

return M
--[[
	-- 状态 - 待机 Idle
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-27 14:15
	-- Desc : 
]]

local E_State = LES_C_State
local E_AniState = LES_C_Action_State

local super = ActionBasic
local M = class( "action_idle",super )

function M:_On_A_Init()
	self.jugde_state = E_State.Idle
	self.action_state = E_AniState.Idle
end

function M:_IsAEnter()
	return self.lbOwner:CheckIdle()
end

return M
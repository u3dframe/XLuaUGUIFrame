--[[
	-- 状态 - 展示动作1
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-27 18:19
	-- Desc : 
]]

local E_State = LES_C_State
local E_AniState = LES_C_Action_State

local super = ActionBasic
local M = class( "action_show1",super )

function M:_On_A_Init()
	self.jugde_state = E_State.Show_1
	self.action_state = E_AniState.Show_1
	self.isAi_Up = true
end

return M
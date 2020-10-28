--[[
	-- 状态 - 攻击 attack - skill
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-27 18:19
	-- Desc : 
]]

local type,tostring = type,tostring

local E_Life = LES_Life
local E_State = LES_C_State

local super = ActionBasic
local M = class( "action_attack",super )

function M:_On_A_Init()
	self.jugde_state = E_State.Attack
	self.tmData = self.lbOwner:GetAttackEffets()
end

function M:_IsAEnter()
	return self.lbOwner:CheckAttack()
end

function M:_On_AEnter()
	local _isBl = true
	if self.lbOwner:IsBigSkill() then
		_isBl = false
		self:SetState( E_Life.Update )
	end
	if _isBl then
		self.isAi_Up = false
		self.n_cursor = 0
		local _tout = self.lbOwner:GetSkillTimeOut()
		if _tout > 0 then
			self.time_out = _tout / 1000
		else
			self.isAi_Up = true
		end
	end
	return _isBl
end

function M:_On_AUpdate(dt)
	self:_Excute_Effect()
end

function M:_On_AExit()
	self.tmData,self.n_cursor = nil
	super._On_AExit( self )
end

function M:_Excute_Effect()
	self:_Exc_AniEvent( self.n_cursor,self.up_sec * 1000 )
end

function M:_Exc_AniEvent(index,exc_time_ms)
	local lb = self.tmData
	if type(lb) ~= "table" then
		return
	end

	if index < #lb then
		local tickData = lb[index + 1]
		if tickData.time <= exc_time_ms then
			--开始调用回调!
			self.n_cursor = index + 1
			local _ids = tickData.ids
			for _,v in ipairs(_ids) do
				self.lbOwner:ExcuteEffectByEid( v )
			end
		end
	end
end

return M
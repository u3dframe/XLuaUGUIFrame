--[[
	-- 行为动作 - 攻击 attack - skill
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-27 18:19
	-- Desc : 
]]

local _mfloor = math.floor

local E_Action = LES_C_Action
local E_AniState = LES_C_Action_State
local E_State = LES_C_State

local super = ActionBasic
local M = class( "action_attack",super )

function M:_On_A_Init()
	self.jugde_state = E_State.Attack
end

function M:_IsAEnter()
	return self.lbOwner:CheckAttack()
end

function M:_On_AEnter()
	local _isBl = true
	if self.lbOwner.cfgSkill_Eft.type == 1 then
		_isBl = false
	end
	if _isBl then
		self.start_sec = Time.time
		self.up_sec = 0
		self.n_cursor = 0
		self.lbOwner:Add_AUpFunc( self.action_state,self._On_Ani_Update,self )
	end
	return _isBl
end

function M:_On_Ani_Update(ani,info,layer)
	local _ti = Time.time
	local _t1 = _ti - self.start_sec
	local _t2 = self.up_sec

	printInfo("=====[%s] = [%s]",_t1,_t2)
	self:exceAniEvent(self.n_cursor,_t1)
end

function M:exceAniEvent(index,exc_time)
	local lb = self.lbOwner:GetAttackEffets()
	if type(lb) ~= "table" then
		return
	end

	if index < #lb then
		local tickData = lb[index + 1]

		if tickData.time <= exc_time then
			--开始调用回调!
			self.n_cursor = index + 1
			local _datas = tickData.datas
			for _,v in ipairs(_datas) do
				self.lbOwner:ExcuteEffectData( v )
			end
		end
	end
end

function M:_On_AUpdate(dt)
	self.up_sec = self.up_sec + dt
end

return M
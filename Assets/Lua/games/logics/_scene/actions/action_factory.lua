--[[
	-- 行为-状态-脚本
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-27 16:45
	-- Desc : 
]]

local E_State = LES_C_State

local fdir = "games/logics/_scene/actions/"
local _req = reimport or require

ActionBasic            = _req (fdir .. "a_basic")     -- 状态 - 基础类
local _lbCls_ = {
	[E_State.Idle]     = _req (fdir .. "a_idle"),     -- 状态 - 待机
	[E_State.Run]      = _req (fdir .. "a_run"),      -- 状态 - 移动
	[E_State.Grab]     = _req (fdir .. "a_grab"),     -- 状态 - 被拧起
	[E_State.Show_1]   = _req (fdir .. "a_show1"),    -- 状态 - 展示1
	[E_State.Attack]   = _req (fdir .. "a_attack"),   -- 状态 - 攻击
	[E_State.Die]      = _req (fdir .. "a_die"),      -- 状态 - 死亡
	[E_State.BeHit]    = _req (fdir .. "a_behit"),    -- 状态 - 被击、受击
}

local M = {}
local this = M

function M.MakeMachine(obj,...)
	if obj:CheckDead() then return end
	local _o_state,_o_pre_state = obj:GetState()
	local _a_state = obj:GetActionState()
	if not _a_state then return end

	local _machine = obj.machine
	local _is_enter = (_machine == nil)
	if _machine then
		local _isBreak = false
		if _machine.jugde_state == _o_state then
			_isBreak = _machine.isBreakSelf
			if _a_state ~= _machine.action_state then
				_isBreak = _machine.isBreakOther
			end
		else
			_isBreak = _machine.isBreakOther
		end
		if _isBreak then
			_machine:Exit()
			_machine = nil
			_is_enter = true
		end
	end

	if _is_enter then
		local _cls = _lbCls_[_o_state]
		obj:SetStateAndPre( _o_state,_o_pre_state )
		if _cls then
			_machine = _cls.New( obj ):Enter(...)
		end
	end
	obj.machine = _machine
end

return M
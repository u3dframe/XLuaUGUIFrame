--[[
	-- 状态 - 死亡
	-- Author : canyon / 龚阳辉
	-- Date : 2020-09-07 10:25
	-- Desc : 
]]

local E_Life = LES_Life
local E_State = LES_C_State
local E_AniState = LES_C_Action_State

local MgrData = MgrData

local super,evt = ActionBasic,Event
local M = class( "action_die",super )

function M:_On_A_Init()
	self.jugde_state = E_State.Die
	self.action_state = E_AniState.Die

	self.cfg_id = self.lbOwner:GetCfgEID4Die()
end

function M:_On_AEnter()
	local _cfg
	if self.cfg_id then
		_cfg = MgrData:GetCfgSkillEffect( self.cfg_id )		
	end
	if _cfg then
		self.time_out = _cfg.effecttime / 1000
		evt.Brocast( Evt_Battle_Delay_End_MS,_cfg.effecttime )
		self.lbOwner:ExcuteEffectByEid( self.cfg_id,true )
		self:SetState( E_Life.Update )
	else
		self:Exit()
	end
	return false
end

function M:_On_AExit()
	super._On_AExit( self )
	if not self.ownerCursor then return end
	-- printError("======= die _On_AExit = [%s] = [%s] = [%s] = [%s]",self.time_out,self.cfg_id,self.ownerCursor,self.up_sec)
	evt.Brocast( Evt_Map_SV_RmvObj, self.ownerCursor )
	self.cfg_id,self.ownerCursor = nil
end

return M
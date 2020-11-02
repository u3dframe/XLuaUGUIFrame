--[[
	-- 状态 - 受击、被击
	-- Author : canyon / 龚阳辉
	-- Date : 2020-09-26 10:19
	-- Desc : 
]]

local E_Life = LES_Life
local E_State = LES_C_State
local E_AniState = LES_C_Action_State
local E_CEType = LES_Ani_Eft_Type
local m_min,m_max = math.min,math.max

local super = ActionBasic
local M = class( "behit",super )

function M:_On_A_Init()
	self.jugde_state = E_State.BeHit
end

function M:Reset( e_id,cfgEft,idCaster,idTarget,svData )
	self.e_id = e_id
	self.idCaster = idCaster
	self.idTarget = idTarget
	self.beType = -1
	self.svData = svData
	if cfgEft then
		self.beType = cfgEft.type
	end
	
	self.isBFlay = (self.beType == E_CEType.HitBack) or (self.beType == E_CEType.HitFly)
end

function M:_On_AExit()
	self.e_id,self.cfgEft,self.svData = nil
	self.idCaster,self.idTarget = nil
	super._On_AExit( self )
end

function M:_On_AEnter()
	local _isBl = (self.svData ~= nil)
	if _isBl then
		_isBl = false
		if self.isBFlay then
			_isBl = true
			local _x,_y = self.svData.args2 * 0.01,self.svData.args3 * 0.01
			local to_x,to_y = self.lbOwner:SvPos2MapPos( _x,_y )
			self.to_x,self.to_y = to_x,to_y

			local cfgEft = self.lbOwner:GetCfgEftByEType( self.beType )
			self.fps_loop = nil
			if cfgEft then
				self.time_out = (cfgEft.effecttime) / 1000

				if cfgEft.chg_time then
					local chg_time = (cfgEft.chg_time) / 1000
					local _fps = self:MCeil( chg_time / 0.02 )
					local _cpos = self.lbOwner:GetPosition()
					self.c_x,self.c_y = _cpos.x,_cpos.z
					self.s_x,self.s_y = (self.to_x - self.c_x) / _fps , (self.to_y - self.c_y) / _fps
					self.isAddX,self.isAddY = (self.s_x > 0),(self.s_y > 0)
					self.fps_loop = _fps
				end
			end
		end
	end
	return _isBl == true
end

function M:_OnEnd_AEnter()
	if (self.isBFlay) and (not self.fps_loop) then
		self.lbOwner:SetPos( self.to_x,self.to_y )
	end
end

function M:_On_AUpdate(dt)
	if self.isBFlay and self.fps_loop then
		if self.fps_loop > 0 then
			self.c_x,self.c_y = self.c_x + self.s_x,self.c_y + self.s_y
			self.c_x = self.isAddX and m_min(self.c_x,self.to_x) or m_max(self.c_x,self.to_x)
			self.c_y = self.isAddY and m_min(self.c_y,self.to_y) or m_max(self.c_y,self.to_y)
			self.lbOwner:SetPos( self.c_x,self.c_y )
		end
		self.fps_loop = self.fps_loop - 1
	end
end

return M
--[[
	-- 场景对象 - 生物 单元
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-26 21:25
	-- Desc : 
]]

local _vec3 = Vector3
local _v3_zero = _vec3.zero
local LC_State = LES_C_State

local super = SceneObject
local M = class( "scene_creature",super )

function M:InitCUnit(worldY,mvSpeed)
	self:SetWorldY( worldY or 0 )
	self:SetMoveSpeed( mvSpeed or 1 )
end

function M:OnInit()
	self:_Init_CU_Vecs()

	self._lf_On_Up = handler_pcall(self,self.OnUpdate_CUnit)
	self._lf_On_A_Enter = handler_pcall(self,self.OnUpdate_A_Enter)
	self._lf_On_A_Up = handler_pcall(self,self.OnUpdate_A_Up)
	self._lf_On_A_Exit = handler_pcall(self,self.OnUpdate_A_Exit)

	self.comp:InitCCEx(self._lf_On_Up,self._lf_On_A_Enter,self._lf_On_A_Up,self._lf_On_A_Exit)

	self:OnInit_Unit()
end

function M:OnInit_Unit()
end

function M:_Init_CU_Vecs()
	self.v3MoveTo = _vec3.zero
	self.v3Move = _vec3.zero
end

function M:OnUpdate4Moving( dt )
	if not self.comp then return end

	--注意，这里需要修改movement的y轴
	local movement = self.movement

	self.groundPosY =  self.groundPosY or 0
	self.gravityPosY = self.gravityPosY or 0

	local _posY = self.trsf.position.y
	if self.comp.isGrounded then
		self.groundPosY = _posY
		self.gravityPosY = 0
	else
		if _posY > self.groundPosY then
			self.gravityPosY = self.gravity * _evtime
			movement.y =  movement.y - self.gravityPosY
		end
	end
	
	if _v3_zero:Equals(movement) then return end

	local speed = self.move_speed
	-- 瞬移速度
	if self.speedShift and self.speedShift ~= 0 then
		speed = self.speedShift
	end
	
	speed = speed * dt
	
	self.v3Move.x = movement.x * speed
	self.v3Move.y = movement.y
	self.v3Move.z = movement.z * speed

	if _v3_zero:Equals(self.v3Move) then return end

	self.comp:Move(self.v3Move.x,self.v3Move.y,self.v3Move.z)
end

function M:OnUpdate_CUnit(dt,undt)
end

function M:OnUpdate_A_Enter()
end

function M:OnUpdate_A_Up(_,info,_)
end

function M:OnUpdate_A_Exit(_,info,_)
	-- if info.loop then return end
	if self.state == LC_State.Show_1_Exed then
		self:SetState( LC_State.Idle )
	end
end

function M:SetState(state,isReplace)
	isReplace = (isReplace == true) or (self.state == nil)  or (state ~= self.state)
	if not isReplace then return end
	self.preState = self.state
	self.state = state
end

function M:SetPos(x,y)
	self:SetPosition ( x,self.worldY,y )
end

function M:SetWorldY(w_y)
	self.worldY = w_y or 0
end

function M:SetMoveSpeed(speed)
	self.move_speed = speed or 0
end

-- 瞬移速度
function M:SetMoveSpeedShift(speed)
	self.speedShift = speed
end

function M:MoveEnd(x,y)
	self:SetState( LC_State.Idle )
	self:SetPos( x,y )
end

-- 暂停
function M:Pause()
	if self.isPause then
		return false
	end
	self.isPause = true
	return true
end

-- 恢复
function M:Regain()
	if not self.isPause then
		return
	end
	self.isPause = nil
end

return M
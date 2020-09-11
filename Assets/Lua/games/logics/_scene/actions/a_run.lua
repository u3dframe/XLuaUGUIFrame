--[[
	-- 行为动作 - 移动 Run
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-27 17:44
	-- Desc : 
]]
local _vec3 = Vector3
local _v3_zero = _vec3.zero
local _speed_offset,_dis_end = 0.01,(0.06)^2

local E_Action = LES_C_Action
local E_AniState = LES_C_Action_State
local E_State = LES_C_State

local super = ActionBasic
local M = class("action_run", super)

function M:_On_A_Init()
    self.jugde_state = E_State.Run
    self.action_state = E_AniState.Run
    self.isBreakSelf = false
end

function M:_IsAEnter()
    local _isBl = self.lbOwner:CheckRun()
    if _isBl then
        if self.lbOwner._async_m_x ~= nil or self.lbOwner._async_m_y ~= nil then
            self.lbOwner:MoveTo(
                self.lbOwner._async_m_x,
                self.lbOwner._async_m_y,
                self.lbOwner._async_c_x,
                self.lbOwner._async_c_y
            )
            return false
		end
    end
    return _isBl
end

function M:_On_AEnter()
	self.v3Move = self.v3Move or _vec3.zero
    self.v3Move:Set(0,0,0)
    self.v3Curr = self.v3Move or _vec3.zero
    self.v3Curr:Set(0,0,0)
    self.v3To = self.v3To or _vec3.zero
    self.v3To:Set(0,0,0)
	self.groundPosY = 0
    self.gravityPosY = 0
    return true
end

function M:_On_AUpdate(dt)
    self:OnUpdate4Moving( dt )
    self:_Jugde_MoveEnd()
end

function M:OnUpdate4Moving(dt)
    local _owner,_comp,movement,speed,_v3To = self.lbOwner
    local _pos = _owner:GetPosition()
    _comp,movement,speed,_v3To = _owner:Move_Info()
    if _v3To then
        self.v3To:Set(_v3To.x,_v3To.y,_v3To.z)
    end
    --注意，这里需要修改movement的y轴
    if _comp.isGrounded then
        self.groundPosY = _pos.y
        self.gravityPosY = 0
        _owner:SetUpMovement( 0 )
    else
        if _pos.y > self.groundPosY then
            self.gravity = self.gravity or 1
            self.gravityPosY = self.gravity * dt
            movement.y = movement.y - self.gravityPosY
        end
    end

    if _v3_zero:Equals(movement) then
        return
    end
    speed = speed * dt * _speed_offset

    self.v3Move.x = self:TF( movement.x * speed,9 )
    self.v3Move.y = movement.y
    self.v3Move.z = self:TF( movement.z * speed,9 )

    if _v3_zero:Equals(self.v3Move) then
        return
    end
    _comp:Move(self.v3Move.x, self.v3Move.y, self.v3Move.z)
end

function M:_Jugde_MoveEnd()
    local _pos = self.lbOwner:GetPosition()
    self.v3Curr:Set( _pos.x,_pos.y,_pos.z )
    _pos = self.v3To - self.v3Curr
    if _pos.sqrMagnitude < _dis_end then
        self.lbOwner:SetPos(self.v3To.x,self.v3To.z)
        self:Exit()
    end
end

function M:_On_AExit()
    local _owner = super._On_AExit(self)
    _owner:Move_Over()
end

return M

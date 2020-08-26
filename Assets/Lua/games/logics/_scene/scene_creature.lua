--[[
	-- 场景对象 - 生物
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local _vec3,_vec2,type = Vector3,Vector2,type

local _v3_zero = _vec3.zero

local LES_Object = LES_Object
local LC_State,LC_AniState = LES_C_State,LES_C_Animator_State

local super = SceneObject
local M = class( "scene_creature",super )

function M:ctor(objType,nCursor,...)
	objType = objType or LES_Object.Creature
	super.ctor( self,objType,nCursor,... )
	self.worldY = 0 -- map里面给一个值
end

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.strComp = "CharacterControllerEx"
	_cfg.isUpdate = true
	_cfg.isStay = true
	return _cfg
end

function M:OnInit()
	self:_Init_SC_Vecs()

	self._lf_On_Up = handler_pcall(self,self.OnUpdate_Creature)
	self._lf_On_A_Enter = handler_pcall(self,self.OnUpdate_A_Enter)
	self._lf_On_A_Up = handler_pcall(self,self.OnUpdate_A_Up)
	self._lf_On_A_Exit = handler_pcall(self,self.OnUpdate_A_Exit)

	self.comp:InitCCEx(self._lf_On_Up,self._lf_On_A_Enter,self._lf_On_A_Up,self._lf_On_A_Exit)
	self:OnInitCreatureUnit()

	-- self.worldY = 0 -- 发一个射线去高度
end

function M:OnActive(isActive)
	if not isActive then
		self.preState,self.state,self.a_n_state = nil
	end
end

function M:_Init_SC_Vecs()
	self.v3MoveTo = _vec3.zero
	self.v3Move = _vec3.zero
end

function M:OnInitCreatureUnit()
end

function M:OnUpdate_Creature(dt,undt)
	if not self:IsLoadedAndShow() then return end

	if self._async_a_n_state ~= nil then
		self:PlayAction( self._async_a_n_state,self._async_a_n_immed )
	end

	if self.state == LC_State.Idle then
		self:SetState( LC_State.Idle_Exed )
		self:PlayAction( LC_AniState.Idle )
	elseif self.state == LC_State.Die then
		self:SetState( LC_State.Die_Exed )
		self:PlayAction( LC_AniState.Die )
	elseif self.state == LC_State.Run then
		if self._async_m_x ~= nil or self._async_m_y ~= nil then
			self:MoveTo( self._async_m_x,self._async_m_y )
			return
		end
		self:PlayAction( LC_AniState.Run )
		self:SetState( LC_State.Run_Ing )
	elseif self.state == LC_State.Run_Ing then
		self:OnUpdate4Moving( dt )
	elseif self.state == LC_State.Grab then
		self:SetState( LC_State.Grab_Exed )
		self:PlayAction( LC_AniState.Grab )
	elseif self.state == LC_State.Show_1 then
		self:SetState( LC_State.Show_1_Exed )
		self:PlayAction( LC_AniState.Show_1 )
	end

	self:OnUpdateCreatureUnit( dt )
end

function M:OnUpdateCreatureUnit(dt)
end

function M:OnUpdate4Moving( dt )
	--注意，这里需要修改movement的y轴
	local movement = self.movement
	
	if _v3_zero:Equals(movement) then return end

	local speed = self.speed
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

function M:OnUpdate_A_Enter()
end

function M:OnUpdate_A_Up(_,info,_)
end

function M:OnUpdate_A_Exit()
	if self.state == LC_State.Show_1_Exed then
		self:SetState( LC_State.Idle )
	end
end

function M:PlayAction(a_n_state)
	a_n_state = a_n_state or 0
	if a_n_state == self.a_n_state then
		return
	end
	self._async_a_n_state = nil
	if self.comp then
		self.a_n_state = a_n_state
		self.comp:SetAction(self.a_n_state)
	else
		self._async_a_n_state = a_n_state
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

function M:MoveTo(to_x,to_y,cur_x,cur_y)
	if cur_x and cur_y then
		self:SetPos( cur_x,cur_y )
	end
	self._async_m_x,self._async_m_y = nil
	if self.comp then
		self:SetState( LC_State.Run )
		to_x,to_y = self:ReXYZ( to_x,to_y )
		self.v3MoveTo:Set(to_x,self.worldY,to_y)
		self.movement = self.v3MoveTo.normalized
	else
		self._async_m_x,self._async_m_y = to_x,to_y
	end
end

function M:MoveEnd(x,y)
	self:SetState( LC_State.Idle )
	self:SetPos( x,y )
end

return M
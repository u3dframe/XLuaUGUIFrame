--[[
	-- 场景对象 - 生物
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local _vec3,_vec2,type = Vector3,Vector2,type

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
	return _cfg;
end

function M:OnInit()
	self:_Init_SC_Vecs()

	self._lf_On_Up = handler_pcall(self,self.OnUpdate_Creature)
	self._lf_On_A_Enter = handler_pcall(self,self.OnUpdate_A_Enter)
	self._lf_On_A_Up = handler_pcall(self,self.OnUpdate_A_Up)
	self._lf_On_A_Exit = handler_pcall(self,self.OnUpdate_A_Exit)

	self.comp:InitCCEx(self._lf_On_Up,self._lf_On_A_Enter,self._lf_On_A_Up,self._lf_On_A_Exit);
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
		self:SetState( LC_State.Run_Exed )
		self:PlayAction( LC_AniState.Run )
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

function M:MoveTo(x,y)
	self._async_m_x,self._async_m_y = nil
	if self.comp then
		self:SetState( LC_State.Run )
		x,y = self:ReXYZ( x,y )
		self.v3MoveTo:Set(x,self.worldY,y)
		-- self:LookAt(x,self.worldY,y)
		-- printInfo("===[%s] =[%s] =[%s]",x,self.worldY,y)
		self.comp:Move(x,self.worldY,y)
	else
		self._async_m_x,self._async_m_y = x,y,z
	end
end

return M
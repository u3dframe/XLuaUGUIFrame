--[[
	-- 场景对象 - 生物
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local LES_Object = LES_Object
local LC_State,LC_AniState = LES_C_State,LES_C_Animator_State

local super = SceneObject
local M = class( "scene_creature",super )

function M:ctor(objType,nCursor,...)
	objType = objType or LES_Object.Creature
	super.ctor( self,objType,nCursor,... )
end

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.strComp = "CharacterControllerEx"
	_cfg.isUpdate = true
	_cfg.isStay = true
	return _cfg;
end

function M:OnInit()
	self._lf_On_Up = handler_pcall(self,self.OnUpdate_Creature)
	self._lf_On_A_Enter = handler_pcall(self,self.OnUpdate_A_Enter)
	self._lf_On_A_Up = handler_pcall(self,self.OnUpdate_A_Up)
	self._lf_On_A_Exit = handler_pcall(self,self.OnUpdate_A_Exit)

	self.comp:InitCCEx(self._lf_On_Up,self._lf_On_A_Enter,self._lf_On_A_Up,self._lf_On_A_Exit);
	self:OnInitCreatureUnit()
end

function M:OnInitCreatureUnit()
end

function M:OnUpdate_Creature(dt,undt)
	if not self:IsLoadedAndShow() then return end

	if self._async_a_n_state ~= nil then
		self:PlayAction( self._async_a_n_state,self._async_a_n_immed )
	end

	if self.state == LC_State.Idle then
		self:SetState( LC_AniState.Idle_Exed )
		self:PlayAction( LC_AniState.Idle,true )
	elseif self.state == LC_State.Die then
		self:SetState( LC_AniState.Die_Exed )
		self:PlayAction( LC_AniState.Die,true )
	elseif self.state == LC_State.Run then
		self:SetState( LC_AniState.Run_Exed )
		self:PlayAction( LC_AniState.Run,true )
	end

	self:OnUpdateCreatureUnit( dt )
end

function M:OnUpdateCreatureUnit(dt)
end

function M:OnUpdate_A_Enter(_,info,_)
end

function M:OnUpdate_A_Up(_,info,_)
end

function M:OnUpdate_A_Exit(_,info,_)
end

function M:PlayAction(a_n_state,isImmediate)
	a_n_state = a_n_state or 0
	if a_n_state == self.a_n_state then
		return
	end
	isImmediate = (isImmediate == true)
	self._async_a_n_state,self._async_a_n_immed = nil
	if self.comp then
		self.a_n_state = a_n_state
		if isImmediate then
			self.comp:SetAction(self.a_n_state)
		else
			self.comp:PlayAction(self.a_n_state)
		end
	else
		self._async_a_n_state,self._async_a_n_immed = a_n_state,isImmediate
	end
end

function M:SetState(currState)
	self.preState = self.state
	self.state = currState
end

return M
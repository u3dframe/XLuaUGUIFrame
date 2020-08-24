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
	return _cfg;
end

function M:OnUpdateLoaded(dt)
	if self.state == LC_State.Idle then
		self:PlayAction( LC_AniState.Idle,true )
	elseif self.state == LC_State.Die then
		self:PlayAction( LC_AniState.Die,true )
	elseif self.state == LC_State.Run then
		self:PlayAction( LC_AniState.Run,true )
	end

	if self._async_a_n_state ~= nil then
		self:PlayAction( self._async_a_n_state,self._async_a_n_immed )
	end
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
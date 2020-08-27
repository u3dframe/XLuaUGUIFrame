--[[
	-- 场景对象 - 生物体
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local SceneCUnit = require ("games/logics/_scene/scene_c_unit") -- 生物 - 单元

local _vec3,_vec2,type = Vector3,Vector2,type

local _v3_zero = _vec3.zero

local LES_Object = LES_Object
local LC_State,LC_AniState = LES_C_State,LES_C_Animator_State

local super = SceneCUnit
local M = class( "scene_creature",super )

function M:ctor(objType,nCursor,...)
	objType = objType or LES_Object.Creature
	super.ctor( self,objType,nCursor,... )

	self:InitCUnit( 0,1 )
end

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.strComp = "CharacterControllerEx"
	_cfg.isUpdate = true
	_cfg.isStay = true
	return _cfg
end

function M:OnInit_Unit()
	-- local worldY = 0 -- 发一个射线去高度
	-- self:SetWorldY( worldY )
	self:OnInitCreature()
end

function M:OnActive(isActive)
	if not isActive then
		self.preState,self.state,self.a_n_state = nil
	end
end

function M:OnSetData(svData)
	self:SetParent(nil,true)

	self.svData = svData
	if svData then
		self:SetMoveSpeed( svData.attrs.speed or 0.5 )
	end
end

function M:OnInitCreature()
end

function M:OnUpdate_CUnit(dt,undt)
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

	self:OnUpdate_Creature( dt )
end

function M:OnUpdate_Creature(dt)
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

return M
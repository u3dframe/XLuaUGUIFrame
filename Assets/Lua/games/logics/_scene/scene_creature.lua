--[[
	-- 场景对象 - 生物体
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local SceneCUnit = require ("games/logics/_scene/scene_c_unit") -- 生物 - 单元

local tb_insert,tb_sort = table.insert,table.sort

local LES_Object = LES_Object
local E_State = LES_C_State
local MgrData = MgrData

local super = SceneCUnit
local M = class( "scene_creature",super )
local this = M

function M.InsertTimeLineData(lb,time,cfgData)
	if lb[time] then
		local _tmp0 = lb[time].datas
		tb_insert(_tmp0, cfgData )
	else
	    lb[time] = {time = time, datas = { cfgData }}
	end
end

function M:InitBase(sobjType,nCursor,resCfg)
	self:InitCUnit( 0,1 )
	return super.InitBase( self,(sobjType or LES_Object.Creature),nCursor,resCfg )
end

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.strComp = "CharacterControllerEx"
	_cfg.isUpdate = true
	_cfg.isStay = true
	return _cfg
end

function M:OnInit_Unit()
	self:OnInit_Creature()
end

function M:OnActive(isActive)
	super.OnActive( self,isActive )
	if not isActive then
		self:SetParent(nil,true)
		self.preState,self.state,self.n_action = nil
	end
end

function M:OnSetData(svData)
	self.svData = svData
	if svData then
		self:SetPos_SvPos( svData.x,svData.y )
		self:SetMoveSpeed( svData.attrs.speed or 0.5 )
	end
end

function M:OnInit_Creature()
end

function M:OnUpdate_CUnit(dt,undt)
	super.OnUpdate_CUnit( self,dt,undt )
	self:OnUpdate_Creature( dt )
end

function M:OnUpdate_Creature(dt)
end

function M:PlayAction(n_action)
	n_action = n_action or 0
	if n_action == self.n_action then
		return
	end
	self._async_n_action = nil
	if self.comp then
		self.n_action = n_action
		self.comp:SetAction(self.n_action)
	else
		self._async_n_action = n_action
	end
end

function M:GetActionState()
	local _a_state
	if self.state == E_State.Attack then
		_a_state = self.cfgSkill_Action.action_state
	else
		_a_state = super.GetActionState( self )
	end
	return _a_state
end

function M:SetPos_SvPos(x,y)
	x,y = self:SvPos2MapPos( x,y )
	self:SetPos ( x,y )
end

function M:MoveTo_SvPos(to_x,to_y,cur_x,cur_y)
	to_x,to_y = self:SvPos2MapPos( to_x,to_y )
	cur_x,cur_y = self:SvPos2MapPos( cur_x,cur_y )
	self:MoveTo( to_x,to_y,cur_x,cur_y )
end

function M:MoveEnd_SvPos(x,y)
	x,y = self:SvPos2MapPos( x,y )
	self:MoveEnd( x,y )
end

function M:CastAttack(svMsg)
	if not svMsg then return false end
	local _isOkey,_cfg,_cfgAction = self:JugdeCastAttack( svMsg.skillid )
	if not _isOkey then return false end
	self:_DoAttack( svMsg,_cfg,_cfgAction )
end

function M:JugdeCastAttack(skillid)
	if not skillid then return false end
	local _cfg_skill = MgrData:GetCfgSkill(skillid)
	if not _cfg_skill then return false end
	local _cfg_s_effect = MgrData:GetCfgSkillEffect(_cfg_skill.cast_effect)
	if not _cfg_s_effect then return false end
	return true,_cfg_skill,_cfg_s_effect
end

function M:_DoAttack(svMsg,cfgSkill,cfgAction)
	local _obj = self:GetSObjBy( svMsg.target )
	local _tx,_ty = self:SvPos2MapPos( svMsg.targetx,svMsg.targety )
	self.svDataCast = svMsg
	self.cfgSkill = cfgSkill
	self.cfgSkill_Action = cfgAction
	self.tmEfts = {}
	local _temp = {}
	self:_InitAttackEffets( _temp,cfgSkill.cast_effect )
	-- this.InsertTimeLineData( _temp,_ef.nexttime,_ef_next )
	for _,v in pairs(_temp) do
		tb_insert(self.tmEfts,v)
	end

	self:LookPos( _tx,_ty )
	self:SetState( E_State.Attack )
end

function M:_InitAttackEffets(lb,e_id )
	if not e_id then return end
	local _ef = MgrData:GetCfgSkillEffect( e_id )
	if (not _ef) or (not _ef.nextid) then return end

	local _ef_next = MgrData:GetCfgSkillEffect( _ef.nextid )
	if (not _ef_next) then return end
	this.InsertTimeLineData( lb,_ef.nexttime,_ef_next )
	if _ef_next.nextid then
		self:_InitAttackEffets( lb,_ef.nextid )
	end
end

local function _sort_time_line(a, b) return a.time < b.time end

function M:GetAttackEffets()
	if self.tmEfts then
		tb_sort( self.tmEfts,_sort_time_line )
	end
	return self.tmEfts
end

function M:ExcuteEffectData( cfgEft )
	if not cfgEft or not self.svDataCast then return end

	if cfgEft.type == 1 then
		-- 执行大招
		return
	end
	
	if cfgEft.action_state then
		self:PlayAction( cfgEft.action_state )
	end
	
	if not cfgEft.point then return end

	local _elNm = LES_Ani_Eft_Point[cfgEft.point]
	if not _elNm then return end

	local _elNms,_gobj = string.split(_elNm,";")
	if 1 == cfgEft.type or 7 == cfgEft.type then
		for _, v in ipairs(_elNms) do
			_gobj = self:GetElement(v)
			if _gobj then
				
			end
		end
	end
end

return M
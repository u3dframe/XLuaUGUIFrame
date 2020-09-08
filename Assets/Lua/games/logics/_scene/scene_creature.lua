--[[
	-- 场景对象 - 生物体
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local SceneCUnit = require ("games/logics/_scene/scene_c_unit") -- 生物 - 单元
local ClsEffect = ClsEffect -- 特效

local tb_insert,tb_sort,tb_lens = table.insert,table.sort,table.lens
local tostring,NumEx = tostring,NumEx
local str_split = string.split

local E_Object,E_State,E_AE_Point = LES_Object,LES_C_State,LES_Ani_Eft_Point
local MgrData,LTimer = MgrData,LTimer

local super,evt = SceneCUnit,Event
local M = class( "scene_creature",super )
local this = M

this.nm_pool_cls = "p_cls_sobj_" .. tostring(E_Object.Creature)

function M.Builder(nCursor,resid)
	this:GetResCfg( resid )
	local _p_name,_ret = this.nm_pool_cls .. "@@" .. resid

	_ret = this.BorrowSelf( _p_name,E_Object.Creature,nCursor,resid )
	return _ret
end

function M.InsertTimeLineIds(lb,time,id,max_duration)
	local _tmp_ = lb[time]
	if _tmp_ then
		if max_duration and _tmp_.duration < max_duration then
			_tmp_.duration = max_duration
		end
		tb_insert(_tmp_.ids, id )
	else
	    lb[time] = {time = time,duration = (max_duration or 0), ids = { id }}
	end
end

function M:Reset(sobjType,nCursor,resid)
	super.Reset( self,(sobjType or E_Object.Creature),nCursor,resid )
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

function M:OnEnd(isDestroy)
	if self._cmds_d_hurt then
		for _cmd,_ in pairs(self._cmds_d_hurt) do
			LTimer.RemoveDelayFunc( _cmd )
		end
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

function M:IsBigSkill()
	if not self.cfgSkill_Action then return false end
	return self.cfgSkill_Action.type == 1
end

function M:_AddECastData( e_id,e_svData )
	local _lb = self.lbEInfo or {}
	self.lbEInfo = _lb
	_lb[e_id] = e_svData
end

function M:_GetECastData( e_id )
	if self.lbEInfo and e_id then
		return self.lbEInfo[e_id]
	end
end

function M:CastAttack(svMsg)
	if not svMsg then return false end
	local _isOkey,_cfg,_cfgAction = self:JugdeCastAttack( svMsg.skillid )
	if not _isOkey then return false end
	self:SetState( E_State.Idle )
	if (_cfgAction.type == 1)then
		self:_DoComboAttack(svMsg,_cfg,_cfgAction)
	else
		self:_DoAttack( svMsg,_cfg,_cfgAction )
	end
end

function M:JugdeCastAttack(skillid)
	if not skillid then return false end
	local _cfg = MgrData:GetCfgSkill(skillid)
	if not _cfg then return false end
	if not self:CheckAttack() then return false end
	local _cfg_s_eft
	if _cfg.cast_effect then
		_cfg_s_eft = MgrData:GetCfgSkillEffect( _cfg.cast_effect )
	end
	if (not _cfg_s_eft) and (tb_lens(_cfg.cast_effects) > 0) then
		local _k = NumEx.nextWeightList( _cfg.cast_effects,2 )
		if _k and _k > 0 then
			local _e_id = _cfg.cast_effects[_k][1]
			_cfg_s_eft = MgrData:GetCfgSkillEffect( _e_id )
		end
	end
	if not _cfg_s_eft then return false end
	return true,_cfg,_cfg_s_eft
end

function M:_DoAttack(svMsg,cfgSkill,cfgAction)
	local _e_id = cfgSkill.cast_effect
	self.svDataCast = svMsg
	self:_AddECastData( _e_id,svMsg )
	self.cfgSkill = cfgSkill
	self.cfgSkill_Action = cfgAction
	self.tmEfts = {}
	local _temp = {}
	self:_InitAttackEffets( _temp,_e_id )
	-- this.InsertTimeLineIds( _temp,_ef.nexttime,_ef_next )
	for _,v in pairs(_temp) do
		tb_insert(self.tmEfts,v)
	end
	
	self:LookTarget( svMsg.target,svMsg.targetx,svMsg.targety )
	self:SetState( E_State.Attack )
end

function M:_DoComboAttack(svMsg, cfgSkill, cfgAction)
	MgrCombo:PlayComboSkill(svMsg, cfgSkill, cfgAction);
end

function M:_InitAttackEffets(lb,e_id )
	if not e_id then return end
	local _ef = MgrData:GetCfgSkillEffect( e_id )
	if (not _ef) or (not _ef.nextid) then return end

	local _ef_next = MgrData:GetCfgSkillEffect( _ef.nextid )
	if (not _ef_next) then return end
	this.InsertTimeLineIds( lb,_ef.nexttime,_ef.nextid,(_ef_next.effecttime or 0) )
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

function M:ExcuteEffectByEid( e_id,isHurt )	
	if not e_id then return end
	local cfgEft = MgrData:GetCfgSkillEffect( e_id )
	if not cfgEft then return end
	if cfgEft.type == 1 then return end
	
	if cfgEft.action_state then
		self:PlayAction( cfgEft.action_state )
	end
	
	if not cfgEft.point then return end
	if not cfgEft.resid then return end
	local _cfgRes = MgrData:GetCfgRes(cfgEft.resid)
	if not _cfgRes then return end

	local _elNm = E_AE_Point[cfgEft.point]
	if not _elNm then return end
	local _lbs = self.lbEffects or {}
	self.lbEffects = _lbs

	local _elNms,_gobj = str_split(_elNm,";")
	local _e_data,_id,_idTarget,_isFollow = self:_GetECastData( e_id ),self:GetCursor()
	_idTarget = _id
	if _e_data then
		_id = (isHurt == true) and _e_data.caster or _id
		_idTarget = (2 == _cfgRes.type or 7 == _cfgRes.type) and _id or _e_data.target
	end

	_isFollow = (2 == cfgEft.type) or (3 == cfgEft.type) or (5 == cfgEft.type)
	for _, v in ipairs(_elNms) do
		ClsEffect.Builder( _id,cfgEft.resid,_idTarget,v,cfgEft.effecttime,_isFollow )
	end
end

-- 处理效果
function M:CastInjured(svMsg)
	local _list = svMsg.list
	svMsg.list = nil
	self:_HurtDataState( _list )
	local _bl = self:DoInjured( svMsg )
	if _bl then
		local _lens = tb_lens( _list )
		if _lens > 0 then
			local _cmd = "d_do_hurts_" .. tostring(_list)
			self._cmds_d_hurt = self._cmds_d_hurt or {}
			self._cmds_d_hurt[_cmd] = _cmd

			LTimer.AddDelayFunc1( _cmd,0.08,self.DoHurts,self,_list )
		end
	else
		self:DoHurts( _list )
	end
end

function M:_HurtDataState(hurtList)
	local _lens = tb_lens( hurtList )
	if _lens <= 0 then return end
	local _svOne,_obj
	for i = 1, _lens do
		_svOne = hurtList[i]
		_obj = self:GetSObjBy( _svOne.target )
		if _obj ~= nil then
			_obj.isDied = (_svOne.dead == true)
		end
	end
end

-- 主动 效果
function M:DoInjured(svMsg)
	self.nOrder = self.nOrder or 0
	self.nOrder = self.nOrder + 1
	local _cfgSkill = MgrData:GetCfgSkill( svMsg.skillid ) or self.cfgSkill
	if (not _cfgSkill) or (not _cfgSkill.cast_order) then return end
	local _data = _cfgSkill.cast_order[self.nOrder]
	if not _data or _data <= 0 then return end
	self:_AddECastData( _data,svMsg )
	self:LookTarget( svMsg.target,svMsg.targetx,svMsg.targety )
	self:ExcuteEffectByEid( _data )
	return true
end

-- 被动 效果
function M:DoHurts(svList)
	local _lens = tb_lens( svList )
	if _lens <= 0 then return end

	local _cmd = "d_do_hurts_" .. tostring(svList)
	if self._cmds_d_hurt then self._cmds_d_hurt[_cmd] = nil end
	LTimer.RemoveDelayFunc( _cmd )

	local _svOne,_obj
	for i = 1, _lens do
		_svOne = svList[i]
		_obj = self:GetSObjBy( _svOne.target )
		if _obj ~= nil then
			_obj:DoHurtEffect( _svOne )
		end
	end
end

-- 判断是否可以执行伤害效果(判断闪避等)
function M:_IsHurtEffect(svOne)
	return (svOne ~= nil) and (svOne.effectid ~= nil)
end

-- 受伤 效果
function M:DoHurtEffect(svOne)
	if self:_IsHurtEffect(svOne) then
		local _temp = MgrData:GetCfgHurtEffect( svOne.effectid )
		if _temp.hit_effect then
			self:_AddECastData( _temp.hit_effect,svOne )
			self:ExcuteEffectByEid( _temp.hit_effect,true )
		end

		if svOne.dead == true then
			_temp = (self.data ~= nil) and (self.data.die ~= nil)
			if _temp then
				self:_AddECastData( self.data.die,svOne )
				self:SetState( E_State.Die,true )
			else
				self:Reback()
				printError("======= no die effect,hero id = [%s]",self.svData.cfgid)
			end
		end
	end
	self:DoHurtNumData( svOne )
end

-- 受伤 效果 - 数值表现
function M:DoHurtNumData(svOne)
	evt.Brocast(Evt_BattlePlayHarmTip, svOne)
end

function M:IsDeath()
	return self.isDied == true or self.state == E_State.Die
end

function M:GetCfgEID4Die()
	if self.data and self.data.die then
		return self.data.die
	end
end

return M
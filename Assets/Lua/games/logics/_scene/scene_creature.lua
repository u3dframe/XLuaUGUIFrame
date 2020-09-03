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

local super = SceneCUnit
local M = class( "scene_creature",super )
local this = M

function M.InsertTimeLineIds(lb,time,id)
	if lb[time] then
		local _tmp0 = lb[time].ids
		tb_insert(_tmp0, id )
	else
	    lb[time] = {time = time, ids = { id }}
	end
end

function M:InitBase(sobjType,nCursor,resCfg)
	self:InitCUnit( 0,1 )
	return super.InitBase( self,(sobjType or E_Object.Creature),nCursor,resCfg )
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

function M:CastAttack(svMsg)
	if not svMsg then return false end
	local _isOkey,_cfg,_cfgAction = self:JugdeCastAttack( svMsg.skillid )
	if not _isOkey then return false end
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
	local _cfg_s_eft
	if _cfg.cast_effect then
		_cfg_s_eft = MgrData:GetCfgSkillEffect( _cfg.cast_effect )
	end
	if (not _cfg_s_eft) and (tb_lens(_cfg.cast_effects) > 0) then
		local _k = NumEx.nextWeightList( _cfg.cast_effects,2 )
		if _k and _k > 0 then
			_cfg_s_eft = _cfg.cast_effects[_k][1]
		end
	end
	if not _cfg_s_eft then return false end
	return true,_cfg,_cfg_s_eft
end

function M:_DoAttack(svMsg,cfgSkill,cfgAction)
	self.svDataCast = svMsg
	self.svDataCurr = svMsg
	self.cfgSkill = cfgSkill
	self.cfgSkill_Action = cfgAction
	self.tmEfts = {}
	local _temp = {}
	self:_InitAttackEffets( _temp,cfgSkill.cast_effect )
	-- this.InsertTimeLineIds( _temp,_ef.nexttime,_ef_next )
	for _,v in pairs(_temp) do
		tb_insert(self.tmEfts,v)
	end

	self:LookTarget( svMsg.target,svMsg.targetx,svMsg.targety )
	self:SetState( E_State.Attack )
end

function M:_DoComboAttack(svMsg, cfgSkill, cfgAction)
	MgrBattle:PlayComboSkill(svMsg, cfgSkill, cfgAction);
end

function M:_InitAttackEffets(lb,e_id )
	if not e_id then return end
	local _ef = MgrData:GetCfgSkillEffect( e_id )
	if (not _ef) or (not _ef.nextid) then return end

	local _ef_next = MgrData:GetCfgSkillEffect( _ef.nextid )
	if (not _ef_next) then return end
	this.InsertTimeLineIds( lb,_ef.nexttime,_ef.nextid )
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
	if not e_id or not self.svDataCurr then return end
	local cfgEft = MgrData:GetCfgSkillEffect( e_id )
	if not cfgEft then return end
	if cfgEft.type == 1 then return end
	
	if cfgEft.action_state then
		self:PlayAction( cfgEft.action_state )
	end
	
	self:_Exc_EffectTime( cfgEft,isHurt )
end

function M:_Exc_EffectTime( cfgEft,isHurt )
	if not cfgEft.point then return end
	if not cfgEft.resid then return end
	local _cfgRes = MgrData:GetCfgRes(cfgEft.resid)
	if not _cfgRes then return end

	local _elNm = E_AE_Point[cfgEft.point]
	if not _elNm then return end
	local _lbs = self.lbEffects or {}
	self.lbEffects = _lbs

	local _elNms,_gobj = str_split(_elNm,";")
	local _id = (isHurt == true) and self.svDataCurr.caster or self:GetCursor()
	local _idTarget = (1 == _cfgRes.type or 7 == _cfgRes.type) and id or self.svDataCurr.target
	local _isFollow = (1 == cfgEft.type) or (3 == cfgEft.type) or (5 == cfgEft.type)
	for _, v in ipairs(_elNms) do
		ClsEffect.Builder( _id,cfgEft.resid,_idTarget,v,cfgEft.effecttime,_isFollow )
	end
end

-- 处理效果
function M:CastInjured(svMsg)
	local _list = svMsg.list
	svMsg.list = nil
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

-- 主动 效果
function M:DoInjured(svMsg)
	self.nOrder = self.nOrder or 0
	self.nOrder = self.nOrder + 1
	local _cfgSkill = MgrData:GetCfgSkill( svMsg.skillid ) or self.cfgSkill
	if (not _cfgSkill) or (not _cfgSkill.cast_order) then return end
	local _data = _cfgSkill.cast_order[self.nOrder]
	if not _data or _data <= 0 then return end

	self:LookTarget( svMsg.target,svMsg.targetx,svMsg.targety )
	self.svDataCurr = svMsg
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
		local _cfg = MgrData:GetCfgHurtEffect( svOne.effectid )
		if _cfg.hit_effect then
			self.svDataCurr = svOne
			self:ExcuteEffectByEid( _cfg.hit_effect,true )
		end

		if svOne.dead == true then
			local _die
			if self.data and self.data.die then
				self.svDataCurr = svOne
				_die = self.data.die
			end
			self:ExcuteEffectByEid( _die )
		end
	end
	self:DoHurtNumData( svOne )
end

-- 受伤 效果 - 数值表现
function M:DoHurtNumData(svOne)
	Event.Brocast(Evt_BattlePlayHarmTip, svOne)
end

return M
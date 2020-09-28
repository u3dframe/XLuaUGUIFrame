--[[
	-- 场景对象 - 生物体
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local SceneCUnit = require ("games/logics/_scene/scene_c_unit") -- 生物 - 单元

local tb_insert,tb_sort,tb_lens = table.insert,table.sort,table.lens
local tostring,NumEx = tostring,NumEx
local str_split = string.split

local E_Object,E_State = LES_Object,LES_C_State
local E_EType,E_CEType = LE_Effect_Type,LES_Ani_Eft_Type
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
	self:InitCUnit()
end

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.strComp = "CharacterControllerEx"
	_cfg.isUpdate = true
	_cfg.isStay = true
	return _cfg
end

function M:OnInit_Unit()
	self.csRMatProp = CRMatProp.Get( self.gobj )
	self.ccType = 0
	self:OnInit_Creature()
end

function M:OnInit_Creature()
end

function M:OnActive(isActive)
	super.OnActive( self,isActive )
	if not isActive then
		self:SetParent(nil,true)
		self.preState,self.state,self.n_action = nil
		self:ExcuteSEByCCType( 0 )
	end
end

function M:OnSetData(svData)
	self.svData = svData
	self.isSeparation = false
	if svData then
		self.isSeparation = (svData.master ~= nil)
		self:SetPos_SvPos( svData.x,svData.y )
		local _attrs = svData.attrs
		self:SetMoveSpeed( _attrs.speed )
		self:SetAtkSpeed( _attrs.atkspeed )
		self:SetAniSpeed( 1 )
	end
end

function M:OnEnd(isDestroy)
	if self._cmds_d_hurt then
		for _cmd,_ in pairs(self._cmds_d_hurt) do
			LTimer.RemoveDelayFunc( _cmd )
		end
	end
end

function M:OnUpdate_CUnit(dt,undt)
	super.OnUpdate_CUnit( self,dt,undt )
	self:OnUpdate_Creature( dt )
end

function M:OnUpdate_Creature(dt)
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

function M:_AddECastData( e_id,e_svData )
	local _lb = self.lbEInfo or {}
	self.lbEInfo = _lb
	_lb[e_id] = e_svData
end

function M:_GetECastData( e_id )
	local _e_data = nil
	if self.lbEInfo and e_id then
		_e_data = self.lbEInfo[e_id]
	end
	return _e_data or self.svDataCast
end

function M:CastAttack(svMsg)
	if not svMsg then return false end
	local _isOkey,_cfg,_cfgAction,_e_id = self:JugdeCastAttack( svMsg.skillid )
	if not _isOkey then return false end
	self:State2Idle()
	if (_cfgAction.type == 1)then
		self:_DoComboAttack(svMsg,_cfg,_cfgAction)
	else
		self:_DoAttack( svMsg,_cfg,_cfgAction,_e_id )
	end
end

function M:JugdeCastAttack(skillid)
	if not skillid then return false end
	local _cfg = MgrData:GetCfgSkill(skillid)
	if not _cfg then return false end
	if not self:CheckAttack() then return false end
	local _e_id,_cfg_s_eft = _cfg.cast_effect
	if _e_id then
		_cfg_s_eft = MgrData:GetCfgSkillEffect( _e_id )
	end
	if (not _cfg_s_eft) and (tb_lens(_cfg.cast_effects) > 0) then
		local _k = NumEx.nextWeightList( _cfg.cast_effects,2 )
		if _k and _k > 0 then
			_e_id = _cfg.cast_effects[_k][1]
			_cfg_s_eft = MgrData:GetCfgSkillEffect( _e_id )
		end
	end
	if not _cfg_s_eft then return false end
	return true,_cfg,_cfg_s_eft,_e_id
end

function M:_DoAttack(svMsg,cfgSkill,cfgAction,e_id)
	self.svDataCast = svMsg
	self:_AddECastData( e_id,svMsg )
	self.cfgSkill = cfgSkill
	self.cfgSkill_Action = cfgAction
	self.tmEfts = {}
	local _temp = {}
	self:_InitAttackEffets( _temp,e_id )
	-- this.InsertTimeLineIds( _temp,_ef.nexttime,_ef_next )
	for _,v in pairs(_temp) do
		tb_insert(self.tmEfts,v)
	end
	
	self:LookTarget( svMsg.target,svMsg.targetx,svMsg.targety )
	self:SetState( E_State.Attack )
	self:ExcuteEffectByEid( e_id,false,true )
end

function M:_DoComboAttack(svMsg, cfgSkill, cfgAction)
	MgrCombo:PlayComboSkill(svMsg, cfgSkill, cfgAction);
end

function M:_InitAttackEffets(lb,e_id )
	if not e_id then return end
	local _ef = MgrData:GetCfgSkillEffect( e_id )
	if (not _ef) or (not _ef.nextid) then return end

	local _ef_next = MgrData:GetCfgSkillEffect( _ef.nextid )
	if (not _ef_next) or (not _ef.nexttime) then return end
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

function M:ExcuteSEByCCType( ccType )
	if ccType and ccType ~= self.ccType then
		local _pre = self.ccType
		self.ccType = ccType
		self.csRMatProp:SetInt("_CCType",self.ccType)
		self:On_SEByCCType(_pre)
	end
end

function M:On_SEByCCType(preType)
end

function M:ExcuteEffectByEid( e_id,isHurt,isNotAct )
	isHurt = (isHurt == true)
	local _isOkey,cfgEft = MgrData:CheckCfg4Action( e_id )
	if not _isOkey then return end

	if (not isNotAct) and cfgEft.action_state then
		self:PlayAction( cfgEft.action_state )
	end
	
	local _e_data,_idCaster,_idTarget = self:_GetECastData( e_id ),self:GetCursor()
	_idTarget = _idCaster
	local _e_tp = cfgEft.type
	if _e_data then
		_idCaster = (isHurt) and _e_data.caster or _idCaster
		_idTarget = (E_CEType.SelfBone == _e_tp or E_CEType.SelfBonePos == _e_tp) and _idCaster or _e_data.target
	end

	self:_ExcuteEffect(e_id,cfgEft,_idCaster,_idTarget)

	self:_ExcuteSpecialEffect(e_id,cfgEft,_idCaster,_idTarget)

	if isHurt then
		local _e_tmp_ = self:GetCfgEftByEType( _e_tp )
		if _e_tmp_ then
			self.behit_action_state = _e_tmp_.action_state
			self:SetState( E_State.BeHit,false,e_id,cfgEft,_idCaster,_idTarget,_e_data )
		end
	end
end

function M:_ExcuteEffect( e_id,cfgEft,idCaster,idTarget )
	local _isOkey = MgrData:CheckCfg4Effect( e_id )
	if not _isOkey then
		return
	end

	if cfgEft.type == E_CEType.FlyTarget or cfgEft.type == E_CEType.FlyPosition then
		return EffectFactory.Make( E_EType.Bullet_Show,idCaster,idTarget,e_id )
	else
		return EffectFactory.Make( E_EType.Effect_Show,idCaster,idTarget,e_id )
	end
end

function M:_ExcuteSpecialEffect( e_id,cfgEft,idCaster,idTarget )
	local _obj = self:GetSObjBy( idTarget )
	if not _obj then
		return
	end

	local _ccType = AET_2_SE[cfgEft.type]
	if _ccType then
		_obj:ExcuteSEByCCType( _ccType )
	end

	self:ChangeBody( e_id )
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
	local _isOkey,cfgEft = MgrData:CheckCfg4Effect( _data )
	if not _isOkey then return end
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
		if _temp and _temp.hit_effect then
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

function M:AddBuff( b_id,duration )
	local _idCaster = self:GetCursor()
	local _buff = EffectFactory.Make( E_EType.Buff,_idCaster,_idCaster,b_id,duration )
	if not _buff then return end
	local _pool = self.buffs or {}
	self.buffs = _pool
	_pool[b_id] = _buff
	_buff:Start()
end

function M:RmvBuff( b_id )
	if not b_id then return end
	if not self.buffs then return end
	local _obj = self.buffs[b_id]
	if _obj then
		_obj:Disappear()
	end
	self.buffs[b_id] = nil
end

function M:RmvAllBuff()
	local _pool = self.buffs
	self.buffs = nil
	if not _pool then return end
	for _, v in pairs(_pool) do
		v:Disappear()
	end
end

return M
--[[
	-- 管理 - 场景 - 战斗
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-13 09:25
	-- Desc : defenses,offenses
]]

local tonumber = tonumber
local tb_remove,tb_insert,tb_contain = table.remove,table.insert,table.contains
local tb_rm_val,tb_keys,tb_concat = table.removeValues,table.keys,table.concat
local MgrData,LTimer = MgrData,LTimer
local E_B_State,E_Object = LES_Battle_State,LES_Object
local _is_debug = false

MgrScene = require( "games/logics/_scene/mgr_scene" )

local super,_evt = MgrBase,Event
local M = class( "mgr_scene_battle",super )
local this = M

function M.Init()
	MgrScene:Init()

	this._ms_delay_end = 0
	this._need_load = 0
	this._loaded = 0

	this.state = E_B_State.None
	this:ReEvent4OnUpdate( true )

	_evt.AddListener( Evt_Map_SV_AddObj,this.OnSv_Add_Map_Obj )
	_evt.AddListener( Evt_Map_SV_RmvObj,this.OnSv_Rmv_Map_Obj )
	_evt.AddListener( Evt_Map_SV_MoveObj,this.OnSv_Move_Map_Obj )
	_evt.AddListener( Evt_Map_SV_Skill,this.OnSv_Map_Obj_Skill )
	_evt.AddListener( Evt_Map_SV_Skill_Effect,this.OnSv_Map_Obj_Skill_Effect )
	
	_evt.AddListener( Evt_State_Battle_Start,this.Start )
	_evt.AddListener( Evt_Battle_Delay_End_MS,this.SetDelayEndBattle )
	_evt.AddListener( Evt_Msg_Battle_End,this._OnMsgEndBattle )

	_evt.AddListener( Evt_Msg_B_Buff_Add,this.OnMsg_Buff_Add )
	_evt.AddListener( Evt_Msg_B_Buff_Rmv,this.OnMsg_Buff_Rmv )
	_evt.AddListener( Evt_Bat_OneAttrChg,this.OnMsg_OneAttrChg )
	_evt.AddListener(Evt_Re_Login,this.OnClear)
end

function M.OnClear()
	this.state = E_B_State.Battle_End
	this._need_load = 0
	this._loaded = 0
	this.RemoveAll()

	MgrScene.OnClear()
end

function M:OnUpdate(dt)
	if this.state == E_B_State.Start then
		this.state = E_B_State.Create_Objs
	elseif this.state == E_B_State.Create_Objs then
		this._ST_Create_Obj()
	elseif this.state == E_B_State.Create_Objs_End then
		this.state = E_B_State.Entry_CG
	elseif this.state == E_B_State.Entry_CG then
		this.state = E_B_State.Entry_CG_Ing
	elseif this.state == E_B_State.Entry_CG_Ing then
		this.state = E_B_State.Entry_CG_End
	elseif this.state == E_B_State.Entry_CG_End then
		this.state = E_B_State.Play_BG
	elseif this.state == E_B_State.Play_BG then
		this._ST_PlayBG()
	elseif this.state == E_B_State.Ready then
		this._ST_Ready()
	elseif this.state == E_B_State.GO then
		this._ST_Go()
	elseif this.state == E_B_State.Battle_Ing then
	elseif this.state == E_B_State.Battle_End then
		this.state = E_B_State.End
		this.isUping = false
	elseif this.state == E_B_State.Battle_Error then
		this.state = E_B_State.End
		this.isUping = false
	end
end

function M.GetSObj(uniqueID)
	return MgrScene.OnGet_Map_Obj( uniqueID )
end

function M._IsCanStart()
	if this.state == E_B_State.None or this.state == E_B_State.End then
		return true
	end
	return true
end

function M.Start()
	if this._IsCanStart() then
		this.state = E_B_State.Start
	end
	this._ms_delay_end = 0
	this.isUping = true
end

function M._ST_Create_Obj()
	if not this.sv_queue_add then return end
	if #this.sv_queue_add <= 0 then
		if (this._loaded >= this._need_load) then
			this.state = E_B_State.Create_Objs_End
		end
		return
	end
	local _lf = this.sv_queue_add[1]
	tb_remove( this.sv_queue_add,1 )
	_lf()
end

function M._ST_PlayBG()
	this.state = E_B_State.Ready
end

function M._ST_Ready()
	this.state = E_B_State.Ready_Ing
	MgrBattle:FormalStartBattle(this._On_ST_Start_Battle)
end

function M._On_ST_Start_Battle(msg)
	if msg.e == 0 then
		this.state = E_B_State.GO
	else
		this.state = E_B_State.Battle_Error
	end
end

function M._ST_Go()
	this.state = E_B_State.Battle_Ing
end

function M.OnSv_Add_Map_Obj(objType,svMsg)
	local _lb_dic = this.sv_dic_add or {}
	this.sv_dic_add = _lb_dic
	local _func = _lb_dic[svMsg.id]
	if _is_debug then
		local _tb = reTable( this.sv_dic_add )
		printInfo("=== Add  = [%s] = [%s]",svMsg.id,tb_concat(_tb, ""))
	end
	if _func then
		printError("=== add sv obj is repeat  id = [%s]",svMsg.id)
		return
	end

	_func = function()
		local _cfg_
		if objType ==  E_Object.Hero or objType ==  E_Object.Monster then
			_cfg_ = this:GetCfgData("hero",svMsg.cfgid)
		end
		if _cfg_ then
			local _obj = MgrScene.Add_SObj( objType,_cfg_.resource,svMsg.id )
			if _obj then
				_obj.lfOnShowOnce = function()
					this._loaded = this._loaded + 1
				end
				_obj:View(true,_cfg_,svMsg)
			end
		end
	end

	_lb_dic[svMsg.id] = _func

	local _lb = this.sv_queue_add or {}
	this.sv_queue_add = _lb
	tb_insert(_lb,_func)
	this._need_load = this._need_load + 1
end

function M.OnSv_Rmv_Map_Obj(s_id)
	this.RemoveById( s_id )
end

function M.OnSv_Move_Map_Obj(svMsg,isStop)
	local _obj = this.GetSObj( svMsg.id )
	if not _obj then return end
	if isStop then
		_obj:MoveEnd_SvPos( svMsg.x,svMsg.y )
	else
		_obj:MoveTo_SvPos( svMsg.dx,svMsg.dy,svMsg.x,svMsg.y )
	end
end

function M.OnSv_Map_Obj_Skill(svMsg)
	local _obj = this.GetSObj( svMsg.caster )
	if not _obj then return end
	_obj:CastAttack( svMsg )
end

function M.OnSv_Map_Obj_Skill_Effect(svMsg)
	local _obj = this.GetSObj( svMsg.caster )
	if not _obj then return end
	_obj:CastInjured( svMsg )
end

function M.RemoveCurr( id )
	if (not id) or (not this.sv_dic_add) then return end

	local _func = this.sv_dic_add[id]
	if _func then
		tb_rm_val( this.sv_queue_add,_func )
	end
	this.sv_dic_add[id] = nil
end

function M.RemoveById(id)
	this.RemoveCurr( id )

	local _obj = this.GetSObj( id )
	if _obj then
		_obj:ReturnSelf()
	end
	MgrScene.RemoveCurrMapObj( id )
end

function M.RemoveAll()
	if (not this.sv_dic_add) then return end
	local _keys = tb_keys( this.sv_dic_add )
	for _, k in ipairs(_keys) do
		this.RemoveById( k )
	end
end

function M.EndBattle4Scene(isInterrupt)
	-- printTable("=========EndBattle4Scene")
	LTimer.RemoveDelayFunc( "battle_end" )
	_evt.Brocast(Evt_Battle_End)
	this.RemoveAll()
	this.state = E_B_State.Battle_End
	this._need_load = 0
	this._loaded = 0
	MgrBattle:OpenBattleSettlement(isInterrupt)
end

function M.SetDelayEndBattle( ms )
	ms = tonumber(ms) or 0
	if this._ms_delay_end < ms then
		this._ms_delay_end = ms
	end
end

function M._OnMsgEndBattle( msg )
	LTimer.RemoveDelayFunc( "battle_end" )
	local _isInterrupt = (msg.terminate == true)
	if _isInterrupt or (not this.sv_dic_add) then
		this.EndBattle4Scene( _isInterrupt )
		return 
	end
	local _isWin = (msg.win == 1)
	local _keys,_sobj = tb_keys( this.sv_dic_add )
	local _max_ms,_e_id,_cfgEft = this._ms_delay_end
	for _, k in ipairs(_keys) do
		_sobj = this.GetSObj( k )
		if _sobj and not _sobj:IsDeath() and _sobj.data then
			if _sobj:IsEnemy() then
				if _isWin then
					_e_id = _sobj.data.lose
				else
					_e_id = _sobj.data.win
				end
			else
				if _isWin then
					_e_id = _sobj.data.win
				else
					_e_id = _sobj.data.lose
				end
			end
			if _e_id then
				_cfgEft = MgrData:GetCfgSkillEffect( _e_id )
			end
			
			if _cfgEft then
				if _cfgEft.effecttime and _max_ms < _cfgEft.effecttime then
					_max_ms = _cfgEft.effecttime
				end
				_sobj:SetState( LES_C_State.Idle,true )
				_sobj:ExcuteEffectByEid( _e_id )
			end
		end
	end

	if _max_ms > 0 then
		LTimer.AddDelayFunc1( "battle_end",((_max_ms + 100) / 1000),this.EndBattle4Scene )
	else
		this.EndBattle4Scene()
	end
end

function M.OnMsg_Buff_Add(svMsg)
	local _obj = this.GetSObj( svMsg.id )
	if not _obj then return end
	_obj:AddBuff( svMsg.buffid,(svMsg.duration or 0) * 0.01 )
end

function M.OnMsg_Buff_Rmv(svMsg)
	local _obj = this.GetSObj( svMsg.id )
	if not _obj then return end
	_obj:RmvBuff( svMsg.buffid )
end

function M.OnMsg_OneAttrChg(svMsg)
	local _obj = this.GetSObj( svMsg.id )
	if not _obj then return end
	if svMsg.speed then
		_obj:SetMoveSpeed( tonumber( svMsg.speed ) or 1 )
	end

	if svMsg.atkspeed then
		_obj:SetAtkSpeed( tonumber( svMsg.atkspeed ) or 1 )
	end
end

return M
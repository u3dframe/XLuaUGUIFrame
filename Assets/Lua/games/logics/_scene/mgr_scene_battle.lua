--[[
	-- 管理 - 场景 - 战斗
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-13 09:25
	-- Desc : defenses,offenses
]]

local tonumber,type,tostring = tonumber,type,tostring
local tb_remove,tb_insert,tb_contain = table.remove,table.insert,table.contains
local tb_rm_val,tb_keys,tb_concat = table.removeValues,table.keys,table.concat
local tb_lens = table.lens
local MgrData,LTimer = MgrData,LTimer
local E_B_State,E_Object = LES_Battle_State,LES_Object
local E_Type = LE_Effect_Type
local _is_debug = false

MgrScene = require( "games/logics/_scene/mgr_scene" )
local ClsCG = require( "games/logics/story/storyplaychild" )

local super,_evt = MgrBase,Event
local M = class( "mgr_scene_battle",super )
local this = M

function M.Init()
	MgrScene:Init()

	this.ReInitPars()
	this.eveRegion = this:TF((1 / (E_B_State.Entry_CG - E_B_State.Start)),4)
	this:ReEvent4OnUpdate( true )

	_evt.AddListener( Evt_Map_SV_AddObj,this.OnSv_Add_Map_Obj )
	_evt.AddListener( Evt_Map_SV_RmvObj,this.OnSv_Rmv_Map_Obj )
	_evt.AddListener( Evt_Map_SV_MoveObj,this.OnSv_Move_Map_Obj )
	_evt.AddListener( Evt_Map_SV_Skill,this.OnSv_Map_Obj_Skill )
	_evt.AddListener( Evt_Map_SV_Skill_Effect,this.OnSv_Map_Obj_Skill_Effect )
	_evt.AddListener( Evt_Map_SV_BreakSkill,this.OnSv_Map_Obj_Skill_Break )
	
	_evt.AddListener( Evt_State_Battle_Start,this.Start )
	_evt.AddListener( Evt_FightUI_Showing,this._ST_UIOpenFinished )
	_evt.AddListener( Evt_Battle_Delay_End_MS,this.SetDelayEndBattle )
	_evt.AddListener( Evt_Msg_Battle_End,this._OnMsgEndBattle )

	_evt.AddListener( Evt_Msg_B_Buff_Add,this.OnMsg_Buff_Add )
	_evt.AddListener( Evt_Msg_B_Buff_Rmv,this.OnMsg_Buff_Rmv )
	_evt.AddListener( Evt_Bat_OneAttrChg,this.OnMsg_OneAttrChg )
	_evt.AddListener(Evt_Re_Login,this.OnClear)
	_evt.AddListener( Evt_Msg_B_Trigger_Add,this.OnMsg_Trigger_Add )
	_evt.AddListener( Evt_Msg_B_Trigger_Rmv,this.OnMsg_Trigger_Rmv )
	_evt.AddListener(Evt_Map_Load,this.EndBattle4Scene)
end

function M.ReInitPars()
	this.isUping = false
	this.state = E_B_State.None

	this.progress = 0
	this._ms_delay_end = 0
	this._ndelay_fps = 0
	this._need_load,this._loaded = 0,0
	this._need_load_obj,this._loaded_obj = 0,0
	-- this._deLObjSec = 0.03

	this.ReInit_Cmr()

	this.isJugdeCmr = nil
	this.isBattleEnd = nil
	this.res_ids,this._need_funcs = nil
end

function M.ReInit_Cmr()
	this._avgX = 0
	this._ceneterX = 0
	this._lbCmrX,this._lbCmrFOV = nil
	this._curChgX,this._curChgFov = nil
end

function M.OnClear()
	Time:SetTimeScale(1)
	this.ReInitPars()
	this.RemoveAll()
	MgrScene.OnClear()
end

function M:OnUpdate(dt)
	this._ST_Create_Obj()
	this._ST_LoadObjs()
	this._ST_JugdeCamera()

	if this.state == E_B_State.Start then
		this._SetUpState( E_B_State.Create_Objs )
	elseif this.state == E_B_State.Create_Objs then
		this._ST_OnUp_LoadObj( dt )
	elseif this.state == E_B_State.LoadOtherObjs then
		this._ST_OnUp_LoadObj( dt )
	elseif this.state == E_B_State.Entry_CG then
		this._SetUpState( E_B_State.Entry_CG_Ing )
	elseif this.state == E_B_State.Entry_CG_Ing then
		this._SetUpState( E_B_State.Entry_CG_End )
	elseif this.state == E_B_State.Entry_CG_End then
		this._SetUpState( E_B_State.Play_BG )
	elseif this.state == E_B_State.Play_BG then
		this._ST_PlayBG()
	elseif this.state == E_B_State.Ready then
		this._ST_Ready()
	elseif this.state == E_B_State.GO then
	end
end

function M.GetSObj(uniqueID)
	return MgrScene.OnGet_Map_Obj( uniqueID )
end

function M._Up_Progress()
	this.progress = (this.state - E_B_State.Start) * this.eveRegion;
	_evt.Brocast(Evt_Loading_UpPlg,this.progress)
end

function M._SetUpState( state,isNoMsgProg )
	this.state = state or E_B_State.None
	if not isNoMsgProg then
		this._Up_Progress();
	end
end

function M._IsCanStart()
	if this.state == E_B_State.None or this.state == E_B_State.End then
		return true
	end
	return true
end

function M.Start()
	_evt.Brocast(Evt_Loading_Show,this.progress,this._ST_Begin)
end

function M._ST_Begin()
	this.isUping = true
	this.isJugdeCmr = true
	this._SetUpState( E_B_State.Start )
end

function M._ST_Create_Obj()
	if not this.sv_queue_add then return end
	if #this.sv_queue_add <= 0 then
		if this.state == E_B_State.Create_Objs and (this._loaded >= this._need_load) then
			this._SetUpState( E_B_State.LoadOtherObjs )
		end
		return
	end
	local _lf = tb_remove( this.sv_queue_add,1 )
	_lf()
end

function M._IsDelayLoadObj(dt)
	if this._deLObjSec and this._deLObjSec >= 0.02 then
		this._cd1 = this._cd1 or 0
		while (this._cd1 <= 0) do
			this._cd1 = this._cd1 + this._deLObjSec
		end
		this._cd1 = this._cd1 - dt
		if this._cd1 > 0 then
			return true
		end
	end
end

function M._ST_OnUp_LoadObj(dt)
	if this._IsDelayLoadObj(dt) then
		return
	end
	local _cur,_need = this._loaded,this._need_load
	if this.state == E_B_State.LoadOtherObjs then
		_cur,_need = this._loaded_obj,this._need_load_obj
		if _need <= 0 then
			this._SetUpState( E_B_State.WaitOpenFightUI )
			_evt.Brocast( Evt_View_FightUI )
			return
		end
	end

	local _v = this:TF2(this.progress + (_cur * this.eveRegion / _need))
	_evt.Brocast(Evt_Loading_UpPlg,_v)
end

local function _pre_load_obj()
	this._loaded_obj = this._loaded_obj + 1
end

function M._AddNeedLoadResid( resid,isCG )
	if not resid then
		return
	end

	local _lb = this.res_ids or {}
	this.res_ids = _lb

	if _lb[resid] ~= nil then
		return
	end
	_lb[resid] = true
	local _func_ = nil
	if isCG == true then
		_func_ = function()
			ClsCG.PreLoad( resid,_pre_load_obj )
		end
	else
		_func_ = function()
			EffectFactory.Make( E_Type.Pre_Effect,nil,nil,resid,_pre_load_obj )
		end
	end
	

	_lb = this._need_funcs or {}
	this._need_funcs = _lb
	tb_insert(_lb,_func_)
	this._need_load_obj = this._need_load_obj + 1
end

function M._ST_LoadObjs()
	if not this._need_funcs then return end
	if #this._need_funcs <= 0 then
		if this.state == E_B_State.LoadOtherObjs then
			if (this._loaded_obj > this._need_load_obj) then
				if this._ndelay_fps >= 3 then
					this._SetUpState( E_B_State.WaitOpenFightUI )
					_evt.Brocast( Evt_View_FightUI )
				end
				this._ndelay_fps = this._ndelay_fps + 1
			elseif (this._loaded_obj == this._need_load_obj) then
				this._loaded_obj = this._loaded_obj + 1
			end
		end
		return
	end
	local _lf = tb_remove( this._need_funcs,1 )
	_lf()
end

function M._ST_UIOpenFinished()
	if this.state == E_B_State.WaitOpenFightUI then
		this._SetUpState( E_B_State.Entry_CG )
	end
end

function M._ST_PlayBG()
	this._SetUpState( E_B_State.Ready )
end

function M._ST_Ready()
	this._SetUpState( E_B_State.Ready_Ing )
	MgrBattle:FormalStartBattle(this._On_ST_Start_Battle)
end

function M._On_ST_Start_Battle(msg)
	if msg.e == 0 then
		this._SetUpState( E_B_State.GO )
		_evt.Brocast(Evt_Loading_Hide)
	else
		-- 弹出提示，并且重置所有
	end
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
		local _cfg_,_resid
		if objType ==  E_Object.Trigger then
			_cfg_ = this:GetCfgData("skill_trigger",svMsg.cfgid)
			if _cfg_ then
				local _cfgEft = MgrData:GetCfgSkillEffect( _cfg_.cast_effect )
				if _cfgEft then
					_resid = _cfgEft.resid
				end
			end
		elseif objType ==  E_Object.Hero or objType ==  E_Object.Monster then
			_cfg_ = this:GetCfgData("hero",svMsg.cfgid)
			if _cfg_ then
				_resid = _cfg_.resource
				if svMsg.master then
					_resid = _cfg_.resid_fs -- 分身资源
				end
			end
		end
		
		if _cfg_ and _resid then
			local _obj = MgrScene.Add_SObj( objType,_resid,svMsg.id )
			if _obj then
				_obj.lfOnShowOnce = function()
					this._loaded = this._loaded + 1
				end
				_obj:View(true,_cfg_,svMsg)
			end
			
			if _cfg_.resid_fs then
				this._AddNeedLoadResid( _cfg_.resid_fs )
			end

			if _cfg_.resids then
				for _, resid in ipairs(_cfg_.resids) do
					this._AddNeedLoadResid( resid )
				end
			end

			if _cfg_.resid_cg then
				this._AddNeedLoadResid( _cfg_.resid_cg,true )
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
	if (not _obj) or type(_obj.CastAttack) ~= "function" then return end
	_obj:CastAttack( svMsg )
end

function M.OnSv_Map_Obj_Skill_Effect(svMsg)
	local _obj = this.GetSObj( svMsg.caster )
	if _obj and type(_obj.CastInjured) == "function" then 
		_obj:CastInjured( svMsg )
		return 
	end
	local _list = svMsg.list
	local _lens = tb_lens( _list )
	if _lens > 0 then
		local _svOne,_obj
		for i = 1, _lens do
			_svOne = _list[i]
			_obj = this.GetSObj( _svOne.target )
			if _obj ~= nil then
				_obj:DoHurtEffect( _svOne )
			end
		end
	end
end

function M.OnSv_Map_Obj_Skill_Break(svMsg)
	local _obj = this.GetSObj( svMsg.id )
	if not _obj then return end
	_obj:State2Idle()
end

function M.RemoveCurr( id )
	if (not id) or (not this.sv_dic_add) then return end

	local _func = this.sv_dic_add[id]
	if _func then
		tb_rm_val( this.sv_queue_add,_func )
	end
	this.sv_dic_add[id] = nil
end

function M.RemoveById(id,isNotDis)
	this.RemoveCurr( id )

	local _obj = this.GetSObj( id )
	MgrScene.RemoveCurrMapObj( id )
	if _obj then
		if not (isNotDis == true) then
			_obj:Disappear()
		end
	end
end

function M.RemoveAll(isNotDis)
	if (not this.sv_dic_add) then return end
	local _keys = tb_keys( this.sv_dic_add )
	local _tp = type(isNotDis)
	local _isNotDis = (_tp ~= "number") and (isNotDis == true)
	for _, k in ipairs(_keys) do
		if _tp == "number" then
			_isNotDis = (k == isNotDis)
		end
		this.RemoveById( k,_isNotDis )
	end
end

function M.EndBattle4Scene(isInterrupt,isNotRmv)
	-- printTable("=========EndBattle4Scene")
	LTimer.RemoveDelayFunc( "battle_end" )
	this.ReInitPars()
	if not isNotRmv then
		this.RemoveAll()
	end
	_evt.Brocast(Evt_Battle_End)
	-- MgrBattle:OpenBattleSettlement(isInterrupt)
end

function M.SetDelayEndBattle( ms )
	ms = tonumber(ms) or 0
	if this._ms_delay_end < ms then
		this._ms_delay_end = ms
	end
end

function M._OnMsgEndBattle( msg )
	this.isBattleEnd = true
	local _uuid = nil 
	if msg._msg_pre_end then
		_uuid = msg._msg_pre_end.uuid
		msg._msg_pre_end = nil
	end
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
		if _sobj and _sobj.data and type(_sobj.IsDeath) == "function" and not _sobj:IsDeath() then
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
		if _isWin and _uuid then
			_sobj = this.GetSObj( _uuid )
			local _tMap = this.GetSObj( "mapobj" )
			if _sobj and _tMap then
				_sobj:SetLocalEulerAngles( 0,0,0 )
				this.RemoveAll( _uuid )
				local _t,_ox,_oy,_oz,_fov = MgrData:GetCfgBasic("battle_end_offset"),-3,0.5,0
				local _cy = nil
				if _t then
					_ox,_oy,_oz = (tonumber(_t[1]) or -300) * 0.01,(tonumber(_t[2]) or 50) * 0.01,(tonumber(_t[3]) or 0) * 0.01
					
					if _t[4] then
						_fov = (tonumber(_t[4]) or 0) * 0.01
					end
					if _t[5] then
						_cy = tonumber(_t[5])
						if _cy then
							_cy = _cy * 0.01
						end
					end
				end
				MgrCamera:GetMainCamera():StopSmooth()
				_tMap:CmrFov( _fov )
				local _fmid = _sobj:GetElementTrsf("f_mid")
				_tMap:CmrLookAtTarget( _fmid or _sobj.trsf,_ox,_oy,_oz,true )
				_tMap:CmrLocalPosY( _cy )
			end
		end
		LTimer.AddDelayFunc1( "battle_end",((_max_ms + 100) / 1000),this.EndBattle4Scene,false,true )
	else
		this.EndBattle4Scene()
	end
end

function M.OnMsg_Buff_Add(svMsg)
	local _obj = this.GetSObj( svMsg.id )
	if not _obj then return end
	_obj:AddBuff( svMsg.buffid,(svMsg.duration or 0) * 0.01,svMsg.fromid )
end

function M.OnMsg_Buff_Rmv(svMsg)
	local _obj = this.GetSObj( svMsg.id )
	if not _obj then return end
	_obj:RmvBuff( svMsg.buffid )
end

function M.OnMsg_OneAttrChg(svMsg)
	local _obj = this.GetSObj( svMsg.id )
	if not _obj then
		return
	end
	local _attrs = svMsg.attrs
	if not _attrs then
		return
	end
	if _attrs.speed then
		_obj:SetMoveSpeed( tonumber( _attrs.speed ) or 1 )
	end

	if _attrs.atkspeed then
		_obj:SetAtkSpeed( tonumber( _attrs.atkspeed ) or 1 )
	end
end

function M.OnMsg_Trigger_Add(svMsg)
	this.OnSv_Add_Map_Obj( E_Object.Trigger,svMsg )
end

function M.OnMsg_Trigger_Rmv(svMsg)
	this.OnSv_Rmv_Map_Obj( svMsg.id )
end

function M._Get_CfgCmrMove( lb,cur )
	if lb and cur and #lb > 0 then
		local _min,_max,_item_ = nil
		for _, item in ipairs(lb) do
			if #item >= 4 then
				_min,_max = item[1] * 0.01,item[2] * 0.01
				if cur >= _min and cur <= _max then
					return item[3] * 0.01,item[4] * 0.001
				end
				_item_ = item
			end
		end
		if _item_ then
			return _item_[3] * 0.01,_item_[4] * 0.001
		end
	end
end

function M._ST_JugdeCamera()
	if (this.state ~= E_B_State.GO) or (not this.isJugdeCmr) or this.isBattleEnd then
		this.ReInit_Cmr()
		return
	end
	
	local _lbAlls = MgrScene.GetCurrMapAllObjs()
	if not _lbAlls then
		return
	end

	if not this._lbCmrX then
		local _cfg_ = MgrScene.GetCurrMapCfg()
		this._lbCmrX = _cfg_.fight_move_x
		this._lbCmrFOV = _cfg_.fight_move_fov
	end

	local _minPosX,_maxPosX,_curPos = 0,0
	local _sobjType = nil
	for _, item in pairs(_lbAlls) do
		_sobjType = item:GetSObjType()
		if _sobjType and _sobjType >= E_Object.Creature and _sobjType <= E_Object.MPartner then
			_curPos = item.v3Pos
			if _curPos then
				if _minPosX > _curPos.x then
					_minPosX = _curPos.x
				end
				if _maxPosX < _curPos.x then
					_maxPosX = _curPos.x
				end
			end
		end
	end

	if _maxPosX == _minPosX and _minPosX == 0 then
		return
	end
	local _avg = this:TF( (_maxPosX - _minPosX) * 0.5,2 )
	local _abs = this:MAbs( _avg )
	local _chgFov,_chgFovT = this._Get_CfgCmrMove( this._lbCmrFOV,_abs )
	this._ceneterX = _minPosX + _avg
	_abs = this:MAbs( this._ceneterX )
	local _chgX,_chgXT = this._Get_CfgCmrMove( this._lbCmrX,_abs )
	if _chgX  or _chgFov then
		this._avgX = _avg
		if this._ceneterX < 0 then
			_chgX = (_chgX ~= nil) and _chgX * -1 or _chgX
		end
		if _chgX == this._curChgX and _chgFov == this._curChgFov then
			return
		end
		this._curChgX,this._curChgFov = _chgX,_chgFov
		MgrCamera:GetMainCamera():ToSmooth4LocXYZ( _chgX,_chgFov,_chgFovT,nil,nil,true,_chgXT )
	end
end

function M.SetJugdeCamera( isBl )
	if this.state ~= E_B_State.GO then
		return
	end

	this.isJugdeCmr = isBl == true
	if not this.isJugdeCmr then
		MgrCamera:GetMainCamera():RebackStart( 0.3 )
	end
end

return M
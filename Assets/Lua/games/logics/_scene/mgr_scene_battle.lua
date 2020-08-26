--[[
	-- 管理 - 场景 - 战斗
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-13 09:25
	-- Desc : defenses,offenses
]]

local tb_remove,tb_insert,tb_contain = table.remove,table.insert,table.contains
local tb_rm_val = table.removeValues

MgrScene = require( "games/logics/_scene/mgr_scene" )

local LES_B_State,LES_Object = LES_Battle_State,LES_Object

local super,_evt = MgrBase,Event
local M = class( "mgr_scene_battle",super )
local this = M

function M.Init()
	MgrScene:Init()

	this.state = LES_B_State.None
	this:ReEvent4OnUpdate(true)

	_evt.AddListener(Evt_Map_SV_AddObj,this.OnSv_Add_Map_Obj)
	_evt.AddListener(Evt_Map_SV_RmvObj,this.OnSv_Rmv_Map_Obj)
	_evt.AddListener(Evt_Map_SV_MoveObj,this.OnSv_Move_Map_Obj)
	
	_evt.AddListener(Evt_State_Battle_Start,this.Start)
	_evt.AddListener(Evt_State_Battle_End,this._On_ST_End_Battle)
end

function M:OnUpdate(dt)
	if this.state == LES_B_State.Start then
		this.state = LES_B_State.Create_Objs
	elseif this.state == LES_B_State.Create_Objs then
		this._ST_Create_Obj()
	elseif this.state == LES_B_State.Create_Objs_End then
		this.state = LES_B_State.Entry_CG
	elseif this.state == LES_B_State.Entry_CG then
		this.state = LES_B_State.Entry_CG_Ing
	elseif this.state == LES_B_State.Entry_CG_Ing then
		this.state = LES_B_State.Entry_CG_End
	elseif this.state == LES_B_State.Entry_CG_End then
		this.state = LES_B_State.Play_BG
	elseif this.state == LES_B_State.Play_BG then
		this._ST_PlayBG()
	elseif this.state == LES_B_State.Ready then
		this._ST_Ready()
	elseif this.state == LES_B_State.GO then
		this._ST_Go()
	elseif this.state == LES_B_State.Battle_Ing then
	elseif this.state == LES_B_State.Battle_End then
		this.state = LES_B_State.End
		this.isUping = false
	elseif this.state == LES_B_State.Battle_Error then
		this.state = LES_B_State.End
		this.isUping = false
	end
end

function M.OnSv_Add_Map_Obj(objType,svMsg)
	local _lb_dic = this.sv_dic_add or {}
	this.sv_dic_add = _lb_dic

	local _func = _lb_dic[svMsg.id]
	if _func then
		printError("=== add sv obj is repeat  id = [%s]",svMsg.id)
		return
	end

	_func = function()	
		if objType ==  LES_Object.Hero then
			local cfg = this:GetCfgData("hero",svMsg.cfgid)
			if cfg then
				local _obj = MgrScene.Add_SObj( objType,cfg.resource,svMsg.id )
				if _obj then
					_obj:SetParent(nil,true)
					_obj:View(true,_cfg,svMsg)
				end
			end
		end
	end

	_lb_dic[svMsg.id] = _func

	local _lb = this.sv_queue_add or {}
	this.sv_queue_add = _lb
	tb_insert(_lb,_func)
end

function M.OnSv_Rmv_Map_Obj(svMsg)
	if this.sv_dic_add then
		local _func = this.sv_dic_add[svMsg.id]
		if _func then
			tb_rm_val( this.sv_queue_add,_func )
		end
	end

	MgrScene.Reback_MapObj( svMsg.id )
end

function M.OnSv_Move_Map_Obj(svMsg,isStop)
	local _obj = MgrScene.GetCurrMapObj( svMsg.id )
	if not _obj then return end
	_obj:SetPos( svMsg.x,svMsg.y )
	if not isStop then
		_obj:MoveTo( svMsg.dx,svMsg.dy )
	end
end


function M._IsCanStart()
	if this.state == LES_B_State.None or this.state == LES_B_State.End then
		return true
	end
	return true
end

function M.Start()
	if this._IsCanStart() then
		this.state = LES_B_State.Start
	end
	this.isUping = true
end

function M._ST_Create_Obj()
	if not this.sv_queue_add then return end
	if #this.sv_queue_add <= 0 then
		this.state = LES_B_State.Create_Objs_End
		return
	end
	local _lf = this.sv_queue_add[1]
	tb_remove( this.sv_queue_add,1 )
	_lf()
end

function M._ST_PlayBG()
	this.state = LES_B_State.Ready
end

function M._ST_Ready()
	printError("========== start sv battle")
	MgrBattle:FormalStartBattle(this._On_ST_Start_Battle)
end

function M._On_ST_Start_Battle(msg)
	if msg.e == 0 then
		this.state = LES_B_State.GO
	else
		this.state = LES_B_State.Battle_Error
	end
end

function M._ST_Go()
	this.state = LES_B_State.Battle_Ing
end

function M._On_ST_End_Battle()
	this.state = LES_B_State.Battle_End
end

return M
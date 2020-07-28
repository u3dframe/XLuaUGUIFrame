--[[
	-- 定时及服务器时间管理操作
	-- Author : canyon / 龚阳辉
	-- Date   : 2020-07-23 12:20
	-- Desc   : 延迟执行,每秒及定点通知
]]

local tb_insert = table.insert
local tb_cid = table.contains_id
local tb_rm = table.removeValuesFunc
local tb_for = table.foreachArrs
local tb_vk = table.getVK
local _tEx,_nEx = TimeEx,NumEx
local _dTr,_pErr,_clr = debug.traceback,printError,clearLT
local _tLb,_ok,_err = {}

local super,_evt = LuaObject,Event
local M = class( "lua_timer",super )
local this = M

function M.Init()
	this:clean_end()
end

function M:clean_end()
	this.oneMin = 60
	this.oneHour = 60 * 24
	this.sumCDTime = 0
	this.gcTime = 0
	this.cdSec = 1
	this.cdMin = this.oneMin
	this.cdHour = this.oneHour
	this:ReEvent4OnUpdate(true)
end

function M:OnUpdate(dt)
	this.sumCDTime = this.sumCDTime + dt
	this.gcTime = this.gcTime + dt
	this.cdSec = this.cdSec - dt
	this.cdMin = this.cdMin - dt
	this.cdHour = this.cdHour - dt

	if this.cdSec <= 0 then
		this.cdSec = this.cdSec + 1
		_evt.Brocast(Evt_UpEverySecond)
	end

	if this.cdMin <= 0 then
		this.cdMin = this.cdMin + this.oneMin
		this.curMin = (this.curMin + 1) % 60
		_evt.Brocast(Evt_UpEveryMin,this.curMin)
	end

	if this.cdHour <= 0 then
		this.cdHour = this.cdHour + this.oneHour
		this.curHour = (this.curHour + 1) % 24
		_evt.Brocast(Evt_UpEveryHour,this.curHour)
	end

	this._ExcDelayFunc(dt)

	if this.gcTime >= 900 then
		this.gcTime = this.gcTime - 900
		this.GC()
	end
end

function M.GC()
	CHelper.ClearMemory()
	collectgarbage("collect")
	collectgarbage()
end

function M.SetSvTimeMs(svMs)
	this.SetSvTime(_tEx.toSec(svMs or 0))
end

function M.SetSvTime(svTimeSec)
	this.isUping = false
	local _svSec = this:TF( svTimeSec,3 )
	local _nowSec = this.GetLocTime()
	_tEx.setDiffSec(_svSec - _nowSec)
	if (this.lastSvSec) then
		this.sumCDTime = this.sumCDTime + this.lastSvSec - _svSec
	end
	this.lastSvSec = _svSec
	this.cdSec = 1 - _nEx.modDecimal(_svSec)
	_svSec = (this.cdSec == 1) and 0 or this.cdSec
	local _lb = this.GetSvDate()
	this.curMin = _lb.min
	this.curHour = _lb.hour
	this.cdMin = (this.oneMin - _lb.sec) + _svSec
	this.cdHour = (this.oneHour - this.curMin * this.oneMin) + this.cdMin
	this.isUping = true
end

function M.ReLocTime()
	this.SetSvTime(this.GetLocTime())
end

function M.GetLocTime()
	return _tEx.getTime()
end

function M.GetSvTime()
	return _tEx.getCurrentTime()
end

function M.GetSvDate()
	return _tEx.getDate()
end

local function _rf_delay(item,obj)
	return item.cmd == obj
end

function M.RemoveDelayFunc(cmd,isNoAll)
	local times = (isNoAll == true) and 1 or -1
	tb_rm(this._lbFuncDelays,_rf_delay,cmd,times)
end

function M.AddDelayFunc(cmd,delay,func,loop,duration)
	this._lbFuncDelays = this._lbFuncDelays or {}
	local _v = tb_vk(this._lbFuncDelays,"cmd",cmd)
	loop = (loop or 1)
	if _v and _v.delay > 0.01 then
		_v.delay = delay
		_v.duration = (duration or delay)
		_v.func = func
		_v.loop = loop -- 负数标识无线循环
	else
		_v = {cmd = cmd,delay = delay,func = func,loop = loop,duration = (duration or delay)}
		tb_insert(this._lbFuncDelays,_v)
	end
	return _v
end

function M._ExcDelayFunc(dt)
	if not this._lbFuncDelays or #this._lbFuncDelays <= 0 then
		return
	end
	for _, v in ipairs(this._lbFuncDelays) do
		if v.delay > 0 then
			if not v.isPause then 
				v.delay = v.delay - dt
			end
		else
			v.loop = v.loop - 1
			if v.func then
				_ok,_err = xpcall(v.func,_dTr)
				if not _ok then
					v.loop = 0
					_pErr(_err)
				end
			else
				v.loop = 0
			end

			if v.loop == 0 then
				tb_insert(_tLb,v.cmd)
			else
				v.delay = v.delay + v.duration
			end
		end
	end
	
	if #_tLb <= 0 then return end

	for _, v in ipairs(_tLb) do
		this.RemoveDelayFunc(v)
	end

	_clr(_tLb)
end

function M.PauseDelayFunc(cmd,isPause)
	local _v = tb_vk(this._lbFuncDelays,"cmd",cmd)
	if _v then
		_v.isPause = (isPause == true)
	end
end

function M.GetHMS(diffSec,isDay)
	if (isDay == true) then return _tEx.getDHMSBySec(diffSec) end
	return _tEx.getHMSBySec(diffSec)
end

function M.OutGame()
	this.isUping = false
	this:clean()
end

return M
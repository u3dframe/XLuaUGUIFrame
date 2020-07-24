--[[
	-- 游戏定时操作
	-- Author : canyon / 龚阳辉
	-- Date   : 2020-07-23 12:20
	-- Desc   : 延迟执行,每秒及定点通知
]]

local tb_insert = table.insert
local _tEx,_nEx = TimeEx,NumEx

local super,_evt = LuaObject,Event
local M = class( "lua_timer",super )
local this = M

function M.Init()
	this.sumCDTime = 0
	this.gcTime = 0
	this.cdSec = 1
	this:ReEvent4OnUpdate(true)
end

function M:OnUpdate(dt)
	this.sumCDTime = this.sumCDTime + dt
	this.gcTime = this.gcTime + dt
	this.cdSec = this.cdSec - dt
	if this.cdSec <= 0 then
		this.cdSec = this.cdSec + 1
		_evt.Brocast(Evt_UpEverySecond)
	end

	if this.gcTime >= 900 then
		this.gcTime = this.gcTime - 900
		CHelper.ClearMemory()
		collectgarbage("collect")
		collectgarbage()
	end
end

function M.SetSvTimeMs(svMs)
	this.SetSvTime(_tEx.toSec(svMs or 0))
end

function M.SetSvTime(svTimeSec)
	this.isUping = false
	local _svSec = self:TF( svTimeSec,3 )
	local _nowSec = this.GetLocTime()
	_tEx.setDiffSec(_svSec - _nowSec)
	if (this.lastSvSec) then
		this.sumCDTime = this.sumCDTime + this.lastSvSec - _svSec
	end
	this.lastSvSec = _svSec
	this.cdSec = this.cdSec - _nEx.modDecimal(_svSec)
	this.isUping = true
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

function M.AddDelayFunc(cmd,delay,func)
	
end

return M
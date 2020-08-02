--[[
	-- 管理 - 功能解锁
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-30 13:25
	-- Desc : 
]]

local _e_tip = Evt_Popup_Tips

local super,_evt,_mDt = MgrBase,Event,MgrData
local M = class( "mgr_unlock", super)
local this = M

function M.Init()
	--TODO:功能解锁检查函数初始化
	local _lb = {}
	this.lfChecks = _lb
	
	_lb[1] = this.CheckLevel
end

function M.GetData(id)
	return _mDt:GetOneData("unlock",id)
end

--解锁
function M.IsUnlock(id,isTips)
	isTips = (isTips == true)
	
	if not id then
		if isTips then
			_evt.Brocast(_e_tip,"功能ID为空了")
		end
		return false
	end

	local _cfg = this.GetData(id)
	if not _cfg then
		if isTips then
			_evt.Brocast(_e_tip,"功能解锁表里无此功能ID,ID = [" .. id .. "]为空了")
		end
		return false 
	end

	local _tmp,_lf = _cfg["unlock"]
	if (_tmp and #_tmp > 0)then
		for _,v in ipairs(_tmp) do
			_lf = this.lfChecks[v[1]]
			if _lf then
				return _lf((v[2] or 0),isTips),_cfg
			end
		end
	end
	return true,_cfg
end

-- 判断等级解锁
function M.CheckLevel(lv,isTips)
	lv = lv or 0
	local _curLv = 0

	if lv > _curLv then
		if isTips then
			_evt.Brocast(_e_tip,"等级不足,当前等级 = " .. _curLv .. "，需要解锁等级 = " .. lv)
		end
		return false
	end
	return true
end

return M
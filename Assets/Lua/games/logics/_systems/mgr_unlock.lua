--[[
	-- 管理 - 功能解锁
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-30 13:25
	-- Desc : 
]]

local _e_tip = Evt_Popup_Tips

local super,_evt = MgrBase,Event
local M = class( "mgr_unlock", super)
local this = M

function M.Init()
	--TODO:功能解锁检查函数初始化
	local _lb = {}
	this.lfChecks = _lb
	_lb[1] = this.CheckMLine
	_lb[2] = this.CheckLevel
	_lb[3] = this.CheckMaxHeroLevel
	_lb[4] = this.CheckHeroStageNum
	_lb[5] = this.CheckVipLevel
	this:AddPCall( "fnopen_list",this.On_SvOpenIds )
	this:AddPCall( "fnopen_new",this.On_SvOpenNew )
end

function M.GetData(id)
	return this:GetCfgData("fnopen",id)
end

function M.On_SvOpenIds( msg )
	this.svData = msg
end

function M.On_SvOpenNew(msg)
	if this.svData then
		table.append(this.svData.ids, msg.ids, -1)
		MgrGuide:CheckGuideDispose()
	else
		this.svData = msg
	end
	_evt.Brocast(Evt_FnOpenNew, msg.ids)
end

function M.IsUnlock_Sv( id )
	if this.svData then
		return table.contains( this.svData.ids,id )
	end
	return false
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

	if this.IsUnlock_Sv( id ) then
		return true,_cfg
	end

	local _tmp,_lf = _cfg["precondition"]--数据结构：{{{a},{b}},{{a},{b}}} 格式:-> {{{a}且{b}} 或 {{a}且{b}}}

	if (_tmp and #_tmp > 0)then
		for i,v in ipairs(_tmp) do
			local islock = false;
			for s, b in ipairs(v) do
				if (this.lfChecks[b[1]])then
					_lf = this.lfChecks[b[1]](b);
					if (_lf ~= true)then islock = true; end
				else
					printError("未查找到类型为%s的解锁处理逻辑",b[1]);
				end
			end
			if (islock ~= true)then
				return true, _cfg;
			else
				if (i == #_tmp and isTips)then
					if (_cfg.tips)then
						_evt.Brocast(Evt_Popup_Tips, _cfg.tips)
					else
						_evt.Brocast(Evt_Popup_Tips, 42513)
						printInfo("ID = %s 功能不满足解锁条件，且无配置tips", id)--进入这里代表策划没有配数据，打印以提醒策划配置
					end
				end
			end
		end
	else
		return true, _cfg
	
	end return false,_cfg
end

--1:主线关卡解锁（当前达到某个关卡）
function M.CheckMLine(dt)
	local lv = dt[2] or 0
	local _curLv = MgrMainMission.svbasic and  MgrMainMission.svbasic.id or 0
	return lv <= _curLv
end

--2:判断等级解锁（当前达到某个等级）
function M.CheckLevel(dt)
	local lv = dt[2] or 0
	local _curLv = MgrRoleInfo.svdata and MgrRoleInfo.svdata.level or 0
	return lv <=_curLv
end

--3:英雄最大等级解锁（英雄最大等级达到配置）
function M.CheckMaxHeroLevel(dt)
	local lv = dt[2] or 0
	local _curLv = 0
	local HeroList = MgrStore:GetStoryDataList(MgrStore.HeroType) or {};
	for _, v in ipairs(HeroList) do
		if (_curLv < (v.level or 0))then
			_curLv = v.level;
		end
	end return lv <= _curLv
end

--4:英雄品阶个数解锁(钦屿需求：stage 大于等于配置v[2]，相同tab的个数最大值大于等于v[3]解锁)
function M.CheckHeroStageNum(dt)
	local lv = dt[3] or 0
	local _curLv = {}
	local HeroList = MgrStore:GetStoryDataList(MgrStore.HeroType) or {};
	for _, v in ipairs(HeroList) do
		local ct = MgrStore:GetItemCfg(MgrStore.HeroType, v.id)
		if ((ct.stage or 0) >= dt[2])then
			_curLv[ct.tab] = (_curLv[ct.tab] or 0) + 1;
		end
	end
	for i, v in pairs(_curLv) do
		if (v >= lv)then
			return true;
		end
	end
	return false
end

--5:VIP等级
function M.CheckVipLevel(dt)
	local currLv, _ = MgrVip:GetVipLvAndExp()
	return currLv >= dt[2]
end

return M
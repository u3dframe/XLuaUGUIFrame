--[[
	-- 管理 -- 系统配置表
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-30 13:25
	-- Desc : 
]]

local strRoot = "games/config/" --配置表根路径
local str_split = string.split
local str_contains = string.contains
local _req,pcall = require,pcall
local clearLoadLua,weakTB,readonly = clearLoadLua,weakTB,readonly

UIType = {}

local M = class( "mgr_data")

local function _lfIndexLoad(t, k)
	local _arrs = str_split(k,"_")
	local _fn,_nm = _arrs[1],(_arrs[2] or _arrs[1])
	local _fp,_data = strRoot .. _fn
	pcall(function()
		_data = _req( _fp )
		clearLoadLua(_fp)
	end)
	if not _data then return end
	for kk,vv in pairs(_data) do
		t[_fn .. "_" .. kk] = vv
	end
	return t[_fn .. "_" .. _nm]
end

function M:Init()
	self._cfgDicWeak = weakTB("v",_lfIndexLoad)
	self:_LoadCfgs()
	self:_InitCfgs()
end

-- 添加常用配置
function M:_LoadCfgs()
	local _isOneXlsMoreSheet = true -- 一个系统Excel,有多工作表Sheet
	local _lbCfgs = {
	}
	local _fp,_data,_itm,_nk
	self._cfgDic = {}
	for _, v in ipairs(_lbCfgs) do
		_fp = strRoot .. v
		_data = _req(_fp)
		if _data then
			if _isOneXlsMoreSheet then
				for kk,vv in pairs(_data) do
					_nk = v .. "_" .. kk
					_itm = self._cfgDic[_nk]
					if (_itm) then
						printError( "配置表[%s]的[%s]配置重复，請检查", _fp,_nk )
					else
						self._cfgDic[_nk] = vv
					end
				end
			else
				self._cfgDic[v] = _data
			end
			
			clearLoadLua(_fp)
		else
			printError( "未查找到配置表[%s]，請检查是否添加", strRoot )
		end
	end
end

function M:_InitCfgs()
	self:_InitUnlock()
end

function M:GetConfig(cfgKey)
	if cfgKey and not str_contains(cfgKey,"_") then
		cfgKey = cfgKey .. "_" .. cfgKey
	end
	local _vb = self._cfgDic[cfgKey]
	if not _vb then
		_vb = self._cfgDicWeak[cfgKey]
	end
	if _vb then
		return _vb
	end
	printError("未查找到[%s]的配置表，請查找是否添加", cfgKey)
end

function M:GetOneData(cfgKey, idKey)
	local _cfg,_lb = self:GetConfig(cfgKey)
	if _cfg then
		_lb = _cfg[idKey] 
		if (_lb) then
			return readonly(_lb)
		end
		printError("未查找到[%s]的配置表 ID = [%s] 的数据，請检查", cfgKey, idKey)
	end
end

function M:_InitUnlock()
	local _cfg = self:GetConfig("fnopen")
	if _cfg then
		for k, v in pairs(_cfg) do
			UIType[v.uitype] = k
		end
	end
end

function M:GetCfgRes(idKey)
	return self:GetOneData( "resource",idKey )
end

function M:GetCfgMap(idKey)
	return self:GetOneData( "scenemap",idKey )
end

function M:GetCfgSkill(idKey)
	return self:GetOneData( "skill",idKey )
end

function M:GetCfgSkillEffect(idKey)
	return self:GetOneData( "skill_skilleffect",idKey )
end

function M:GetCfgHurtEffect(idKey)
	return self:GetOneData( "effect",idKey )
end

return M
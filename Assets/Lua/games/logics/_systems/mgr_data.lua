--[[
	-- 管理 -- 系统配置表
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-30 13:25
	-- Desc : 
]]

UIType = {}

local M = class( "mgr_data")

function M:Init()
	self:_LoadCfgs()
	self:_InitCfgs()
end

function M:_LoadCfgs()
	local _isOneXlsMoreSheet = true -- 一个系统Excel,有多工作表Sheet
	local strRoot = "games/config/" --配置表根路径
	local _lbCfgs = {
			"unlock",  --功能开放表
			"resource",--资源特效表
			"scenemap",--场景地图表
			"errtips", -- 服务器错误提示
			"story",
	}

	local _req = reimport or require
	local _fp,_data,_itm
	self._cfgDic = {}
	for _, v in ipairs(_lbCfgs) do
		_fp = strRoot .. v
		_data = _req(_fp)
		if _data then
			if _isOneXlsMoreSheet then
				for kk,vv in pairs(_data) do
					_itm = self._cfgDic[kk]
					if (_itm) then
						printError( "配置表[%s]的[%s]配置与配置表[%s]里面的配置相重复，請检查", _fp,kk,_itm.path )
					else
						self._cfgDic[kk] = { path = _fp,data = vv}
					end
				end
			else
				self._cfgDic[v] = { path = _fp,data = _data}
			end
		else
			printError( "未查找到配置表[%s]，請检查是否添加", strRoot )
		end
	end
end

function M:_InitCfgs()
	self:_InitUnlock()
end

function M:GetConfig(cfgKey)
	local _vb = self._cfgDic[cfgKey]
	if _vb then
		return _vb.data
	end
	printError("未查找到[%s]的配置表，請查找是否添加", cfgKey)
end

function M:GetOneData(cfgKey, idKey)
	local _cfg,_lb = self:GetConfig(cfgKey)
	if _cfg then
		_lb = _cfg[idKey] 
		if (_lb) then
			return _lb
		end
		printError("未查找到[%s]的配置表 ID = [%s] 的数据，請检查", cfgKey, idKey)
	end
end

function M:_InitUnlock()
	local _cfg = self:GetConfig("unlock")
	if _cfg then
		for k, v in pairs(_cfg) do
			UIType[v.uitype] = k
		end
	end
end

return M
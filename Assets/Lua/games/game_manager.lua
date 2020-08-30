--[[
	-- 游戏 管理
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-23 20:26
	-- Desc : 管理 并 加载 luafp 中的对象
]]

fmt_p1_p2 = "%s%s"
local str_format = string.format
local _req = reimport or require
local M = {}
local this = M;

--游戏初始化主要接口
function M.Init()
	_req "games/defines/define_luafp"

	local _MG = _G;
	for _,v in ipairs(_L_NoKey) do
		_req(v)
	end
	local _arrs = GetLuaFp4Globals()
	for _, v in ipairs(_arrs) do
		this.RequireByTab( v );
	end
end


function M.RequireByTab(lb)
	local _MG,_entity,_fp = _G;
	for _,v in ipairs(lb) do
		_fp = "";
		if v[3] then
			_fp = _LuaPacakge[v[3]] or ""
		end
		_fp = str_format(fmt_p1_p2,_fp,v[2])
		_entity = _req(_fp)
		
		if not (v[1] == "" or v[1] == "nil") then
			_MG[v[1]] = _entity;
		end

		if type(_entity) == "table" and _entity.Init then
			_entity:Init();
		end
	end
end

return M;

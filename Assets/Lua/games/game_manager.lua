fmt_s1_s2 = "%s%s"
local str_format = string.format

local M = {}
local this = M;

--游戏初始化主要接口
function M.Init()
	
	require "games/defines/define_luafp"

	local _MG = _G;
	for _,v in ipairs(_LuaFpNoKey) do
		require(v)
	end
	this.RequireByTab(_LuaFpBasic);
	this.RequireByTab(_LuaFpMidle);
	this.RequireByTab(_LuaFpEnd);
end


function M.RequireByTab(lb)
	local _MG,_entity,_fp = _G;
	for _,v in ipairs(lb) do
		_fp = "";
		if v[3] then
			_fp = _LuaPacakge[v[3]] or ""
		end
		_fp = str_format(fmt_s1_s2,_fp,v[2])
		_entity = require(_fp)
		if type(_entity) == "table" and _entity.Init then
			_entity:Init();
		end

		if not (v[1] == "" or v[1] == "nil") then
			_MG[v[1]] = _entity;
		end
	end
end

return M;

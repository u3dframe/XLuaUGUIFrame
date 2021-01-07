--[[
	-- 工具类脚本
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-27 19:35
	-- Desc : 封装函数用 . 号
]]
local tonumber,type,tostring = tonumber,type,tostring
local Color,CRSettingEx = Color,CRSettingEx
local str_2rgb = string.toColRGB

local _x_util = require 'games/tools/xlua_util'
local _c_yield = coroutine.yield

local M = {}
M.__index = M
local this = M

function M.csLuaMgr()
	this._csLMgr = this._csLMgr or CLuaMgr.instance
	return this._csLMgr
end

function M.StartCor( func,... )
	return this.csLuaMgr():StartCoroutine( _x_util.cs_generator( func,... ) )
end

function M.StoptCor( coroutine )
	this.csLuaMgr():StopCoroutine( coroutine )
end

function M.Wait( sec,func,... )
	local _args = { ... }
	return this.StartCor(function()
		_c_yield(UWaitForSeconds(sec))
		if func then func ( unpack(_args) ) end
	end)
end

function M.csLocz()
	this._csLocz = this._csLocz or CLocliz
	return this._csLocz
end

function M.GetOrFmtLoczStr(val,...)
	local _lens = lensPars( ... )
	if (_lens > 0) then return this.csLocz().Format( val,... ) end
	return this.csLocz().Get( val )
end

function M.ReRGBA(r,g,b,a)
	r = r > 1 and r / 255 or r;
	g = g > 1 and g / 255 or g;
	b = b > 1 and b / 255 or b;
	if a then
		a = a > 1 and a / 255 or a;
	else
		a = 1;
	end
	return r,g,b,a;
end

function M.RRGBA(r,g,b,a)
	if r and g and b then
		r,g,b,a = this.ReRGBA(r,g,b,a)
	elseif r then
		if type(r) == "string" then
			r,g,b,a = this.ReRGBA(str_2rgb(r))
		else
			r,g,b,a = r.r,r.g,r.b,r.a
		end
	end
	return r,g,b,a
end

function M.RColor(color,r,g,b,a)
	r,g,b,a = this.RRGBA( r,g,b,a )
	if color then
		color.r,color.g,color.b,color.a = r,g,b,a
	else
		color = Color.New( r,g,b,a )
	end
	return color
end

function M.ReColor(r,g,b,a)
	return this.RColor( nil,r,g,b,a )
end

function M.ReEnvironment(tp,intensity,...)
	intensity = tonumber( intensity ) or 0
	if tp == "gradient" then
		local _t = {...}
		if table.lens2(_t) < 9 then
			return
		end
		local _c_s = this.ReColor( _t[1],_t[2],_t[3] )
		local _c_e = this.ReColor( _t[4],_t[5],_t[6] )
		local _c_g = this.ReColor( _t[7],_t[8],_t[9] )
		CRSettingEx.SetAmbientGradient( _c_s,_c_e,_c_g,intensity )
	elseif tp == "color" then
		local _c = this.ReColor( ... )
		CRSettingEx.SetAmbientColor( _c,intensity )
	else
		CRSettingEx.SetAmbientSkybox( intensity )
	end
end

return M
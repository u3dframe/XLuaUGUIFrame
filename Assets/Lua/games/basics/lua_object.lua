--[[
	-- lua的基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]

local _str_beg = string.starts
local _str_end = string.ends
local _str_fmt = string.format
local _nPars = lensPars
local _m_ceill = math.ceil
local __tn = tonum
local __ti = toint
local __tf = todecimal
local __tf2 = todecimal2
local tb_ct = table.contains
local type = type

local super = LuaBasic
local M = class( "lua_object",super )

function M:pre_clean()
	super.pre_clean( self )
	self.callFunc = nil
end

function M:SetCallFunc(func)
	self.callFunc = func
	return self
end

-- 执行回调函数
function M:ExcuteCallFunc(data)
	if self.callFunc then
		self.callFunc(data or self)
	end
end

function M:Lens4Pars( ... )
	return _nPars( ... )
end

function M:AddSuppers( ... )
	local nLens = self:Lens4Pars( ... )
	if nLens <= 0 then return self end
	local _args = { ... }
	local _cls = self.class
	local _sups = _cls.__supers or {}
	local _ncls = #_sups
	for _, v in ipairs(_args) do
		if (type(v) == "table") and (not tb_ct( _sups,v )) then
			_sups[#_sups + 1] = v
		end
	end
	nLens = #_sups
	
	if nLens == _ncls then return self end

	_cls.__supers = _sups

	local mt = getmetatable(_cls)
	local _isOne,_isMore = false,(_ncls == 1)
	if _ncls == 0 then
		_isOne = nLens == 1
		_isMore = nLens > 1
	end

	_cls.super = _sups[1]
	if _isOne then
		mt.__index = _cls.super
	elseif _isMore then
		mt.__index = function(_, key)
			local supers = _cls.__supers
			for i = 1, #supers do
				local super = supers[i]
				if super[key] then return super[key] end
			end
		end
	end
	return self
end

function M:AddSupUIPubs()
	return self:AddSuppers(UIPubs)
end

function M:IsHasSupper(clsSupper)
	if not clsSupper or type(clsSupper) ~= "table" then return false end
	return tb_ct(self.class.__supers,clsSupper)
end

function M:SFmt( s_fmt,... )
	if _nPars( ... ) > 0 then
		return _str_fmt( s_fmt , ... )
	else
		return tostring( s_fmt )
	end
end

function M:ReSBegEnd( sSrc,sBeg,sEnd )
	if not sSrc then return "" end
	if sBeg and not _str_beg(sSrc,sBeg) then
		sSrc = _str_fmt("%s%s",sBeg,sSrc)
	end
	if sEnd and not _str_end(sSrc,sEnd) then
		sSrc = _str_fmt("%s%s",sSrc,sEnd)
	end
	return sSrc
end

function M:ReSEnd( sSrc,sEnd )
	return self:ReSBegEnd(sSrc,nil,sEnd)
end

function M:IsBeg( sSrc,sBeg )
	if not sSrc or not sBeg then return false end
	return _str_beg(sSrc,sBeg)
end

function M:IsEnd( sSrc,sEnd )
	if not sSrc or not sEnd then return false end
	return _str_end(sSrc,sEnd)
end

function M:MCeil( num )
	return _m_ceill( num )
end

function M:NPage( num,column )
	if (not num) or (num <= 0) or (not column) or (column <= 0) then return 0 end
	if num <= column then return 1 end
	return _m_ceill( num / column )
end

-- 保留m位小数
function M:TF( num,m,def )
	def = def or 0
	if (not num) then return def end
	return __tf( num,m,def )
end

-- 保留两位小数
function M:TF2( num,def )
	def = def or 0
	if (not num) then return def end
	return __tf2( num,def )
end

function M:TNum( num,def )
	def = (def or 0)
	if (not num) then return def end
	return __tn( num,nil,def )
end

function M:TInt( num,def )
	def = (def or 0)
	if (not num) then return def end
	return __ti( num,def )
end

return M
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

local super = LuaBasic
local M = class( "lua_object",super )

function M:Lens4Pars( ... )
	return _nPars( ... )
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

function M:MCeil( num )
	return _m_ceill( num )
end

function M:NPage( num,column )
	if (not num) or (num <= 0) or (not column) or (column <= 0) then return 0 end
	if num <= column then return 1 end
	return _m_ceill( num / column )
end

return M
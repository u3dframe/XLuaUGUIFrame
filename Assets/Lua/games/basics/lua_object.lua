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

local tb_has = table.contains
local _lbKeys = { "__cname","class","__supers","__create","__index","__newindex" }

local M = class( "lua_object" )
function M:ctor( )
end

function M:getCName()
	return self.__cname
end

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

function M:ReEvent4OnUpdate(isBind)
	self._lfUp = self._lfUp or handler_pcall(self,self._OnUpdate)
	if Event then
		Event.RemoveListener(Evt_Update,self._lfUp)
		if isBind == true then
			Event.AddListener(Evt_Update,self._lfUp);
		end
	end
end

function M:_OnUpdate(dt)
	self:OnUpdate(dt)
end
function M:OnUpdate(dt) end

function M:ReEvent4Self(isBind) end

function M:_clean()
	local _tpv
	for k, v in pairs(self) do
		if not tb_has(_lbKeys,k) then
			_tpv = type(v)
			if  _tpv ~= "function" then
				if (_tpv == "table") and (v ~= self) and type(v.clean) == "function" then
					v:clean()
				end
				self[k] = nil
			end
		end
	end
end

function M:pre_clean()
	self:ReEvent4OnUpdate(false)
	self:ReEvent4Self(false)
end

function M:on_clean()
end

function M:clean_end()
end

function M:clean()
	self:pre_clean()
	self:on_clean()
	self:_clean()
	self:clean_end()
end

return M
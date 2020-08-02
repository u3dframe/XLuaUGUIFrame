--[[
	-- lua的Basic类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-22 10:25
	-- Desc : 
]]

local _nPars,type = lensPars,type
local tb_has,tb_insert = table.contains,table.insert
local _lbKeys = { "__cname","class","super","__supers","__create","__index","__newindex","lbParent","isUping" }

local M = class( "lua_basic" )

function M.AddNoClearKeys( ... )
	local nLens = _nPars( ... )
	if nLens <= 0 then return end
	local _args = { ... }
	for _, v in ipairs(_args) do
		if not tb_has(_lbKeys,v) then
			tb_insert(_lbKeys,v)
		end
	end
end

function M:ctor( )
	self.isUping = true
end

function M:getCName()
	return self.__cname
end

function M:IsSameClass(clsName)
	return self.__cname == clsName
end

function M:_OnInit()
	if self.isInited then return end
	self.isInited = true
	self:OnInit();	
end

function M:OnInit()
end

function M:ReEvent4OnUpdate(isBind)
	if Event then
		if self._lfUp then
			Event.RemoveListener(Evt_Update,self._lfUp)
		end

		if isBind == true then
			self._lfUp = self._lfUp or handler_xpcall(self,self.__OnUpdate)
			Event.AddListener(Evt_Update,self._lfUp);
		end
	end
end

function M:__OnUpdate(dt,unscaledDt)
	if not self.isUping then return end
	self:_OnUpdate((self.isDelayTime == true) and dt or unscaledDt)
end

function M:_OnUpdate(dt)
	self:OnUpdate(dt)
end

function M:OnUpdate(dt)
end

function M:ReEvent4Self(isBind)
end

function M:RemoveEvents()
	self:ReEvent4OnUpdate(false)
	self:ReEvent4Self(false)
end

function M:_clean()
	local _tpv
	for k, v in pairs(self) do
		if not tb_has(_lbKeys,k) then
			_tpv = type(v)
			if  _tpv ~= "function" then
				if (_tpv == "table") and type(v.clean) == "function" and (v ~= self) then
					v:clean()
				end
				self[k] = nil
			end
		end
	end
end

function M:pre_clean()
	self:RemoveEvents()
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
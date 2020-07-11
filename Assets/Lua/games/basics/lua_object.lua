--[[
	-- lua的基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]

local tb_has = table.contains
local _lbKeys = { "__cname","class","__supers","__create","__index","__newindex" }

local M = class( "lua_object" )
function M:ctor( )
end

function M:getLuaName()
	return self.__cname
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
end

function M:clean()
	self:pre_clean()
	self:_clean()
	self:clean_end()
end

function M:clean_end()
end

return M
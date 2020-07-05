--[[
	-- lua的基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local M = class( "lua_object" )

function M:ctor( )
end

function M:getLuaName()
	return self.__cname
end

function M:_clean()
	local _tpv
	for k, v in pairs(self) do
		if k ~= "__cname" and k ~= "__supers" and k ~= "__create" and k ~= "__index" and k ~= "__newindex" then
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
--[[
	-- 对象池 : 借出，归还
	-- Author : canyon / 龚阳辉
	-- Date   : 2016-07-25 14:33
	-- Modify : 2020-08-30 08:50
]]

local type,xpcall = type,xpcall
local tb_remove,tb_insert = table.remove,table.insert

local M = class( "obj_pools" )

local _instance

function M.GetInstance()
	if nil == _instance then
		_instance = M.New()
	end
	return _instance
end

function M:AddClass( name,lbCls )
	self.__p_cls = self.__p_cls or {}
	self.__p_cls[name] = lbCls
end

function M:GetClass( name )
	if self.__p_cls then return self.__p_cls[name] end
end

function M:GetPool( name )
	if not name then return end
	self.__pools = self.__pools or {}
	local _pool = self.__pools[name] or {}
	self.__pools[name] = _pool
	return _pool
end

function M:BorrowObj(name, ... )
	local _pool = self:GetPool(name)
	local obj = tb_remove(_pool,1)

	if not obj then
		local _cls = self:GetClass( name )
		if type(_cls.IsObjPool) == "function" then
			obj = _cls.New()
		end
	end
	
	if obj then
		obj:ResetAndShow( ... )
	end
	
	return obj
end

function M:ReturnObj(obj)
	if type(obj) ~= "table" or type(obj.IsObjPool) ~= "function" then return end
	local _func = function() obj:ResetAndHide() end
	local _error = function()
		-- print(debug.traceback())
		obj:DoClear()
	end

	local state = xpcall(_func,_error)
	if state == true then
		local _pool = self:GetPool( obj:GetObjName() )
		if _pool then
			tb_insert( _pool,obj )
		end
	end
end

function M:GetGobjRootPool()
	local _gobj = LUGobj.CsFindGobj("/_Pools")
	if not _gobj then
		_gobj = LUGobj.CsNewGobj("_Pools")
	end
	return _gobj
end

return M

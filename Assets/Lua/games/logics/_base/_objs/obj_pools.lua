--[[
	-- 对象池 : 借出，归还
	-- Author : canyon / 龚阳辉
	-- Date   : 2016-07-25 14:33
	-- Modify : 2020-08-30 08:50
]]

local type,xpcall = type,xpcall
local tb_remove,tb_insert = table.remove,table.insert
local str_split = string.split
local _is_debug = false

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
	if not name then return end
	if self.__p_cls then return self.__p_cls[name] end
end

function M:AddClassBy( lbCls )
	if not lbCls or not lbCls.nm_pool_cls then return end
	local name = lbCls.nm_pool_cls
	self:AddClass( name,lbCls )
end

function M:GetClassBy( name,sp )
	if not name then return end
	if sp then
		local _arrs = str_split( name,sp )
		name = _arrs[1]
	end
	return self:GetClass( name )
end

function M:GetPool( name,isNew )
	if not name then return end
	self.__pools = self.__pools or {}
	local _pool = self.__pools[name]
	if isNew == true then
		_pool = _pool or {}
		self.__pools[name] = _pool
	end
	return _pool
end

function M:BorrowObj(name, ... )
	if not name or "" == name then
		if _is_debug then
			printInfo("=== BorrowObj name is nil")
		end
		return 
	end

	local _pool = self:GetPool( name,true )
	local obj = tb_remove(_pool,1)

	if not obj then
		local _cls = self:GetClassBy( name,"@@" )
		if type(_cls.IsObjPool) == "function" then
			obj = _cls.New()
			if _is_debug then
				printInfo("=== BorrowObj == [%s] = [%s] = [%s]",name,obj,_cls:getCName())
			end
		end
	end
	
	if obj then
		obj:SetObjPoolName( name )
		obj:ResetAndShow( ... )
	elseif _is_debug then
		printInfo( "=== BorrowObj is null obj ==[%s]",name )
	end
	
	return obj
end

function M:ReturnObj(obj)
	if type(obj) ~= "table" or type(obj.IsObjPool) ~= "function" then return end
	local _p_name = obj:GetObjPoolName()
	if not _p_name then
		if _is_debug then
			printInfo("=== ReturnObj pool name is nil == [%s]",obj:getCName())
		end
		return 
	end

	local _func = function() obj:ResetAndHide() end
	local _error = function()
		if _is_debug then
			printError(debug.traceback())
		end
		obj:Do_Clear()
	end

	local state = xpcall(_func,_error)
	if state == true then
		local _pool = self:GetPool( _p_name )
		if _pool ~= nil then
			if not table.contains( _pool,obj ) then
				obj:OnReback2Pool()
				tb_insert( _pool,obj )
			elseif _is_debug then
				printInfo("=== ReturnObj many times ==[%s] = [%s]",_p_name,obj:getCName())
			end
		elseif _is_debug then
			printInfo("=== ReturnObj not has pool ==[%s] = [%s]",_p_name,obj:getCName())
		end
	end
end

return M

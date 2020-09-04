--[[
	-- 对象池所需函数父类
	-- Author : canyon / 龚阳辉
	-- Date   : 2016-07-25 14:33
	-- Modify : 2020-08-30 09:05
]]

-- 对象池
objsPool = require("games/logics/_base/_objs/obj_pools").GetInstance()

local M = class( "obj_basic" )

function M.BorrowSelf( pname,... )
	return objsPool:BorrowObj( pname,... )
end

function M:IsObjPool()
	return true
end

function M:SetObjPoolName(objPoolName)
	self.objPoolName = objPoolName
end

function M:GetObjPoolName()
	return self.objPoolName
end

-- 重置属性
function M:Reset( ... )
end

-- pool调用函数 - 显示
function M:ResetAndShow( ... )
	self:Reset( ... )
	self:ShowView( true )
end

function M:GetRoot4Hide()
end

-- pool调用函数 - 隐藏
function M:ResetAndHide()
	local gobjParent = self:GetRoot4Hide()
	self:SetParent( gobjParent,true )
	self:ShowView( false )
end

-- pool调用函数 - 清除
function M:Do_Clear()
	self:On_Clear()
end

function M:On_Clear()
end

-- 外包调用函数
function M:ReturnSelf()
	objsPool:ReturnObj( self )
end

return M

--[[
	-- 对象池所需函数父类
	-- Author : canyon / 龚阳辉
	-- Date   : 2016-07-25 14:33
	-- Modify : 2020-08-30 09:05
]]

-- 对象池
objsPool = require("games/logics/_objs/obj_pools").GetInstance()

local M = class( "obj_basic")

function M:IsObjPool()
	return true
end

function M:SetObjName(objName)
	self.objName = objName
end

function M:GetObjName()
	return (self.objName or self.cfgAsset.objName) or self.strABAsset
end

-- 重置属性
function M:Reset( ... )
end

-- pool调用函数 - 显示
function M:ResetAndShow( ... )
	self:Reset( ... )
	self:ShowView( true )
end

-- pool调用函数 - 隐藏
function M:ResetAndHide()
	local gobjParent = objsPool:GetGobjRootPool()
	self:SetParent( gobjParent,true )
	self:ShowView( false )
end

-- pool调用函数 - 清除
function M:DoClear()
	self:OnClear()
end

function M:OnClear()
end

-- 外包调用函数
function M:ReturnSelf()
	objsPool:ReturnObj( self )
end

function M:BorrowSelf(...)
	objsPool:BorrowObj( self:GetObjName(),... )
end

return M

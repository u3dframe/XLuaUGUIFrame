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

-- 是否Brrow就显示对象
function M:IsReShow()
end

-- 重置属性
function M:Reset( ... )
end

-- pool调用函数 - 显示
function M:ResetAndShow( ... )
	self:Reset( ... )
	if self:IsReShow() then
		self:ShowView( true )
	end
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

-- pool调用函数 - 已归还
function M:OnReback2Pool()
end

-- 外包调用函数
function M:ReturnSelf()
	objsPool:ReturnObj( self )
end

function M:Disappear()
	self:OnPreDisappear()
	self:ReturnSelf()
	self:OnDisappear()
end

function M:OnPreDisappear()
end

function M:OnDisappear()
end

return M

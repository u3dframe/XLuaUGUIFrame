--[[
	-- ui cell 基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-15 13:45
	-- Desc : 单元格Cell的父对象
]]

local super,super2 = LCFabElement,UIPubs
local M = class( "uicell_base",super,super2 )

function M:ctor(gobj,comp)
	super.ctor( self,gobj,comp )
	super2.ctor( self )
	self:_OnInit()
end

function M:OnInit()
end

function M:SetActive( isActive )
	super.SetActive( self,isActive )
	self:ReEvent4Self(self.isActive)
end

function M:ShowViewByData(data,lbParent)
	local _isAcitve = (data ~= nil) or (self.isVwEmpty == true)
	self.data = data
	self.lbParent = lbParent
	self:SetActive(_isAcitve)
	if _isAcitve then
		if self.data == nil then
			self:OnVwEmpty()
		else
			self:OnView()
		end
	end
end

function M:OnView()
end

function M:OnVwEmpty()
end

return M
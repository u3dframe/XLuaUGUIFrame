--[[
	-- ui cell 基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-15 13:45
	-- Desc : 单元格Cell的父对象
]]

local super,super2 = LCFabElement,UIPubs
local M = class( "uicell_base",super,super2 )

function M:ctor(gobj,cfClick,lbParent,comp)
	super.ctor( self,gobj,comp )
	super2.ctor( self )
	self:SetCallFunc(cfClick)
	self.lbParent = lbParent

	if self.callFunc ~= nil then
		self.lbBtnSelf = self:_ClsUBtn().New(self.gobj,handler(self,self.OnClickSelf))
	end
	if self:IsGLife() then
		self.m_callShow = function() self:ReEvent4Self(true) end
		self.m_callHide = function() self:ReEvent4Self(false) end
	end
	self:_OnInit()
end

function M:OnClickSelf()
	self:ExcuteCallFunc(self)
end

function M:OnInit()
end

function M:ShowViewByData( data,... )
	local _isAcitve = (data ~= nil) or (self.isVwEmpty == true)
	self:SetData( data,... )
	self:SetActive(_isAcitve)
	if _isAcitve then
		if self.data == nil then
			self:OnVwEmpty()
		else
			self:OnView()
		end
	end
end

function M:SetData( data,... )
	self.data = data
end

function M:OnView()
end

function M:OnVwEmpty()
end

return M
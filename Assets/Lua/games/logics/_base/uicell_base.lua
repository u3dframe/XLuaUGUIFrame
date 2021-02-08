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
	self:SetLBParent(lbParent)

	if self.callFunc ~= nil then
		self.lbBtnSelf = self:NewBtnBy(self.gobj,handler(self,self.OnClickSelf))
	end
	self:_OnInit()
	if self:IsActiveInView() then
		self:ReEvent4Self(true)
	end
end

function M:OnCF_Show()
	self:ReEvent4Self(true)
end

function M:OnCF_Hide()
	self:RemoveEvents()
	self:OnHide()
end

function M:OnHide()
end

function M:OnClickSelf()
	self:ExcuteCallFunc(self)
end

function M:OnInit()
end

function M:ShowViewByData( data,... )
	self:SetData( data,... )
	local _isAcitve = (data ~= nil) or (self.isVwEmpty == true)
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

function M:SetIsPressScale(isScale)
	if self.lbBtnSelf then
		self.lbBtnSelf:SetIsPressScale( isScale )
	end
end

function M:SetRaycastTarget(isBl)
	if self.lbBtnSelf then
		self.lbBtnSelf:SetRaycastTarget( isBl )
	end
end

function M:SetGray4Cell(isBl,isGrayTxt,isSyncRT)
	if self.lbBtnSelf then
		self.lbBtnSelf:SetGray( isBl,isSyncRT,isGrayTxt )
	else
		self:SetGray( isBl,isGrayTxt )
	end
end

return M
--[[
	-- InputField 输入框
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-20 10:05
	-- Desc : 
]]

local super = LuBase
local M = class( "ugui_inputfield", super )

function M:ctor( obj,callFunc,val )
	assert(obj,"inpfield's obj is null")
	local gobj = obj.gameObject
	assert(gobj,"inpfield's gobj is null")
	super.ctor( self,gobj,"InputField" )
	
	self:_Init(callFunc,val)

	local _tmp = self.comp.textComponent
	if _tmp then
		self.lbTxtMain = self:NewTxtBy(_tmp)
	end
end

function M:GetTextVal()
	if self.lbTxtMain then
		return self.lbTxtMain:GetTextVal()
	end
	return ""
end

function M:SetText4Main(val)
	if self.lbTxtMain then
		return self.lbTxtMain:SetText(val)
	end
	return self
end

function M:SetUText4Main(val)
	if self.lbTxtMain then
		return self.lbTxtMain:SetUText(val)
	end
	return self
end

function M:SetOrFmt4Main( val, ... )
	if self.lbTxtMain then
		self.lbTxtMain:SetOrFmt( val, ... )
	end
	return self
end
return M
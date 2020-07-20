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

	local _tmp = self.comp.text
	if _tmp then
		self.lbTxtMain = self:_ClsUTxt().New(_tmp)
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
end

return M
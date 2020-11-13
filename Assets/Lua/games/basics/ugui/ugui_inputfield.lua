--[[
	-- InputField 输入框
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-20 10:05
	-- Desc : 
]]

local super,LUtils,tostring = LuBase,LUtils,tostring
local M = class( "ugui_inputfield", super )

function M:ctor( obj,val,callFunc )
	assert(obj,"inpfield's obj is null")
	local gobj = obj.gameObject
	assert(gobj,"inpfield's gobj is null")
	super.ctor( self,gobj,"InputField" )
	self.lf_ChgEnd = self.lf_ChgEnd or function()
		self:ExcuteCallFunc()
	end
	self.comp.onEndEdit:AddListener(self.lf_ChgEnd)
	self:_Init(callFunc,val)
end

function M:GetTextVal()
	if self.comp then
		return self.comp.text
	end
	return ""
end

function M:SetText4Main(val,isLoc)
	if self.comp then
		val = (isLoc == true) and LUtils.GetOrFmtLoczStr(val) or tostring(val)
		self.comp.text = val
	end
	return self
end

function M:SetOrFmt4Main( val, ... )
	if self.comp then
		val = LUtils.GetOrFmtLoczStr( val, ... )
		self.comp.text = val
	end
	return self
end

function M:RemoveListeners()
	if self.comp then
		self.comp.onEndEdit:RemoveAllListeners()
	end
end

function M:on_clean()
	self:RemoveListeners()
end

return M
--[[
	-- InputField 输入框
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-20 10:05
	-- Desc : 
]]

local super,CLocliz,tostring = LuBase,CLocliz,tostring
local M = class( "ugui_inputfield", super )

function M:ctor( obj,callFunc,val )
	assert(obj,"inpfield's obj is null")
	local gobj = obj.gameObject
	assert(gobj,"inpfield's gobj is null")
	super.ctor( self,gobj,"InputField" )
	
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
		val = (isLoc == true) and CLocliz.Get(val) or tostring(val)
		self.comp.text = val
	end
	return self
end

function M:SetOrFmt4Main( val, ... )
	if self.comp then
		local _lens = self:Lens4Pars( ... )
		_val = (_lens > 0) and CLocliz.Format( val,... ) or CLocliz.Get(val)
		self.comp.text = _val
	end
	return self
end
return M
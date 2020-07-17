--[[
	-- ugui的文本
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local super = LuBase
local M = class( "ugui_text", super )

function M:ctor( obj,com )
	assert(obj,"text's obj is null")
	local gobj = obj.gameObject
	assert(gobj,"text's gobj is null")
	if true == com then
		com = CTxt.Get(gobj)
	end
	super.ctor( self,gobj,com or "UGUILocalize" )
end

function M:GetTextVal()
	return self.comp.m_textVal
end

-- 本地化内容处理完毕
function M:SetText( val )
	self.comp:SetText(val);
end

-- 格式化文本,是 {0} 的模式，非lua的 %s
function M:SetTextFmt( val, ... )
	local _pars = {...}
	self.comp:SetText(val,unpack(_pars));
end

function M:SetUText( val )
	self.comp:SetUText(val)
end

return M
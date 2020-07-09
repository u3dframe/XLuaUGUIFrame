--[[
	-- ugui的文本
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local super = LuBase
local M = class( "ugui_text", super )

function M:ctor( gobj,com )
	super.ctor( self,gobj,com or "UGUILocalize" )
end

-- 本地化内容处理完毕
function M:setText( val )
	self.ucom:SetText(val);
end

-- 格式化文本,是 {0} 的模式，非lua的 %s
function M:setTextFmt( val, ... )
	local _pars = {...}
	self.ucom:SetText(val,unpack(_pars));
end

function M:setUText( val )
	self.ucom:SetUText(val)
end

return M
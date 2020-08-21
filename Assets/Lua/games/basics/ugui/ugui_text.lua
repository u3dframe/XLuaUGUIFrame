--[[
	-- ugui的文本
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local super,LUtils = LuBase,LUtils
local M = class( "ugui_text", super )

function M:ctor( obj,com )
	assert(obj,"text's obj is null")
	local gobj = obj.gameObject
	assert(gobj,"text's gobj is null")
	if true == com then
		com = CTxt.Get(gobj)
	end
	super.ctor( self,gobj,com or "UGUILocalize" )
	local _c = self.comp:GetColor()
	self.defColor = _c
	self.curColor = LUtils.RColor( nil,_c.r,_c.g,_c.b,_c.a )
end

function M:GetTextVal()
	return self.comp.m_textVal
end

-- 本地化内容处理完毕
function M:SetText( val )
	if val == nil or val == "" then
		val = 1
	end
	self.comp:SetText(val);
end

-- 格式化文本,是 {0} 的模式，非lua的 %s
function M:FmtText( val, ... )
	self.comp:Format( val,... );
end

function M:SetOrFmt( val, ... )
	if self:Lens4Pars( ... ) > 0 then
        self:FmtText( val,... )
    else
        self:SetText( val )
    end
end

function M:SetUText( val )
	if val == nil or val == "" then
		self:SetText( val )
		return
	end
	self.comp:SetUText(val)
end

function M:SetColor( r,g,b,a )
	local _c = LUtils.RColor( self.curColor,r,g,b,a )
	self.comp:SetColor(_c)
end

function M:RebackColor( )
	self:SetColor( self.defColor )
end

return M
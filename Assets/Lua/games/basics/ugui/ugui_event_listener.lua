--[[
	-- UGUI的Event事件监听者
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-11 16:05
	-- Desc : cs ugui event listener
]]

local handler = handler
local super = LuBase
local M = class( "ugui_event_listener", super )
local this = M

function M:ctor( obj,comp )
	assert(obj,"listener's obj is null")
	local gobj = obj.gameObject
	assert(gobj,"listener's gobj is null")
	if true == comp then
		comp = CEvtListener.Get(gobj)
	end
	super.ctor( self,gobj,comp or "UGUIEventListener" )
	self._hds = {}
end

function M:_ReEvt_Func(lfunc,obj)
	if obj then
		local _k = self:SFmt("%s_%s",obj,lfunc)
		lfunc = self._hds[_k] or handler(obj,lfunc)
		self._hds[_k] = lfunc
	end
	return lfunc
end

function M:ReEvt_BegDrag(lfunc,obj,isBind)
	lfunc = self:_ReEvt_Func( lfunc,obj )
	self.comp:onBegDrag("-",lfunc);
	if isBind == true then
		self.comp:onBegDrag("+",lfunc);
	end
end

function M:ReEvt_Draging(lfunc,obj,isBind)
	lfunc = self:_ReEvt_Func( lfunc,obj )
	self.comp:onDraging("-",lfunc);
	if isBind == true then
		self.comp:onDraging("+",lfunc);
	end
end

function M:ReEvt_EndDrag(lfunc,obj,isBind)
	lfunc = self:_ReEvt_Func( lfunc,obj )
	self.comp:onEndDrag("-",lfunc);
	if isBind == true then
		self.comp:onEndDrag("+",lfunc);
	end
end

function M:ReEvt_Drop(lfunc,obj,isBind)
	lfunc = self:_ReEvt_Func( lfunc,obj )
	self.comp:onDrop("-",lfunc);
	if isBind == true then
		self.comp:onDrop("+",lfunc);
	end
end

function M:ReEvt_Press(lfunc,obj,isBind)
	lfunc = self:_ReEvt_Func( lfunc,obj )
	self.comp:onPress("-",lfunc);
	if isBind == true then
		self.comp:onPress("+",lfunc);
	end
end

function M:ReEvt_PClick(lfunc,obj,isBind)
	lfunc = self:_ReEvt_Func( lfunc,obj )
	self.comp:onClick("-",lfunc);
	if isBind == true then
		self.comp:onClick("+",lfunc);
	end
end

return M
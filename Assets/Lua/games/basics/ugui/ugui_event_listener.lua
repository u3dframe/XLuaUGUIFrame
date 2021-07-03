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

function M.AddSyncDrag( uobj,destUObj )
	assert(uobj or destUObj,"listener's uobj is null")
	local _csEvt = CEvtListener.Get( uobj,false )
    if _csEvt then
        _csEvt:AddSyncDrag4EventTrigger( destUObj )
    end
end

function M:ctor( obj,comp )
	assert(obj,"listener's obj is null")
	if true == comp then
		comp = CEvtListener.Get(obj)
	end
	super.ctor( self,obj,comp or "UGUIEventListener" )
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
	self.comp:OnlyOnceCallBegDrag(lfunc,isBind == true)
end

function M:ReEvt_Draging(lfunc,obj,isBind)
	lfunc = self:_ReEvt_Func( lfunc,obj )
	self.comp:OnlyOnceCallDrag(lfunc,isBind == true)
end

function M:ReEvt_EndDrag(lfunc,obj,isBind)
	lfunc = self:_ReEvt_Func( lfunc,obj )
	self.comp:OnlyOnceCallEndDrag(lfunc,isBind == true)
end

function M:ReEvt_Drop(lfunc,obj,isBind)
	lfunc = self:_ReEvt_Func( lfunc,obj )
	self.comp:OnlyOnceCallDrop(lfunc,isBind == true)
end

function M:ReEvt_Press(lfunc,obj,isBind)
	lfunc = self:_ReEvt_Func( lfunc,obj )
	self.comp:OnlyOnceCallPress(lfunc,isBind == true)
end

function M:ReEvt_PClick(lfunc,obj,isBind)
	lfunc = self:_ReEvt_Func( lfunc,obj )
	self.comp:OnlyOnceCallClick(lfunc,isBind == true)
end

return M
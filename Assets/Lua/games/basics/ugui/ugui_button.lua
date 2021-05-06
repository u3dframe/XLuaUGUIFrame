--[[
	-- btn 按钮
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]

local _tn = tonumber
local super = LuBase
local M = class( "ugui_button", super )
local this = M

function M.CsIsFreezeAll(isAll)
	CBtn.isFreezedAll = (isAll == true)
end

function M.CsAddExcept( ... )
	local _ids,_id = {...}
	for _, v in ipairs(_ids) do
		_id = _tn(v) or v:GetInstanceID()
		_id = this:MFloor( _id )
		CBtn.AddExcept( _id )
	end
end

function M.CsRmExcept( ... )
	local _ids,_id = {...}
	for _, v in ipairs(_ids) do
		_id = _tn(v) or v:GetInstanceID()
		_id = this:MFloor( _id )
		CBtn.RemoveExcept( _id )
	end
end

function M:ctor( obj,callFunc,val,isNoScale )
	assert(obj,"btn's obj is null")
	local _tmp = CBtn.Get(obj)
	assert(_tmp,"btn's gobj is null")
	super.ctor( self,obj,_tmp )
	local function _funcClick(_gobj,pos)
		self:OnClickSelf(_gobj,pos)
	end
	_tmp.m_onClick = _funcClick

	self:_Init(callFunc,val)

	_tmp = (not isNoScale)
	self:SetRaycastTarget(true,_tmp)
	self:SetIsPressScale(_tmp)
	self:ReLmtClick( self.secLmt )
end

-- 限定下单击间隔时间
function M:ReLmtClick( sec )
	if (not self.secLmt) or (self.secLmt ~= sec) then
		sec = self:TNum( sec,0.1 )
		self.secLmt = sec
	end
	self.lmtSecClick = Time.time + sec;
end

-- 单击自身
function M:OnClickSelf(gobj,pos)
	if (not self.isRaycastTarget) or (self.lmtSecClick and self.lmtSecClick > Time.time) then
		return
	end
	self:VwCircle( true )
	self:ReLmtClick( self.secLmt )

	self.respName = ""
	if gobj then
		self.respName = gobj.name
	end

	self:ExcuteCallFunc()
	self:VwCircle( false )
end

function M:SetRaycastTarget( isBl,isNoSync )
	self.isRaycastTarget = isBl == true
	if not isNoSync then
		self:SetIsPressScale(self.isRaycastTarget)
	end
end

function M:SetIsPressScale( isBl )
	if not self.comp then
		return
	end

	isBl = isBl == true
	if isBl ~= self.isPressScale then
		self.isPressScale = isBl
		self.comp.m_isPressScale = isBl
	end
end

function M:SetIsSyncScroll( isBl )
	if not self.comp then
		return
	end

	isBl = isBl == true
	if isBl ~= self.isSyncScl then
		self.isSyncScl = isBl
		self.comp:IsSyncScroll(isBl)
	end
end

function M:SetIsPropagation( isBl )
	if not self.comp then
		return
	end

	isBl = isBl == true
	if isBl ~= self.isPropagation then
		self.isPropagation = isBl
		self.comp:IsPropagation(isBl)
	end
end

function M:SetGray( isBl,isSyncRT,isGrayTxt )
	super.SetGray( self,isBl,isGrayTxt )
	if isSyncRT == true then
		self:SetRaycastTarget(not isBl)
	end
end

return M
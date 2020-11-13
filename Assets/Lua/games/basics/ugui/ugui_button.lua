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
		CBtn.AddExcept(v)
	end
end

function M.CsRmExcept( ... )
	local _ids,_id = {...}
	for _, v in ipairs(_ids) do
		_id = _tn(v) or v:GetInstanceID()
		CBtn.RemoveExcept(v)
	end
end

function M:ctor( obj,callFunc,val,isNoScale )
	assert(obj,"btn's obj is null")
	local gobj = obj.gameObject
	assert(gobj,"btn's gobj is null")
	local _tmp = CBtn.Get(gobj)
	super.ctor( self,gobj,_tmp )
	_tmp.m_onClick = handler(self,self.OnClickSelf)

	self:_Init(callFunc,val)

	_tmp = (not isNoScale)
	self:SetRaycastTarget(true,_tmp)
	self:SetIsPressScale(_tmp)
end

-- 单击自身
function M:OnClickSelf(gobj,pos)
	if not self.isRaycastTarget then
		return
	end

	self.respName = ""
	if gobj then
		self.respName = gobj.name
	end

	self:ExcuteCallFunc()
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
	self:AddGray4Self()

	isBl = isBl == true
	if self.lbGray then
		self.lbGray:IsGrayAll( isBl,isGrayTxt )
	end

	if isSyncRT == true then
		self:SetRaycastTarget(not isBl)
	end

end

return M
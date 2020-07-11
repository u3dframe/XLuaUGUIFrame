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

function M:ctor( gobj,callFunc,val,isNoScale )
	assert(gobj,"btn ctor is null")
	local _tmp,_tmp2 = CBtn.Get(gobj)
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
		self.comp.m_isPressScale = self.isPressScale
	end
end

return M
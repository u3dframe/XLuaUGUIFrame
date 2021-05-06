--[[
	-- 置灰
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-17 10:35
	-- Desc : 
]]
local tostring,CGray = tostring,CGray
local super = LuBase
local M = class( "ugui_gray", super )

function M:ctor( obj )
	assert(obj,"gray's obj is null")	
	local _tmp = CGray.Get(obj)
	assert(_tmp,"gray's gobj is null")
	super.ctor( self,obj,_tmp )
end

function M:IsGrayTxt(isBl)
	isBl = (isBl == true)
	if self.isGrayTxt ~= isBl then
		self.isGrayTxt = isBl
		self.comp.m_isGrayTxt = isBl
	end
end

function M:IsClearExcept(isBl)
	isBl = (isBl == true)
	if self.isClearExcept ~= isBl then
		self.isClearExcept = isBl
		self.comp.m_isClearExceptNames = isBl
	end
end

function M:IsGray(isBl)
	isBl = (isBl == true)
	if self.isGray ~= isBl then
		self.isGray = isBl
		self.comp.m_isGray = isBl
	end
end

function M:IsGrayAll(isBl,isGrayTxt)
	isBl = (isBl == true)
	if isGrayTxt ~= nil then
		isGrayTxt = (isGrayTxt == true)
		if self.isGray ~= isBl and self.isGrayTxt ~= isGrayTxt then
			self.isGray = isBl
			self.isGrayTxt = isGrayTxt
			self.comp:IsGrayAll( isBl,isGrayTxt )
		end
	else
		self:IsGray( isBl )
	end
end

function M:IsRaycastTarget(isBl)
	isBl = (isBl == true)
	if self.isRaycastTarget ~= isBl then
		self.isRaycastTarget = isBl
		self.comp.m_isRaycastTarget = isBl
	end
end

function M:AddExceptName(name)
	if not name then return end
	self.comp:AddExceptName(tostring(name))
end

return M
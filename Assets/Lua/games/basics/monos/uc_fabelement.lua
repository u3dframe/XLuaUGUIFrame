--[[
	-- PrefabElement
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]

local super = LCFabBasic
local M = class( "lua_PrefabElement",super )

function M:ctor( obj,component,isNotSetCSCall )
	assert(obj,"element is null")
	if true == component then
		component = CPElement.Get(obj)
	end
	super.ctor(self,obj,component or "PrefabElement",isNotSetCSCall)
	self.isEleComp = CHelper.IsElement(self.comp)
end

function M:_GetCFComp()
	if self.isCanSetCSCall then
		return super._GetCFComp( self )
	end
end

function M:IsHasChild( elName )
	if not self.isEleComp then return end
	local _k = self:SFmt("__isHas_%s",elName)
	if not self[_k] then 
		self[_k] = self.comp:IsHasGobj(elName) 
	end
	return self[_k]
end

function M:GetElement( elName )
	if not self.isEleComp then return end
	local _k,_v = self:SFmt("__gobj_%s",elName)
	_v = self[_k]
	if not _v then
		local _k1 = self:SFmt("__trsf_%s",elName)
		_v = self[_k1]
		if _v then
			_v = _v.gameObject
		else
			_v = self.comp:GetGobjElement(elName) 
		end
		self[_k] = _v
	end
	return _v
end

function M:GetElementTrsf( elName )
	if not self.isEleComp then return end
	local _k,_v = self:SFmt("__trsf_%s",elName)
	_v = self[_k]
	if not _v then
		local _k1 = self:SFmt("__gobj_%s",elName)
		_v = self[_k1]
		if _v then
			_v = _v.transform
		else
			_v = self.comp:GetTrsfElement(elName) 
		end
		self[_k] = _v
	end
	return _v
end

function M:GetElementComponent( elName,strComp )
	if not self.isEleComp then return end
	local _k = self:SFmt("__com_%s_%s",elName,strComp)
	if not self[_k] then 
		self[_k] = self.comp:GetComponent4Element( elName,strComp ) 
	end
	return self[_k]
end

function M:ForeachElement( callFunc )
	if (not self.isEleComp) or (not callFunc) then return end
	self.comp:ForeachElement( callFunc )
end

function M:SetChildActive( elName,isActive )
	if not self.isEleComp then return end
	self.comp:SetActive(elName,isActive == true)
end

return M
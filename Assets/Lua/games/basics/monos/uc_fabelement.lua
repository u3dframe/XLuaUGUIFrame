--[[
	-- PrefabElement
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]

local super = LCFabBasic
local M = class( "lua_PrefabElement",super )

function M:makeElement( obj )
	local _isEl,_el = CHelper.IsElement(obj)
	if _isEl then
		_el = obj;
	end
	return M.New( obj,_el )
end

function M:ctor( obj,component )
	assert(obj,"element is null")
	if true == component then
		component = CPElement.Get(obj)
	end
	super.ctor(self,obj,component or "PrefabElement")
end

function M:IsHasChild( elName )
	local _k = self:SFmt("__isHas_%s",elName)
	if not self[_k] then 
		self[_k] = self.comp:IsHasGobj(elName); 
	end
	return self[_k]
end

function M:GetElement( elName )
	local _k = self:SFmt("__gobj_%s",elName)
	if not self[_k] then 
		self[_k] = self.comp:GetGobjElement(elName); 
	end
	return self[_k]
end

function M:GetElementComponent( elName,strComp )
	local _k = self:SFmt("__com_%s_%s",elName,strComp)
	if not self[_k] then 
		self[_k] = self.comp:GetComponent4Element( elName,strComp ); 
	end
	return self[_k]
end

function M:SetChildActive( elName,isActive )
	self.comp:SetActive(elName,isActive == true);
end

return M
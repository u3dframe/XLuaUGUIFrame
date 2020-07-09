--[[
	-- PrefabElement
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local str_format = string.format

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
	super.ctor(self,obj,component or "PrefabElement")
end

function M:IsHasChild( elName )
	local _k = str_format("__isHas_%s",elName)
	if not self[_k] then 
		self[_k] = self.comp:IsHasGobj(elName); 
	end
	return self[_k]
end

function M:GetElement( elName )
	local _k = str_format("__gobj_%s",elName)
	if not self[_k] then 
		self[_k] = self.comp:GetGobjElement(elName); 
	end
	return self[_k]
end

function M:GetElementComponent( elName,strComp )
	local _k = str_format("__com_%s_%s",elName,strComp)
	if not self[_k] then 
		self[_k] = self.comp:GetComponent4Element( elName,strComp ); 
	end
	return self[_k]
end

function M:SetChildActive( elName,isActive )
	self.comp:SetActive(elName,isActive == true);
end

return M
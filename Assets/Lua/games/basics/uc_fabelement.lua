--[[
	-- PrefabElement
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local str_format = string.format
local super = LuCFabBasic
local M = class( "lua_PrefabElement",super )

function M:ctor( obj )
	super.ctor(self,obj,"PrefabElement")
end

function M:IsHasGobj( elName )
	local _k = str_format("__isHas_%s",elName)
	if not self[_k] then 
		self[_k] = self.comp:IsHasGobj(elName); 
	end
	return self[_k]
end

function M:GetGobjElement( elName )
	local _k = str_format("__gobj_%s",elName)
	if not self[_k] then 
		self[_k] = self.comp:GetGobjElement(elName); 
	end
	return self[_k]
end

function M:GetComponent4Element( elName,strComp )
	local _k = str_format("__com_%s_%s",elName,strComp)
	if not self[_k] then 
		self[_k] = self.comp:GetComponent4Element(elName); 
	end
	return self[_k]
end

function M:SetActive4Element( elName,isActive )
	self.comp:SetActive(elName,isActive == true);
end

return M
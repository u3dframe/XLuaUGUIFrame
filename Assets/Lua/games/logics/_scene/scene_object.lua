--[[
	-- 场景对象
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local LES_Object = LES_Object

local super = SceneBase
local M = class( "scene_object",super )

function M:ctor(sobjType,nCursor,resCfg,...)
	self.cfgRes = resCfg; 
	super.ctor( self )
	self:SetSObjType( sobjType )
	self:SetCursor( nCursor )
end

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.abName = self.cfgRes.rsaddress
	return _cfg;
end

function M:OnViewBeforeOnInit()
	local _ot = self:GetSObjType()
	self:SetLayer(LES_Layer[_ot],true)
end


function M:SetSObjType(sobjType)
	self.sobjType = sobjType or LES_Object.Object
	return self
end

function M:GetSObjType()
	return self.sobjType
end

function M:SetCursor(nCursor)
	self.nCursor = nCursor
	return self
end

function M:GetCursor()
	return self.nCursor
end

return M
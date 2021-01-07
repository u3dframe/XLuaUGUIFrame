--[[
	-- UI Spine 对象
	-- Author : canyon / 龚阳辉
	-- Date : 2021-01-06 20:31
	-- Desc : 
]]

local type,tostring = type,tostring
local _vec3 = Vector3
local tb_lens = table.lens
local super = FabBase
local M = class( "ui_spine",super )

function M:ctor()
	super.ctor( self )
end

function M:BuilderUObj( uobj )
	return CEDUISpine.Builder( uobj )
end

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.layer = LE_UILayer.UTemp
	if self.data then
		local _ab = "sp_" .. tostring( self.data[1] )
		_cfg.abName = self:ReSBegEnd(_ab,"spines/_fabs/")
	end
	return _cfg;
end

function M:OnSetData(parent)
	local _obj = parent
	if type(parent) == "table" then
		_obj = parent.trsf
	end
	self.p_parent = _obj
	self.v3LScale = self.v3LScale or _vec3.one
	self.v3LPos = self.v3LPos or _vec3.zero
	self.v3LScale.x = self.data[2] or 1
	self.v3LScale.y = self.data[2] or 1
	self.v3LPos.x = (self.data[3] or 0) * 0.01
	self.v3LPos.y = (self.data[4] or 0) * 0.01
	self.v3LPos.z = (self.data[5] or 0) * 0.01

	self:InitAsset( self.cfgAsset )
end

function M:View(isShow,data,...)
	super.View( self,isShow,data,... )
end

function M:OnInit()
end

function M:OnShow()
	self.csEDComp:SetPars( self.p_parent,self.v3LScale,self.v3LPos )
end

return M
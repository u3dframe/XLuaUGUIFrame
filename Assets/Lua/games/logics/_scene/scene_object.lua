--[[
	-- 场景对象
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local E_Object,E_Layer = LES_Object,LES_Layer

local super,_evt = FabBase,Event
local M = class( "scene_object",super )
local this = M

this.nm_pool_cls = "p_cls_sobj_" .. tostring(E_Object.Object)

function M.Builder(nCursor,resid)
	this:GetResCfg( resid )
	local _p_name,_ret = this.nm_pool_cls .. "@@" .. resid

	_ret = this.BorrowSelf( _p_name,E_Object.Object,nCursor,resid )
	return _ret
end

function M:ctor()
	super.ctor( self )
end

function M:Reset(sobjType,nCursor,resid)
	if self.resid and resid and resid ~= self.resid then
		self:OnUnLoad()
	end
	self:InitAsset4Resid( resid )
	self:SetSObjType( sobjType )
	self:SetCursor( nCursor )
end

function M:OnViewBeforeOnInit()
	local _ot = self:GetSObjType()
	self:SetLayer(E_Layer[_ot],true)
end

function M:SetSObjType(sobjType)
	self.sobjType = sobjType or E_Object.Object
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

function M:GetResid()
	return self.resid
end

-- 设置阵营
function M:SetCamp( nCamp )
	self.n_camp = nCamp
	return self
end

function M:IsEnemy()
	if self.n_camp then return (self.n_camp == 1) end
	return true
end

function M:Reback()
	_evt.Brocast( Evt_Map_SV_RmvObj,self:GetCursor() )
end

function M:OnCF_OnDestroy()
	self:Reback()
end

return M
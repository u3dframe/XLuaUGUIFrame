--[[
	-- 场景对象
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local E_Object,E_Layer = LES_Object,LES_Layer
local tostring,tonumber = tostring,tonumber

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

-- 设置阵营
function M:SetCamp( nCamp )
	self.n_camp = nCamp
	return self
end

function M:IsEnemy()
	if self.n_camp then return (self.n_camp == 1) end
	return true
end

function M:SetWorldY(w_y)
	self.worldY = w_y or 0
end

function M:SvPos2MapPos( svX,svY )
	local _lb = self:GetSObjMapBox()
	if not _lb then return svX,svY end
	return _lb:SvPos2MapPos( svX,svY )
end

function M:SetPos(x,y)
	self:SetPosition ( x,self.worldY,y )
end

function M:SetPos_SvPos(x,y)
	x,y = self:SvPos2MapPos( x,y )
	self:SetPos ( x,y )
end

function M:LookPos(x,y)
	self:LookAt ( x,self.worldY,y )
end

function M:LookPos_SvPos(x,y)
	x,y = self:SvPos2MapPos( x,y )
	self:LookAt ( x,self.worldY,y )
end

function M:LookTarget(target_id,svX,svY)
	local _target = self:GetSObjBy( target_id )
	local _x,_z = 0,0
	if _target then
		local _pos = _target:GetPosition()
		_x,_z = _pos.x,_pos.z
	else
		_x,_z = self:SvPos2MapPos( svX,svY )
	end
	self:LookPos( _x,_z )
end

function M:SetSize( size )
	size = tonumber( size ) or 1
	if size ~= self.size then
		self.size = size
		self:SetLocalScale( size,size,size )
	end
end

function M:ReEvent4Self(isbind)
	_evt.RemoveListener(Evt_Map_SV_Skill_Pause, self.Pause, self)
	_evt.RemoveListener(Evt_Map_SV_Skill_GoOn, self.Regain, self)
	if (isbind)then
		_evt.AddListener(Evt_Map_SV_Skill_Pause, self.Pause, self)
		_evt.AddListener(Evt_Map_SV_Skill_GoOn, self.Regain, self)
	end
end

function M:Reback()
	_evt.Brocast( Evt_Map_SV_RmvObj,self:GetCursor() )
end

function M:OnCF_OnDestroy()
	self:Reback()
end

return M
--[[
	-- 场景对象
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-14 09:25
	-- Desc : 
]]

local E_Object,E_Layer = LES_Object,LES_Layer
local tostring,tonumber = tostring,tonumber
local unpack = unpack

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

-- 设置阵营
function M:SetCamp( nCamp )
	self.n_camp = nCamp
	return self
end

function M:IsEnemy()
	return (not self.n_camp) or (self.n_camp ~= 1)
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
		if _pos then
			_x,_z = _pos.x,_pos.z
		end
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

function M:ReSInfo( cfg )
	if self.csEDComp then
		self.csEDComp:ReSInfo()
	end
	if cfg then 
		local LUtils,MgrCamera = LUtils,MgrCamera
		if cfg.lightSource and cfg.lightColors then
			local _val = tonumber( cfg.lightIntensity ) or 0
			LUtils.ReEnvironment( cfg.lightSource,_val * 0.01,unpack(cfg.lightColors) )
		end

		if cfg.lightFog then
			LUtils.LFog( unpack(cfg.lightFog) )
		end

		if cfg.residSkybox then
			MgrCamera:ReSkybox( cfg.residSkybox )
		end

		if cfg.residPPFile then
			MgrCamera:RePPFile( cfg.residPPFile )
		end
		local _t,_type = cfg.postGFog
		_type = _t ~= nil and 1 or nil
		MgrCamera:RePGFog( _type,unpack(_t) )
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

function M:DoHurtEffect(svOne)
end

function M:Reback()
	_evt.Brocast( Evt_Map_SV_RmvObj,self:GetCursor() )
end

function M:OnCF_OnDestroy()
	self:Reback()
	super.OnCF_OnDestroy( self )
end

function M:DestroyObj(isNotImmediate)
	super.DestroyObj( self, not isNotImmediate)
end

return M
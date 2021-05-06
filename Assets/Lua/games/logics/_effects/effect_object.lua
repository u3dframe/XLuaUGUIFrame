--[[
	-- 特效对象
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-30 21:25
	-- Desc : 
]]

local super,super2 = FabBase,ClsEftBase
local _cLayer = L_SObj
local M = class( "effect_object",super,super2 )
local this = M
this.nm_pool_cls = "p_efct"

function M.Builder(idMarker,idTarget,resid,mount_point,isfollow,timeout,v3Offset,v3Angle)
	this:GetResCfg( resid )
	local _p_name,_ret = this.nm_pool_cls .. "@@" .. resid

	_ret = this.BorrowSelf( _p_name,idMarker,idTarget,resid,mount_point,isfollow,timeout,v3Offset,v3Angle )
	return _ret
end

function M.PreLoad(idMarker,idTarget,resid,lfOnceShow)
	local _ret_ = this.Builder( idMarker,idTarget,resid )
	_ret_:SetCallFunc( lfOnceShow )
	_ret_.lfOnShowOnce = function()
		local _lf = _ret_.callFunc
		_ret_.callFunc = nil
		_ret_:Disappear()

		if _lf then
			_lf()
		end
	end
	_ret_:Start()
	return _ret_
end

function M:ctor()
	super.ctor( self )
	super2.ctor( self )
	self.isUping = false
end

function M:Reset(idMarker,idTarget,resid,mount_point,isfollow,timeout,v3Offset,v3Angle)
	self.isUping,self.isDisappear,self.timeOut = nil
	if self.resid and resid and resid ~= self.resid then
		self:OnUnLoad()
	end
	self:InitAsset4Resid( resid )
	self:SetData( idMarker,idTarget,mount_point,isfollow,timeout,v3Offset,v3Angle )
end

function M:InitComp4OnLoad(gobj)
	return CParticleEx.Get( gobj )
end

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.isUpdate = true
	_cfg.isStay = true
	return _cfg
end

function M:OnSetData(idTarget,mount_point,isfollow,timeout,v3Offset,v3Angle)
	self.idTarget = idTarget
	self.mount_point = mount_point
	self.isFollow = isfollow == true
	timeout = (timeout or 1000)
	self.timeOut = (timeout > 0) and (timeout  * 0.001) or timeout
	self.v3Offset = v3Offset
	self.v3Angle = v3Angle
	self.curex_time = 0
end

function M:OnViewBeforeOnInit()
	self.start_time = Time.time
	self.curr_time = 0
	self.isDelayTime = true
	local _sid,_tid = self.idTarget
	local cfgEft = self:GetCurrCfgEft()
	if cfgEft and cfgEft.is_link == 1 then
		_sid = self.idCaster or self.data
		_tid = self.idTarget
	end
	local _lbTarget = self:GetSObjBy( _sid )
	if not _lbTarget then
		-- 立即销毁 ???
		return
	end

	local _lbT_Point
	if self.mount_point then
		_lbT_Point = _lbTarget:GetHookPoint( self.mount_point )
	end
	_lbT_Point = _lbT_Point or _lbTarget

	-- 跟随
	self:SetParent(_lbT_Point.trsf,true)
	
	if self.v3Offset then
		self:AddLocalPosByV3(self.v3Offset)
	end

	if self.v3Angle then
		self:SetLocalEulerAngles( self.v3Angle.x,self.v3Angle.y,self.v3Angle.z )
	end
	
	if not self.isFollow then
		local _x,_y,_z
		if self.v3Angle then
			_x,_y,_z = self:GetEulerAngles()
		end
		self:SetParent()
		self:SetLocalScale(1)
		if self.v3Angle then
			self:SetEulerAngles(_x,_y,_z)
		end
	end
	-- self:SetLayer( _cLayer,true )

	self._link2id = nil
	if _tid then
		local _sobjLine = self:GetSObjBy( _tid )
		if _sobjLine then
			self._link2id = _tid
		end
	end
	self.isUping = true
end

function M:OnInit()
	self.csCurve = CCurveEx.GetInChild(self.gobj)
end

function M:OnShow()
	self.comp.speedRate = self:GetSpeed()
	self.comp.isPause = (self.isPause == true)
	if self.csCurve then
		self.csCurve.m_indexCurve = -1
	end

	if self._link2id and not self.lbTrsfOffset then
		local _obj = self:FindGobj("offset")
		if _obj then
			self.lbTrsfOffset = self:NewTrsfBy( _obj,true )
		end
	end
end

function M:GetCurrCfgEft()
	if self.cfg_e_id then
		return MgrData:GetCfgSkillEffect( self.cfg_e_id )
	end
end

function M:GetSpeed2()
	if self.data then
		local _maker = self:GetSObjBy( self.data )
		if _maker and _maker:GetCursor() and _maker.GetCurrAniSpeed then
			return _maker:GetCurrAniSpeed()
		end
	end
	return 1
end

function M:ReEvent4Self(isbind)
	super2.ReEvent4Self( self,isbind )
end

function M:OnUpdateLoaded(dt)
	if super2.OnCurrUpdate( self,dt ) then
		self:OnUp_Link( dt )
	end
end

-- 暂停
function M:Pause()
	if not super.Pause( self ) then
		return
	end
	if self.comp then
		self.comp.isPause = true
	end
	return true
end

-- 恢复
function M:Regain()
	super.Regain( self )
	if self.comp then
		self.comp.isPause = false
	end
end

function M:SetSpeed( speed )
	super2.SetSpeed( self,speed )
	if self.comp then
		self.comp.speedRate = self.speed
	end
end

function M:StartBy( out_sec,speed )
	self:ResetTimeOut( out_sec )
	self:SetSpeed( speed )
	self:ShowView( true )
end

function M:Start(speed)
	self:StartBy( self.timeOut,speed or self.speed )
end

return M
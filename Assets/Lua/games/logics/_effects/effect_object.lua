--[[
	-- 特效对象
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-30 21:25
	-- Desc : 
]]

local super,_evt = FabBase,Event
local M = class( "effect_object",super )
local this = M
this.nm_pool_cls = "p_cls_e"

function M.Builder(resid,idMarker,idTarget,mount_point,timeout,isfollow)
	this:GetResCfg( resid )
	local _p_name,_ret = this.nm_pool_cls .. "@@" .. resid

	_ret = this.BorrowSelf( _p_name,resid,idMarker,idTarget,mount_point,timeout,isfollow )
	return _ret
end

function M.BuilderAndShow(resid,idMarker,idTarget,mount_point,timeout,isfollow)
	local _ret = this.Builder( resid,idMarker,idTarget,mount_point,timeout,isfollow )
	_ret:ShowView( true )
	return _ret
end

function M:ctor()
	super.ctor( self )
	self.isUping = false
end

function M:Reset(resid,idMarker,idTarget,mount_point,timeout,isfollow)
	if self.resid and resid and resid ~= self.resid then
		self:OnUnLoad()
	end
	self:InitAsset4Resid( resid )
	self.isUping = false
	self.isDisappear,self.timeOut = nil
	self:SetData( idMarker,idTarget,mount_point,timeout,isfollow )
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

function M:OnSetData(idTarget,mount_point,timeout,isfollow)
	self.idTarget = idTarget
	self.mount_point = mount_point
	self.timeOut = (timeout or 1000) / 1000
	self.isFollow = isfollow == true
end

function M:ReEvent4Self(isbind)
	_evt.RemoveListener(Evt_Map_SV_Skill_Pause, self.Pause, self)
	_evt.RemoveListener(Evt_Map_SV_Skill_GoOn, self.Regain, self)
	if (isbind)then
		_evt.AddListener(Evt_Map_SV_Skill_Pause, self.Pause, self)
		_evt.AddListener(Evt_Map_SV_Skill_GoOn, self.Regain, self)
	end
end

function M:OnViewBeforeOnInit()
	self.start_time = Time.time
	self.currt_time = 0
	self.isDelayTime = true
	self.speed = self:GetSpeed()
	local idTarget = self.idTarget
	if not idTarget then 
		-- 立即销毁 ???
		return 
	end

	local _lbTarget = self:GetSObjBy( idTarget )
	if not _lbTarget then
		-- 立即销毁 ???
		return
	end

	local _lbT_Point
	if self.mount_point then
		_lbT_Point = _lbTarget:NewTrsf(self.mount_point,true)
	end
	if not _lbT_Point then
		_lbT_Point = _lbTarget
	end

	
	local _cfgEft = self.cfgRes
	if not _cfgEft then 
		-- 立即销毁 ???
		return 
	end
	
	-- 跟随
	self:SetParent(_lbT_Point.trsf,true)
	if not self.isFollow then
		self:SetParent()
		self:SetLocalScale(1)
	end

	self.isUping = true
end

function M:OnShow()
	self.comp.speedRate = self.speed or 1
	self.comp.isPause = (self.isPause == true)
end

function M:GetSpeed()
	if self.data then
		local _maker = self:GetSObjBy( self.data )
		if _maker and _maker:GetCursor() and _maker.GetCurrAniSpeed then
			return _maker:GetCurrAniSpeed()
		end
	end
	return 1
end

function M:OnUpdateLoaded(dt)
	if self.isPause then
		return
	end
	
	if (self.isDisappear == true) then
		self.isDisappear,self.timeOut = nil
		self.isUping = false
		self:ReturnSelf()
	end

	self.currt_time = self.currt_time + dt * self.speed
	if self.timeOut and self.timeOut > 0  then
		if self.timeOut <= self.currt_time then
			self.isDisappear = true			
		end
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

function M:ResetTimeOut( time_out_sec )
	self.timeOut = time_out_sec
	if self.timeOut and self.timeOut > 0 then
		self.currt_time = 0
	end
end

return M
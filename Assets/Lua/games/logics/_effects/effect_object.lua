--[[
	-- 特效对象
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-30 21:25
	-- Desc : 
]]

local super,_evt = FabBase,Event
local M = class( "effect_object",super )
local this = M

function M.Builder(idMarker,resid,idTarget,mount_point,timeout,isfollow)
	local _cfg = this:GetResCfg( resid )
	local _ret = this.New():InitAsset4Resid( resid )
	_ret:SetData( idMarker,idTarget,mount_point,timeout,isfollow )
	_ret:ShowView( true )
	return _ret
end

function M:ctor()
	super.ctor( self )
	self.isUping = false
end

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.isUpdate = true
	-- _cfg.isStay = true
	return _cfg
end

function M:OnSetData(idTarget,mount_point,timeout,isfollow)
	self.idTarget = idTarget
	self.mount_point = mount_point
	self.timeOut = (timeout or 1000) / 1000
	self.isFollow = isfollow == true
end

function M:OnViewBeforeOnInit()
	self.start_time = Time.time
	self.currt_time = 0
	self.isDelayTime = true
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

function M:OnUpdateLoaded(dt)
	self.currt_time = self.currt_time + dt
	if self.timeOut  then
		if self.timeOut <= self.currt_time then
			self.isUping = false
			self:Destroy()
		end
	end
end

return M
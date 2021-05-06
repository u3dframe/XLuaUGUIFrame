--[[
	-- UI 特效对象
	-- Author : canyon / 龚阳辉
	-- Date : 2021-01-04 14:27
	-- Desc : 
]]

local _vec3,type = Vector3,type
local _v3_0,_v3_1 = _vec3.zero,_vec3.one
local super,super2 = FabBase,ClsEftBase
local M = class( "ui_effect",super,super2 )
local this = M
this.nm_pool_cls = "p_uieft"

function M.Builder(resid,parent,timeout,v3LocPos,v3LocScale)
	this:GetResCfg( resid )
	local _p_name,_ret = this.nm_pool_cls .. "@@" .. resid

	_ret = this.BorrowSelf( _p_name,resid,parent,timeout,v3LocPos,v3LocScale )
	_ret.curr_time = 0
	return _ret
end

function M:ctor()
	super.ctor( self )
	super2.ctor( self )
	self.isUping = false
end

function M:BuilderUObj( uobj )
	return CEDUIEffect.Builder( uobj )
end

function M:Reset(resid,parent,timeout,v3LocPos,v3LocScale)
	self.isUping,self.isDisappear,self.timeOut = nil
	if self.resid and resid and resid ~= self.resid then
		self:OnUnLoad()
	end
	self:InitAsset4Resid( resid )
	self:SetData( resid,parent,timeout,v3LocPos,v3LocScale )
end

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.abName =  self:ReSBegEnd( _cfg.abName,"prefabs/uis/" )
	_cfg.isUpdate = true
	return _cfg
end

function M:OnSetData(parent,timeout,v3LocPos,v3LocScale)
	local _obj = parent
	if type(parent) == "table" then
		_obj = parent.trsf
	end
	self.p_parent = _obj
	timeout = (timeout or 0)
	self.timeOut = timeout
	if timeout > 0 then
		self.timeOut = self.timeOut  * 0.001
	end
	self.v3LocPos = v3LocPos or _v3_0
	self.v3LocScale = v3LocScale or _v3_1
end

function M:OnInit()
	if self.timeOut and self.timeOut == 0 then
		self.timeOut = self.csEDComp.m_maxTime
	end
end

function M:OnShow()
	self.csEDComp:SetPars( self.p_parent,self.v3LocPos,self.v3LocScale )
	self.isDelayTime = true
	self.isUping = true
end

function M:ReEvent4Self(isbind)
end

function M:OnUpdateLoaded(dt)
	super2.OnCurrUpdate( self,dt )
end

function M:ResetTimeOut( time_out_sec )
	self.timeOut = time_out_sec
	if self.timeOut and self.timeOut > 0 then
		self.curr_time = 0
	end
end

function M:Start()	
	self:ShowView( true )
end

return M
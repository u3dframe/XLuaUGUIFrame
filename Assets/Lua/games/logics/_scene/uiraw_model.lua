--[[
	-- UI上面展示模型
	-- Author : canyon / 龚阳辉
	-- Date : 2020-11-30 10:05
	-- Desc : 
]]
local tonumber,type,tostring = tonumber,type,tostring
local super,evt = FabBase,Event
local _cLayer = L_SObj
local M = class( "uipart_model",super )
local this = M
this.nm_pool_cls = "up_model"
this.n_x = 0
this.n_y = 1000
this.n_every_x = 300
this.n_every_y = 20000
this.n_max_x = this.n_every_x * 5
this.n_max_y = this.n_every_y * 101

function M.Builder(nCursor,_,parent)
	local _ret = this.BorrowSelf( this.nm_pool_cls,nCursor,parent )
	return _ret
end

function M:Reset(nCursor,parent)
	self.p_parent = parent
	self:SetCursor( nCursor )
end

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.abName = "model/modelui"
	_cfg.strComp = "UGUIModel";
	_cfg.layer = LE_UILayer.Default
	return _cfg;
end

function M:OnInit()
	self.lbNode = self:NewTrsf("ModelNode")
	self._lfCallLoadAsset = handler(self,self._OnCallLoaded)
	local _temp = self:GetElement("ModelWrap")
	if _temp then
		self.trsfModelWrap = _temp.transform
	end
	self:SetParent( self.p_parent,true )
	local _x,_y = self._x1,self._y1
	if not _x or not _y then
		_x,_y = self:CalcNodeXY()
	end
	self._x1,self._y1 = _x,_y
	self.lbNode:SetLocalPosition( _x,_y,0 )
end

function M:OnShow()
	self:ReViewModle( self.heroid )
	self:ReRawWH( self.rawW,self.rawH )
	self:ReSfwer( self.s_distance,self.s_height,self.s_offHeight )
end

function M:OnDestroy()
	self._lfCallLoadAsset = nil
	self:_OnUnLoadAsset()
	self:Disappear()
end

function M:ReHeroid(heroid)
	local _cfgHero = MgrData:GetOneData( "hero",heroid )
	assert(_cfgHero,"=== hero cfg is null,by hid = " .. tostring(heroid))
	if self.heroid and heroid then
		if heroid == self.heroid then
			return
		end
		self:_OnUnLoadAsset()
	end
	self._x1,self._y1 = self:CalcNodeXY()
	self:InitAsset4Resid( _cfgHero.resource )
	local _abName = self.cfgRes.rsaddress
	self.m_abname = self:ReFabABName( _abName )
	self.heroid = heroid
end

function M:ReViewModle(heroid)
	self:ReHeroid( heroid )
	if self:IsLoadedAndShow() then
		self.lbAsset = self.lbAsset or self:NewAssetABName( self.m_abname,LE_AsType.Fab,self._lfCallLoadAsset )
	end
	return self
end

function M:_OnCallLoaded(isNoObj,_,_s)	
	if isNoObj then
		return
	end
	local _c = _s.csEDComp:GetComponent("CharacterController")
	if _c then
		M.CsDestroy( _c,true )
	end
	self.lbAsset = self.lbAsset or _s
	self.lbAsset:SetParent( self.trsfModelWrap,true,true )
end

function M:_OnUnLoadAsset()
	local lbObj = self.lbAsset
	self.lbAsset = nil
	if lbObj then
		lbObj:OnUnLoad()
	end
end

function M:ReRawWH(w,h)
	self.rawW = tonumber( w ) or 0
	self.rawH = tonumber( h ) or 0

	if self:IsInitComp() then
		self.comp:ReRawWH( self.rawW,self.rawH )
	end
	return self
end

function M:ReSfwer(distance,height,offHeight)
	self.s_distance = tonumber( distance ) or 3.9
	self.s_height = tonumber( height ) or 1.78
	self.s_offHeight = tonumber( offHeight ) or 0.86

	if self:IsInitComp() then
		self.comp:ReSfwer( self.s_distance,self.s_height,self.s_offHeight )
	end
	return self
end

function M:ReModelLocalScale(scale)
	scale = tonumber( scale ) or 50
	if scale == self.mdScale then
		return
	end
	self.mdScale = scale
	if self:IsInitComp() then
		self.comp:ReModelLocalScale( self.mdScale )
	end
	return self
end

function M:CalcNodeXY()
	local _x,_y = this.n_x,this.n_y;
	this.n_x = this.n_x + this.n_every_x
	if this.n_x >=  this.n_max_x then
		this.n_y = this.n_y + this.n_every_y
		this.n_x = 0
	end
	if this.n_y >=  this.n_max_y then
		this.n_y = 0
		this.n_x = 0
	end
	return _x,_y
end

return M
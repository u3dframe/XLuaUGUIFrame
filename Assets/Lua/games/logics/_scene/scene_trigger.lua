--[[
	-- 场景对象 - 机关，陷进，触发器
	-- Author : canyon / 龚阳辉
	-- Date : 2020-11-07 09:35
	-- Desc : 
]]

local E_Object = LES_Object
local E_CEType = LES_Ani_Eft_Type
local MgrData,Vector2 = MgrData,Vector2
local tb_insert = table.insert
local m_max = math.max
local super,_evt = SceneObject,Event
local M = class( "scene_trigger",super )
local this = M

this.nm_pool_cls = "p_cls_sobj_" .. tostring(E_Object.Trigger)

function M.Builder(nCursor,resid)
	this:GetResCfg( resid )
	local _p_name,_ret = this.nm_pool_cls .. "@@" .. resid

	_ret = this.BorrowSelf( _p_name,E_Object.Trigger,nCursor,resid )
	return _ret
end

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.isUpdate = true
	_cfg.isStay = true
	return _cfg
end

function M:OnSetData(svData)
	self.svData,self.tgrType,self.tgrSize = svData
	self.chgTime,self.chgTInval,self.chgTCur = nil
	self.chgDiff,self.chgIndex = nil
	if self.data then
		local cfgEft = MgrData:GetCfgSkillEffect( self.data.cast_effect )
		self.tgrType = cfgEft.type
		self.tgrSize = (cfgEft.size or 100) * 0.01
		self.tgrSize_o1 = 1 / self.tgrSize
		self.chgTime = (cfgEft.chg_time or 600) * 0.001
	end
end

function M:OnShow()
	-- self:SetGName(self:GetCursor())
	local _sd = self.svData
	local _cx,_cy = self:SvPos2MapPos( _sd.x,_sd.y )
	self:SetPos( _cx,_cy )
	
	if _sd.targety and _sd.targetx then
		local _tx,_ty = self:SvPos2MapPos( _sd.targetx,_sd.targety )
		self:LookPos( _tx,_ty )
		if (E_CEType.TriggerMore == self.tgrType) then
			if not self.lb_tgs then
				self.lb_tgs = {}
				_sd = self:FindGobj("offset/000")
				if _sd then
					tb_insert(self.lb_tgs,self:NewTrsfBy( _sd ))
				end
				self.nSizeTgs = #self.lb_tgs
			end
			if self.nSizeTgs <= 0 then
				return
			end

			local _diff = 0
			if _tx ~= _cx or _ty ~= _cy then
				local _d2 = Vector2(_tx -  _cx,_ty - _cy)
				_diff = self:MFloor((_d2.magnitude * self.tgrSize_o1 + 0.5))
			end

			local len = m_max(_diff,self.nSizeTgs)
			for i = 2 , len do
				if i > self.nSizeTgs then
					_sd = self.lb_tgs[1]:Clone()
					_sd = self:NewTrsfBy( _sd )
					tb_insert(self.lb_tgs,_sd)
					_sd:SetActive( false )
					_sd:SetLocalPosition(0,0,(i - 1) * self.tgrSize)
				end
			end
			self.nSizeTgs = #self.lb_tgs

			if _diff > 1 then
				self.chgDiff = _diff
				self.chgIndex = 1
				self.chgTInval = self.chgTime / _diff
				self.chgTCur = 0
			end
		end
	end
end

function M:OnHide()
	for i = 2 , self.nSizeTgs do
		self.lb_tgs[i]:SetActive( false )
	end
end

function M:OnUpdateLoaded(dt)
	if self.isPause then
		return
	end
	
	if (self.isDisappear == true) then
		self:Disappear()
	end

	if self.chgDiff and self.chgIndex and self.chgDiff > self.chgIndex  then
		self.chgTCur = self.chgTCur + dt
		if self.chgTCur >= self.chgTInval then
			self.chgTCur = self.chgTCur - self.chgTInval
			self.chgIndex = self.chgIndex + 1
			self.lb_tgs[self.chgIndex]:SetActive( true )
		end
	end
end

return M
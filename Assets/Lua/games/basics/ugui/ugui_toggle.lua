--[[
	-- toggle
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-10 13:25
	-- Desc : 
]]
local super = LuBase
local M = class( "ugui_toggle", super )
local this = M

function M:ctor(uniqueID,gobj,callFunc,val,isNoCall4False)
	super.ctor( self,gobj,"Toggle" )
	self.uniqueID = uniqueID
	isNoCall4False = isNoCall4False == true
	self._lfChanged = self._lfChanged or handler(self,self.OnValueChanged)

	if self.comp then
		self.isOn = self.comp.isOn
		self.isFirst = self.isOn
	end

	self:SetIsCanCall(not isNoCall4False)
	self:_Init(callFunc,val)
	self:AddListener(callFunc)
end

function M:SetIsOn(isOn)
	isOn = isOn == true
	if self.comp then
		local _preIsOn = self.comp.isOn
		if _preIsOn ~= isOn then
			self.comp.isOn = isOn
		elseif self.isValChg and self.isFirst then
			self.isFirst = nil
			self:OnValueChanged(isOn)
		end
	end

	if not (self.isValChg and self.comp) then
		self.isOn = isOn
	end
end

function M:OnValueChanged( isState )
	self.isOn = isState
	if self.isOn or self.isCanCall then
		self:ExcuteCallFunc()
	end
	self:SetActiveDef(not self.isOn)
end

function M:SetIsCanCall( isCanCall )
	self.isCanCall = isCanCall == true
end

function M:AddListener(func)
	self.isValChg = func ~= nil
	if self.isValChg then
		self.comp.onValueChanged:AddListener(self._lfChanged)
	end
	self:SetCallFunc(func)
end

function M:RemoveListeners()
	if self.comp then
		self.comp.onValueChanged:RemoveAllListeners()
	end
end

function M:RebindClick(callFunc)
	self.callFunc = callFunc
	self.lbBtn = self.lbBtn or LuBtn.New(self.gobj)
	self._lfuncBtn = self._lfuncBtn or function() self:OnValueChanged(not self.isOn) end
	self.lbBtn:SetCallFunc(self._lfuncBtn)
	self:RemoveListeners()
end

function M:SetActiveDef(isActive)
	self:SetActiveSelect(isActive)
end

function M:on_clean()
	self:RemoveListeners()
end

return M
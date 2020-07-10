--[[
	-- toggle
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-10 13:25
	-- Desc : 
]]

local _tn = tonumber
local _clsEle,_clsGobj,_csTxt = LCFabElement,LUGobj,LuText
local super = LuBase
local M = class( "ugui_toggle", super )
local this = M

function M:ctor(gobj,uniqueID,valStr,callFunc,isNoCall4False)
	self.gobj = gobj.gameObject;
	self.uniqueID = uniqueID;
	self.callFunc = callFunc;
	self.isValChg = callFunc ~= nil;

	self.togObj = self.gobj:GetComponent("Toggle");
	if self.togObj then
		self.isOn = self.togObj.isOn;
		self.isFirst = self.isOn;
		if self.isValChg then
			self.togObj.onValueChanged:AddListener(function (state)
				self:OnValueChanged(state);
			end);
		end
	end

	local uiCom = self.gobj:GetComponent("UIComponent");
	if uiCom then
		self.txtVal = uiCom:GetComponent("Label","Text");
		self:SetTextVal(ReStr(valStr));

		self.gobjDef = uiCom:GetGameObject("Def");
	end

	self.uCom = uiCom;  -- 提供外部使用

	isNoCall4False = isNoCall4False == true
	self:SetIsCanCall(not isNoCall4False);
end

-- 执行回调函数
function M:ExcuteCallFunc()
	if self.callFunc then
		self.callFunc(self);
	end
end

function M:SetIsOn(isOn)
	isOn = isOn == true;
	if self.togObj then
		local _preIsOn = self.togObj.isOn;
		if _preIsOn ~= isOn then
			self.togObj.isOn = isOn;
		elseif self.isValChg and self.isFirst then
			self.isFirst = nil;
			self:OnValueChanged(isOn);
		end
	end

	if not (self.isValChg and self.togObj) then
		self.isOn = isOn;
	end

end

function M:OnValueChanged( isState )
	self.isOn = isState;
	if self.isOn or self.isCanCall then
		self:ExcuteCallFunc();
	end
	self:SetActiveDef(not self.isOn);
end

function M:SetIsCanCall( isCanCall )
	self.isCanCall = isCanCall == true;
end

function M:SetTextVal(valStr)
	if self.txtVal then
		valStr = valStr or "";
		if "" ~= valStr then
			valStr = ReStr(valStr);
		end
		self.strVal = valStr;
		self.txtVal.text = valStr;
	end
	return self;
end

function M:RemoveListeners()
	if self.togObj then
		self.togObj.onValueChanged:RemoveAllListeners();
	end
end

function M:RebindClick(callFunc)
	self.callFunc = callFunc;
	local csIBtn = IButton.Get(self.gobj);
	csIBtn.clickCallBack = function ()
		self:OnValueChanged(not self.isOn);
	end
end

function M:SetActiveDef(isActive)
	if self.gobjDef then
		self.gobjDef:SetActive(isActive == true);
	end
end

return M
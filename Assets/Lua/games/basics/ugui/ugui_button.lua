--[[
	-- ugui的文本
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]

local _tn = tonumber
local _clsEle,_clsGobj,_csTxt = LCFabElement,LUGobj,LuText
local super = LuBase
local M = class( "ugui_button", super )
local this = M

function M.IsFreezeAll(isAll)
	CBtn.isFreezedAll = (isAll == true)
end

function M.AddExcept( ... )
	local _ids,_id = {...}
	for _, v in ipairs(_ids) do
		_id = _tn(v) or v:GetInstanceID();
		CBtn.AddExcept(v)
	end
end

function M.RmExcept( ... )
	local _ids,_id = {...}
	for _, v in ipairs(_ids) do
		_id = _tn(v) or v:GetInstanceID();
		CBtn.RemoveExcept(v)
	end
end

function M:ctor( gobj,callFunc,val,isNoScale )
	local _tmp = CBtn.Get(gobj)
	super.ctor( self,gobj,_tmp )
	self.callFunc = callFunc;
	_tmp.m_onClick = handler(self,self.OnClickSelf)

	_tmp = self:GetComponent("PrefabElement");
	if _tmp then
		_tmp = _clsEle.New(_tmp,_tmp)
		self.lbComp = _tmp
		self.lbTxt = _csTxt.New(_tmp:GetElement("text"));
		self.lbSel = _clsGobj.New(_tmp:GetElement("select"));
	else
		_tmp = self:GetChild(0);
		if _tmp then
			_tmp = _tmp:GetComponent("UGUILocalize");
			self.lbTxt = _csTxt.New(_tmp,_tmp);
		end
	end

	self:SetTextVal(val)
	_tmp = (not isNoScale);
	self:SetRaycastTarget(true,_tmp)
	self:SetIsPressScale(_tmp)
end

-- 单击自身
function M:OnClickSelf(gobj,pos)
	if not self.isRaycastTarget then
		return
	end

	self.respName = "";
	if gobj then
		self.respName = gobj.name;
	end

	if self.callFunc then
		self.callFunc(self);
	end
end

function M:SetTextVal(val)
	if self.lbTxt then
		self.txtVal:SetText(val);
	end
	return self;
end

function M:SetRaycastTarget( isBl,isNoSync )
	self.isRaycastTarget = isBl == true;
	if not isNoSync then
		self:SetIsPressScale(self.isRaycastTarget);
	end
end

function M:SetIsPressScale( isBl )
	if not self.comp then
		return
	end

	isBl = isBl == true;
	if isBl ~= self.isPressScale then
		self.isPressScale = isBl;
		self.comp.m_isPressScale = self.isPressScale;
	end
end

function M:SetSelectState( isBl )
	self.isSelect = isBl == true;
	if self.lbSel then
		self.lbSel:SetActive(self.isSelect)
	end
end

return M
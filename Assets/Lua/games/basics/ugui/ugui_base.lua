--[[
	-- ugui的基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]

local _clsEle,_clsGobj,_clsTxt

local super = LUComonet
local M = class( "ugui_base",super )

function M:_Init( callFunc,val )
	_clsEle,_clsGobj,_clsTxt = (_clsEle or LCFabElement),(_clsGobj or LUGobj),(_clsTxt or LuText)
	local _tmp,_tmp2 = self:GetComponent("PrefabElement")
	if _tmp then
		_tmp = _clsEle.New(_tmp,_tmp)
		self.lbComp = _tmp
		_tmp2 = _tmp:GetElementComponent("text","Text")
		if _tmp2 then self.lbTxt = _clsTxt.New(_tmp2,true) end
		
		_tmp2 = _tmp:GetElement("select")
		if _tmp2 then self.lbSel = _clsGobj.New(_tmp2) end
	else
		_tmp = self:GetChild(0)
		if _tmp then
			_tmp2 = _tmp:GetComponent("Text")
			if _tmp2 then self.lbTxt = _clsTxt.New(_tmp2,true) end
		end
	end
	
	self:SetCallFunc(callFunc)
	self:SetText(val)
end

function M:SetCallFunc(func)
	self.callFunc = func
end

-- 执行回调函数
function M:ExcuteCallFunc()
	if self.callFunc then
		self.callFunc(self)
	end
end

function M:SetText(val)
	if self.lbTxt and val then
		self.lbTxt:SetText(val)
	end
	return self
end

function M:FormatText( val, ... )
	if self.lbTxt then
		self.lbTxt:SetTextFmt( val, ... )
	end
	return self
end

function M:SetActiveSelect( isBl )
	self.isSelect = isBl == true
	if self.lbSel then
		self.lbSel:SetActive(self.isSelect)
	end
	return self
end

return M
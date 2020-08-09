--[[
	-- ugui的基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]

local super,super2 = LUComonet,LuaPubs
local M = class( "ugui_base",super,super2 )

function M:ctor(obj,comp)
	super.ctor( self,obj,comp )
	super2.ctor( self )
end

function M:_Init( callFunc,val )
	local _clsEle,_clsGobj,_clsTxt = self:_ClsEle(),self:_ClsTrsf(),self:_ClsUTxt()
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

function M:SetOrFmt( val, ... )
	if self.lbTxt then
		self.lbTxt:SetOrFmt( val, ... )
	end
	return self
end

function M:SetText(val)
	return self:SetOrFmt(val)
end

function M:SetUText(val)
	if self.lbTxt then
		self.lbTxt:SetUText( val )
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
--[[
	-- 动态创建组件
	-- Author : canyon / 龚阳辉
	-- Date   : 2020-07-24 10:35
	-- Desc   : 列表有多少个单元就创建多少个(用于少量的不定列表數量的)
]]

local _clr,_upk,_req = clearLT,unpack,require
local tb_insert = table.insert

local super = LUTrsf
local M = class( "uic_list",super )
local this = M

function M:ctor(lbCfg)
	local gobj = lbCfg.gobj
	local clsLua = lbCfg.clsLua
	local isAllActive = lbCfg.isAllActive == true
	local cfClick = lbCfg.cfClick
	local cfShow = lbCfg.cfShow
	local _ext,_tmp = {}
	for i = 1,10 do
		_tmp = lbCfg[self:SFmt("ext_%s",i)]
		if _tmp then
			tb_insert(_ext,_tmp)
		end
	end

	_clr(lbCfg)

	_tmp = clsLua
	if (type(_tmp) == "string") then
		_tmp =  _req(_tmp)
	end
	assert( _tmp,self:SFmt("scripte is null = [%s]",clsLua) )
	super.ctor( self,gobj )
	
	self.clsLua = _tmp
	self.tpClsLua = type(_tmp)
	self.isAllActive = (isAllActive == true)
	self.lfClick = cfClick
	self.lfShow = cfShow
	self.exts = _ext
	self._lfCkCell = handler(self,self._OnClickCell)

	self:_InitChild()
end

function M:_InitChild()
	local nLen = self:GetChildCount()
	local _tmp,_it = {}
	for i = 1,nLen do
		_it = self.trsf:GetChild(i - 1)
		_it = self:_CreateCell(_it.gameObject)
		tb_insert(_tmp,_it)
	end
	self.lbCells = _tmp
end

function M:_NewChild()
	local _it = this.CsClone(self.lbCells[1].gobj)
	_it =  self:_CreateCell(_it)
	tb_insert(self.lbCells,_it)
end

-- 此函数在OnShow里面调用
function M:ShowScroll(listData)
	self.listData = listData
	local nLen = #self.listData
	local _count = #self.lbCells
	local nMax = (nLen > _count) and  nLen or _count
	for i = _count + 1,nMax do
		self:_NewChild()
	end
	_count = #self.lbCells

	local _nIdx,_it,_isActive = 1
	for i = _count,1,-1 do
		_isActive = self.isAllActive or (i <= nMax)
		_it = self.lbCells[_nIdx]
		if _it then
			if _it.SetActive then
				_it:SetActive(_isActive)
			else
				_it.gobj:SetActive(_isActive)
			end
			if _isActive then
				self:_ShowCell(_it,_nIdx)
			end
		end
		_nIdx = _nIdx + 1
	end
end

function M:_CreateCell(newGo)
	if self.tpClsLua == "function" then
		return self.clsLua(newGo,self._lfCkCell)
	end
	return self.clsLua.New(newGo,self._lfCkCell)
end

function M:_ShowCell(lbCell,nRow)
	if not lbCell then return end
	if self.lfShow then
		self.lfShow(lbCell,nRow,_upk(self.exts))
		return
	end
	lbCell:ShowViewByData(self.listData[nRow],_upk(self.exts))
end

function M:_OnClickCell(lbCell)
	if self.lfClick then self.lfClick(lbCell) end
end

M.AddNoClearKeys("clsLua")

return M
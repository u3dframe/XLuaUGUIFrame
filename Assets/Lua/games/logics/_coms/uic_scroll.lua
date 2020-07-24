--[[
	-- 固定循环组件
	-- Author : canyon / 龚阳辉
	-- Date   : 2020-07-24 10:35
	-- Desc   : 
]]

local _clr = clearLT
local tb_insert = table.insert
local _row,_upub,_upk = UIRow,LuaPubs,unpack

local super = LUTrsf
local M = class( "uic_scroll",super )

function M:ctor(lbCfg)
	local gobj = lbCfg.gobj
	local gobjCell = lbCfg.gobjCell
	local clsLua = lbCfg.clsLua
	local cfClick = lbCfg.cfClick
	local cfShow = lbCfg.cfShow
	local nColumn = lbCfg.nColumn
	local isAllActive = lbCfg.isAllActive == true
	local isVertical = lbCfg.isVertical == true
	local isCallNoData = lbCfg.isCallNoData == true
	local isAlpha = lbCfg.isAlpha == true
	local _ext = (lbCfg.ext_1 ~= nil) and {} or nil
	for i = 1,10 do
		_tmp = lbCfg[self:SFmt("ext_%s",i)]
		if _tmp then
			tb_insert(_ext,_tmp)
		end
	end

	_clr(lbCfg)

	local _tmp = clsLua
	if (type(_tmp) == "string") then
		_tmp =  require(_tmp)
	end
	assert( _tmp,self:SFmt("scripte is null = [%s]",clsLua) )
	super.ctor( self,gobj )
	super2.ctor( self )
	
	self.clsLua = _tmp
	self.nColumn = self:TInt( nColumn,0 )
	self.isUseRow = self.nColumn > 1
	self.isAllActive = (isAllActive == true)
	self.lfClick = cfClick
	self.lfShow = cfShow
	self.exts = _ext
	

	self._lfCkCell = handler(self,self._OnClickCell)
	local _lfCCell = handler(self,self._CreateCell)
	local _lfSCell = handler(self,self._ShowCell)
	self.lbScl = _upub:_ClsUScl().New(self.gobj,_lfCCell,_lfSCell,gobjCell)
	self.lbScl:ShowScroll(0,isVertical,isCallNoData,isAlpha)
end

-- 此函数在OnShow里面调用
function M:ShowScroll(listData)
	self.listData = listData
	local nLen = #self.listData
	if self.isUseRow then nLen = self:NPage(nLen,self.nColumn) end
	self.lbScl:ChangeListCount(nLen)
end

function M:_CreateCell(newGo)
	if self.isUseRow then
		return _row.New(newGo,self.clsLua,self.nColumn,self._lfCkCell)
	end
	return self.clsLua.New(newGo,self._lfCkCell)
end

function M:_ShowCell(lbCell,nRow)
	if self.cfShow then
		self.cfShow(lbCell,nRow)
		return
	end
	if self.isUseRow then
		return lbCell:ShowViewByList(self.listData,nRow,_upk(self.exts))
	end
	lbCell:ShowViewByData(self.listData[nRow],_upk(self.exts))
end

function M:_OnClickCell(lbCell)
	if self.cfClick then self.cfClick(lbCell) end
end

return M
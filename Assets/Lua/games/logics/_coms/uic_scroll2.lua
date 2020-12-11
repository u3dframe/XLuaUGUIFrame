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
	local clsLua = lbCfg.clsLua
	local cfClick = lbCfg.cfClick
	local cfShow = lbCfg.cfShow
	local ItemName = lbCfg.itemName
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
		_tmp =  require(_tmp)
	end
	assert( _tmp,self:SFmt("scripte is null = [%s]",clsLua) )
	super.ctor( self,gobj )

	self.clsLua = _tmp
	self.tpClsLua = type(_tmp)
	self.lfClick = cfClick
	self.lfShow = cfShow
	self.exts = _ext

	local _lfCCell = handler(self,self._CreateCell)
	local _lfSCell = handler(self,self._ShowCell)
	self._lfCkCell = handler(self,self._OnClickCell)
	self.lbScl = _upub:NewSSclBy(self.gobj, ItemName,_lfCCell,_lfSCell,self._lfCkCell )
end

-- 此函数在OnShow里面调用
function M:ShowScroll(listData)
	self.listData = listData
	local nLen = #self.listData
	self.lbScl:ShowScroll(nLen);
end

function M:_CreateCell(newGo)
	if self.tpClsLua == "function" then
		return self.clsLua(newGo)
	end
	return self.clsLua.New(newGo)
end

function M:_ShowCell(lbCell,nRow)
	if self.lfShow then
		self.lfShow(lbCell,nRow,_upk(self.exts))
		return
	end
	lbCell:ShowViewByData(self.listData[nRow],_upk(self.exts))
end

function M:_OnClickCell(lbCell)
	if self.lfClick then self.lfClick(lbCell) end
end

function M:on_clean()
	self.clsLua,self.lfClick,self.lfShow,self._lfCkCell = nil
end

M.AddNoClearKeys("clsLua")

return M
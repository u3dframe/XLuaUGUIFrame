--[[
	-- 行单元 
	-- Author : canyon / 龚阳辉
	-- Date   : 2017-08-02 16:20
	-- Desc   : 一行里面可以是一个或者多个元素
]]

local tb_insert = table.insert

local super = LUTrsf
local M = class( "uicell_row",super )

function M:ctor(gobj,clsLua,nColumn,cfClick,isAllActive,syncUObj,nColumnData)
	super.ctor( self,gobj )
	
	self.nColumn = nColumn
	self.nColumnData = nColumnData or self.nColumn
	self.isAllActive = (isAllActive == true)

	local _trsf = self.trsf
	
	-- 行单元中的列元素
	local columns = {}
	local _func = handler(self,self.ExcuteCallFunc)
	local _gobjCell,_lb = nil
	local _tObj = LuEvtListener
	for i = 1,self.nColumn do
		_gobjCell = _trsf:GetChild(i-1).gameObject
		_lb = clsLua.New(_gobjCell,_func)
		tb_insert(columns,_lb)

		if _tObj and syncUObj then
			_tObj.AddSyncDrag(_gobjCell,syncUObj)
		end
	end

	self.columns = columns
	self:SetCallFunc(cfClick)
end

-- 显示数据
function M:ShowViewByList(listOrg,nRow,...)
	nRow = nRow <= 0 and 1 or nRow;
	local count = #listOrg
	local _isActive,_tmp,_nIndex
	for i = 1,self.nColumn do
		_tmp = self.columns[i]
		_nIndex = (nRow - 1) * self.nColumnData + i;
		_isActive = ((_nIndex <= count or self.isAllActive) and i <= self.nColumnData)
		if _isActive then
			_tmp:ShowViewByData(listOrg[_nIndex],_nIndex,...)
		end
		_tmp:SetActive(_isActive)
	end

	if self.isAllActive and self.isActive ~= self.isAllActive then
		self:SetActive(true)
	end
end

function M:GetCell( index )
	return self.columns[index]
end

function M:GetCellByDataId( data_id )
	return self:GetCellByFunc(function ( item )
		return data_id == item.data.id
	end)
end

function M:GetCellByFunc( func )
	local _tmp,_ret
	for i = 1,self.nColumn do
		_tmp = self.columns[i]
		if _tmp.data and func and func(_tmp) then
			_ret = _tmp
			break
		end
	end
	return _ret
end

return M
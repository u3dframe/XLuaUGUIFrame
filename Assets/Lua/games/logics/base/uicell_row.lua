--[[
	-- 行单元 
	-- Author : canyon / 龚阳辉
	-- Date   : 2017-08-02 16:20
	-- Desc   : 一行里面可以是一个或者多个元素
]]

local tb_insert = table.insert

local super,super2 = LUTrsf,UIPubs
local M = class( "uicell_row",super,super2 )

function M:ctor(gobj,clsLua,nColumn,cfClick,isAllActive)
	super.ctor( self,gobj )
	super2.ctor( self )
	
	self.nColumn = nColumn
	self.isAllActive = (isAllActive == true)
	
	local _trsf = self.trsf
	
	-- 行单元中的列元素
	local columns = {}
	local _func = handler(self,self.ExcuteCallFunc)
	local _gobjCell,_lb = nil
	for i = 1,self.nColumn do
		_gobjCell = _trsf:GetChild(i-1).gameObject
		_lb = clsLua.New(_gobjCell,_func)
		tb_insert(columns,_lb)
	end

	self.columns = columns
	self:SetCallFunc(cfClick)
end

-- 显示数据
function M:ShowViewByList(listData,pars)
	local count = #listData
	local _isActive,_tmp
	for i = 1,self.nColumn do
		_tmp = self.columns[i]
		_isActive = (i <= count) or self.isAllActive
		if _isActive then			
			_tmp:ShowViewByData(listData[i],pars)
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
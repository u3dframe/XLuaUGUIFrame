--[[
	-- 滚动
	-- Author : canyon / 龚阳辉
	-- Date : 2020-12-16 15:05
	-- Desc : csharp脚本的作者：赖永飞
]]

local tonumber,type,tostring = tonumber,type,tostring
local _tinsert = table.insert
local _titKVArr = table.getVK4Arr
local _mfloor,_mabs,_mClamp = math.floor,math.abs,Mathf.Clamp

local super = LuBase
local M = class("ugui_scroll_loop", super)

function M:ctor(gobj, itemName, funcCreat, funcSetData)
    super.ctor(self, gobj, "LoopListView3")
    self.objlist = {}
    self.funcCreat = funcCreat
    self.funcSetData = funcSetData
    self.itemName = itemName
    self.tpItemName = type(itemName)
    
    self.lfGetPName = handler(self, self.GetPrefabName)
    self.lfCreateCell = handler(self, self.OnCreatItem)
    self.lfUpCell = handler(self, self.OnUpItemData)
    self.lfMvEnd = handler(self, self.OnMovingEnd)
    self.lfChgVal = handler(self, self.OnValueChanged)
    self.lfMvState = handler(self, self.OnMovingState)
    self.comp:Init( self.lfGetPName, self.lfCreateCell, self.lfUpCell,self.lfMvEnd,self.lfChgVal,self.lfMvState )
end

function M:ShowScroll(count)
    count = tonumber( count ) or 0
    self.n_count = count
    self.comp:SetItemCount(count)
end

-- 平滑移动某个对象
function M:MoveToForcibly(nIndex)
    nIndex = tonumber( nIndex ) or 1
    self.comp:MoveToForcibly(nIndex - 1)
end

-- 移动某个对象
function M:MoveToImmediately(nIndex)
    nIndex = tonumber( nIndex ) or 1
    self.comp:MoveToImmediately(nIndex - 1)
end

function M:SetSyncLoop(csLoop)
    self.comp:SetSyncView(csLoop)
end

function M:GetPrefabName(index)
    index = tonumber( index ) or 0
	index = index + 1
	if (index <= 0 or index > self.n_count) then
		return
	end
	local _n_
	if (self.tpItemName == "function") then
		_n_ = self.itemName(index)
	else
		_n_ = self.itemName
	end
	return _n_
end

function M:OnCreatItem(newGO)
    local _lb
    if self.funcCreat then
        _lb = self.funcCreat(newGO)
    end
    _lb = _lb or {}
    _lb.gobj = _lb.gobj or newGO
    self.objlist[_lb.gobj] = _lb
    local _csEvt = CEvtListener.Get(newGO,false)
    if _csEvt then
        _csEvt:AddSyncDrag4EventTrigger( self.gobj )
    end
end

function M:OnUpItemData(gobj,index,n01)
    index = index + 1
    local _lb = self.objlist[gobj]
    _lb.cur_index = index
    if self.funcSetData then
        self.funcSetData(_lb,index)
    end
    self:ExcScale( _lb,n01 )
    self:ExcAlpha( _lb,n01 )
    self:ExcCustom(_lb,n01 )
end

function M:OnMovingEnd(index)
    index = tonumber( index )
    if not self.objlist or not index then
        return
    end
    for _, _v in pairs(self.objlist) do
        if _v.cur_index == index + 1 then
            if self.lfcMvEnd then
                self.lfcMvEnd(_v, _v.cur_index)
            end
            break
        end
    end
end

function M:SetFunc4MvEnd(func)
    self.lfcMvEnd = func
end

function M:OnValueChanged(fval)
    if self.lfcChgVal then
        self.lfcChgVal( fval )
    end
end

function M:SetFunc4ChgVal(func)
    self.lfcChgVal = func
end

function M:OnMovingState(isMoving)
    if self.lfcMovingState then
        self.lfcMovingState( isMoving )
    end
end

function M:SetFunc4MovingState(func)
    self.lfcMovingState = func
end

function M:SetScalePars( minVal,maxVal,scaleNode )
    self.scl_min_val = tonumber( minVal ) or 0.01
    self.scl_max_val = tonumber( maxVal ) or 1
    self.scl_node = scaleNode
end

function M:ExcScale( lbCell,val )
    if (not lbCell) or (not self.scl_min_val) or (not self.scl_max_val) then
        return
    end
    val = 1 - _mabs( val )
    val = _mClamp( val,self.scl_min_val,self.scl_max_val )
    self.comp:SetScale( lbCell.gobj,val,self.scl_node )
end

function M:SetAlphaPars( minVal,maxVal,... )
    self.a_min_val = tonumber( minVal ) or 0.01
    self.a_max_val = tonumber( maxVal ) or 1
    self.a_nodes = { ... }
end

function M:ExcAlpha( lbCell,val )
    if (not lbCell) or (not self.a_min_val) or (not self.a_max_val) then
        return
    end
    val = 1 - _mabs( val )
    val = _mClamp( val,self.a_min_val,self.a_max_val )
    self.comp:SetAlpha( lbCell.gobj,val,unpack(self.a_nodes) )
end

function M:ExcCustomChange(isCustom)
    self.isCustomChange = (isCustom == true)
end

function M:ExcCustom(lb, val)
    if (lb.CustomChangeEffect)then
        lb:CustomChangeEffect(_mabs(val));--自定义界面拖拽时的表现效果
    end
end

function M:on_clean()
    self.funcCreat, self.funcSetData,self.itemName = nil
    self.lfGetPName, self.lfCreateCell, self.lfUpCell = nil
    self.lfMvEnd,self.lfChgVal,self.lfMvState = nil
    self.lfcMvEnd,self.lfcChgVal,self.lfcMovingState = nil
end

return M

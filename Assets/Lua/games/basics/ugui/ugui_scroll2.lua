--[[
	-- 滚动
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-11 12:25
	-- Desc : 参照
]]
local _tinsert = table.insert
local _titKVArr = table.getVK4Arr
local _mfloor = math.floor

local super = LuBase
local M = class("ugui_scroll2", super)

function M:ctor(gobj, itemName, funcCreat, funcSetData, clickCallBack)
    super.ctor(self, gobj, "ScrollRect")
    self.loopComp = self:GetComponent("LoopListView2")
    self.isInit = false
    self.objuuid = 0
    self.objlist = {}
    self.itemName = itemName
    self.funcCreat = funcCreat
    self.funcSetData = funcSetData
    self.clickCallBack = clickCallBack
    local _cont = self.comp.content
    self.lbContent = self:NewTrsfBy(_cont)
    self.lbContent:SetPivot(0, 1)
    self.lbContent:SetAnchorMin(0, 1)
    self.lbContent:SetAnchorMax(0, 1)
    self.tpItemName = type(itemName)
    self.isVertical = self.comp.vertical
    local _func = handler(self, self.OnValueChanged)
    self.comp.onValueChanged:AddListener(_func)

    _func = handler(self, self.OnValue2Middle)
    self.loopComp.mOnMiddle = _func

    self.lfGetPName = handler(self, self.GetPrefabName)
    self.lfCreateCell = handler(self, self.OnCreatItem)
    self.lfUpCell = handler(self, self.OnUpItemData)
    self.lfClickCell = handler(self, self.OnClickItem)
    self.loopComp:InitList(0, self.lfGetPName, self.lfCreateCell, self.lfUpCell)
end

function M:GetPrefabName(index)
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

function M:OnCreatItem(csLoopItem)
    local _uuid = csLoopItem.UUID
    local newGO, _lb = csLoopItem.gameObject
    if self.funcCreat then
        _lb = self.funcCreat(newGO)
    end
    _lb = _lb or {}
    _lb.gobj = _lb.gobj or newGO
    self.objlist[_uuid] = _lb

    csLoopItem:SetClickEvent(self.lfClickCell)
end

function M:OnUpItemData(uuid, index)
    if self.funcSetData then
        index = index + 1
        local _lb = self.objlist[uuid]
        _lb.cur_index = index
        self.funcSetData(_lb, index)
    end
end

function M:OnClickItem(uuid, index)
    if self.clickCallBack then
        self.clickCallBack(index)
    end
end

function M:ShowScroll(count)
    self.n_count = count
    self.loopComp:SetListItemCount(count)
end

function M:IntermediateAmplification(minScale)
    self.loopComp:UpdateAllShownItemSnapData()
    local count = self.loopComp.ShownItemCount
    for i = 1, count do
        local item = self:GetItem(i)
        local cell = self.objlist[item.UUID]
        if (cell) then
            local Scale = 1 - Mathf.Abs(item.DistanceWithViewPortSnapCenter) / 700
            Scale = Mathf.Clamp(Scale, minScale, 1)
            if (cell.SetIntermediateAmplification) then
                cell:SetIntermediateAmplification(Scale, Scale, 1)
            end
            if (Scale >= 0.9) then
                self.CurrIntermediateIndex = item.ItemIndex + 1
            end
        end
    end
end

-- 通过索引获取子物体Table (可能空)
function M:GetItem(nIndex)
    return self.loopComp:GetShownItemByIndex(nIndex - 1)
end

function M:MoveTo(nIndex)
    self.loopComp:MoveTo2(nIndex - 1)
end

-- 将第nIndex 个元素 设置到显示的第一个位置
function M:SetTopByIndex(nIndex,duration)
    self.loopComp:MoveTo(nIndex - 1,duration or 0)
end

function M:on_clean()
    self.funcCreat, self.funcSetData, self.clickCallBack = nil
    self.lfGetPName, self.lfCreateCell, self.lfUpCell, self.lfClickCell = nil
    self.cfChange, self.cfVal2Middle = nil
    if self.comp then
        self.comp.onValueChanged:RemoveAllListeners()
    end
end

function M:SetNormalizedPosition(norVal)
    if not self.comp then
        return
    end
    if self.isVertical then
        self.comp.verticalNormalizedPosition = norVal
    else
        self.comp.horizontalNormalizedPosition = norVal
    end
end

function M:OnValueChanged(v2)
    self.v2Chg = self.v2Chg or {v2.x, v2.y}
    self.v2Chg[1] = v2.x
    self.v2Chg[2] = v2.y
    local _curr = self.isVertical and v2.y or v2.x
    self.normalVal = _curr
    if self.cfChange then
        self.cfChange(self, _curr)
    end
end

--设置滚动回调
function M:SetFunc4ValueChanged(func)
    self.cfChange = func
end

function M:OnValue2Middle(_, csObj)
    local _lb = self.objlist[csObj.UUID]
    if self.cfVal2Middle then
        self.cfVal2Middle(_lb, _lb.cur_index)
    end
end

function M:SetFunc4Value2Middle(func)
    self.cfVal2Middle = func
end

return M

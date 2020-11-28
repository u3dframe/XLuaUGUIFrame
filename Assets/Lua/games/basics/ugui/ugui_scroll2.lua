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
local M = class( "ugui_scroll2", super )


function M:ctor(gobj, itemName, funcCreat, funcSetData, clickCallBack)
	super.ctor( self, gobj, "ScrollRect" )
	self.loopComp = self:GetComponent("LoopListView2")
	self.isInit = false;
	self.objuuid = 0;
	self.objlist = {};
	self.itemName = itemName
	self.funcCreat = funcCreat
	self.funcSetData = funcSetData
	self.clickCallBack = clickCallBack
	local _cont = self.comp.content
	self.lbContent = self:NewTrsfBy(_cont)
	self.lbContent:SetPivot(0,1)
	self.lbContent:SetAnchorMin(0, 1)
	self.lbContent:SetAnchorMax(0, 1)
end

function M:ShowScroll(count)
	if (self.isInit ~= true)then
		self.isInit =  true;
		self.loopComp:InitListView(count, function (listview, index)
			index = index + 1;
			if (index <= 0 or index > count)then return end
			local item = listview:NewListViewItem(self.itemName);
			if (item.IsInitHandlerCalled == false)then
				self.objuuid = self.objuuid + 1;
				item.IsInitHandlerCalled = true;
				item.UUID = self.objuuid;
				if (self.clickCallBack)then item:SetClickEvent(item.gameObject, self.clickCallBack); end
				if  self.funcCreat then self.objlist[self.objuuid] = self.funcCreat(item.gameObject); end
			end
			if (self.funcSetData)then
				self.funcSetData(self.objlist[item.UUID], index)
			end
			return item
		end);
	else
		self.loopComp:SetListItemCount(count);
	end
end

function M:IntermediateAmplification(minScale)
    self.loopComp:UpdateAllShownItemSnapData();
	local count = self.loopComp.ShownItemCount;
	for i = 1, count do
		local item = self:GetItem(i);
		local cell = self.objlist[item.UUID];
		if (cell)then
			local Scale = 1 - Mathf.Abs(item.DistanceWithViewPortSnapCenter) / 700;
			Scale = Mathf.Clamp(Scale, minScale, 1);
			if (cell.SetIntermediateAmplification)then
				cell:SetIntermediateAmplification(Scale, Scale, 1);
			end
			if (Scale >= 0.9)then self.CurrIntermediateIndex = item.ItemIndex + 1; end
		end
	end
end

-- 通过索引获取子物体Table (可能空)
function M:GetItem(nIndex)
	return self.loopComp:GetShownItemByIndex(nIndex - 1);
end

-- 将第nIndex 个元素 设置到显示的第一个位置
function M:SetTopByIndex(nIndex)
	self.loopComp:MoveTo(nIndex - 1);
end

return M
--[[
	-- 滚动
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-11 12:25
	-- Desc : 参照
]]
local _tinsert = table.insert
local _titKVArr = table.getVK4Arr
local _tsort = table.sort
local _tremove = table.remove
local _mfloor = math.floor
local _mfmod = math.fmod

local super = LuBase
local M = class( "ugui_scroll", super )
local this = M

function M:ctor(gobj,funcCreat,funcSetData,gobjItem)
	super.ctor( self,gobj,"ScrollRect" )

	local _sr = self.comp
	local _cont = _sr.content
	if not gobjItem then
		gobjItem = _cont.transform:GetChild(0)
	end
	assert(gobjItem,"== cell is null")
	
	self.funcCreat = funcCreat
	self.funcSetData = funcSetData	
	
	self.lbContent = self:NewTrsfBy(_cont)
	self.lbContent:SetPivot(0,1)
	self.lbContent:SetAnchorMin(0, 1)
	self.lbContent:SetAnchorMax(0, 1)
	
	self.lbItem = self:NewTrsfBy(gobjItem)
	self.lbItem:SetPivot(0,1)
	self.lbItem:SetAnchorMin(0, 1)
	self.lbItem:SetAnchorMax(0, 1)
	self.lbItem:SetActive(false)

	self.isCInCon = CHelper.IsInParent(self.lbItem.gobj,self.lbContent.gobj)
	self.curIndexArray ={} -- eg:{1,2,3,4} 
	self.lbLItems = {} 	-- item table array

	local _func = handler_xpcall(self,self.OnValueChanged)
	_sr.onValueChanged:AddListener(_func);
	self.normalVal = 0

	-- _func = handler(self,self.OnEndDrag);
	-- self.tmEnd = Timer.New(_func,1,1);
	self.wSelf,self.hSelf = self:GetRectSize()
	self.wContent,self.hContent = self.lbContent:GetRectSize()
	self.wCell,self.hCell = self.lbItem:GetRectSize()
end

function M:on_clean()
	self.funcCreat,self.funcSetData = nil
	if self.comp then
		self.comp.onValueChanged:RemoveAllListeners()
	end
end

function M:ReInit(bIsVertical,bIsCallNoData,bIsAlpha,iOffsetCell)
	self.isVertical = (bIsVertical == true)
	self.isCallNoData = (bIsCallNoData == true)
	self.isAlpha = (bIsAlpha == true)
	self.nCellOffset = self:TInt(iOffsetCell,1)
	self.itemUnitLength = (self.isVertical == true) and (self.hCell + self.nCellOffset) or (self.wCell + self.nCellOffset);
	self.scrollViewLength = (self.isVertical == true) and self.hSelf or self.wSelf;
	self.isInit = true
	return self
end

function M:OnValueChanged(v2)
	self.v2Chg = self.v2Chg or {v2.x,v2.y}
	self.v2Chg[1] = v2.x
	self.v2Chg[2] = v2.y

	local _curr = self.isVertical and (1 - v2.y) or v2.x
	self.is0To1 = _curr > self.normalVal;
	self.normalVal = _curr;
	self:UpdateAllItem()

	if self.cfChange and not self._isSetCenter then
		self.cfChange(self)
	end
	-- self.tmEnd.time = 0.1;
	-- self.tmEnd:Start();
end

--设置滚动回调
function M:SetFunc4ValueChanged(func)
	self.cfChange = func
end

function M:SetLocPos4Cont(x,y)
	self.lbContent:SetLocalPosition(x,y)
end

function M:SetAnPos4Cont(x,y)
	self.lbContent:SetAnchoredPosition(x,y)
end

function M:SetSize4Cont(x,y)
	self.lbContent:SetSizeDelta(x,y)
end

function M:GetLocalPos4Cont()
	return self.lbContent.trsf.localPosition
end

function M:_CreatItem(nIndex)
	local newGO,_lb;
	if nIndex == 1 and self.isCInCon then
		newGO = self.lbItem.gobj
	end
	if not newGO then
		newGO = (not self.isCInCon) and self.lbContent.gobj or nil
		newGO = self.lbItem:Clone(newGO)
	end
	if self.funcCreat then
		_lb = self.funcCreat(newGO)
	end
	_lb = _lb or {}
	_lb.gobj = _lb.gobj or newGO;
	if (not _lb.IsHasSupper) then
		_lb.lbMy = self:NewTrsfBy(_lb.gobj)
	else
		_lb.lbMy = _lb
	end

	_tinsert(self.lbLItems,_lb);
	_tinsert(self.curIndexArray,nIndex);
end

-- 通过索引获取子物体Table (可能空)
function M:GetItem(nIndex)
	return _titKVArr(self.lbLItems,"index",nIndex)
end

-- 获取所有子物体Table
function M:GetItems()
	return self.lbLItems
end

--更新单个信息 index 为nil时更新当前显示的子单元
function M:UpdateRankItem(index)
	if not self.isInit then
		return
	end
	if #self.curIndexArray > 0 then
		local _it
		for i=1,#self.curIndexArray do
			_it = self.curIndexArray[i]
			if (not index) or (_it == index) then
				self:_UpdateItem(i,true)
			end
		end
	end
end

-- 获取显示的索引数组
function M:GetShowingIndexArray()
	self.curContentPos = self:GetLocalPos4Cont()
	local mOvertopCounts = _mfloor((self.isVertical and self.curContentPos.y or -self.curContentPos.x) /self.itemUnitLength)
	local mFloor = _mfloor(mOvertopCounts/self.itemCreatCounts) --倍数
	local mRemainder = mOvertopCounts - mFloor*self.itemCreatCounts --余数
	local _r = {}
	for i=1,self.itemCreatCounts do
		_tinsert(_r,i+self.itemCreatCounts*(mRemainder >= i and mFloor+1 or mFloor))
	end
	return _r
end

function M:_CalcAlpha(index)
	local _lb = self.lbLItems[index]
	if not _lb then return 0 end

	local mContentOneSide = self.isVertical and self.curContentPos.y or -self.curContentPos.x
	local mItemPos = _lb.lbMy.trsf.localPosition
	local mItemOneSide = self.isVertical and mItemPos.y or -mItemPos.x
	local mItemUnit = self.itemUnitLength/self.scrollViewLength
	local mScale = (-mContentOneSide-mItemOneSide)/self.scrollViewLength
	local mAlpha = 1
	if mScale < 0 then
		mAlpha = 1 + mScale/mItemUnit
	elseif mScale > 1 - mItemUnit then
		mAlpha = 1 - (mScale - 1 + mItemUnit)/mItemUnit
	end
	return mAlpha
end

--更新所有信息
function M:UpdateAllItem(array,isMust)
	if not self.isInit then
		return
	end
	array = array or self:GetShowingIndexArray()
	if #array == #self.curIndexArray then
		local _it1,_it2,_v,_isData
		for i=1,#array do
			_it1 = array[i]
			_it2 = self.lbLItems[i]
			_isData = false
			if (isMust == true) or (_it1 > 0 and _it1 <= self.listCount and _it1 ~= self.curIndexArray[i]) then
				_v = (_it1 - 1) * self.itemUnitLength
				_it2.lbMy:SetLocalPosition(self.isVertical and 0 or _v, self.isVertical and (-1 * _v) or 0);
				self.curIndexArray[i] = _it1
				_isData = true
			end
			self:_UpdateItem(i,_isData)
		end
	else
		printError("=== BUG: two difference array,#array = [%s],#self.curIndexArray = [%s]",#array,#self.curIndexArray)
	end
end

function M:_UpdateItem(i,isDate)
	local _it,_v = self.lbLItems[i]
	if self.isAlpha then
		_v = self:_CalcAlpha(i)
		if _it.alpha ~= _v then
			_it.alpha = _v
			isDate = true
		end
	end

	if isDate then
		self:SetData(i)
	end
end

function M:SetData(nIndex)
	local luaCell = self.lbLItems[nIndex]
	-- rowindex 从1开始，符合lua
	local nRowIndex = self.curIndexArray[nIndex]

	luaCell.cur_index = nRowIndex --设置子物体在列表相对应的索引

	local isActive = nRowIndex <= self.listCount
	if not self.isCallNoData and luaCell.gobj then
		if luaCell.SetActive then
			luaCell:SetActive(isActive)
		else
			luaCell.lbMy:SetActive(isActive)
		end
		luaCell.isActive = isActive
	end

	if self.isCallNoData or isActive then
		if self.funcSetData then
			self.funcSetData(luaCell , nRowIndex ,luaCell.alpha or 1)
		end
	end
end

-- 改变列表长度
function M:ChangeListCount(nCurListCount)
	if not self.isInit then
		return
	end

	if nCurListCount ~= self.listCount then
		local _val = (nCurListCount * self.itemUnitLength);
		local _h2 = self.isVertical and _val or self.hContent;
		local _w2 =  self.isVertical and self.wContent or _val;
		local _l2 = self.isVertical and _h2 or _w2;
		
		self.hContent = _h2
		self.wContent =  _w2
		self.contentLength = _l2

		local _v2 = self:GetLocalPos4Cont()
		self:SetSize4Cont(_w2,_h2)

		self.overtopLength = _l2 - self.scrollViewLength
		self.overtopLength = self.overtopLength > 0 and self.overtopLength or 0

		if nCurListCount < self.listCount then
			local _cur = (self.isVertical and _v2.y or -_v2.x);
			if _cur > self.overtopLength then
				local _diff = _cur - self.overtopLength;
				local _x = self.isVertical and _v2.x or (_v2.x + _diff);
				local _y = self.isVertical and (_v2.y - _diff) or _v2.y;
				self:SetAnPos4Cont(_x,_y)
			end
		end
	end

	self.listCount = nCurListCount
	self:UpdateRankItem()
end

-- 是否内容超出了视口长度
function M:IsOverView()
	if not self.isInit then
		return
	end
	return self.contentLength > self.scrollViewLength;
end

--- 显示
function M:ShowScroll(nListCount,bIsVertical,bIsCallNoData,bIsAlpha)
	if bIsVertical == nil then bIsVertical = self.isVertical end
	if bIsCallNoData == nil then bIsCallNoData = self.isCallNoData end
	if bIsAlpha == nil then bIsAlpha = self.isAlpha end
	self.listCount = nListCount
	self:ReInit(bIsVertical,bIsCallNoData,bIsAlpha)

	self.hContent = self.isVertical and self.listCount * self.itemUnitLength or self.hContent
	self.wContent =  self.isVertical and self.wContent or self.listCount * self.itemUnitLength
	self.contentLength = self.isVertical and self.hContent or self.wContent

	self.displayItemCounts = _mfloor(self.scrollViewLength/self.itemUnitLength)
	self.itemCreatCounts = self.displayItemCounts + 2
	
	self:SetSize4Cont(self.wContent,self.hContent)
	self.curContentPos = self:GetLocalPos4Cont()
	self:SetAnPos4Cont(0,0)
	self.normalVal = 0

	--初始化数据
	if next(self.lbLItems) then
		if next(self.curIndexArray)then
			for i=1,#self.curIndexArray do
				self.curIndexArray[i] = i
			end
		end
	else
		for i = 1,self.itemCreatCounts do
			self:_CreatItem(i)
		end
	end

	local _tmp = self.contentLength - self.scrollViewLength
	_tmp = _tmp > 0 and _tmp or 0
	self.overtopLength = _tmp

	self:UpdateAllItem(nil,true)
end

-- 将第nIndex 个元素 设置到显示的第一个位置
function M:SetTopByIndex(nIndex)
	if not self.isInit then
		return
	end
	if type(nIndex) ~= "number" then
		printError("输入的值有误 nIndex = [%s]",nIndex)
		return;
	end
	local _v = self.listCount - self.displayItemCounts
	if nIndex <= 1 or _v <= 0 then
		nIndex = 1
	elseif nIndex > _v then
		nIndex = _v + 1
	end
	_v = self.itemUnitLength *(nIndex - 1)
	self:SetLocPos4Cont(self.isVertical and 0 or (-1 * _v), self.isVertical and _v or 0);
	self:UpdateAllItem()
end

-- 将第nIndex 个元素 设置到显示的中间位置
function M:SetCenterByIndex(nIndex)
	if not self.isInit then
		return
	end
	if type(nIndex) ~= "number" then
		printError("输入的值有误 nIndex = [%s]",nIndex)
		return
	end
	local _p1 = self.itemUnitLength * (nIndex - 0.5)
	local _p2 = (self.listCount - nIndex + 0.5) * self.itemUnitLength
	local _p3 = self.scrollViewLength * 0.5
	local _x,_y,_v = -1,-1,0
	if _p1 <= _p3 then
		_v = 0
	elseif _p2 <= _p3 then
		_v = self.overtopLength
	elseif _p1 > _p3 and _p2 > _p3 then
		_v = _p1 - _p3
	end
	_x,_y = self.isVertical and 0 or (-1 * _v),self.isVertical and _v or 0
	self:UpdateAllItem()
end

function M:SetNormalizedPosition(norVal)
	if not self.comp then
		return
	end
	if self.isVertical then
		self.comp.verticalNormalizedPosition = 1 - norVal
	else
		self.comp.horizontalNormalizedPosition = norVal
	end
end

return M
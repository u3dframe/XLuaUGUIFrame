--[[
	-- item 组件 
	-- Author : canyon / 龚阳辉
	-- Date   : 2017-07-25 20:10
	-- Desc   : 主要显示格式为type_id_num的数据
]]

-- value文本显示模式
LE_ItVShowType = {
	None = 0, -- 空字节 : 
    Need = 1, -- 传递进来的值 : 1
	Have = 2, -- 当前拥有值 : 5
	XNeed = 3, -- x传递进来的值 : x1
	XHave = 4, -- x当前拥有值 : x5
	Have_Need = 5, -- 拥有值/需要值  : 5/1
	Need_Have = 6, -- 需要值/拥有值  : 1/5
	NeedMoreThan1 = 7, -- 需要值> 1显示需要值，否則为空值
}

local tb_lens = table.lens
local m_max = math.max
local _c_red,_c_green = Color.red,Color.green

local super,_evt = UICell,Event
local M = class( "ui_item",super )

-- 用[_]占位，兼容row传递参数
function M:OnSetData(valType,isVwEmpty)
	self.valType = valType or LE_ItVShowType.Have
	self.isVwEmpty = isVwEmpty == true
	self.isNoChgColor = isNoChgColor == true
end

function M:OnInit()
	self.lbShadow = self:GetElement("shadow")
	self.lbTxtName = self:NewTxt("name",true) -- 名字
	self.lbTxtValue = self:NewTxt("value",true) -- 值
	self.lbTxtDesc = self:NewTxt("desc",true) -- 描述
	self.lbTxtOrder = self:NewTxt("order",true) -- 阶级
	self.lbTag = self:GetElement("bg_tag") -- 标签组件
	self.lbTxtTag = self:NewTxt("tag",true) -- 标签

	self.lbImgIcon = self:NewImg("icon","Image",true) -- 图标
	self.lbImgQuality = self:NewImg("quality","Image",true) -- 品质
	
	self.lbTrsfEmpty = self:NewTrsf("empty",true) -- 空
	self.lbStars = {}
	local _tmp = self:GetElement("wrapStars") -- 星星
	if _tmp then
		_tmp = _tmp.transform;
		-- self.lbStars = {_tmp:GetChild(0).gameObject}
		for i = 0  ,_tmp.childCount - 1 do
			local temp = nil
			temp = _tmp:GetChild(i).gameObject
			table.insert( self.lbStars,temp )
		end
	end

	self:VwEmptyObj(false)
end

function M:OnView()
	local _data = self.data -- type,id,num
	local _cfg = nil; -- 本地数据
	-- self.cfgData = _cfg

	-- local _svData =  -- 取背包的服务器数据
	-- self.svData = _svData

	local _name,_desc,_ord = nil
	local _star = 0
	local _icon,_qua = nil
	local _nNum,_cNum = 0,1

	_val = self:_ReVal(_nNum,_cNum,_showNum)

	self:VwName(_name)
	self:VwValue(_val)
	self:VwValueColor()
	self:VwDesc(_desc)
	self:VwOrder(_ord)
	self:VwStars(_star)
	self:VwIcon(_icon)
	self:VwQuality(_qua)
	self:VwEmptyObj(false)
end

function M:OnVwEmpty()
	self.data,self.cfgData,self.svData = nil
	self:VwName("")
	self:VwValue("")
	self:VwDesc("")
	self:VwOrder("")
	self:VwStars(0)
	self:VwIcon()
	self:VwQuality()
	self:VwEmptyObj(true)
end

function M:VwName(v)
	if not self.lbTxtName then return end
	self.lbTxtName:SetText(v)
end

function M:_ReVal( nNum ,curNum,showNum )
	local _v = nil
	if LE_ItVShowType.Need == self.valType then
		_v = nNum
	elseif LE_ItVShowType.Have == self.valType then
		_v = curNum
	elseif LE_ItVShowType.XNeed == self.valType then
		_v = "x" .. nNum
	elseif LE_ItVShowType.XHave == self.valType then
		_v = "x" .. curNum
	elseif LE_ItVShowType.Have_Need == self.valType then
		_v = curNum .. "/" .. nNum
	elseif LE_ItVShowType.Need_Have == self.valType then
		_v = nNum .. "/" .. curNum
	elseif (LE_ItVShowType.NeedMoreThan1 == self.valType) then
		if nNum > 1 then
			_v = nNum
		end
	end
	
	self.isEnough = curNum >= nNum
	return _v
end

function M:VwValue(v)
	if not self.lbTxtValue then return end
	self.lbTxtValue:SetUText(v)
end

function M:VwValueColor()
	if self.isNoChgColor or not self.lbTxtValue then return end
	local _c = self.isEnough and _c_green or _c_red
	self.lbTxtValue:SetColor( _c )
end

function M:VwOrder(v)
	if not self.lbTxtOrder then return end	
	self.lbTxtOrder:SetText(v)
end

function M:VwDesc(v)
	if not self.lbTxtDesc then return end
	self.lbTxtDesc:SetText(v)
end

function M:VwIcon(icon)
	self.icon = icon
	if not self.lbImgIcon then return end
	local _isAtive = icon ~= nil
	if _isAtive then
		self.lbImgIcon:SetIcon(icon)
	end
	self.lbImgIcon:SetActive(_isAtive)
end

-- 显示品质
function M:VwQuality(quality)
	self.quality = quality
	if not self.lbImgQuality then return end
	local _imgQ = quality
	local _isAtive = _imgQ ~= nil
	if _isAtive then
		self.lbImgQuality:SetIcon(_imgQ)
	end
	self.lbImgQuality:SetActive(_isAtive)
end

--显示星星
function M:VwStars(nStars)
	if not self.lbStars then return end
	nStars = tonumber(nStars) or 0
	local _nsize = #self.lbStars
	local _max,_tmp = m_max( _nsize,nStars )
	for i=1,_max do
		if i > _nsize then
			_tmp = self.CsClone(self.lbStars[1])
			insert(self.lbStars,_tmp)
		else
			_tmp = self.lbStars[i]
		end
		_tmp:SetActive( i <= nStars )
	end
end

function M:VwEmptyObj(isActive)
	if not self.lbTrsfEmpty then return end
	self.lbTrsfEmpty:SetActive(isActive == true)
end

return M
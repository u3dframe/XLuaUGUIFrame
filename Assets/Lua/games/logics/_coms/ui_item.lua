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

local tonumber,type,tostring = tonumber,type,tostring
local str_format = string.format
local tb_lens = table.lens
local m_max = math.max
local LUtils = LUtils
local _c_temp = Color.white
local _c_red,_c_green,_c_white = nil
local MgrStore

local super,_evt = UICell,Event
local M = class( "ui_item",super )

function M:BuilderUObj( uobj )
	return CEDUIItem.Builder( uobj )
end

-- 用[_]占位，兼容row传递参数
function M:OnSetData(nRowOrColumn,valType,isVwEmpty,isNoChgColor,Synlv)
	self.cur_index = nRowOrColumn
	self.valType = valType or LE_ItVShowType.Have
	self.isVwEmpty = isVwEmpty == true
	self.isNoChgColor = isNoChgColor == true
	self.Synlv = Synlv
end

function M:OnInit()
	MgrStore = MgrStore or _G.MgrStore

	self.isShowShadow = true
	self:Select(false)
	self:Lock(false)
	self:SetTopTag()
	self:SetMinHero()
	self:ShowFrag(false)
	self:VwEmptyObj(false)
end

function M:OnView()
	local _data = self.data -- type,id,num
	local _cfg,_svData = nil; -- 本地数据
	local _desc,_ord, _feature = nil
	local _rare = nil
	local _showNum = ""
	local _qua,_name,_icon,_star,_cNum = nil
	local _type,_cfgid,_nNum,_level = _data[1],_data[2],(_data[3] or 0)
	_cfg = MgrStore:GetItemCfg(_type,_cfgid)
	if not _cfg then
		printError("==== ui_item,not has cfg ; type = [%s],id = [%s],num = [%s]",_type,_cfgid,_nNum)
		return
	end
	
	if _type == 1 or _type == 2 or _type == 3 or _type == 4 or _type == 5 or _type == 8 then 
		_showNum = MgrStore:GetItemNumStr(_type,_cfgid)
	elseif _type == 6 then 
		_rare = _cfg.rare
		_feature = _cfg.feature
		_level = _nNum
	end
	_qua = _cfg.quality
	_name = _cfg.name 
	_icon = _cfg.min_icon or _cfg.icon
	_star = _cfg.star or 0
	_cNum = MgrStore:GetItemNum(_type,_cfgid) or 1

	local _val = self:_ReVal(_nNum,_cNum,_showNum)
	self:VwName(_name)
	self:VwDesc(_desc)
	self:VwOrder(_ord)
	local _de = (_type == 6) and "Lv." or "x"
	self:VwValueDesc(_de)
	self:VwStars(_star, _qua)
	self:VwIcon(_icon,_type,_cfgid,_type)
	self:VwRare(_rare, _qua)
	self:VwQuality( _qua)
	self:VwBgImg(_qua)
	self:VwEmptyObj(false)
	self:VwDQuality(_type, _level or _val, _qua,_feature)
end

function M:OnVwEmpty()
	self.data,self.cfgData,self.svData = nil
	self:VwName("")
	self:VwValue()
	self:VwValueDesc()
	self:VwDesc("")
	self:VwOrder()
	self:VwStars(0)
	self:VwIcon()
	self:VwRare()
	self:VwQuality()
	self:VwBgImg()
	self:VwEmptyObj(true)
	self:VwDQuality()
	self:SetFeature( )
end

function M:VwName(v)
	self.csEDComp:VwName( v )
end

function M:VwNameColor(r,g,b,a)
	_c_temp = LUtils.RColor( _c_temp,r,g,b,a )
	self.csEDComp:VwNameColor( _c_temp )
end

function M:_ReVal( nNum ,curNum,showNum )
	local _v = nil
	if LE_ItVShowType.Need == self.valType then
		_v = nNum
	elseif LE_ItVShowType.Have == self.valType then
		--_v = curNum
		_v = showNum
	elseif LE_ItVShowType.XNeed == self.valType then
		_v = "x" .. nNum
	elseif LE_ItVShowType.XHave == self.valType then
		--_v = "x" .. curNum
		_v = "x" .. showNum
	elseif LE_ItVShowType.Have_Need == self.valType then
		-- _v = curNum .. "/" .. nNum
		_v = showNum .. "/" .. nNum
	elseif LE_ItVShowType.Need_Have == self.valType then
		--_v = nNum .. "/" .. curNum
		_v = nNum .. "/" .. showNum
	elseif (LE_ItVShowType.NeedMoreThan1 == self.valType) then
		if nNum > 1 then
			_v = nNum
		end
	end
	self.isEnough = curNum >= nNum
	return _v
end

function M:VwValue(v,isNoUTxt)
	isNoUTxt = (isNoUTxt == true)
	self.csEDComp:VwValue( v,(not isNoUTxt) )
end

function M:VwValueDesc(v)
	self.csEDComp:VwValueDesc( v )
end

function M:VwValueColor(r,g,b,a)
	if self.isNoChgColor then return end
	local _c = r
	if _c == nil then
		_c_red,_c_green = (_c_red or Color.red),(_c_green or Color.green)
		_c = self.isEnough and _c_green or _c_red
	else
		_c = LUtils.RColor( _c_temp,r,g,b,a )
	end
	self.csEDComp:VwValueColor( _c )
end

--值背景
function M:VwValueBg(quality)
	local _icon = nil
	if quality then
		_icon = "item_d_" .. quality
	end
	self.csEDComp:VwValueBg( _icon )
end

function M:VwOrder(v)
	self.csEDComp:VwOrder( v )
end

function M:VwTag(v)
	self.csEDComp:VwTag( v )
end

function M:VwDesc(v)
	self.csEDComp:VwDesc( v )
end

function M:VwIcon(icon,ntype,cid,ctype)
	self.icon = icon
	ntype = tonumber(ntype) or 0
	self.csEDComp:VwIcon( icon,ntype )
	local _cid = cid or self.data[2]
	local _ctype = ctype
	if _ctype and _ctype == MgrStore.EquipType and _cid then 	
		local _cfg_ = MgrData:GetOneData("equip", _cid)
		local x,y = 0,0
		local _scale = _cfg_.scale
		if _scale then
			x,y = _scale[1],_scale[2]
		end
		self.csEDComp:SetIconSize(x,y)
	end 
end

-- 显示品质
function M:VwQuality(quality,isNotRe)
	local _icon = quality
	if quality and not isNotRe then
		_icon = "eitem_q_" .. quality
	end
	self.csEDComp:VwQuality( _icon )
end

-- 显示背景品质
function M:VwBgImg(quality)
	local _icon = nil
	if quality then
		_icon = "bg_item_" .. quality
	end
	self.csEDComp:VwBgImg( _icon )
end

-- 显示品质
function M:VwDQuality(type, value, quality, feature)
	local _isVal = (value ~= nil)
	if _isVal then
		self:VwValue( value )
		--_c_white = _c_white or Color.white
		local _c = _c_white
		if self.Synlv then    -- 英雄显示映射等级
			_c = LUtils.RColor( _c_temp,246,218,0,255 )
		end
		self:VwValueColor( _c )
	end

	local _isVBg = (feature == nil)
	local _qua = (_isVal and _isVBg) and quality or nil
	self:VwValueBg( _qua )

	if MgrStore:IsHeroType(type) or MgrStore:IsEquipType(type) then
		self:SetFeature(quality, feature)
	else
		self:SetFeature()
	end
end

-- SSR
function M:VwRare(rare, quality)
	local _icon = nil
	if quality and rare then
		_icon = str_format( "rare_%s_%s",quality,rare )
	end
	self.csEDComp:VwSSR( _icon )
end

--显示星星
function M:VwStars(nStars, quality)
	nStars = tonumber(nStars) or 0
	local _iconbg,_icon = nil
	if quality then
		_iconbg = "star_b_" .. quality
		_icon = "star_q_" .. quality
	end
	self.csEDComp:VwStars( nStars,_iconbg,_icon )
end

function M:VwEmptyObj(isActive)
	self.csEDComp:VwEmptyObj(isActive == true)
end

function M:ShowShadow(isShow)
	self.csEDComp:VwShadow(isShow == true)
end

function M:SetClickHandler(func)
	self.clickHandler = func
	if type(func) == "function" and not self.lbBgBtn then
		self.lbBgBtn = self:NewBtn("bg", function()
			if type(self.clickHandler) == "function" then
				self.clickHandler(self)
			end
		end, nil, true)
	end
end

function M:SetSubBtnHandler(func)
	self.subBtnHandler = func
	if type(func) == "function" and not self.subBtn then
		self.subBtn = self:NewBtn("subBtn", function()
			if type(self.subBtnHandler) == "function" then
				self.subBtnHandler(self)
			end
		end)
	end
end

function M:Select(b)
	self.csEDComp:VwSelect(b == true)
end

function M:ShowSubBtn(b)
	if not self.subBtn then return end
	self.subBtn:SetActive(b)
end

function M:SetTopTag(id)
	self.csEDComp:VwTopTag( id )
end

function M:SetTagdi( quality)
	local _icon = nil
	if quality then
		_icon = "eitem_d_" .. quality
	end

	self.csEDComp:VwFeatureBg( _icon )
end

function M:SetFeature(quality,feature,isNotRe)
	local _icon = feature
	if feature and not isNotRe then
		local _obj = MgrData:GetCfgBasic("hero_features")
		if _obj and _obj[feature] then
			_icon = "features_".._obj[feature]
		end
	end
	self.csEDComp:VwFeatureIcon( _icon )
	self:SetTagdi( (_icon ~= nil) and quality or nil )
end

function M:SetMinHero(uuid)
	if not uuid then
		return
	end
	local hero,_cfg_ = MgrStore:GetStoryData(MgrStore.HeroType, uuid)
	local _icon,_str,_quality = nil
	local offX,offY = 0,0
	if hero and hero.config then
		_cfg_ = hero.config
		_str = "Lv." .. hero.level
		_icon = _cfg_.min_icon
		local offset = _cfg_.minhero_offset
		if offset then
			offX,offY = offset[1],offset[2]
		end
		_quality = _cfg_.quality
	end
	self.csEDComp:VwMinHero( _icon,_str,offX,offY )
	self:VwValueBg( _quality )
end

function M:ShowFrag(b)
	self.csEDComp:VwFragment(b == true)
end

function M:ShowByArgs(ty, id, cnt, feature, level)
	level = level or 0
	if MgrStore:IsEquipType(ty) and level > 0 then
		level = "+"..level
		self:VwOrder(level)
	else
		self:VwOrder()
	end
	local cfg = MgrStore:GetItemCfg(ty, id)
	self:VwTag(cfg.tag)
	local fragCfg = {}
	local isFrag = MgrStore:IsItemType(ty) and MgrStore:IsItemFragment(id)
	if isFrag and MgrStore:IsItemFixedFragment(id) then
		local fragTarget = cfg.usepara[2]
		fragCfg = MgrStore:GetItemCfg(fragTarget[1], fragTarget[2])
	end
	self:VwStars(cfg.star or fragCfg.star, cfg.quality)
	local icon = MgrStore:IsHeroType(ty) and cfg.min_icon or cfg.icon
	self:VwIcon(icon, ty,id,ty)
	self:VwRare(fragCfg.rare or cfg.rare, fragCfg.rare and fragCfg.quality or cfg.quality)
	self:VwQuality( cfg.quality)
	self:VwBgImg(cfg.quality)
	self:SetFeature(cfg.quality)
	if not MgrStore:IsEquipType(ty) and (not feature or feature == 0) then
		feature = cfg.feature or fragCfg.feature
	end
	feature = feature or 0
	cnt = cnt or 0
	self:VwValueBg()
	if feature > 0 and cnt > 1 then
		self:VwValueDesc("x")
		self:VwValue(cnt)
		self:VwValueBg(cfg.quality)
		self:SetFeature(cfg.quality, feature)
	elseif feature > 0 then
		self:SetFeature(cfg.quality, feature)
		if MgrStore:IsHeroType(ty) and level > 0 then
			self:VwValueBg(cfg.quality)
			self:VwValueDesc("LV.")
			self:VwValue(level)
			self:SetFeature(cfg.quality, feature)
		end
	elseif cnt > 1 then
		self:VwValueBg(cfg.quality)
		self:VwValueDesc("x")
		self:VwValue(cnt)
	end
	self:ShowFrag(isFrag)
end

function M:Lock(b)
	self.csEDComp:VwLock(b == true)
end

return M
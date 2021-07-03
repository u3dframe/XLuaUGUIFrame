--[[
	-- ui 模版类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-05 09:25
	-- Desc : 显示隐藏界面 self:View(true/false,data,parameter1,p2,...)
	-- 界面需要绑定脚本 PrefabeElement.cs
]]

local _clsCell = require("xxx/xx/xx1") -- 列表单元
local _clsPart = require("xxx/xx/xx2") -- 界面部分part
local _mgr -- 界面的管理脚本
local super = UIBase
local M = class( "ui_xxx",super )

-- 构造参数(必要)
function M:onAssetConfig( _cfg )
	-- _mgr = Mgrxxxx -- 配置在 define_luafp 里面的管理脚本
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.abName = "login/uilogin" -- ui 资源 ab 名，在prefab/ui/文件夹下
	-- _cfg.assetName = "uiroot.prefab" -- ab里面的资源Asset名
	-- _cfg.assetLType = LE_AsType.UI 资源类型
	-- _cfg.layer = LE_UILayer.Normal -- 所在层级 默认是 Normal 层
	-- _cfg.isStay = true -- 常驻界面不销毁
	-- _cfg.isUpdate = true -- 是否调用update 对应函数 function M:OnUpdateLoaded(dt)
	-- _cfg.isLogVTime = true -- 打印 _OnView 执行时间
	
	-- 界面通用按钮(界面独立按钮)，取得按钮的方式：self.lbBtnXxx
	--_cfg.lbBtns = {
		--{name = "elName"(绑定在PrefabeElement里面的对象), func = 单击执行函数, val = 按钮文字(可), isNoScale = 单击时是否-不缩放(可), isNoPrint = 没有时是否-不告知(可)},
		--{name = "Close",func = handler(self, self.OnClickCloseSelf),val = 201}, -- 取得按钮的方式：self.lbBtnClose
		--{name = "GoFight",func = function() self:OnClick2Fight(); end,val = "开始战斗"}, -- 取得按钮的方式：self.lbGoFight
	--}
	return _cfg;
end

-- 初始化对象只调用一次(必要)
function M:OnInit()
	local _tmp
	-- self.lbTxtXxx = self:NewTxt("elementName");
	-- self.lbBtnXxx = self:NewBtn("elementName",callFunc,val,isNoScale)
	-- self.lbTogXxx = self:NewTog(elName,uniqueID,callFunc,val,isNoCall4False)
	-- self.lbSclXxx = self:NewScl(elName,funcCreat,funcSetData,gobjItem)
	-- self.lbTrsfXxx = self:NewTrsf(elName);
	-- self.lbCompXXX = self:NewComp(elName,compName);
	
	_tmp = self:GetElement("elName") -- GetElementTrsf , GetElementComponent
	self.lbPartXxx = _clsPart.New(_tmp,self)
	
	_tmp = self:GetElement("elName")
	self.lbCellXxx = _clsCell.New(_tmp)

	-- 循环滚动： 多行多列/单行单列（无外部脚本的） -- 不支持非固定大小，和多个固定大小子元素的混合
	self.lbUSclXxx = self:NewUScl(elName,{
		clsLua = _clsCell, -- 可以为 require 后对象，也可以为字符串(需要被 require 的脚本路径):"xxx/xx/cellXxx"，还有为 Create 函数
		-- clsLua = "xxx/xx/cellXxx",
		-- clsLua = function(newGobj,clickFunc) end,
		
		cfClick = function(lbCell) end, -- 单击单元格执行函数； handler(self,self.OnClickCellXxx)
		-- cfClick = handler(self,self.OnClickCellXxx),
		-- cfShow = function(lbCell,nRow,ext1,ext2,...) end, -- 可以自定义的展示数据函数（可选，一般是子元素的无对应脚本时使用）
		nColumn = 5, -- 该字段存在并且大于1的时多行多列，否则为单行单列
		isVertical = true/nil,
		
		-- isAlpha = true/nil, -- 是否让计算单元Cell对象Alpha (为true时，cell脚本对象self.alpha就有值了)
		-- ext_1 = _lfBegDrag, -- ext_1~ext_10 （可选，透传参数1~10）
		-- gobjCell = 指定列表子元素对象（可选）,
	})
	
	-- 循环滚动： 多行多列/单行单列（自定义外部脚本的 LoopListView3 ） -- 支持多个固定大小子元素的混合 ; 不支持非固定大小
	self.lbCSclXxx = self:NewUSclLoop(elName,{
		clsLua = _clsCell, -- 可以为 require 后对象，也可以为字符串(需要被 require 的脚本路径):"xxx/xx/cellXxx"，还有为 Create 函数
		-- clsLua = "xxx/xx/cellXxx",
		-- clsLua = function(newGobj,clickFunc) end,
		
		itemName = "绑定到 LoopListView3里面的对应的name；如果是多个子对象时为函数，取当前对应name",
		cfClick = function(lbCell) end, -- 单击单元格执行函数； handler(self,self.OnClickCellXxx)
		-- cfClick = handler(self,self.OnClickCellXxx),
		-- cfShow = function(lbCell,nRow,ext1,ext2,...) end, -- 可以自定义的展示数据函数（可选，一般是子元素的无对应脚本时使用）
		nColumn = 5, -- 该字段存在并且大于1的时多行多列，否则为单行单列
		
		-- scaleNode = 子对象缩放节点名,
		-- scaleMin = 最小缩放值,
		-- scaleMax = 最大缩放值,
		
		-- alphaNode = 子对象透明节点名,
		-- alphaMin = 最小透明值（不会小于0）,
		-- alphaMax = 最大透明值（不会大于1）,
		
		-- ext_1 = _lfBegDrag, -- ext_1~ext_10 （可选，透传参数1~10）
		-- gobjCell = 指定列表子元素对象（可选）,
	})
	
	-- 动态创建组件列表：elName的为列表父对象，会克隆子对象
	self.lbListXxx = self:NewULst(elName,{
		clsLua = _clsCell, -- 可以为 require 后对象，也可以为字符串(需要被 require 的脚本路径):"xxx/xx/cellXxx"，还有为 Create 函数
		-- clsLua = "xxx/xx/cellXxx",
		-- clsLua = function(newGobj,clickFunc) end,
		
		cfClick = function(lbCell) end, -- 单击单元格执行函数； handler(self,self.OnClickCellXxx)
		-- cfClick = handler(self,self.OnClickCellXxx),
		-- cfShow = function(lbCell,nRow,ext1,ext2,...) end, -- 可以自定义的展示数据函数（可选，一般是子元素的无对应脚本时使用）
		-- ext_1 = _lfBegDrag, -- ext_1~ext_10 （可选，透传参数1~10）
	})
end

-- 显示的时候都会调用，做数据的刷新更新(必要)
function M:OnShow()
	self.lbPartXxx:ShowViewByData(data)
	self.lbCellXxx:ShowViewByData(data)
	
	self.lbUSclXxx:ShowScroll(listData)
	self.lbCSclXxx:ShowScroll(listData)
	self.lbListXxx:ShowScroll(listData)
end

-- 隐藏，销毁都会调用(必要)
function M:OnEnd(isDestroy)
end

-- 接受参数，当界面调用 View(true,data,p1,p2,...) (非必要)
function M:OnSetData(p1,p2,...)
	-- 取第一个data参数时 self.data
	-- data后面参数在此函数里面接收
end

-- 当isUpdate = true,资源加载完毕后，每帧才会回调(非必要)
function M:OnUpdateLoaded(dt)
end

-- 自定义的刷新事件绑定函数(非必要,处理事件刷新)
function M:ReEvent4Self(isBind)
	local _evt = self._fevt()
	-- _evt.RemoveListener(Evt_RefreshXxx,self.Refresh,self); -- 移除事件
	if isBind == true then
		-- _evt.AddListener(Evt_RefreshXxx,self.Refresh,self); -- 添加事件
	end
end

-- 刷新界面
function M:Refresh()
end

return M
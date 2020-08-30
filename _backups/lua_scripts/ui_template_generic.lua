--[[
	-- ui 模版类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-05 09:25
	-- Desc : 显示隐藏界面 self:View(true/false)
	-- 界面需要绑定脚本 PrefabeElement.cs
]]

local _clsCell = require("xxx/xx/xx1") -- 列表单元
local _clsPart = require("xxx/xx/xx2") -- 界面部分part

local _mgr -- 界面管理脚本
local super,_evt = UIBase,Event
local M = class( "ui_xxx",super )

-- 构造参数(必要)
function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.abName = "login/uilogin" -- ui 资源 ab 名，在prefab/ui/文件夹下
	_cfg.isLogVTime = true
	-- _cfg.assetName = "uiroot.prefab" -- ab里面的资源Asset名
	-- _cfg.assetLType = LE_AsType.UI 资源类型
	-- _cfg.layer = LE_UILayer.Normal -- 所在层级 默认是 Normal 层
	-- _cfg.isStay = true -- 常驻界面不销毁
	-- _cfg.isUpdate = true -- 是否调用update 对应函数 function M:OnUpdateLoaded(dt)
	return _cfg;
end

-- 初始化对象只调用一次(必要)
function M:OnInit()
	local _tmp
	-- _mgr = Mgrxxxx -- 配置在 define_luafp 里面的管理脚本
	-- self.lbTxtXxx = self:NewTxt("elementName");
	-- self.lbBtnXxx = self:NewBtn("elementName",callFunc,val,isNoScale)
	-- self.lbTogXxx = self:NewTog(elName,uniqueID,callFunc,val,isNoCall4False)
	-- self.lbSclXxx = self:NewScl(elName,funcCreat,funcSetData,gobjItem)
	-- self.lbTrsfXxx = self:NewTrsf(elName);
	-- self.lbCompXXX = self:NewComp(elName,compName);
	
	_tmp = self:GetElement("elName")
	self.lbPartXxx = _clsPart.New(_tmp,self)
	
	_tmp = self:GetElement("elName")
	self.lbCellXxx = _clsCell.New(_tmp)

	-- 多行多列的
	self.lbUSclXxx = self:NewUScl(elName,{
		clsLua = _clsCell,
		cfClick = function(lbCell) end,
		nColumn = 5,
		isVertical = true/nil
		ext_1 = _lfBegDrag,
		ext_2 = _lfDrag,
		ext_3 = _lfEndDrag,
	})
	-- 单行单列
	self.lbUSclXxx = self:NewUScl(elName,{
		clsLua = _clsCell,
		cfClick = function(lbCell) end,
		isVertical = true/nil
	})
end

-- 显示的时候都会调用，做数据的刷新更新(必要)
function M:OnShow()
	self.lbPartXxx:ShowViewByData(data)
	self.lbUSclXxx:ShowScroll(listData)
end

-- 隐藏，销毁都会调用(必要)
function M:OnEnd(isDestroy)
end

function M:OnSetData()
end

-- 当isUpdate = true,资源加载完毕后，每帧才会回调(非必要)
function M:OnUpdateLoaded(dt)
end

-- 自定义的刷新事件绑定函数(非必要,处理事件刷新)
function M:ReEvent4Self(isBind)
	-- _evt.RemoveListener(Evt_ToChangeScene,self.Refresh,self); -- 移除事件
	if isBind == true then
		-- _evt.AddListener(Evt_ToChangeScene,self.Refresh,self); -- 添加事件
	end
end

function M:Refresh()
end

return M
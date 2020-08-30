--[[
	-- ui 模版类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-05 09:25
	-- Desc : 显示隐藏界面 self:View(true/false)
	-- 界面需要绑定脚本 PrefabeElement.cs
]]

local super,_evt = UIBase,Event
local M = class( "ui_xxx",super )

-- 构造参数(必要)
function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.abName = "prefabs/ui/uiroot.ui" -- 资源ab 名
	-- _cfg.assetName = "uiroot.prefab" -- ab里面的资源Asset名
	-- _cfg.assetLType = LE_AsType.UI 资源类型
	_cfg.layer = LE_UILayer.Normal -- 所在层级
	-- _cfg.isStay = true -- 常驻界面不销毁
	-- _cfg.isUpdate = true -- 是否调用update 对应函数 function M:OnUpdateLoaded(dt)
	return _cfg;
end

-- 初始化对象只调用一次(必要)
function M:OnInit()
	-- self.lbTxtName = self:NewTxt("elementName");
	-- self.lbBtnSure = self:NewBtn("elementName",callFunc,val,isNoScale)
	-- self.lbTogTitle = self:NewTog(elName,uniqueID,callFunc,val,isNoCall4False)
	-- self.lbSclSvlist = self:NewScl(elName,funcCreat,funcSetData,gobjItem)
	-- self.gobjXXX = self:GetElement(elName); -- 取子元素GameObject
	-- self.compXXX = self:GetElementComponent(elName,compName); -- 取子元素的组件
	-- self._lfXxx = self._lfXxx or handler(self,self.xxxFunc)
	-- _evt.AddListener(Evt_ToChangeScene,self._lfXxx); -- 添加事件
end

-- 显示的时候都会调用，做数据的刷新更新(必要)
function M:OnShow()
end

-- 隐藏的时候会调用 (可选)
function M:OnHide()
end

-- 销毁的时候会调用 (可选)
function M:OnDestroy()
end

-- 隐藏，销毁都会调用(可选)
function M:OnEnd(isDestroy)
-- _evt.RemoveListener(Evt_ToChangeScene,self._lfXxx); -- 移除事件
end

-- 当isUpdate = true,资源加载完毕后，每帧才会回调(非必要)
function M:OnUpdateLoaded(dt)
end

return M
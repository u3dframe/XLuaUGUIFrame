--[[
	-- ui 子对象，或者ui的部分part对象
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-05 09:25
	-- Desc : 显示隐藏界面 self:ShowViewByData(data)
	-- 界面需要绑定脚本 PrefabeElement.cs
]]

local super = UICell
local M = class( "uicell_xxx",super ) -- uipart_xxx

-- 初始化对象只调用一次(必要)
function M:OnInit()
	-- self.isVwEmpty = true --是否数据data为空是也要显示
	-- self.lbTxtXxx = self:NewTxt("elementName");
	-- self.lbBtnXxx = self:NewBtn("elementName",callFunc,val,isNoScale)
	-- self.lbTogXxx = self:NewTog(elName,uniqueID,callFunc,val,isNoCall4False)
	-- self.lbSclXxx = self:NewScl(elName,funcCreat,funcSetData,gobjItem)
	-- self.lbTrsfXxx = self:NewTrsf(elName);
	-- self.lbCompXXX = self:NewComp(elName,compName);

	-- self._lfXxx = self._lfXxx or handler(self,self.xxxFunc) -- 定义事件
end

function M:OnSetData( xx1,xx2 )
	self.xx1 = xx1
	self.xx2 = xx2
end

-- self.data 不为空的时候(必要)
function M:OnView()
end

-- self.data 为空的时候(非必要,self.isVwEmpty == true时才会调用)
function M:OnVwEmpty()
end

-- 自定义的刷新事件绑定函数(非必要,处理事件刷新)
function M:ReEvent4Self(isBind)
	local _evt = self._fevt()
	-- _evt.RemoveListener(Evt_ToChangeScene,self._lfXxx); -- 移除事件
	if isBind == true then
		-- _evt.AddListener(Evt_ToChangeScene,self._lfXxx); -- 添加事件
	end
end

return M
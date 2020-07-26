--[[
	-- 登录界面管理脚本
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]

local M = {}

function M:Init()
	Event.AddListener(Evt_ToView_Login,handler(self,self.ToLoginView));
	printTable(M)
end

function M:ToLoginView()
	printInfo("=== 1")
	local _gobj = UGameObject.New()
	printInfo("=== 2")
	coroutine.wait(2)
	local _glife = CGobjLife.Get(_gobj);
	printWarn("=== 1")
	_glife.m_onDestroy = function() printError("=========destory") end
	_glife:DetroySelf();
	printWarn("=== 2")
	coroutine.wait(5)
	printWarn("=== 3")
	_glife = CGobjLife.Get(_gobj);
	_glife.m_onDestroy = function() printError("=========destory2") end
	_glife:DetroySelf(false);
	printError("=== 1")
	coroutine.wait(3)
	_glife = CPElement.Get(_gobj);
	_glife.m_onDestroy = function() printError("=========destory4") end
	_glife:DetroySelf(false);
	coroutine.wait(3)
	printError("=== 5")
	printInfo(string.csFmt2Luafmt("{0}天{1}时{2}分{3}秒"))
	printInfo(string.csFmt2Luafmt("{0}天{1}时{2}分{3}秒{4}"))
	printInfo(string.csFmt2Luafmt("时{2}分{3}秒"))
	printInfo(string.csFmt2Luafmt("{0:D2}:{1:D2}:{2:D2}"))
end

function M:OnUpdate(dt)
	if not self.uptime or self.uptime <= 0 then
		self.uptime = 1;
		if not self.objdd then
			self.objdd = MgrRes.GetAsset(self.cfgAsset.abName,self.cfgAsset.assetName,self.cfgAsset.assetLType);
		end
		printTable(self.objdd,"obj");
		-- printInfo(self.assetCfg.abName)
	end
	self.uptime = self.uptime - dt;
end

return M
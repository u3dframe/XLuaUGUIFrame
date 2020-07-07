--[[
	-- 游戏入口脚本
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]

local _MG = _G;

local M = {}

function M:Init()
	Event.AddListener(Evt_GameEntryAfterUpRes,handler(self,self.EntryAfterUpRes));
end

function M:EntryAfterUpRes()
	-- UIRoot.singler()
	local ui = UIBase.New({
		abName = "prefabs/updateui.fab",
		-- assetName = "updateui.prefab",
	});
	-- ui.lfLoaded = function() UIRoot.singler() end
	ui:View(true)
end

return M
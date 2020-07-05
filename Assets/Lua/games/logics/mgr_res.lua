--[[
	-- 加载资源脚本
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-04 10:25
	-- Desc : 
]]

local M = {}
local this = M

function M.Init()
	this._InitLoadFuncs()
end

function M._InitLoadFuncs()
	local _lb  = this.lbLoadFuncs or {}
	this.lbLoadFuncs = _lb
	_lb[LE_AsType.Fab] = this._LoadFab;
	_lb[LE_AsType.Sprite] = this._LoadSprite;
	_lb[LE_AsType.Texture] = this._LoadTexture;
end


function M._LoadFab(abName,assetName,callLoad)
	CResMgr.LoadFab(abName,assetName,function(obj)
		printInfo("== [%s] == [%s] == [%s] ",abName,assetName,obj)
		if callLoad then
			callLoad(obj);
		end
	end)
end

function M._LoadSprite(abName,assetName,callLoad)
	CResMgr.LoadSprite(abName,assetName,function(obj)
		printInfo("== [%s] == [%s] == [%s] ",abName,assetName,obj)
		if callLoad then
			callLoad(obj);
		end
	end)
end

function M._LoadTexture(abName,assetName,callLoad)
	CResMgr.LoadTexture(abName,assetName,function(obj)
		printInfo("== [%s] == [%s] == [%s] ",abName,assetName,obj)
		if callLoad then
			callLoad(obj);
		end
	end)
end

function M.LoadAsset(abName,assetName,assetLType,callLoad)
	local _func = this.lbLoadFuncs[assetLType];
	if _func then
		_func(abName,assetName,callLoad);
	else
		printError("load asset err by type, abName =[%s],assetName =[%s],aLtype =[%s]",abName,assetName,assetLType);
	end
end

function M.UnLoad(abName,assetName,assetLType)
	if LE_AsType.Fab == assetLType then
		CResMgr.UnLoadFab(abName,assetName);
	else
		CResMgr.UnLoadAsset(abName);
	end
end

return M
--[[
	-- 加载资源脚本
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-04 10:25
	-- Desc : 
]]

local _csRes = CResMgr

local M = {}
local this = M

function M.Init()
	this._InitLoadFuncs()
	this._GetAssetFuncs()
end

function M._InitLoadFuncs()
	local _lb  = this.lbLoads or {}
	this.lbLoads = _lb
	_lb[LE_AsType.Fab] = this._LoadFab;
	_lb[LE_AsType.UI] = this._LoadFab;
	_lb[LE_AsType.Sprite] = this._LoadSprite;
	_lb[LE_AsType.Texture] = this._LoadTexture;
end

function M._GetAssetFuncs()
	local _lb  = this.lbGets or {}
	this.lbGets = _lb
	_lb[LE_AsType.Fab] = this._Get4Fab;
	_lb[LE_AsType.UI] = this._Get4Fab;
	_lb[LE_AsType.Sprite] = this._Get4Sprite;
	_lb[LE_AsType.Texture] = this._Get4Texture;
end

function M._LoadFab(abName,assetName,callLoad)
	_csRes.LoadFab(abName,assetName,callLoad)
end

function M._LoadSprite(abName,assetName,callLoad)
	_csRes.LoadSprite(abName,assetName,callLoad)
end

function M._LoadTexture(abName,assetName,callLoad)
	_csRes.LoadTexture(abName,assetName,callLoad)
end

function M.LoadAsset(abName,assetName,assetLType,callLoad)
	local _func = this.lbLoads[assetLType];
	if _func then
		_func(abName,assetName,callLoad);
	else
		printError("load asset err by type, abName =[%s],assetName =[%s],aLtype =[%s]",abName,assetName,assetLType);
	end
end

function M.UnLoad(abName,assetName,assetLType)
	if assetLType == LE_AsType.UI or assetLType == LE_AsType.Fab then
		this.ClearPool(abName,assetName);
	else
		_csRes.UnLoadAsset(abName);
	end
end

function M.ReturnObj(abName,assetName,gobj)
	_csRes.ReturnObj(abName,assetName,gobj);
end

function M.ClearPool(abName,assetName)
	_csRes.UnLoadPool(abName,assetName); -- 清除对象池
end

function M._Get4Fab(abName,assetName)
	return _csRes.GetAsset4Fab(abName,assetName)
end

function M._Get4Sprite(abName,assetName)
	return _csRes.GetAsset4Fab(abName,assetName)
end

function M._Get4Texture(abName,assetName)
	return _csRes.GetAsset4Fab(abName,assetName)
end

function M.GetAsset(abName,assetName,assetLType)
	local _func = this.lbGets[assetLType];
	if _func then
		return _func(abName,assetName);
	else
		printError("get assetinfo err by type, abName =[%s],assetName =[%s],aLtype =[%s]",abName,assetName,assetLType);
	end
end

return M
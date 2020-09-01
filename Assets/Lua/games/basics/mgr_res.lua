--[[
	-- 加载资源脚本
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-04 10:25
	-- Desc : 
]]

local type = type
local _csRes,_evt,CHelper = CResMgr,Event,CHelper

local M = {}
local this = M

function M.Init()
	this._InitLoadFuncs()
	this._GetAssetFuncs()
	_evt.AddListener(Evt_LoadAllShaders,this.LoadShaders)
end

function M._InitLoadFuncs()
	local _lb  = this.lbLoads or {}
	this.lbLoads = _lb
	_lb[LE_AsType.Fab] = this._LoadFabNo;
	_lb[LE_AsType.UI] = this._LoadUI;
	_lb[LE_AsType.Sprite] = this._LoadSprite;
	_lb[LE_AsType.Texture] = this._LoadTexture;
	_lb[LE_AsType.Animator] = this._LoadAnimator;
	_lb[LE_AsType.AnimationClip] = this._LoadAnimationClip;
	_lb[LE_AsType.AudioClip] = this._LoadAudioClip;
	_lb[LE_AsType.Playable] = this._LoadPlayable;
end

function M._GetAssetFuncs()
	local _lb  = this.lbGets or {}
	this.lbGets = _lb
	_lb[LE_AsType.Fab] = this._Get4Fab;
	_lb[LE_AsType.UI] = this._Get4Fab;
	_lb[LE_AsType.Sprite] = this._Get4Sprite;
	_lb[LE_AsType.Texture] = this._Get4Texture;
	_lb[LE_AsType.Animator] = this._Get4Animator;
	_lb[LE_AsType.AnimationClip] = this._Get4AnimationClip;
	_lb[LE_AsType.AudioClip] = this._Get4AudioClip;
	_lb[LE_AsType.Playable] = this._Get4Playable;
end

function M._LoadFab(abName,assetName,callLoad,parent)
	_csRes.LoadFab(abName,assetName,callLoad)
end

function M._LoadFabNo(abName,assetName,callLoad)
	_csRes.LoadFabNoParent(abName,assetName,callLoad)
end

function M._LoadUI(abName,assetName,callLoad)
	_csRes.LoadUIParent(abName,assetName,callLoad,1)
end

function M._LoadSprite(abName,assetName,callLoad)
	_csRes.LoadSprite(abName,assetName,callLoad)
end

function M._LoadTexture(abName,assetName,callLoad)
	_csRes.LoadTexture(abName,assetName,callLoad)
end

function M._LoadAnimator(abName,assetName,callLoad)
	_csRes.LoadAnimator(abName,assetName,callLoad)
end

function M._LoadAnimationClip(abName,assetName,callLoad)
	_csRes.LoadAnimationClip(abName,assetName,callLoad)
end

function M._LoadAudioClip(abName,assetName,callLoad)
	_csRes.LoadAudioClip(abName,assetName,callLoad)
end

function M._LoadPlayable(abName,assetName,callLoad)
	_csRes.LoadTimelineAsset(abName,assetName,callLoad)
end

function M.LoadAsset(abName,assetName,assetLType,callLoad,parent)
	local _func = this.lbLoads[assetLType];
	if (assetLType == LE_AsType.UI) or (assetLType == LE_AsType.Fab) then
		if parent and CHelper.IsTransform(parent) then
			_func = this._LoadFab
		end
	end
	if _func then
		_func(abName,assetName,callLoad,parent);
	else
		printError("load asset err by type, abName =[%s],assetName =[%s],aLtype =[%s]",abName,assetName,assetLType);
	end
end

function M.UnLoad(abName,assetName,assetLType)
	_csRes.UnLoadAsset(abName);
end

function M._Get4Fab(abName,assetName)
	return _csRes.GetAsset4Fab(abName,assetName)
end

function M._Get4Sprite(abName,assetName)
	return _csRes.GetAsset4Sprite(abName,assetName)
end

function M._Get4Texture(abName,assetName)
	return _csRes.GetAsset4Texture(abName,assetName)
end

function M._Get4Animator(abName,assetName)
	return _csRes.GetAsset4Animator(abName,assetName)
end

function M._Get4AnimationClip(abName,assetName)
	return _csRes.GetAsset4AnimationClip(abName,assetName)
end

function M._Get4AudioClip(abName,assetName)
	return _csRes.GetAsset4AudioClip(abName,assetName)
end

function M._Get4Playable(abName,assetName)
	return _csRes.GetAsset4TimelineAsset(abName,assetName)
end

function M.GetAsset(abName,assetName,assetLType)
	local _func = this.lbGets[assetLType];
	if _func then
		return _func(abName,assetName);
	else
		printError("get assetinfo err by type, abName =[%s],assetName =[%s],aLtype =[%s]",abName,assetName,assetLType);
	end
end

function M.GetAB(abName)
	return _csRes.GetABInfo(abName)
end

function M.GetDependences(abName)
	return _csRes.GetDependences(abName)
end

function M.LoadAllShaders(callLoaded)
	_csRes.LoadShaders(callLoaded)
end

function M.LoadShaders()
	this.LoadAllShaders(this.FinishLoadedShaders)
end

function M.FinishLoadedShaders()
	_evt.Brocast(Evt_GameEntryAfterUpRes);
end

return M
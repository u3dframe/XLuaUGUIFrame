--[[
	-- 资源 prefab 基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-13 09:25
	-- Desc : 
]]

local ClsObjBasic = require("games/logics/_base/_objs/obj_basic")

local _E_AType = LE_AsType

local super,super2 = LuaFab,UIPubs
local M = class( "fab_base",super,super2,ClsObjBasic )

function M:ctor(assetCfg)
	super.ctor( self,assetCfg )
	super2.ctor( self )
	ClsObjBasic.ctor( self )
end

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.assetLType = _cfg.assetLType or _E_AType.Fab

	if self.cfgRes then
		_cfg.abName = self.cfgRes.rsaddress
	end
	return _cfg;
end

function M:onMergeConfig( _cfg )
	_cfg = super.onMergeConfig( self,_cfg )
	if _cfg.assetLType == _E_AType.Fab then
		_cfg.abName = self:ReSBegEnd( _cfg.abName,"prefabs/",".fab" )
	end
	return _cfg;
end

function M:GetResCfg(resid,isNoAsset)
	local _cfgRes = MgrData:GetCfgRes(resid)
	if not isNoAsset then
		assert(_cfgRes,"=== fab_base = no res in resource config, resid = [" .. tostring(resid) .. "]")
	end
	return _cfgRes
end

function M:InitAsset4Resid(resid)
	local _cfgRes = self:GetResCfg( resid )
	self.resid = resid
	self.cfgRes = _cfgRes
	
	self:InitAsset( self.cfgAsset )
	return self
end

-- 暂停
function M:Pause()
	if self.isPause then
		return false
	end
	self.isPause = true
	return true
end

-- 恢复
function M:Regain()
	if not self.isPause then
		return
	end
	self.isPause = nil
end

function M:GetSObjBy(uniqueid)
	return MgrScene.OnGet_Map_Obj( uniqueid )
end

function M:GetSObjMapBox()
	return self:GetSObjBy( "map.gbox" )
end

return M
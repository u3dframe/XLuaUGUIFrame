--[[
	-- 资源 prefab 基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-13 09:25
	-- Desc : 
]]

local ClsObjBasic = ClsObjBasic
local str_contains = string.contains
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

local __special_fabs = { "timeline/","groudbox/","spines/" }
-- 没放在 prefabs 文件夹下面的的fab
function M:IsNoInPrefabsFab( abName )
	if not abName or "" == abName then
		return
	end

	local _isSp = false
	for _, value in ipairs(__special_fabs) do
		_isSp = str_contains(abName,value)
		if _isSp then
			return true
		end
	end
end

function M:ReFabABName( abName )
	if abName and abName ~= "" then
		if self:IsNoInPrefabsFab( abName ) then
			abName = self:ReSEnd( abName,".fab" )
		else
			abName = self:ReSBegEnd( abName,"prefabs/",".fab" )
		end
	end
	return abName
end

function M:onMergeConfig( _cfg )
	_cfg = super.onMergeConfig( self,_cfg )
	if _cfg.assetLType == _E_AType.Fab then
		_cfg.abName = self:ReFabABName( _cfg.abName )
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

function M:GetSObjBy(uniqueid)
	return MgrScene.OnGet_Map_Obj( uniqueid )
end

function M:GetSObjMapBox()
	return self:GetSObjBy( "map.gbox" )
end

function M:SetCursor(nCursor)
	self.nCursor = nCursor
	return self
end

function M:GetCursor()
	return self.nCursor
end

return M
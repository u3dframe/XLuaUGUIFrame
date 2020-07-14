--[[
	-- ui base 基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-05 09:25
	-- Desc : 
]]

local _utxt,_ubtn,_utog,_uscl
local function utxt()
	if not _utxt then _utxt = LuText end
	return _utxt
end

local function ubtn()
	if not _ubtn then _ubtn = LuBtn end
	return _ubtn
end

local function utog()
	if not _utog then _utog = LuScl end
	return _utog
end

local function uscl()
	if not _uscl then _uscl = LuScl end
	return _uscl
end

local super = LuaFab
local M = class( "ui_base",super )

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.assetLType = LE_AsType.UI
	_cfg.layer = LE_UILayer.Normal
	return _cfg;
end

function M:GetLayer()
	return self.cfgAsset.layer
end

function M:OnCF_Fab( obj )
	super.OnCF_Fab( self,obj )
	self:_SetSelfLayer()
	if self.lfLoaded then
		self.lfLoaded()
	end
end

function M:_SetSelfLayer()
	local _lay = self:GetLayer()
	if LE_UILayer.URoot == _lay then
		self:SetParent(nil,true)
		self:DonotDestory()
	elseif LE_UILayer.UpRes ~= _lay then
		UIRoot.singler():SetUILayer(self)
	end
end

function M:NewTxt(elName)
	local _gobj = self:GetElement(elName)
	if _gobj then
		return utxt().New(_gobj)
	end
end

function M:NewBtn(elName,callFunc,val,isNoScale)
	local _gobj = self:GetElement(elName)
	if _gobj then
		return ubtn().New(_gobj,callFunc,val,isNoScale)
	end
end

function M:NewTog(elName,uniqueID,callFunc,val,isNoCall4False)
	local _gobj = self:GetElement(elName)
	if _gobj then
		return utog().New(uniqueID,_gobj,callFunc,val,isNoCall4False)
	end
end

function M:NewScl(elName,funcCreat,funcSetData,gobjItem)
	local _gobj = self:GetElement(elName)
	if _gobj then
		return uscl().New(_gobj,funcCreat,funcSetData,gobjItem)
	end
end

return M
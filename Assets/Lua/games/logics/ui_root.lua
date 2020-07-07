--[[
	-- ui base 基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-05 09:25
	-- Desc : 
]]
local __single = nil
local str_format = string.format
local tb_remove = table.remove
local tb_insert = table.insert
local tb_contain = table.contains

local super = UIBase
local M = class( "ui_root",super )

function M.singler()
	if not __single then
		__single = M.New()
		__single:ReShow()
	end
	return __single
end

function M:ctor()
	super.ctor( self )
end

function M:onAssetConfig( assetCfg )
	local _cfg = super.onAssetConfig( self,assetCfg )
	_cfg.abName = "prefabs/uiroot.fab"
	_cfg.assetName = "uiroot.prefab"
	_cfg.isStay = true
	_cfg.layer = LE_UILayer.URoot
	_cfg.isUpdate = true
	return _cfg;
end

function M:OnCF_Fab( obj )
	super.OnCF_Fab( self,obj )

	if not self:IsInitTrsf() then
		return
	end

	local _it
	for _, v in pairs(LE_UILayer) do
		if LE_UILayer.URoot ~= v and LE_UILayer.UpRes ~= v then
			_it = self:GetChild(v);
			if _it then
				self[str_format("l_%s", v)] = LUComonet.New(_it,"UGUICanvasAdaptive")
			else
				printError("=== not has layer child = [%s]",v)
			end
		end
	end
	self.uiCamera = self:GetChildComponent("UICamera","Camera");
end

function M:SetUILayer( lbUIEntity )
	local _lay = lbUIEntity:GetLayer()
	local _key = str_format("l_%s", _lay)
	local _lb = self[_key];
	if not _lb then
		self._lbLayer = self._lbLayer or {}
		if not tb_contain(self._lbLayer,lbUIEntity) then
			tb_insert(self._lbLayer,lbUIEntity)
		end
		printTable(self._lbLayer)
		self._ti_layer = 0.06
		return false;
	end
	lbUIEntity:SetParent(_lb.trsf,true)
	return true
end

function M:OnUpdate(dt)
	self:_OnUpCheckLayer( dt )
end

function M:_OnUpCheckLayer( dt )
	if (not self._lbLayer) or (not self._ti_layer) or (self._ti_layer <= 0) or (#self._lbLayer <= 0) then
		return
	end

	local _it = self._lbLayer[1]
	if self:SetUILayer(_it) then
		tb_remove(self._lbLayer,1)
	end
	self._ti_layer = self._ti_layer - dt
end

return M
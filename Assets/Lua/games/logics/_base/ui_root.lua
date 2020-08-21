--[[
	-- ui base 基础类
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-05 09:25
	-- Desc : 
]]

local tb_remove = table.remove
local tb_insert = table.insert
local tb_contain = table.contains

local super,_evt = UIBase,Event
local M = class( "ui_root",super )

local __single = nil
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

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.abName = "uiroot"
	-- _cfg.assetName = "uiroot.prefab"
	_cfg.isStay = true
	_cfg.layer = LE_UILayer.URoot
	_cfg.isUpdate = true
	return _cfg;
end

function M:OnInit()
	if not self:IsInitTrsf() then
		return
	end

	local _it
	for _, v in pairs(LE_UILayer) do
		if LE_UILayer.URoot ~= v and LE_UILayer.UpRes ~= v then
			_it = self:GetElement(v);
			if _it then
				self[self:SFmt("l_%s", v)] = LUComonet.New(_it,"UGUICanvasAdaptive")
			else
				printError("=== not has layer child = [%s]",v)
			end
		end
	end
	self.lbCamera = self:NewCmr("UICamera")
	self.uiCamera = self.lbCamera.comp
	_evt.Brocast(Evt_Brocast_UICamera,self.lbCamera)
end

function M:SetUILayer( lbUIEntity )
	local _lay = lbUIEntity:GetLayer()
	local _key = self:SFmt("l_%s", _lay)
	local _lb = self[_key];
	if not _lb then
		self._lbLayer = self._lbLayer or {}
		if not tb_contain(self._lbLayer,lbUIEntity) then
			tb_insert(self._lbLayer,lbUIEntity)
		end
		self._ti_layer = 0.06
		return false;
	end
	lbUIEntity:SetParent(_lb.trsf,true)
	return true
end

function M:OnUpdateLoaded(dt)
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

function M:ReEvent4Self(isBind)
	_evt.RemoveListener(Evt_Get_UICamera,self.GetUICamera,self); -- 移除事件
	if isBind == true then
		_evt.AddListener(Evt_Get_UICamera,self.GetUICamera,self); -- 添加事件
	end
end

function M:GetUICamera(lfunc,obj)
	M.DoCallFunc( lfunc,obj,self.lbCamera )
end

return M
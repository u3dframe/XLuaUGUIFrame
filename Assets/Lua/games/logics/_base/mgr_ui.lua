--[[
	-- 管理 - UI界面
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-01 09:35
	-- Desc : 
]]

local tb_insert,tb_con,tb_conf,tb_rmf = table.insert,table.contains,table.contains_func,table.removeValuesFunc
local _E_Layer,_E_Hide = LE_UILayer,LE_UI_Mutex
local _layVw,_lay_1 = {},{_E_Layer.Default,_E_Layer.Main,_E_Layer.Background,_E_Layer.Normal,_E_Layer.Pop,_E_Layer.Message,_E_Layer.Top}
local _clsUI,_clsUrt = UIBase,UIRoot

local super,_evt = MgrBase,Event
local M = class( "mgr_ui",super )
local this = M

function M.Init()
	this.uiViews = {}
end

function M.URoot()
	return _clsUrt.singler()
end

local function _lf_equipLUI(item,p1)
	return (item == p1) or (item.strABAsset ~= nil and item.strABAsset == p1.strABAsset)
end

function M.AddViewUI(ui)
	if not ui:IsHasSupper( _clsUI ) then return end
	
	local _layer = ui:GetLayer()
	if not _layer then return end

	local _lb = this.uiViews[_layer] or {}
	local _isHas = tb_conf( _lb,_lf_equipLUI,ui )
	if _isHas then
		-- _pErr("== multiple create by res name = [%s] ==",ui.strABAsset)
		return
	end
	tb_insert( _lb,ui )

	if not tb_con( _layVw,_layer ) then
		tb_insert( _layVw,_layer )
	end
	this.uiViews[_layer] = _lb
end

function M.RmViewUI(ui)
	local _layer = ui:GetLayer()
	if not _layer then return end
	local _lb = this.uiViews[_layer]
	if not _lb then return end
	tb_rmf(_lb,_lf_equipLUI,ui)
end


function M.HideAll(layer,exceptUI)
	layer = layer or _layVw
	local _tpVal = type(layer)
	if _tpVal == "table" then
		for _,v in ipairs(layer) do
			this.HideOneLayer(v,exceptUI)
		end
	else
		this.HideOneLayer(layer,exceptUI)
	end
end

function M.HideOneLayer(layer,exceptUI)
	local _lb = this.uiViews[layer]
	if not _lb then return end

	for _,ui in pairs(_lb) do
		if (not exceptUI) or (not _lf_equipLUI(ui,exceptUI)) then
			this.HideUI(ui)
		end
	end
end

function M.HideUI( ui )
	ui:View(false)
end

function M.HideOther(exceptUI)
	local _ht = exceptUI:GetMutexType()
	if (not _ht) or (_ht == _E_Hide.None) then
		return
	end
	
	local hideLayer
	if _ht == _E_Hide.SelfLayer then
		hideLayer = exceptUI:GetLayer()
	elseif _ht == _E_Hide.Main then
		hideLayer = _E_Layer.Main
	elseif _ht == _E_Hide.AllExceptGuide then
		hideLayer = _lay_1
	elseif _ht == _E_Hide.MainAndSelf then
		hideLayer = {_E_Layer.Main,exceptUI:GetLayer()}
	end

	this.HideAll(hideLayer,exceptUI)
end

-- 打开界面
function M.OpenUI(id,lfPreOpen,...)
	--功能解锁判定
	local _isBl,_cfg = this.IsUnlock(id,true)
	if _isBl then
		if lfPreOpen then
			lfPreOpen()
		end

		if _cfg.nback then
			if _cfg.nback == 1 then 
				this.SetCurrUIType(id,true)
			elseif _cfg.nback == 2 then
				this.SetCurrUIType(id)
			end
		end
		_evt.Brocast( id,id,... )
	end
end

function M.IsUnlock(id,isTips)
	return MgrUnlock.IsUnlock(id,isTips)
end

-- 打开上一个界面
function M.OpenPreUI()
	if not this.GetIsOpenPreUI() then return end

	local _pt = this.preNormalType
	if (not _pt) or (_pt == this.curNormalType) then
		return
	end
	this.nTypePre2Curr = _pt

	local _childTag = this.GetChildTag(_pt);
	this.SetChildTag(_childTag,_pt);

	this.SetIsOpenPreUI(false)

	--当时打开的时候存的
	this.OpenUI(this.preNormalType)
end

function M.SetCurrUIType(emType,isSetCurr)
	local curEmType = this.curNormalType
	if emType ~= curEmType then
		this.preNormalType = curEmType
	else
		this.preNormalType = nil
	end
	if isSetCurr == true then
		this.curNormalType = emType
	else
		this.curNormalType = nil
	end
end

function M.SetPreUIType(emType)
	this.SetIsOpenPreUI(true)
	this.preNormalType = emType
end

function M.GetIsOpenPreUI()
	return (this.isOpenPreNormalUI == true)
end

function M.SetIsOpenPreUI(isBl)
	this.isOpenPreNormalUI = (isBl == true)
end

function M.ClearPreInfo()
	this.SetChildTag(nil)
	this.SetIsOpenPreUI(false)
	this.preNormalType = nil
	this.curNormalType = this.nTypePre2Curr
	this.nTypePre2Curr = nil
end

function M.SetChildTag(childTag,_cur)
	this.lbChildTags = this.lbChildTags or {}
	_cur = _cur or this.curNormalType
	if _cur then
		this.lbChildTags[_cur] = childTag
	end
end

function M.GetChildTag(_cur)
	_cur = _cur or this.curNormalType
	if _cur and this.lbChildTags then
		return this.lbChildTags[_cur]
	end
end

return M
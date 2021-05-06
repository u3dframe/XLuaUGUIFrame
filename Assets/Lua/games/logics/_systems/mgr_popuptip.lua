--[[
	-- 管理 - 文本提示
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-02 08:25
	-- Desc : 
]]

local _yStart,_ySpeed,_yTime = 0 , 200 , 1

local tb_insert,tb_rm = table.insert,table.remove

local super,_evt = MgrBase,Event
local M = class( "mgr_poptip", super)
local this = M

function M.Init()
	this.isGoOn = true -- 控制是否可以继续Check
	this.isPreGoOn = this.isGoOn
	this.nMaxMsgSize = 20
	this.lbQueMsg = {}
	this._InitUI()

	_evt.AddListener(Evt_Popup_Tips,PopupTip)
	_evt.AddListener(Evt_Error_Tips,PopupTip)
end

function M._InitUI()
	local ui = UIBase.New({
		abName = "commons/ui_popup_tip",
		layer = LE_UILayer.Pop,
		isStay = true,
		isUpdate = true,
	})
	this.ui = ui

	ui.OnInit = function(_s)
		_s.lbTxt = ui:NewTxt("value")
		_s:SetAnchoredPosition(0,_yStart)
	end

	ui.OnShow = function(_s)
		local _msg = this.GetPopopMsg()
		_s.lbTxt:SetOrFmt2( "_error",_msg )
		
		_s.speed = _ySpeed
		_s.toY = _yStart
		_s.cdTime = _yTime
		
		this.isPreGoOn = this.isGoOn
		this.isGoOn = false
	end

	ui.OnUpdateLoaded = function(_s,_dt)
		this.ui:SetAsLastSibling()
		_s.cdTime = _s.cdTime - _dt
		_s.toY = _s.toY + _dt * _s.speed
		_s:SetAnchoredPosition(0,_s.toY)
		if _s.cdTime <= 0 then
			_s:View(false)
		end
	end

	ui.OnExit = function(_s,isInited)
		UIBase.OnExit(_s,isInited)
		_s:SetAnchoredPosition(0,0)
		if isInited then
			this.isGoOn = this.isPreGoOn
			this.CheckPopupTip()
		end
	end
end

function M.AddPopopMsg(msg)
	if msg then
		while (#this.lbQueMsg >= this.nMaxMsgSize) do
			tb_rm(this.lbQueMsg,1)
		end
		tb_insert(this.lbQueMsg,msg)
	end
	return msg ~= nil
end

function M.GetPopopMsg()
	local msg = this.lbQueMsg[1]
	if msg then
		tb_rm(this.lbQueMsg,1)
	end
	return msg
end

function M.ShowPopupTip(isShow)
	this.ui:View(isShow == true)
end

function M.CheckPopupTip()
	if not this.isGoOn then return end
	local isShow =  #this.lbQueMsg > 0
	this.ShowPopupTip(isShow)
end

function PopupTip(msg)
	if this.AddPopopMsg(msg) then
		this.CheckPopupTip()
	end
end

return M
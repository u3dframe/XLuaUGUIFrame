--[[
	-- 管理 - vdo 视频播放
	-- Author : canyon / 龚阳辉
	-- Date : 2021-02-06 10:25
	-- Desc : 
]]

local tonumber,type,tostring = tonumber,type,tostring

local super,_evt = MgrBase,Event
local M = class( "mgr_vdo", super)
local this = M

function M.Init()
	this._InitUI()
	_evt.AddListener(Evt_View_Vdo,this.ShowVdo)
end

function M._InitUI()
	local ui = UIBase.New({
		abName = "ui_vdo",
		layer = LE_UILayer.Pop,
		isNoCircle = true,
		isStay = true,
		strComp = "VideoEx",
	})
	this.ui = ui

	ui.OnSetData = function(_s,callEnd,callReady,isCJump)
		_s.lfCallEnd = callEnd
		_s.lfCallReady = callReady
		_s.isStrPath = type(_s.data) == "string"
		_s.isCJump = isCJump == true
	end

	-- ui.SelfIsCanHideLoading = function(_s)
	-- 	return true
	-- end

	ui.OnInit = function(_s)		
		_s.lbClose = _s:NewBtn("button",handler(_s,_s.OnCK_Close),42500)
		_s.lfOnReady = handler(_s,_s.OnCSVdoReady)
		_s.lfOnEnd = handler(_s,_s.OnCSVdoEnd)
	end

	ui.OnShow = function(_s)
		if _s.isStrPath then
			local _v = _s:ReSBegEnd( _s.data,"movies/",".mp4" )
			_s.comp:PlayVideo( _v,_s.lfOnReady,_s.lfOnEnd )
		else
			_s.comp:PlayClip( _s.data,_s.lfOnReady,_s.lfOnEnd )
		end
	end

	ui.OnEnd = function(_s,isDestroy)
		_s.lfCallEnd,_s.lfCallReady = nil
	end

	ui.OnCK_Close = function(_s)
		_s.comp:Jump()
	end

	ui.OnCSVdoEnd = function(_s)
		local _lf = _s.lfCallEnd
		_s.lfCallEnd = nil
		_s:OnClickCloseSelf()
		if _lf then
			_lf()
		end
	end

	ui.OnCSVdoReady = function(_s)
		local _lf = _s.lfCallReady
		_s.lfCallReady = nil
		if _lf then
			_lf()
		end
		_s.lbClose:SetActive(_s.isCJump)
	end
end

function M.ShowVdo(vwState,vdo,callEnd,callReady,isCanJump)
	if (2 == vwState) then
		this.ui:View( false )
		this.ui:DestroyObj()
		return
	end

	local isShow = (vwState == true or vwState == 1) and (vdo ~= nil)
	this.ui:View( isShow,vdo,callEnd,callReady,isCanJump )
end

return M
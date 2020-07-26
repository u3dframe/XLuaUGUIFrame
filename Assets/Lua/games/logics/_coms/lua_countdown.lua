LE_TmType = {
    UTC_H_M_S = 1, -- 标准 - 时分秒 00:00:00
    UTC_M_S = 2, -- 标准 - 分秒 00:00
    UTC_S = 3, -- 标准 - 秒 00
    A_D_H_M_S = 4, -- 0天0时0分1秒 / 0d 00:00:00
    A_H_M_S = 5, -- 0时0分1秒 / 00:00:00
    A_M_S = 6, -- 0分1秒 / 00:00
    A_S = 7, -- 1秒 / 00s

    -- 一下该配置在csv里面去
    [1] = 93,
    [2] = 94,
    [3] = 95,
    [4] = 96,
    [5] = 97,
    [6] = 98,
    [7] = 99,
}

local yearSec = 31536000 --一年365天总秒
local _ltimer,_clsTxt = LTimer,LuText
local super, _evt = LuaObject, Event
local M = class("lua_countdown", super)

function M:ctor( endCallFunc,tmType,obj,fmt )
    tmType = tmType or 1
    assert( LE_TmType[tmType],self:SFmt( "time fmt is not has = [%s]",tmType ) )
    self.tmType = tmType or 1
    self.ltmKey = LE_TmType[tmType]
    self:SetCallFunc(endCallFunc)
    self:SetFmt(fmt)
    if obj then
        if type(obj) == "table" then
            if obj.IsClass and obj:IsClass("ugui_text") then
                self.lbTxt = obj
            else
                obj = obj.gobj
            end
        end

        if obj and not self.lbTxt then
            obj = obj.gameObject
            local _txt = obj:GetComponent("Text")
            if _txt then self.lbTxt = _clsTxt.New(_txt,true) end
        end
    end
    self._lfUpSec = self._lfUpSec or handler_xpcall(self, self.OnUpSecond)
end

function M:ReEvent4Self(isBind)
    -- 移除事件
	_evt.RemoveListener(Evt_UpEverySecond,self._lfUpSec);
	if isBind == true then
		-- 添加事件
        _evt.AddListener(Evt_UpEverySecond, self._lfUpSec)
	end
end

-- 开始计时 endTime 结束时间（必填） ，startTime 开始显示时间(选填，不填默认当前时间)
function M:Start(endTime, isAdd, startTime)
    self.isAdd = isAdd == true
    local _tmp = _ltimer.GetSvTime()
    if (endTime > yearSec and endTime < _tmp) or endTime <= 0 then
        self:ExcuteCallFunc()
        return
    end

    if endTime > yearSec then
        startTime = startTime or _tmp
    else
        startTime = (startTime or 0) + _tmp
        endTime = endTime + _tmp
    end

    self.endTime = endTime
    self.startTime = startTime
    self.isUping = true
    self:OnUpSecond()
    self:ReEvent4Self(true)
end

function M:OnUpSecond()
    if not self.isUping then
        return
    end

    local _tm = _ltimer.GetSvTime()

    if _tm > self.endTime then
        self:_OnEnd()
        return
    end

    local _remainder = (self.isAdd) and (_tm - self.startTime) or (self.endTime - _tm)
    
    if _remainder >= 0 then
        local _fmt = (self.fmtObj or self.ltmKey)
        if self.tmType == LE_TmType.A_S or self.tmType == LE_TmType.UTC_S then
            if self.fmtType == "function" then
                _fmt(self,_remainder)
            else
                self:SetText(_fmt,_remainder)
            end
        else
            local _h,_m,_s,_d = _ltimer.GetHMS(_remainder,(self.tmType == LE_TmType.A_D_H_M_S))
            if self.fmtType == "function" then
                _fmt(self,_h,_m,_s,_d)
            else
                if self.tmType == LE_TmType.A_D_H_M_S then
                    self:SetText(_fmt,_d,_h,_m,_s)
                elseif self.tmType == LE_TmType.A_H_M_S or self.tmType == LE_TmType.UTC_H_M_S then
                    self:SetText(_fmt,_h,_m,_s)
                elseif self.tmType == LE_TmType.A_M_S or self.tmType == LE_TmType.UTC_M_S then
                    self:SetText(_fmt,(_m + _h * 60),_s)
                end
            end
        end
    end
end

function M:_OnEnd()
    self.isUping = false
    self:ReEvent4Self(false)
    self:SetText(1)
    self:ExcuteCallFunc()
end

function M:SetFmt(fmt)
    self.fmtObj = fmt
    self.fmtType = type(self.fmtObj)
end

function M:SetText( val,... )
    if not self.lbTxt then return end
    if self:Lens4Pars( ... ) > 0 then
        self.lbTxt:SetTextFmt( val,... )
    else
        self.lbTxt:SetText( val )
    end
end

return M
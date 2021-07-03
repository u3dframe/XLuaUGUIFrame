--[[
	-- 入口服务器列表
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-15 13:25
	-- Desc : 
]]

local _fmt = string.format
local _mgrWWW = MgrWww

local M = {
    _isUseSDK = true,
    defUrl = "http://setting.dianyue.com/static/frontend/all1/serverlist.json",
    listUrl = {
    },

    isVPassed = false,
    isPassed = {
    },

    defUrlCreateEdt = "http://gamecenter.dianyue.com/user/create/1/all/all1",
    defUrlCreate = "http://gamecenter.dianyue.com/user/create/2/all/all1",
    defUrlOrder = "http://gamecenter.dianyue.com/user1/recharge",
    listUrlCreate = {
    },
}

local this = M

function M.IsUseSDK(cur)
    local _isVal = this._isUseSDK
    return _isVal == true
end

-- 取得服务器列表 
function M.GetSvUrl(cur)
    local _strUrl,_strKey
    _strKey = GM_IsEditor and _fmt("e_%s",cur) or _fmt("s_%s",cur)
    _strUrl = this.listUrl[_strKey]
    if  not _strUrl then
        if GM_IsEditor then
            _strUrl = (this.defUrlEdt or this.defUrl)
        else
            _strUrl = this.defUrl
        end
    end
    return _strUrl
end

function M.GetCreateUrl(cur)
    local _strUrl,_strKey
    _strKey = GM_IsEditor and _fmt("e_%s",cur) or _fmt("s_%s",cur)
    _strUrl = this.listUrlCreate[_strKey]
    if  not _strUrl then
        if GM_IsEditor then
            _strUrl = (this.defUrlCreateEdt or this.defUrlCreate)
        else
            _strUrl = this.defUrlCreate
        end
    end
    return _strUrl
end

function M.GetOrderUrl(cur)
    local _strUrl,_strKey
    _strKey = GM_IsEditor and _fmt("e_%s",cur) or _fmt("s_%s",cur)
    _strUrl = this.listUrlCreate[_strKey]
    if  not _strUrl then
        if GM_IsEditor then
            _strUrl = this.defUrlOrder
        else
            _strUrl = this.defUrlOrder
        end
    end
    return _strUrl
end

-- 是否过审核
function M.IsPassedTrial(cur)
    if this.isVPassed == true then
		local _rval,_strKey = GM_IsEditor
		if not _rval then
			_strKey = _fmt("s_%s",cur)
            if this.isPassed then
                _rval = this.isPassed[_strKey]
				_rval = (_rval == nil) or (_rval == true)
			end
		end
		return (_rval == true)
    end
    return true
end

function M.GetServerList(lfCall)
    local _cur = nil
    local _url = M.GetSvUrl(_cur)
    _mgrWWW.SendWWW(_url,lfCall)
end

return M
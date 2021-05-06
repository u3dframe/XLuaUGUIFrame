--[[
	-- 入口服务器列表
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-15 13:25
	-- Desc : 
]]

local _fmt = string.format
local _mgrWWW = MgrWww

local M = {
    -- defEditorUrl = "http://setting.dianyue.com/static/frontend/all1/serverlist.json",
    defUrl = "http://140.143.15.163:8080/static/dev/serverlist.json",
    listUrl = {
    },

    isVPassed = false,
    isPassed = {
    },

    -- defEdUrlCreate = "http://gamecenter.dianyue.com/user/create/1",
    defUrlCreate = "http://140.143.15.163:8084/user/create/1",
}

local this = M

-- 取得服务器列表 
function M.GetSvUrl(cur)
    local _strUrl,_strKey
    _strKey = GM_IsEditor and _fmt("e_%s",cur) or _fmt("s_%s",cur)    
    _strUrl = this.listUrl[_strKey]
    if  not _strUrl then
        _strUrl = this.defUrl
    end
	return _strUrl
end

function M.GetCreateUrl(cur)
    return this.defUrlCreate
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
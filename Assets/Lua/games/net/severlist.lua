--[[
	-- 入口服务器列表
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-15 13:25
	-- Desc : 
]]

local _mgrWWW = MgrWww

local _fmt = string.format
local fdir = "all1"

local M = {
    defEditorUrl = "http://dianyuesetting.com/static/frontend/" .. fdir .."/serverlist.json",
    defUrl = "http://xxxx/" .. fdir .."/serverlist.json;",
    listUrl = {
    },

    isVPassed = false,
    isPassed = {
    }
}

local this = M

-- 取得服务器列表 
function M.GetSvUrl(cur)
	local _strUrl,_strKey
    _strKey = GM_IsEditor and _fmt("e_%s",cur) or _fmt("s_%s",cur)    
    _strUrl = this.listUrl[_strKey]
    if  not _strUrl then
        _strUrl = GM_IsEditor and this.defEditorUrl or this.defUrl
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
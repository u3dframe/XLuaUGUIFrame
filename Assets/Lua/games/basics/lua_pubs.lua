--[[
	-- 公共某块
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-15 13:25
	-- Desc : 减少自身内部引用
]]

local _c_trsf,_c_comp,_c_ele,_lasset,_utxt,_ubtn,_utog,_uscl,_uimg,_uinpfld = nil

local M = class("lua_pubs")

function M:_ClsTrsf()
    if not _c_trsf then
        _c_trsf = LUTrsf
    end
    return _c_trsf
end

function M:_ClsComp()
    if not _c_comp then
        _c_comp = LUComonet
    end
    return _c_comp
end

function M:_ClsEle()
    if not _c_ele then
        _c_ele = LCFabElement
    end
    return _c_ele
end

function M:_ClsAsset()
    if not _lasset then
        _lasset = LuaAsset
    end
    return _lasset
end

function M:_ClsUTxt()
    if not _utxt then
        _utxt = LuText
    end
    return _utxt
end

function M:_ClsUBtn()
    if not _ubtn then
        _ubtn = LuBtn
    end
    return _ubtn
end

function M:_ClsUTog()
    if not _utog then
        _utog = LuScl
    end
    return _utog
end

function M:_ClsUScl()
    if not _uscl then
        _uscl = LuScl
    end
    return _uscl
end

function M:_ClsUImg()
    if not _uimg then
        _uimg = LuImg
    end
    return _uimg
end

function M:_ClsUInpFld()
    if not _uinpfld then
        _uinpfld = LuInpFld
    end
    return _uinpfld
end

function M:NewAsset(ab,asset,atp,callFunc)
    local _lb = self:_ClsAsset().New({
        abName = ab,
        assetName = asset,
        assetLType = atp
    })
    _lb.lfAssetLoaded = function(isNo,obj)
        if callFunc ~= nil then
            callFunc(isNo,obj)
        end
    end
    return _lb
end

return M

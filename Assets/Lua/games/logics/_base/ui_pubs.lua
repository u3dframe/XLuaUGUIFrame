--[[
	-- ui 公共模块
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-15 13:25
	-- Desc : 
]]

local super = LuaPubs
local M = class( "ui_pubs",super )

function M:NewTrsf(elName)
    local _gobj = self:GetElement(elName)
    if _gobj then
        return self:_ClsTrsf().New(_gobj)
    end
    printError("=== NewTrsf is Null, name = [%s]", elName)
end

function M:NewComp(elName,compName)
    local _gobj = self:GetElement(elName)
    if _gobj then
        return self:_ClsComp().New(_gobj,compName)
    end
    printError("=== NewComp is Null, name = [%s]", elName)
end

function M:NewEle(elName)
    local _gobj = self:GetElement(elName)
    if _gobj then
        return self:_ClsEle().New(_gobj)
    end
    printError("=== NewEle is Null, name = [%s]", elName)
end

function M:NewTxt(elName)
    local _gobj = self:GetElement(elName)
    if _gobj then
        return self:_ClsUTxt().New(_gobj)
    end
    printError("=== NewTxt is Null, name = [%s]", elName)
end

function M:NewBtn(elName, callFunc, val, isNoScale)
    local _gobj = self:GetElement(elName)
    if _gobj then
        return self:_ClsUBtn().New(_gobj, callFunc, val, isNoScale)
    end
    printError("=== NewBtn is Null, name = [%s]", elName)
end

function M:NewTog(elName, uniqueID, callFunc, val, isNoCall4False)
    local _gobj = self:GetElement(elName)
    if _gobj then
        return self:_ClsUTog().New(uniqueID, _gobj, callFunc, val, isNoCall4False)
    end
    printError("=== NewTog is Null, name = [%s]", elName)
end

function M:NewScl(elName, funcCreat, funcSetData, gobjItem)
    local _gobj = self:GetElement(elName)
    if _gobj then
        return self:_ClsUScl().New(_gobj, funcCreat, funcSetData, gobjItem)
    end
    printError("=== NewScl is Null, name = [%s]", elName)
end

function M:NewImg(elName,compName)
    if (compName == nil) or (compName == "Image") or (compName == "RawImage") then
        local _gobj = self:GetElement(elName)
        if _gobj then
            return self:_ClsUImg().New(_gobj,compName)
        end
    end
    printError("=== NewImg is Null, name = [%s],comp = [%s]", elName,compName)
end

function M:NewInpFld(elName,val)
    local _gobj = self:GetElement(elName)
    if _gobj then
        return self:_ClsUInpFld().New( _gobj,nil,val )
    end
    printError("=== NewInpFld is Null, name = [%s]", elName)
end
return M

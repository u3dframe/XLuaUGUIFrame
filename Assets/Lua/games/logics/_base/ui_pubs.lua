--[[
	-- ui 公共模块
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-15 13:25
	-- Desc : 
]]

local super = LuaPubs
local M = class( "ui_pubs",super )

function M:NewTrsf(elName,isNoPrint)
    local _gobj = self:GetElement(elName)
    if _gobj then
        return self:NewTrsfBy(_gobj)
    end
    if isNoPrint == true then return end
    printError("=== NewTrsf is Null, name = [%s]", elName)
end

function M:NewComp(elName,compName,isNoPrint)
    local _gobj = self:GetElement(elName)
    if _gobj then
        return NewCompBy(_gobj,compName)
    end
    if isNoPrint == true then return end
    printError("=== NewComp is Null, name = [%s]", elName)
end

function M:NewEle(elName,isNoPrint)
    local _gobj = self:GetElement(elName)
    if _gobj then
        return self:NewEleBy(_gobj):AddSupUIPubs()
    end
    if isNoPrint == true then return end
    printError("=== NewEle is Null, name = [%s]", elName)
end

function M:NewTxt(elName,isNoPrint)
    local _gobj = self:GetElement(elName)
    if _gobj then
        return self:NewTxtBy(_gobj)
    end
    if isNoPrint == true then return end
    printError("=== NewTxt is Null, name = [%s]", elName)
end

function M:NewBtn(elName, callFunc, val, isNoScale,isNoPrint)
    local _gobj = self:GetElement(elName)
    if _gobj then
        return self:NewBtnBy(_gobj, callFunc, val, isNoScale)
    end
    if isNoPrint == true then return end
    printError("=== NewBtn is Null, name = [%s]", elName)
end

function M:NewTog(elName, uniqueID, callFunc, val, isNoCall4False,isNoPrint)
    local _gobj = self:GetElement(elName)
    if _gobj then
        return self:NewTogBy( _gobj, uniqueID, callFunc, val, isNoCall4False)
    end
    if isNoPrint == true then return end
    printError("=== NewTog is Null, name = [%s]", elName)
end

function M:NewScl(elName, funcCreat, funcSetData, gobjItem,isNoPrint)
    local _gobj = self:GetElement(elName)
    if _gobj then
        return self:NewSclBy(_gobj, funcCreat, funcSetData, gobjItem)
    end
    if isNoPrint == true then return end
    printError("=== NewScl is Null, name = [%s]", elName)
end

function M:NewImg(elName,compName,isNoPrint)
    local _gobj = self:GetElement(elName)
    if _gobj then
        return self:NewImgBy(_gobj,compName)
    end
    if isNoPrint == true then return end
    printError("=== NewImg is Null, name = [%s],comp = [%s]", elName,compName)
end

function M:NewInpFld(elName,val,isNoPrint)
    local _gobj = self:GetElement(elName)
    if _gobj then
        return self:NewInpFldBy( _gobj,val,nil )
    end
    if isNoPrint == true then return end
    printError("=== NewInpFld is Null, name = [%s]", elName)
end

-- lbCfg = {clsLua,cfClick,cfShow,nColumn,isAllActive,isVertical,isCallNoData,isAlpha,ext_1~10} 
-- 里面字段的意义
-- clsLua - 自己的子元素脚本,可以为路径，也可以为require对象 (必要)
-- cfClick - 单击cell元素 (非必要)
-- cfShow - 显示cell元素 (非必要)
-- nColumn - 列数 (非必要 - 多行多列的)
-- isAllActive - 显示全都 (非必要 - 多行多列的)
-- isVertical - 是否纵向滚动 (必要 - ugui_scroll 的)
-- isCallNoData - 是否回到Show，在没Data的时候 (非必要 - ugui_scroll 的)
-- isAlpha - 是否让计算单元Alpha (非必要 - ugui_scroll 的)
-- ext_1~10 - 透传参数1~10 (非必要 - 要透传时，必须有ext_1)
function M:NewUScl(elName,lbCfg,elNameItem,isNoPrint)
    local _gobj = self:GetElement(elName)
    if _gobj then
        lbCfg.gobj = _gobj
        if elNameItem then lbCfg.gobjCell = self:GetElement(elNameItem) end
        return self:_ClsUIScl().New(lbCfg)
    end
    if isNoPrint == true then return end
    printError("=== NewUScl is Null, name = [%s]", elName)
end

return M

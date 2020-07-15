--[[
	-- ui 公共模块
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-15 13:25
	-- Desc : 公共函数
]]

local _utxt,_ubtn,_utog,_uscl
local function utxt()
	if not _utxt then _utxt = LuText end
	return _utxt
end

local function ubtn()
	if not _ubtn then _ubtn = LuBtn end
	return _ubtn
end

local function utog()
	if not _utog then _utog = LuScl end
	return _utog
end

local function uscl()
	if not _uscl then _uscl = LuScl end
	return _uscl
end

local M = class( "ui_pubs")

function M:NewTxt(elName)
	local _gobj = self:GetElement(elName)
	if _gobj then
		return utxt().New(_gobj)
	end
	printError("=== NewTxt no child, name = [%s]",elName)
end

function M:NewBtn(elName,callFunc,val,isNoScale)
	local _gobj = self:GetElement(elName)
	if _gobj then
		return ubtn().New(_gobj,callFunc,val,isNoScale)
	end
	printError("=== NewBtn no child, name = [%s]",elName)
end

function M:NewTog(elName,uniqueID,callFunc,val,isNoCall4False)
	local _gobj = self:GetElement(elName)
	if _gobj then
		return utog().New(uniqueID,_gobj,callFunc,val,isNoCall4False)
	end
	printError("=== NewTog no child, name = [%s]",elName)
end

function M:NewScl(elName,funcCreat,funcSetData,gobjItem)
	local _gobj = self:GetElement(elName)
	if _gobj then
		return uscl().New(_gobj,funcCreat,funcSetData,gobjItem)
	end
	printError("=== NewScl no child, name = [%s]",elName)
end

return M
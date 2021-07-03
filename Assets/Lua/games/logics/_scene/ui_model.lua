--[[
	-- ui 模型对象
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-20 15:35
	-- Desc : 
]]

local E_Object = LES_Object

local super = SceneHero
local M = class( "ui_model",super )
local this = M

this.nm_pool_cls = "p_cls_ui_" .. tostring(E_Object.UIModel)

function M.Builder(nCursor,resid)
	this:GetResCfg( resid )
	local _p_name,_ret = this.nm_pool_cls .. "@@" .. resid

	_ret = this.BorrowSelf( _p_name,E_Object.UIModel,nCursor,resid )
	return _ret
end

function M:OnDisappear()
	self:DestroyObj()
end

return M
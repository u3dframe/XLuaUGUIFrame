--[[
	-- 特效 工厂
	-- Author : canyon / 龚阳辉
	-- Date : 2020-09-15 20:35
	-- Desc : 
]]

local E_Type = LE_Effect_Type
local str_split = string.split
local tb_insert,tb_lens = table.insert,table.lens

local fdir = "games/logics/_effects/"
local _req = reimport or require

local ClsEffect               = _req (fdir .. "effect_object")  -- 特效
local ClsBuff                 = _req (fdir .. "buff")           -- buff
local ClsBullet               = _req (fdir .. "bullet")         -- buff
objsPool:AddClassBy( ClsEffect )
objsPool:AddClassBy( ClsBuff )
objsPool:AddClassBy( ClsBullet )

local M = {}
local this = M

-- idCaster
function M.Make(eftType,idMarker,idTarget,...)
	local _ret
	if eftType == E_Type.Effect then
		-- 参数 : e_id
		_ret = this.ViewEffect( idMarker,idTarget,... )
	elseif eftType == E_Type.Buff then
		-- 参数 : b_id , duration
		_ret = ClsBuff.Builder( idMarker,idTarget,... )
	elseif eftType == E_Type.Bullet then
		-- 参数 : e_id
		_ret = ClsBullet.Builder( idMarker,idTarget,... )
	end
	return _ret
end

function M.CreateEffect( idMarker,idTarget,e_id )
	local _isOkey,cfgEft,_points = MgrData:CheckCfg4Effect( e_id )
	if not _isOkey then return end
	local _elNms,_gobj,_isFollow = str_split(_points,";")
	_isFollow = (2 == cfgEft.type) or (3 == cfgEft.type) or (5 == cfgEft.type)

	local _lb,_it = {}
	for _, v in ipairs(_elNms) do
		_it = ClsEffect.Builder( idMarker,idTarget,cfgEft.resid,v,_isFollow,cfgEft.effecttime )
		if _it then
			tb_insert( _lb,_it )
		end
	end
	return _lb
end

function M.ShowEffects( lbList,speed )
	local _lens = tb_lens(lbList)
	if _lens <= 0 then
		return
	end
	for i = 1, _lens do
		lbList[i]:Start( speed )
	end
end

function M.ViewEffect( idMarker,idTarget,e_id,speed )
	local _list = this.CreateEffect( idMarker,idTarget,e_id )
	this.ShowEffects( _list,speed )
	return _list
end

return M
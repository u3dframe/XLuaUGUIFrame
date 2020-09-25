--[[
	-- 特效 工厂
	-- Author : canyon / 龚阳辉
	-- Date : 2020-09-15 20:35
	-- Desc : 
]]

local E_Type = LE_Effect_Type
local str_split = string.split
local tb_insert,tb_lens = table.insert,table.lens
local _vec3 = Vector3

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
	local _isShow = eftType == E_Type.Buff_Show or eftType == E_Type.Effect_Show or eftType == E_Type.Bullet_Show
	local _ret
	if eftType == E_Type.Effect or eftType == E_Type.Effect_Show then
		-- 参数 : e_id
		_ret = this.CreateEffect( idMarker,idTarget,... )
		if _isShow then
			this.ShowEffects( _ret )
		end
	elseif eftType == E_Type.Buff or eftType == E_Type.Buff_Show then
		-- 参数 : b_id , duration
		_ret = ClsBuff.Builder( idMarker,idTarget,... )
		if _isShow and _ret then
			_ret:Start()
		end
	elseif eftType == E_Type.Bullet or eftType == E_Type.Bullet_Show then
		-- 参数 : e_id
		_ret = ClsBullet.Builder( idMarker,idTarget,... )
		if _isShow and _ret then
			_ret:Start()
		end
	elseif eftType == E_Type.Pre_Effect then
		-- 参数 : resid,lfOnceShow
		_ret = ClsEffect.PreLoad( idMarker,idTarget,... )
	end
	return _ret
end

function M.CreateEffect( idMarker,idTarget,e_id )
	local _isOkey,cfgEft,_points = MgrData:CheckCfg4Effect( e_id )
	if not _isOkey then return end
	local _elNms,_gobj,_isFollow = str_split(_points,";")
	_isFollow = (2 == cfgEft.type) or (3 == cfgEft.type)

	local _lb,_it,_v3Of = {}
	for _, v in ipairs(_elNms) do
		if cfgEft.offset_x or cfgEft.offset_y or cfgEft.offset_z then
			_v3Of = _vec3.New( (cfgEft.offset_x or 0) * 0.01,(cfgEft.offset_y or 0) * 0.01,(cfgEft.offset_z or 0) * 0.01 )
		end
		_it = ClsEffect.Builder( idMarker,idTarget,cfgEft.resid,v,_isFollow,cfgEft.effecttime,_v3Of )
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
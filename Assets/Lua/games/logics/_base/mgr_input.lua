--[[
	-- 场景点击事件处理
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-14 13:35
	-- Desc : 
]]

local _lMask,Mathf,_csMgr = LayerMask,Mathf

local super,_evt = MgrBase,Event
local M = class( "mgr_input",super )
local this = M

function M.Init()
	local _masks = this.GetMask( "SceneObj","Ground","Monster","Hero" )
	_csMgr = CInpMgr.instance:InitAll( _masks,this.OnCall_Scale,this.OnCall_Rotate,this.OnCall_Slide,this.OnCall_RayHit )
	_evt.AddListener(Evt_SendRay4ScreenPoint,this.SendRaycast4V2)
end

function M.OnCall_Scale(isBl,scale)
end

function M.OnCall_Rotate(v2Rotate)
end

function M.OnCall_Slide(v2Slide)
end

function M.OnCall_RayHit(hitTrsf)
end

function M.SetMask(...)
	local _masks = this.GetMask( ... )
	_csMgr:SetLayerMask(_masks)
end


function M.GetMask(...)
	return _lMask.GetMask( ... )
end

function M.GetRayInfo(x,y,lfCall,distance,...)
	local _masks = this.GetMask( ... )
	distance = this:TF2(distance)
	return _csMgr:ReRayScreenPointInfo(x,y,distance,_masks,lfCall)
end

function M.SendRaycast4ScreenPoint(x,y,lfCall,distance,isImmediate,...)
	local _masks = this.GetMask( ... )
	distance = this:TF2(distance)
	_csMgr:SendRaycast4ScreenPoint(x,y,distance,_masks,lfCall,(isImmediate == true))
end

function M.SendRaycast4V2(screenPoint,lfCall,distance,isImmediate,...)
	this.SendRaycast4ScreenPoint( screenPoint.x,screenPoint.y,lfCall,distance,isImmediate,... )
end

return M
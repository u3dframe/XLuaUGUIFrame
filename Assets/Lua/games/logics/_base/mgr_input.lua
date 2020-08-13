--[[
	-- 场景点击事件处理
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-14 13:35
	-- Desc : 
]]

local _csMgr,_lMask,Mathf

local super,_evt = MgrBase,Event
local M = class( "mgr_input",super )
local this = M

function M.Init()
	_csMgr = CInpMgr.instance:InitCall(this.OnCall_Scale,this.OnCall_Rotate,this.OnCall_Slide,this.OnCall_RayHit)
	_lMask = LayerMask
	Mathf = Mathf
end

function M.OnCall_Scale(isBl,scale)
end

function M.OnCall_Rotate(v2Rotate)
end

function M.OnCall_Slide(v2Slide)
end

function M.OnCall_RayHit(ray,hit,layer)
end

function M.SendRay4XY(x,y,lfCall,distance,isMust,...)
	local _masks = _lMask.GetMask( ... )
	distance = distance or Mathf.Infinity
	local _info = _csMgr:ReRayScreenPointInfo(x,y,distance,_masks,lfCall)
	_csMgr:SendRay4ScreenPoint(_info,(isMust == true))
end

function M.SendRay4ScreenPoint(screenPoint,lfCall,distance,isMust,...)
	this.SendRay4XY( screenPoint.x,screenPoint.y,lfCall,distance,isMust,... )
end

return M
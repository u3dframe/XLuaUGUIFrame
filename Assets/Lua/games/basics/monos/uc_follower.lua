--[[
	-- SmoothFollower
	-- Author : canyon / 龚阳辉
	-- Date : 2020-09-22 20:25
	-- Desc : 
]]

local CFollower = CFollower

local super = LUComonet
local M = class( "lua_SmoothFollower",super )

function M:ctor( obj,component )
	assert(obj,"follower is null")
	if true == component then
		component = CFollower.Get(obj)
	end
	super.ctor(self,obj,component or "SmoothFollower")
end

function M:_RePars( distance,height,offsetH,isLerpDistance,isLerpHeight,isLerpRotate )
	return (distance or 8),(height or 5),(offsetH or 0),(isLerpDistance == true),(isLerpHeight == true),(isLerpRotate == true)
end

function M:ReSetPars( target,distance,height,offsetH,isLerpDistance,isLerpHeight,isLerpRotate )
	local _p1,_p2,_p3,_p4,_p5,_p6 = self:_RePars( distance,height,offsetH,isLerpDistance,isLerpHeight,isLerpRotate )
	self.comp:ReSetPars( target,_p1,_p2,_p3,_p4,_p5,_p6 )
end

function M:ReSetDHL( distance,height,offsetH )
	local _p1,_p2,_p3 = self:_RePars( distance,height,offsetH )
	self.comp:ReSetDHL( distance,height,offsetH )
end

function M:Start( target,distance,height,offsetH,isLerpDistance,isLerpHeight,isLerpRotate )
	local _p1,_p2,_p3,_p4,_p5,_p6 = self:_RePars( distance,height,offsetH,isLerpDistance,isLerpHeight,isLerpRotate )
	self.comp:DoStart( target,_p1,_p2,_p3,_p4,_p5,_p6 )
end

function M:Stop()
	self.comp.isRunning = false
end

function M:SetTarget( target )
	self.comp.target = target
end

return M
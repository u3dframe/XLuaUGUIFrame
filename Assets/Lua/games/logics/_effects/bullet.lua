--[[
	-- 子弹
	-- Author : canyon / 龚阳辉
	-- Date : 2020-09-16 15:06
	-- Desc : 
]]

local E_Eft_Type = LES_Ani_Eft_Type
local tb_lens = table.lens
local MgrData,_vec3 = MgrData,Vector3

local super,super2 = ClsEftBase,ClsObjBasic
local M = class( "bullet",super,super2 )
local this = M
this.nm_pool_cls = "p_bullet"

function M.Builder(idMarker,idTarget,e_id)
	local _isOkey,cfgEft = MgrData:CheckCfg4Effect( e_id )
	if (not _isOkey) or (cfgEft.type ~= E_Eft_Type.FlyPosition and cfgEft.type ~= E_Eft_Type.FlyTarget) then return end
	local range,_mvSpeed,_diff,_t_out,_v3Target = this.CalcSpeedAndDis( idMarker,idTarget,cfgEft.effecttime,cfgEft.min_mv_speed )
	if not range then
		return
	end
	local _p_name,_ret = this.nm_pool_cls .. "@@" .. e_id
	local isMv2Pos = cfgEft.type == E_Eft_Type.FlyPosition
	_ret = this.BorrowSelf( _p_name,idMarker,idTarget,e_id,range,_mvSpeed,_diff,(_t_out + 0.01),_v3Target,isMv2Pos )
	return _ret
end

function M:ctor()
	super.ctor( self )
	super2.ctor( self )
	self.isDelayTime = true
end

function M:Reset(idMarker,idTarget,e_id,range,mvSpeed,dir,timeOut,targetPos,isMv2Pos)
	self.isUping = false
	self:SetData( e_id,idMarker,idTarget,range,mvSpeed,dir,timeOut,targetPos,isMv2Pos )
end

function M:OnSetData(idMarker,idTarget,range,mvSpeed,dir,timeOut,targetPos,isMv2Pos)
	self.idMarker = idMarker
	self.idTarget = idTarget
	self.range = range
	self.mvSpeed = mvSpeed
	self.timeOut = timeOut
	self.v3Target = targetPos
	self.isMoveToPos = isMv2Pos
	self.maxDistance = self.range or 0
	self:SetMoveDir( dir )
	self:_DisappearEffect()
end

function M:OnUpdate(dt)
	super.OnCurrUpdate( self,dt )
end

function M:OnPreDisappear()
	super.OnPreDisappear( self )
	self:_DisappearEffect()
end

function M:_DisappearEffect()
	local _lbs = self.lbEfcts
	self.lbEfcts,self.currEft = nil

	if _lbs then
		for _, v in ipairs(_lbs) do
			v:Disappear()
		end
	end
end

function M:Start()
	self.lbEfcts = EffectFactory.CreateEffect( self.idMarker,self.idMarker,self.data )
	self.isUping = tb_lens(self.lbEfcts) > 0
	self.curr_time = 0
	self.mileAge = 0
	self:ReEvent4OnUpdate(self.isUping)
	self:ReEvent4Self(self.isUping)
	if self.isUping then
		self.currEft = self.lbEfcts[1]
		self.currEft:SetIsNoCurve( true )
	end
	EffectFactory.ShowEffects( self.lbEfcts )
end

return M

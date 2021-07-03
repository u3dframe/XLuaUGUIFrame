--[[
	-- 场景Map
	-- Author : canyon / 龚阳辉
	-- Date : 2020-08-16 09:25
	-- Desc : 
]]

local _clsGBox = require( "games/logics/_scene/scene_map_gbox" )

local E_Object = LES_Object

local super,_evt = SceneObject,Event
local M = class( "scene_map",super )
local this = M

this.nm_pool_cls = "p_cls_sobj_" .. tostring(E_Object.MapObj)

function M.Builder(nCursor,resid)
	this:GetResCfg( resid )
	local _p_name,_ret = this.nm_pool_cls .. "@@" .. resid

	_ret = this.BorrowSelf( _p_name,E_Object.MapObj,nCursor,resid )
	return _ret
end

function M:OnViewBeforeOnInit()
	self:SetParent(nil,true)
end

function M:OnInit()
	self.lbCamera = self:NewCmr("MainCamera",true)
	self.isHasCamera = self.lbCamera ~= nil
	local _gbox = self:GetElement("gbox")
	if _gbox then
		self.lbGBox = _clsGBox.New(_gbox)
	end
	self.compPPLayer = self:GetElementComponent( "MainCamera","PostProcessLayer" )
	if self.compPPLayer then
		self.compPPLayer.enabled = Is_PPLayer_Enabled
	end

	if self.isHasCamera then
		_evt.Brocast(Evt_Vw_Def3DCamera,false,self.lbCamera)
		self.uObjLShadow = self.lbCamera:Find("light_monster")
	end
end

function M:ReSInfo()
	local _cfgMap = MgrScene.GetCurrMapCfg()
	super.ReSInfo( self,_cfgMap )
end

function M:ReEvent4Self(isBind)
	_evt.RemoveListener(Evt_Map_ReSInfo, self.ReSInfo, self)
	if isBind == true then
		_evt.AddListener(Evt_Map_ReSInfo, self.ReSInfo, self)
	end
end

function M:OnDestroy()
	if self.isHasCamera then
		_evt.Brocast(Evt_Vw_Def3DCamera,true)
	end
end

function M:GetGBoxUnit(nIndex)
	if (not self.lbGBox) then return end
	return self.lbGBox:GetUnit(nIndex)
end

function M:GetWorldY()
	if (not self.lbGBox) then return 0 end
	return self.lbGBox.posY or 0
end

function M:CmrLocalPosY(nY)
	if self.lbCamera and nY then
		nY = tonumber(nY) or 0
		local _v3 = self.lbCamera:GetLocalPosition()
		_v3.y = nY
		self.lbCamera:SetLocalPosition( _v3.x,_v3.y,_v3.z )
	end
	return self
end

function M:CmrLookAt(tx,ty,tz,isNoSmooth,upLate)
	if self.lbCamera then
		self.csAt = self.csAt or CLookAt.Get( self.lbCamera.gobj )
		tx = tonumber(tx) or 0
		ty = tonumber(ty) or 0
		tz = tonumber(tz) or 0
		isNoSmooth = not (isNoSmooth == true)
		self.csAt:LookAt( tx,ty,tz,isNoSmooth,upLate == true )
	end
	return self
end

function M:CmrLookAtTarget(trsfTaget,ox,oy,oz,isNoSmooth,upLate)
	if self.lbCamera and trsfTaget then
		self.csAt = self.csAt or CLookAt.Get( self.lbCamera.gobj )
		ox = tonumber(ox) or 0
		oy = tonumber(oy) or 0
		oz = tonumber(oz) or 0
		isNoSmooth = not (isNoSmooth == true)
		self.csAt:LookAt( trsfTaget,ox,oy,oz,isNoSmooth,upLate == true )
	end
	return self
end

function M:CmrFov(fov)
	fov = tonumber(fov)
	if self.lbCamera and fov then
		self.lbCamera:SetFieldOfView(fov)
	end
	return self
end

function M:Light2Winner()
	local _obj = self.lbCamera
	if _obj then
		local _l_main = self.uObjLShadow
		if _l_main then
			local _l_victory = _obj:Find("lights_victory")
			if _l_victory then
				CHelper.SetParent( _l_main,_l_victory )
			end
		end		
	end
	return self
end

return M
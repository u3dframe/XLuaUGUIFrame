--[[
	-- 摄像机 管理
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-13 09:25
	-- Desc : ui的,默认的,场景的
]]

local _vec2 = Vector2
local super,_evt,_base = MgrBase,Event,FabBase
local M = class( "mgr_camera",super )

function M:Init()
	self:_InitFab()
	_evt.AddListener(Evt_Vw_Def3DCamera,self.ViewMainCamera,self);
	_evt.AddListener(Evt_Brocast_UICamera,self.SetLBUICamera,self);
end

function M:_InitFab()
	local _lb_  = _base.New({
		abName = "m_camera",
		strComp = "MainCameraManager",
		isStay = true,
	})

	self.lbCamera = _lb_

	_lb_.OnInit = function(_s)
		local _c = _s.comp.m_camera
		_s.mainCamera = _s:NewCmrBy(_c,_c)
		_c = _s.comp.m_target
		_s.lbTarget = _s:NewTrsfBy( _c )
		_c = _s.comp.m_follower
		_s.lbFlower = _s:NewFollowerBy( _c,_c )
		_s:SetParent(nil,true)
		_s:DonotDestory()
		_s:SetEulerAngles(0,0,0)
	end

	_lb_.ReSkybox = function(_s,resid)
		if _s.residSkybox == resid then
			return
		end
		_s.residSkybox = resid
		if _s.lbMatSkybox then
			_s.lbMatSkybox:OnUnLoad()
		end
		local _cfg = _s:GetResCfg( resid )
		local _abname = _s:ReSBegEnd( _cfg.rsaddress,"skyboxs/",Mat_End )
		_s.lbMatSkybox = _s:NewAssetABName(_abname,LE_AsType.Mat,function(isNo,obj)
			if not isNo then
				_s.comp:SetSkybox( obj )
			end
		end)
	end

	_lb_.RePPFile = function(_s,resid)
		if _s.residPPFile == resid then
			return
		end
		_s.residPPFile = resid
		if _s.lbPPFile then
			_s.lbPPFile:OnUnLoad()
		end
		local _cfg = _s:GetResCfg( resid )
		local _abname = _s:ReSBegEnd( _cfg.rsaddress,"post_process/",Scriptable_End )
		_s.lbPPFile = _s:NewAssetABName(_abname,LE_AsType.PPFile,function(isNo,obj)
			if not isNo then
				_s.comp:SetPPVolume( obj )
			end
		end)
	end
end

function M:GetCsObj()
	return self.lbCamera.comp
end

function M:GetFollower()
	return self.lbCamera.lbFlower
end

function M:GetDTarget()
	return self.lbCamera.lbTarget
end

function M:ReSkybox( resid )
	if not resid then
		local _comp = self:GetCsObj()
		if _comp then
			_comp:SetSkybox()
		end
		self.lbCamera.residSkybox = nil
		return
	end
	self.lbCamera:ReSkybox( resid )
end

function M:RePPFile( resid )
	if not resid then
		local _comp = self:GetCsObj()
		if _comp then
			_comp:SetPPVolume()
		end
		self.lbCamera.residPPFile = nil
		return
	end
	self.lbCamera:RePPFile( resid )
end

function M:SetTargetPos(x,y,z)
	return self:GetDTarget():SetPosition( x,y,z )
end

function M:SetFTarget(target)
	return self:GetFollower():SetTarget( target )
end

function M:SetDefTarget(x,y,z)
	self:SetTargetPos(x,y,z)
	return self:SetFTarget( self:GetDTarget().trsf )
end

function M:SetLBUICamera(lbUICamera)
	self.lbUICamera = lbUICamera
end

function M:ViewMainCamera(isShow,lb3DCamera)
	self.lbCamera:View(isShow == true)
	self.otherCamera = lb3DCamera
end

function M:GetLBCamera()
	return self.lbCamera
end

function M:GetCur3DLBCamera()
	if self.otherCamera then return self.otherCamera end
	return self.lbCamera.mainCamera
end

function M:GetMainCamera()
	return self:GetCur3DLBCamera() -- .comp
end

function M:GetUILocPos(uobj,uiUObj,csCmr3d)
	local _csCmr = self.lbUICamera.comp
	if csCmr3d then
		local _x,_y = CEDCamera.GetUILocPos( csCmr3d,uobj,_csCmr,uiUObj,0,0 )
		return _vec2.New( _x,_y )
	else
		local _c = self:GetCur3DLBCamera()
		return _c:GetUILocPos( uobj,_csCmr,uiUObj )
	end
end

function M:UIEvtPos2UILocalPos(gobjParent,evt_x,evt_y)
	return self.lbUICamera:ToUILocalPointByEventPos( gobjParent,evt_x,evt_y );
end

function M:ReSRectWH(ofW,ofH)
	ofW,ofH = self:TNum( ofW ),self:TNum( ofH )
	self:GetCsObj():ReScreenRect( ofW,ofH )
end

function M:IsInCamera(gobj)
	local _csCmr = self:GetMainCamera().comp
	return self:GetCsObj():IsInCamera( _csCmr,gobj );
end

return M
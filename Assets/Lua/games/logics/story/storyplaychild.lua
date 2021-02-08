--[[
-- 剧情动画管理
-- Author : zhouyuxiang
-- Date : 2020-07-23 17:25
-- Desc : 此类负责剧情播放数据的初始化进度控制以及资源加载等管理
--]]
local E_Object = LES_Object
local super = SceneObject
---@class ChildStory 剧情播放控制器抽象
local M = class("storyplaychild", super)
local this = M
this.nm_pool_cls = "p_cls_tl_" .. tostring(E_Object.CG)

function M.Builder(resid,playOverCallBack,preloadcompletecb,time)
    this:GetResCfg( resid )
    local _p_name,_ret = this.nm_pool_cls .. "@@" .. resid
    local nCursor = SceneFactory.AddCursor()
    _ret = this.BorrowSelf( _p_name,E_Object.CG,nCursor,resid,playOverCallBack,preloadcompletecb,time )
	return _ret
end

function M.PreLoad(resid,lfOnceShow)
	local _ret_ = this.Builder( resid )
	_ret_:SetCallFunc( lfOnceShow )
	_ret_.lfOnShowOnce = function()
		local _lf = _ret_.callFunc
		_ret_.callFunc = nil
		_ret_:Disappear()

		if _lf then
			_lf()
		end
	end
	_ret_:ShowView( true )
	return _ret_
end

function M:BuilderUObj( uobj )
    return CTimelineUtil.Builder( uobj )
end

function M:ctor()
    super.ctor( self )
end

function M:Reset(sobjType,nCursor,resid,playOverCallBack,preloadcompletecb,time)
    super.Reset( self,(sobjType or E_Object.Creature),nCursor,resid )
    self.time = (tonumber(time) or 0) * 0.001
    self.playOverCallBack = playOverCallBack;
    self.PreloadCompleteCallBack = preloadcompletecb;
end

function M:OnInit()
    self.lbCmr = self:NewCmr("Camera")
    self.compPPLayer = self.csEDComp.m_pLayer
    if self.compPPLayer then self.compPPLayer.enabled = Is_PPLayer_Enabled end
end

function M:OnShow()
    self.csEDComp:Init(self.playOverCallBack,self.time)
    -- super.SetPosition( self,0,10000,0 )
    if self.PreloadCompleteCallBack then self.PreloadCompleteCallBack() end
end

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
	_cfg.isStay = true
	return _cfg;
end

function M:OnCF_Hide()
    super.OnCF_Hide( self )
    self:Disappear()
end

---预加载剧情信息
function M:PreloadPlayableAssetResources()
    if self.PlayableAsset then
        self.PlayableAsset:OnUnLoad()
    end
    self.PlayableAsset = nil
    local PlayableAssetName = self.data
    if (PlayableAssetName == nil)then
        self:InitTimeline()
    else
        --加载PlayableAsset(-.-暂时无用，后期有需要加载再添加配置支持)
        self.PlayableAsset = self:NewAssetABName(PlayableAssetName, LE_AsType.Playable, function (isNo, obj)
            self.pLAssetObj = obj
            self:InitTimeline();
        end)
    end
end

function M:InitTimeline()
    self.csEDComp:Init(self.playOverCallBack, self.pLAssetObj)
    if self.PreloadCompleteCallBack then self.PreloadCompleteCallBack() end
end

function M:Play()
    if (self.csEDComp) then
        self.csEDComp:Play()
    end
end

---暂停当前播放
function M:PauseCurrStory()
    if (self.csEDComp) then
        self.csEDComp:Pause()
    end
end

---继续播放暂停动画
function M:ResumeCurrStory()
    if (self.csEDComp)then
        self.csEDComp:Resume()
    end
end

---完全停止结束播放
function M:StopCurrStory()
    if (self.csEDComp)then
        self.csEDComp:Stop()
    end
end

function M:SetBinding(tarckname , go)
    if (self.csEDComp)then
        self.csEDComp:SetBinding(tarckname, go)
    end
end

function M:SetPosition(x, y , z)
    if (self.csEDComp)then
        self.csEDComp:SetDirectorPosition(x, y, z)
    end
end

function M:SetTimeType(isGameTime)
    if (self.csEDComp)then
        self.csEDComp:SetTimeUpdateModeType(isGameTime)
    end
end

function M:IsCanBinding(tarckname)
    if (self.csEDComp)then
        return self.csEDComp:IsHasTrack(tarckname);
    end
end

function M:SetClip(ch, name)
    if (self.csEDComp)then
        self.csEDComp:SetClip(ch, name);
    end
end

function M:GetCamera()
    return self.lbCmr
end

function M:SetCaster(gobj)
    if (self.csEDComp)then
        return self.csEDComp:SetCaster(gobj);
    end
end

function M:SetTarget(gobj, index)
    if (self.csEDComp)then
        return self.csEDComp:SetTarget(gobj, index);
    end
end

function M:SetTargetActive(index,isActive)
    if (self.csEDComp)then
       return self.csEDComp:SetTargetActive(index,isActive)
    end
end

return M
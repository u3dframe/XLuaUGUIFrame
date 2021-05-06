--[[
	-- 公共某块
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-15 13:25
	-- Desc : 减少自身内部引用
]]

local _c_trsf,_c_comp,_c_cmr,_c_flr,_c_ele,_lasset,_lfab = nil
local _uevt,_ugray,_utxt,_ubtn,_utog,_uimg,_uinpfld = nil
local _uscl,_uloop = nil
local _cl_lst,_cl_scl,_cl_scloop,_cl_sscl = nil
local _ueft,_uspe = nil

local M = class("lua_pubs")

function M:_ClsTrsf()
    if not _c_trsf then
        _c_trsf = LUTrsf
    end
    return _c_trsf
end

function M:NewTrsfBy(gobj,isInitVecs)
    return self:_ClsTrsf().New( gobj,isInitVecs )
end

function M:_ClsComp()
    if not _c_comp then
        _c_comp = LUComonet
    end
    return _c_comp
end

function M:NewCompBy(gobj,compName)
    return self:_ClsComp().New( gobj,compName )
end

function M:_ClsCmr()
    if not _c_cmr then
        _c_cmr = LUCamera
    end
    return _c_cmr
end

function M:NewCmrBy(gobj,compName)
    return self:_ClsCmr().New( gobj,compName )
end

function M:_ClsEle()
    if not _c_ele then
        _c_ele = LCFabElement
    end
    return _c_ele
end

function M:NewEleBy(gobj,isCanSetCSCall)
    isCanSetCSCall = not (isCanSetCSCall == true)
    return self:_ClsEle().New( gobj,"PrefabElement",isCanSetCSCall ):AddSupUIPubs()
end

function M:_ClsFollower()
    if not _c_flr then
        _c_flr = LCFollower
    end
    return _c_flr
end

function M:NewFollowerBy(gobj,compName)
    return self:_ClsFollower().New( gobj,compName )
end

function M:_ClsAsset()
    if not _lasset then
        _lasset = LuaAsset
    end
    return _lasset
end

function M:_ClsFab()
    if not _lfab then
        _lfab = LuaFab
    end
    return _lfab
end

function M:_ClsUEvt()
    if not _uevt then
        _uevt = LuEvtListener
    end
    return _uevt
end

function M:NewUEvtBy(gobj)
    return self:_ClsUEvt().New( gobj,true )
end

function M:_ClsUGray()
    if not _ugray then
        _ugray = LuGray
    end
    return _ugray
end

function M:NewUGrayBy(gobj)
    return self:_ClsUGray().New( gobj )
end

function M:_ClsUTxt()
    if not _utxt then
        _utxt = LuText
    end
    return _utxt
end

function M:NewTxtBy(gobj)
    return self:_ClsUTxt().New( gobj,true )
end

function M:_ClsUBtn()
    if not _ubtn then
        _ubtn = LuBtn
    end
    return _ubtn
end

function M:FreezedBtn(isFrozen)
    isFrozen = isFrozen  == true
    self:_ClsUBtn().CsIsFreezeAll( isFrozen )
end

function M:FreezedExcept(isRm,...)
    isRm = isRm  == true
    if isRm then
        self:_ClsUBtn().CsRmExcept( ... )
    else
        self:_ClsUBtn().CsAddExcept( ... )
    end
end

function M:NewBtnBy(gobj, callFunc, val, isNoScale)
    return self:_ClsUBtn().New( gobj, callFunc, val, isNoScale )
end

function M:_ClsUTog()
    if not _utog then
        _utog = LuTog
    end
    return _utog
end

function M:NewTogBy(gobj, uniqueID, callFunc, val, isNoCall4False)
    return self:_ClsUTog().New( uniqueID, gobj, callFunc, val, isNoCall4False )
end

function M:_ClsUImg()
    if not _uimg then
        _uimg = LuImg
    end
    return _uimg
end

function M:NewImgBy(gobj,compName)
    if (compName == nil) or (compName == "Image") or (compName == "RawImage") then
        return self:_ClsUImg().New( gobj,compName )
    end
end

function M:_ClsUInpFld()
    if not _uinpfld then
        _uinpfld = LuInpFld
    end
    return _uinpfld
end

function M:NewInpFldBy(gobj,val,callFunc)
    return self:_ClsUInpFld().New( gobj,val,callFunc )
end

function M:NewAsset(ab,asset,atp,callFunc,isNoAuto,isPreLoad)
    local _lb = self:_ClsAsset().New({
        abName = ab,
        assetName = asset,
        assetLType = atp
    })
    _lb.lfAssetLoaded = function(isNo,obj,_s)
        if callFunc ~= nil then
            callFunc( isNo,obj,_s )
        end
        if isPreLoad == true then
            _s = _s or _lb
            _s:OnUnLoad()
        end
    end
    if (isPreLoad == true) or (not isNoAuto) then
        _lb:LoadAsset()
    end
    return _lb
end

function M:NewAssetABName(ab,atp,callFunc,isNoAuto,isPreLoad)
    local assetName = CGameFile.GetFileNameNoSuffix(ab)
    return self:NewAsset(ab,assetName,atp,callFunc,isNoAuto,isPreLoad)
end

function M:_ClsUScl()
    if not _uscl then
        _uscl = LuScl
    end
    return _uscl
end

function M:NewSclBy(gobj, funcCreat, funcSetData, gobjItem)
    return self:_ClsUScl().New( gobj, funcCreat, funcSetData, gobjItem )
end

function M:_ClsULoop()
    if not _uloop then
        _uloop = LuScloop
    end
    return _uloop
end

function M:NewULoopBy(gobj, itemName, funcCreat, funcSetData)
    return self:_ClsULoop().New( gobj, itemName, funcCreat, funcSetData )
end

function M:_ClsUIScl()
    if not _cl_scl then
        _cl_scl = UIScl
    end
    return _cl_scl
end

function M:_ClsUILst()
    if not _cl_lst then
        _cl_lst = UILst
    end
    return _cl_lst
end

function M:_ClsUIScloop()
    if not _cl_scloop then
        _cl_scloop = UIScloop
    end
    return _cl_scloop
end

function M:AddGray4Self()
	if self.gobj and (not self.lbGray) then
		self.lbGray = self:NewUGrayBy( self.gobj )
	end
	return self
end

function M:SetGray( isBl,isGrayTxt )
	self:AddGray4Self()
	isBl = isBl == true
	if self.lbGray then
		self.lbGray:IsGrayAll( isBl,isGrayTxt )
	end
end

function M:AddUEvent4Self()
	if self.gobj and (not self.lbUEvt) then
		self.lbUEvt = self:NewUEvtBy( self.gobj )
	end
	return self
end

function M:_ClsUEffect()
    if not _ueft then
        _ueft = UIEffect
    end
    return _ueft
end

function M:NewUIEffect(resid,parent,timeout,v3LocPos,v3LocScale)
    return self:_ClsUEffect().Builder( resid,parent,(timeout or -1),v3LocPos,v3LocScale )
end

function M:_ClsUSpine()
    if not _uspe then
        _uspe = UISpine
    end
    return _uspe
end

function M:NewUISpine(data,parent)
    local _t_ = self:_ClsUSpine().New()
    if data and parent then
        _t_:View( true,data,parent )
    end
    return _t_
end

return M

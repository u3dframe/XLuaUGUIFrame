--[[
	-- ugui的图片image,RawImage
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-17 14:35
	-- Desc : 设置 icon,backgroud,图集图片
]]

local _LTP,tostring = LE_AsType,tostring
local str_split = string.split
local super = LuBase
local M = class( "ugui_image",super )

function M:ctor( obj,com )
	assert(obj,"text's obj is null")
	local gobj = obj.gameObject
	assert(gobj,"text's gobj is null")
	super.ctor( self,gobj,com or "Image" )
	self.lfCFImage = handler(self,self._OnCF_Image)
end

function M:RePng( sVal )
	local _arrs = str_split( sVal,"/" )
	sVal = _arrs[#_arrs]
	return self:ReSEnd( sVal,".png" )
end

function M:SetImage( sAtals,sImg,nType,isNativeSize )
	if nType == 1 then
		sAtals = self:ReSBegEnd( sAtals,"textures/ui_sngs/icons/",".tex" )
	elseif nType == 2 then
		sAtals = self:ReSBegEnd( sAtals,"textures/ui_sngs/bgs/",".tex" )
	elseif nType == 3 then
		sAtals = self:ReSBegEnd( sAtals,"textures/ui_sngs/minihead/",".tex" )
	elseif nType == 4 then
		sAtals = self:ReSBegEnd( sAtals,"textures/ui_sngs/halfbody/",".tex" )
	elseif nType == 5 then
		sAtals = self:ReSBegEnd( sAtals,"textures/ui_sngs/fullbody/",".tex" )
	elseif nType == 6 then
		sAtals = self:ReSBegEnd( sAtals,"textures/ui_sngs/",".tex" )
	else
		sAtals = self:ReSBegEnd( sAtals,"textures/ui_atlas/",".tex_atlas" )
	end
	sImg = self:RePng(sImg)
	if sAtals == self._sAtals and sImg == self._sImg then return end
	self._sAtals = sAtals
	self._sImg = sImg
	self[tostring(sAtals) .. "_" .. tostring(sImg)] = isNativeSize == true

	if self._lbImg and self._lbImg:IsNoLoaded() then
		self._lbImg:OnUnLoad()
	else
		self._pre_lbImg = self._lbImg
	end
	
	self._lbImg = self:NewAsset(sAtals,sImg,_LTP.Sprite,self.lfCFImage)
end

function M:SetIcon( icon,isNativeSize )
	self:SetImage( icon,icon,1,isNativeSize )
end

function M:SetBg( bg,isNativeSize )
	self:SetImage( bg,bg,2,isNativeSize )
end

function M:SetImgHead( head,isNativeSize )
	self:SetImage( head,head,3,isNativeSize )
end

function M:SetImgHalfBody( body,isNativeSize )
	self:SetImage( body,body,4,isNativeSize )
end

function M:SetImgBody( body,isNativeSize )
	self:SetImage( body,body,5,isNativeSize )
end

function M:SetFillAmount( val,max )	
	if max and max > 0 then
		val = val / max
	end
	self.comp.fillAmount = val
end

function M:_OnCF_Image( isNo,obj )
	if isNo or (not self.comp) then return end
	self.comp.sprite = obj
	local _isNSize = self[tostring(self._sAtals) .. "_" .. tostring(self._sImg)]
	if _isNSize == true then
		self.comp:SetNativeSize()
	end
	self:_clear_pre()
end

function M:_clear_pre()
	if not self._pre_lbImg then return end
	self._pre_lbImg:OnUnLoad()
	self._pre_lbImg = nil
end

function M:on_clean()
	self:_clear_pre()
	if not self._lbImg then return end
	self._lbImg:OnUnLoad()
	self._lbImg = nil
end

return M
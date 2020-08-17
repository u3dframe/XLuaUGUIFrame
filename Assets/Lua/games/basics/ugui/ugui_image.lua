--[[
	-- ugui的图片image,RawImage
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-17 14:35
	-- Desc : 设置 icon,backgroud,图集图片
]]

local _LTP = LE_AsType
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

function M:ReAtals( sVal )
	return self:ReSBegEnd( sVal,"textures/ui_atlas/",".tex_atlas" )
end

function M:ReIcon( sVal )
	return self:ReSBegEnd( sVal,"textures/ui_sngs/icons/",".tex" )
end

function M:ReBg( sVal )
	return self:ReSBegEnd( sVal,"textures/ui_sngs/bgs/",".tex" )
end

function M:RePng( sVal )
	local _arrs = str_split( sVal,"/" )
	sVal = _arrs[#_arrs]
	return self:ReSEnd( sVal,".png" )
end

function M:SetImage( sAtals,sImg,nType )
	if nType == 1 then
		sAtals = self:ReIcon(sAtals)
	elseif nType == 2 then
		sAtals = self:ReBg(sAtals)
	else
		sAtals = self:ReAtals(sAtals)
	end
	sImg = self:RePng(sImg)
	if sAtals == self._sAtals and sImg == self._sImg then return end
	self._sAtals = sAtals
	self._sImg = sImg

	if self._lbImg and self._lbImg:IsNoLoaded() then
		self._lbImg:OnUnLoad()
	else
		self._pre_lbImg = self._lbImg
	end
	
	self._lbImg = self:NewAsset(sAtals,sImg,_LTP.Sprite,self.lfCFImage)
end

function M:SetIcon( icon )
	self:SetImage(icon,icon,1)
end

function M:SetBg( bg )
	self:SetImage(bg,bg,2)
end

function M:_OnCF_Image( isNo,obj )
	if isNo or (not self.comp) then return end
	self.comp.sprite = obj
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
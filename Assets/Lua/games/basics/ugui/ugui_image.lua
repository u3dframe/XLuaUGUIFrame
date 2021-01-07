--[[
	-- ugui的图片image,RawImage
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-17 14:35
	-- Desc : 设置 icon,backgroud,图集图片
]]

local tonumber,type,tostring = tonumber,type,tostring
local _LTP = LE_AsType
local str_split = string.split
local super = LuBase
local M = class( "ugui_image",super )

function M:ctor( obj,com )
	assert(obj,"text's obj is null")
	local gobj = obj.gameObject
	assert(gobj,"text's gobj is null")
	super.ctor( self,gobj,com or "Image" )
end

function M:BuilderUObj( uobj )
	return CEDUIImg.Builder( uobj )
end

function M:RePng( sVal )
	local _arrs = str_split( sVal,"/" )
	sVal = _arrs[#_arrs]
	return self:ReSEnd( sVal,".png" )
end

function M:SetImage( sAtals,sImg,nType,isNativeSize )
	nType = tonumber(nType) or 0
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

	self.csEDComp:SetImage( nType,sAtals,sImg,(isNativeSize == true),false )
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
	max = tonumber(max) or 0
	self.csEDComp:SetFillAmount(val,max)
end

return M
--[[
	-- 通用  914*514 小弹窗
	-- Author : DTS
	-- Date   : 2020-08-19 16:31:28
]]

local super,_evt = UIBase,Event
local M = class( "connet_ui",super )

function M:onAssetConfig( _cfg )
	_cfg = super.onAssetConfig( self,_cfg )
    _cfg.abName = "commons/ui_connet" 
    _cfg.layer = LE_UILayer.Pop
    -- _cfg.hideType = LE_UI_Mutex.None
	return _cfg;
end

function M:OnInit()
    self.bgmask = self:NewBtn("bgmask",function (  )
        self:Surefun( )
    end,nil)
    self.close = self:NewBtn("close",function (  )
        self:Surefun( )
    end,nil)
    self.sure = self:NewBtn("sure",function (  )
        self:Surefun( )
    end,177)
    self.cancel = self:NewBtn("cancel",function (  )
        self:CanCelfun( )
    end,176)
end


function M:OnShow()

end

function M:Surefun( )
    MgrNet.nReConnet = nil
	MgrNet.istips = nil 
    _evt.Brocast( Evt_Net_ShutDown,true )
end

function M:CanCelfun( )
    self:OnClickCloseSelf()
    MgrNet._ReConnect()
end


return M
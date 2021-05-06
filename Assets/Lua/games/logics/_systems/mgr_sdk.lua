--[[
	-- 管理 - SDK接入逻辑
	-- Author : canyon / 龚阳辉
	-- Date : 2021-03-05 16:25
	-- Desc : 
]]

local tonumber,type,tostring = tonumber,type,tostring
local _cjson = require "cjson.safe"

local state_success   = "success";

local cmd_logLev     = "logLev";

local cmd_int        = "/dygame/init";
local cmd_login      = "/dygame/login";
local cmd_logout     = "/dygame/logout";
local cmd_pay        = "/dygame/pay";
local cmd_verToken   = "/dygame/onVerToken";
local cmd_exitGame   = "/dygame/exitGame";

local cmd_roleInit   = "/dygame/roleInit";
local cmd_roleRename = "/dygame/roleRename";
local cmd_roleUp     = "/dygame/roleUp";


local super,_evt = MgrBase,Event
local M = class( "mgr_sdk", super)
local this = M

local _cmd_func = {};
local _cmd_func_constant = {};

function M.Init()
	this.csMgr = CBridge
	this.csMgr.Init(this._CallBack);

	this.InitSDK()
end

function M._CallBack(jsonStr)
	local _tab = _cjson.decode( jsonStr );
	if not _tab then
		_evt.Brocast( Evt_UserLog2Net,"sub","bridge_err_null","msg",jsonStr )
		return
	end

	local _code,_msg,_tdata = _tab.code,_tab.msg,_tab.data;
	if (not _tdata or _tdata == "") then
		_evt.Brocast( Evt_UserLog2Net,"sub","bridge_err_msg","msg",_msg )
		return
	end
	
	local _data = _cjson.decode(_tdata);
	local _cmd = tostring(_data.cmd);
	_data.cmd = nil;
	local _func = nil;

	_func = _cmd_func_constant[_cmd];
	if _func then
		_func( _code,_data,_msg );
	end

	_func = _cmd_func[_cmd];
	if _func then
		_cmd_func[_cmd] = nil;
		_func( _code,_data,_msg );
	end
end

function M._Send(jsonStr)
	this.csMgr.Send( jsonStr );
end

function M.SetConstantCB( cmd,callFunc )
	if callFunc then
		_cmd_func_constant[tostring(cmd)] = callFunc;
	end
end

function M.Send( cmd,luaTab,callFunc )
	if callFunc then
		_cmd_func[tostring(cmd)] = callFunc;
	end

	luaTab.cmd = cmd;
	this._Send(_cjson.encode(luaTab));
end


function M.InitSDK()
	this.SetConstantCB( cmd_int,this._CB_Init );
	this.SetConstantCB( cmd_login,this._CB_Login );
	this.SetConstantCB( cmd_logout,this._CB_Logout );
	this.SetConstantCB( cmd_pay,this._CB_Pay );
end

function M._CB_Init(state)
	this.isSDKInit = (state == state_success);

	if this.isSDKInit then
		this.Send(cmd_login,{});
	end
end

function M._CB_Login(state,data)
	this.isSDKLogin = (state == state_success);
	this.loginData = data;
	if this.isSDKLogin then
		_evt.Brocast( Evt_LoginSDK )
	end
end

function M._CB_Logout(state,data)
	local _isOut = (state == state_success);
	if _isOut then
		-- 断链接，重新登录
		this.isSDKLogin = nil;
		this.loginData = nil;
		_evt.Brocast( Evt_Net_ShutDown,true )
	end
end

function M._CB_Pay(state,data,msg)
end



function M.LogLev(lev)
	this.Send( cmd_logLev,{ logLev = tonumber(lev) or 0 } );
end

function M.CloseLog()
	this.LogLev( 10 );
end

function M.SDK_ExitApp()
	this.Send( cmd_exitGame,{} );
end

function M.SDK_Logout(callFunc)
	this.Send( cmd_logout,{},callFunc );
end

function M.SDK_Login(callFunc)
	this.Send( cmd_login,{},callFunc );
end

function M.SDK_LoginVerToken(id,name,callFunc)
	this.Send( cmd_verToken,{id = id,name = name},callFunc );
end

function M.SDK_RoleInit(svid,svname,rid,rname)
	this.Send( cmd_roleInit,{svId = svid,svName = svname,rid = rid,rname = rname} );
end

function M.SDK_RoleRename(rname)
	this.Send( cmd_roleRename,{rname = rname} );
end

function M.SDK_RoleUp(lev,power,upState)
	-- upState = [0 - create,1 - enter,other - uplevel]
	this.Send( cmd_roleUp,{lev = lev,power = power,upState = tonumber(upState) or 2} );
end

-- money 单位分
function M.SDK_Pay(cpId,goodsId,goodsName,money,ext,callFunc)
	this.SDK_PayBy( {cpId = cpId,goodsId = goodsId,goodsName = goodsName,money = tonumber(money) or 0,ext = ext},callFunc );
end

-- tdata = {cpId = 自己订单号,goodsId = 商品ID,goodsName = 商品名字,money = 金额(分),ext = 透传参数}
function M.SDK_PayBy(tdata,callFunc)
	if type(tdata) ~= "table" then
		printError("=== pay tdata is not table = [%s]",tdata)
		return
	end
	this.Send( cmd_pay,tdata,callFunc );
end



function M.IsUseSDK()
	local _isV = (not GM_IsEditor) and (CfgSvList ~= nil) and CfgSvList.IsUseSDK()
	return _isV
end

function M.IsStateSuccess( state )
	return (state == state_success);
end

function M.IsLogined()
	return this.isSDKLogin == true;
end

function M.JugdeLogin(callFunc)
	local _isCall = false
	if this.IsUseSDK() then
		_isCall = this.IsLogined()
		if not _isCall then
			this.SDK_Login(callFunc)
		end
	end
	if _isCall and callFunc then
		callFunc()
	end
end

function M.GetTokenChn()
	local _d = this.loginData
	if _d then
		return _d.accessToken,_d.channelId
	end
end

return M
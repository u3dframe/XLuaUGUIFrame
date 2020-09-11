--[[
	-- 管理 - 网络请求
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-22 17:45
	-- Desc : 
]]

local tb_insert = table.insert
local tb_has = table.contains
local tb_remove = table.remove
local tb_rmvals = table.removeValues

Network = require("games/net/network")
CfgSvList = require("games/net/severlist")

local _lbQueExcepts = {}
local host,sender,_csMgr
local _cursor,_cb_requs,_r_ques,_cb_resps = 0,{},{},{}

local super,_evt = LuaObject,Event
local M = class( "mgr_net",super )
local this = M

function M.Init()
	_csMgr = CNetMgr.instance
	this._Init_Sproto()
	Network.Init(this.OnDispatch_Msg,this.OnConnection, this.OnWriteFinish,this.OnDisConnection)
end

function M._Init_Sproto()
	if host then return end
	local sproto = require "games/net/sproto/sproto"
    local c2s_text = CGameFile.GetText("protos/proto.c2s.sproto")
    local s2c_text = CGameFile.GetText("protos/proto.s2c.sproto")
    local c2s = sproto.parse(c2s_text)
    local s2c = sproto.parse(s2c_text)
    host = s2c:host "package"
    sender = host:attach(c2s)
end

function M.OnDispatch_Msg(msg)
    local _type, name, args, resp = host:dispatch(msg:ReadBytes())
	if _type == "RESPONSE" then
		--客户端请求返回
        local _cb,_isTips =_cb_requs[name]
		_cb_requs[name] = nil
		_isTips = (not _cb(args))
		if _isTips then
			local _e,_m = args.e,args.m
			if _e and _e ~= 0 then
				_m = _m or (resp .. _e)
				_evt.Brocast(Evt_Error_Tips,_m)
				printError(_m)
			end
		end
	else
		--服务器请求或者推送s2c
        local _s = this._ExcPushCall(name,args,resp)
        if not _s then
            printError("no push func name = [%s], pls register handler for [%s]", name, name)
        end
    end
end

function M.OnWriteFinish()
	this._ExcSendQueue()
end

function M.OnConnection(isSucess,errStr)
	-- printInfo("=======[%s] = [%s] = [%s] = [%s]",_lf_,this.isShutDown,isSucess,errStr)
	local _lf_ = this._lfConnected
	this._lfConnected = nil

	if _lf_ and (not this.isShutDown) then
		_lf_( isSucess,errStr )
	end

	-- if isSucess then
	-- 	local _rnd = math.random(1,10)
	-- 	LUtils.Wait(_rnd,this.ShutDown,_rnd > 8 ) -- TODO 随机断开连接 用于重连测试 --测试完毕记得后删除
	-- end
end

function M.OnDisConnection(isError)
	-- printInfo("=== OnDisConnection = [%s]",isError)
	if this.isShutDown then
		this._ExitLogin()
		return
	end
end

function M.Clean()
	_cursor,_cb_requs,_r_ques = 0,{},{}
end

function M.ShutDown(isExit)
	-- printInfo("=== ShutDown = [%s]",isExit)
	this.isShutDown = (isExit == true)
    _csMgr:ShutDown()
end

function M._ExitLogin()
	-- printInfo("=== _ExitLogin = ")
	this.Clean()
	this.isShutDown = nil
	_evt.Brocast( Evt_Re_Login )
end
local function _Connect(addr,port,callback)
	this._Init_Sproto()
	assert(not this._lfConnected)
	this._lfConnected = callback
	this.isShutDown = nil
	_csMgr:Connect(addr,port,true)
end

function M._ReConnect()
	local info = assert(this._ConnectInfo)
	local addr, port = info.addr, info.port
	_Connect(addr,port, function(ok, err)
		if not ok then
			if stream_read then
				stream_read.on_disconnect("Reconnect failure ".. tostring(err))
			else
				this._ExitLogin()
			end
		else
			handshake_reuse()
		end
	end)
end

function M.Connect(addr,port,sid,callback)
	this._ConnectInfo = {
		addr = addr, -- TODO 后续应该支持多地址
		port = port
	}
	_Connect(addr,port,function(ok, err)
		if not ok then
			callback(false, err) -- 通知逻辑连接失败
		else
			handshake_new(callback, string.format("game_%d",sid))
		end
	end)
end

function M.Response(response,result)
	--返回服务器主动请求数据
    _csMgr:SendBytes(response(result))
end

function M.SendRequest( cmd,data,callback )
	local _lf = function()
		this.isSending = true
		local _cur = nil
		if callback then
			_cur = _cursor + 1
			_cursor = _cur
			_cb_requs[_cur] = callback
		end

		local msg = sender(cmd, data, _cur)
		_csMgr:SendBytes(msg)
	end
	
	if this.isSending and (not tb_has(_lbQueExcepts,cmd)) then
		tb_insert( _r_ques,_lf )
	else
		_lf()
	end
end

function M._ExcSendQueue()
	local _lens = (#_r_ques)
	if _lens <= 0 then
		this.isSending = false
		return
	end
	local _v = _r_ques[1]
	tb_remove(_r_ques,1)
	_v()
end

-- 推送常量函数
function M.AddPushCall( cmd,callback )
	if (not cmd) or (not callback) then return end
	local _cbs = _cb_resps[cmd] or {}
	_cb_resps[cmd] = _cbs
	tb_insert( _cbs,callback )
end

function M.RmPushCall( cmd,callback )
	if (not cmd) or (not callback) then return end
	local _cbs = _cb_resps[cmd]
	if (not _cbs) then return end
	tb_rmvals( _cbs,callback )
end

function M._ExcPushCall( cmd,data,resp )
	local _cbs = _cb_resps[cmd]
	if (not _cbs) or (#_cbs <= 0) then return false end
	for _,v in ipairs(_cbs) do
		v(data,resp)
	end
	return true
end

return M
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

CfgSvList = require("games/net/severlist")

local _lbQueExcepts = {}
local host,sender,_csMgr
local _cursor,_cb_requs,_r_ques,_cb_resps = 0,{},{},{}

local super,_evt = LuaObject,Event
local M = class( "mgr_net",super )
local this = M

function M.Init()
	_csMgr = CNetMgr
	this._Init_Sproto()
	local Network = require("games/net/network")
	Network.Init(this.OnDispatch_Msg,this.OnConnection,this.OnDisConnection)
end

function M._Init_Sproto()
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
        local _cb =_cb_requs[name]
    	_cb_requs[name] = nil
		_cb(args)
		this._ExcSendQueue()
	else
		--服务器请求或者推送s2c
        local _s = this._ExcPushCall(name,args,resp)
        if not _s then
            printError("no push func name = [%s], pls register handler for [%s]", name, name)
        end
    end
end

function M.OnConnection()
	if this._lfConnected then this._lfConnected() end
end

function M.OnDisConnection(isError)
	if isError then this:clean() end
end

function M:on_clean()
	_cursor,_cb_requs,_r_ques = 0,{},{}
end

function M.Shutdown( host,port,callback)
    _csMgr:ShutDown()
end

function M.Connect( host,port,callback)
	this._lfConnected = callback
    _csMgr:ReConnect(host, port)
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
	local _isExpt = tb_has(_lbQueExcepts,cmd)
	if (not _isExpt) and this.isSending then
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
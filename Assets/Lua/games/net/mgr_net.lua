--[[
	-- 管理 - 网络请求
	-- Author : canyon / 龚阳辉
	-- Date : 2020-07-22 17:45
	-- Desc : 
]]

local tb_insert = table.insert
local tb_rmvals = table.removeValues
local tb_contains = table.contains
local _not_circle_cmd = { "ping" }

_G.Network = require("games/net/network")
_G.CfgSvList = require("games/net/severlist")

local crypt = require "crypt"
local rc4 = require "crypt.rc4"
local json = require "cjson.safe"
json.encode_sparse_array("on")

local host,sender,_csMgr
local _cursor,_cb_requs,_cb_resps = 0,{},{}

local super,_evt = _G.LuaObject,_G.Event
local M = _G.class( "mgr_net",super )
local this = M

function M.Init()
	_csMgr = CNetMgr.instance
	this._Init_Sproto()
	Network.Init(this.OnDispatch_Msg,this.OnConnection, this.OnWriteFinish,this.OnDisConnection)

	this.heartInterval = 10
	_evt.AddListener(Evt_UpEverySecond,this.DoHeart)
end

function M._Init_Sproto()
	if host then return end
	local sproto = require "games/net/sproto/sproto"
    local c2s_text = CGFile:GetDecryptText("protos/proto.c2s.sproto")
    local s2c_text = CGFile:GetDecryptText("protos/proto.s2c.sproto")
    local c2s = sproto.parse(c2s_text)
    local s2c = sproto.parse(s2c_text)
    host = s2c:host "package"
    sender = host:attach(c2s)
end

local function create_read_stream(ctx, crypt_call, handler, disconnect, data)
	local buffer = crypt_call(data or "")
	local packet = function ()
		local bufferlen = #buffer
		if bufferlen<2 then return end
		local len = string.unpack(">H", buffer)
		if bufferlen < 2 + len then return end
		local msg = string.unpack('>s2', buffer)
		buffer=buffer:sub(3+len)
		assert(#msg==len)
		return msg
	end
	local readbyte = #(data or "")
	return {
		append = function(s)
			local d = crypt_call(s)
			readbyte = readbyte + #d
			buffer = buffer .. d
		end,
		ctx = ctx,
		clean = function()
			local b = buffer
			buffer = ""
			return b
		end,
		bytes = function()
			return readbyte
		end,
		on_disconnect = disconnect,
		execute = function()
			while true do
				local msg = packet()
				if not msg then return end
				local ok,err = xpcall(handler,debug.traceback,msg)
				if not ok then
					printError("=== err = [\n%s\n]",err)
				end
			end
		end
	}
end

function M.Hook(isHook)
	this._isHook = isHook == "start"
	return isHook
end

function M.SendCheat(message)
	local msg = json.decode(message)
	local cmd = msg.name
	local args = json.decode(msg.request)
	this.SendRequest(cmd , args, function()

	end)
end

local CallCs = CS.CsWithLua.CallCs
local function ON_HOOK_OCCUR(data)
	if this._isHook then
		pcall(CallCs,"MCheat",json.encode(data))
	end
end

local function handle_sproto(msg)
	local _type, name, args, resp = host:dispatch(msg)
	if _type == "RESPONSE" then
		if this._isHook then
			ON_HOOK_OCCUR {
				session = name,
				response = json.encode(args)
			}
		end
		
		--客户端请求返回
		local _lbRequs = _cb_requs[name]
		_cb_requs[name] = nil

		if not tb_contains( _not_circle_cmd,_lbRequs.cmd ) then
			HideCircle()
		end

		if _lbRequs.callback then
			local _cb,_isTips = _lbRequs.callback
			_isTips = (not _cb(args))
			if _isTips then
				local _e,_m = args.e,args.m
				if _e and _e ~= 0 then
					_m = _m or (resp .. _e)
					_evt.Brocast(Evt_Error_Tips,_m)
				end
			end
		end
	else
		if this._isHook then
			ON_HOOK_OCCUR {
				name = name,
				request = json.encode(args),
			}
		end
		--服务器请求或者推送s2c
        local _s = this._ExcPushCall(name,args,resp)
        if not _s then
            --printError("no push func name = [%s], pls register handler for [%s]", name, name)
        end
    end
end

local function newcipher(secret)
	local key = table.concat{
		crypt.hmac64_md5(secret, string.char(0,0,0,0,0,0,0,0)),
		crypt.hmac64_md5(secret, string.char(1,0,0,0,0,0,0,0)),
		crypt.hmac64_md5(secret, string.char(2,0,0,0,0,0,0,0)),
		crypt.hmac64_md5(secret, string.char(3,0,0,0,0,0,0,0))
	}
	return rc4.init(key)
end

local stream_read, stream_write

function M.OnDispatch_Msg(bf)
	local d = bf:ReadBytes()
	stream_read.append(d)
	stream_read.execute()
end

local function create_write_stream(crypt_call, _maxbyte)
	local losebyte = 0	-- 缓存(buffer_reuse)过大已导致丢弃的数据
	local buffer = ""	-- 未发送数据缓存
	local buffer_reuse = ""	-- 已发送数据缓存(固定大小)
	local reusemax = _maxbyte or 65535	--64k缓存
	local issend = false
	local isstop = false
	local trysend = function()
		if issend then return end
		if isstop then return end
		if #buffer == 0 then return end
		issend = true
		local d
		d, buffer = buffer, ""
		_csMgr:SendBytes(d)
		--print("trysend "..#d)

		buffer_reuse = buffer_reuse .. d
		local reuselen = #buffer_reuse
		if reuselen > reusemax then
			local lose = reuselen - reusemax -- todo 要不要直接减少固定大小数据? 减少小量数据(buffer)导致的sub行为
			losebyte = losebyte + lose
			buffer_reuse = buffer_reuse:sub(reuselen - reusemax + 1)
		end
		return true
	end
	return {
		stop = function()
			isstop = true
		end,
		append = function(s)
			--print("append "..#s)
			local d = crypt_call(s)
			buffer = buffer .. d
			trysend()
		end,
		finish = function()
			issend = false
			trysend()
		end,
		restart = function(recvbytes)
			isstop = false
			if recvbytes < losebyte then
				return -- 服务器收到的数据 比我们丢弃的数据要少
			end
			buffer_reuse = buffer_reuse .. buffer
			buffer = ""
			if recvbytes > losebyte+#buffer_reuse then
				return -- 服务器收到的数据 比我们发送的数据还要多?
			end
			local d = string.sub(buffer_reuse, recvbytes-losebyte + 1)
			if #d>0 then
				issend = true
				_csMgr:SendBytes(d)
				--print("restart " ..#d)
			else
				issend = false
			end
			return true
		end
	}
end

function M.OnWriteFinish()
	if stream_write then
		stream_write.finish()
	end
end

local function handshake_new(callback, target)
	local mykey = crypt.randomkey()
	local pubkey = crypt.dhexchange(mykey)
	local pair = crypt.base64encode(pubkey)
	local m = (table.concat({0, pair, target ,0},'\n'))
	_csMgr:SendBytes(string.pack(">s2",m))
	---printInfo("handshake_new "..m)

	local function handshake_read(a) return a end
	local function handshake_on_disconnect(err) callback(false, err or "unknown") end
	local function handshake_on_message(msg)
		local tbl = string.split(msg,'\n')
		local id = tonumber(tbl[1])
		local otherkey = crypt.base64decode(tbl[2])
		local secret = crypt.dhsecret(otherkey,mykey)

		local rc4read, rc4write = newcipher(secret),newcipher(secret)
		local function crypt_read(a) return rc4.crypt(rc4read, a) end
		local function crypt_write(a) return rc4.crypt(rc4write, a) end
		local function on_disconnect() this._ReConnect() end
		stream_read = create_read_stream(
			{id = id,secret = secret,},
			crypt_read,
			handle_sproto,
			on_disconnect,
			stream_read.clean()
		)
		stream_write = create_write_stream(
			crypt_write,
			65535,
			1024
		)
		if callback then callback(true) end
	end

	stream_read = create_read_stream(nil, handshake_read, handshake_on_message, handshake_on_disconnect, nil)
end
--[[
local function mem(str)
	return table.concat({str.byte(str,1,#str)},',')
end

local function num(str)
	local v = 0
	for i,_v in ipairs({str.byte(str,1,#str)}) do
		v = v | _v<<((i-1)*8)
	end
	return v
end
]]

local handshake_error = {
	['200'] = "OK"
	,['400']='Malformed request' -- 数据解释失败
	,['401']='Unauthorized' -- 表示 HMAC 计算错误
	,['403']='Index Expired' -- 表示 Index 已经使用过
	,['404']='User Not Found' -- 表示连接 id 已经无效
	,['406']='Not Acceptable' -- 表示 cache 的数据流不够
	,['501']='Network Error' -- 网络相关错误
}

local function handshake_reuse()
	local ctx = assert(stream_read.ctx)
	ctx.index = (ctx.index or 0) +1
	local content = table.concat({ctx.id, ctx.index, stream_read.bytes()},'\n')..'\n'
	local hmaccode = crypt.hmac64_md5(crypt.hashkey(content), ctx.secret)
	local m = content..crypt.base64encode(hmaccode)
	-- print(content)
	-- print(m)
	-- print(mem(crypt.hashkey(content)),num(crypt.hashkey(content)),num(ctx.secret))
	--printInfo("handshake reuse " .. m)
	_csMgr:SendBytes(string.pack(">s2",m))

	local stream_read_last = stream_read
	stream_write.stop() -- wait for stream_write.restart(recvnumber)

	local function handshake_read(a) return a end
	local function handshake_on_disconnect(err)
		_evt.Brocast(Evt_Error_Tips,err)
		this._ExitLogin()
	end
	local function handshake_on_message(msg)
		local tbl = _G.string.split(msg,'\n')
		local recvnumber = tonumber(tbl[1])
		local err = handshake_error[tbl[2]] or "unknown"
		if err ~= 'OK' then
			handshake_on_disconnect("auth failre " .. err)	-- // 重连验证失败, 清空数据, 走重新登陆流程
		else
			--printInfo("reconnect success "..recvnumber)
			stream_read_last.append(stream_read.clean())
			stream_read = stream_read_last
			if not stream_write.restart(recvnumber) then
				handshake_on_disconnect("byte resend failure")	-- // 补发数据失败, 清空数据, 走重新登陆流程
			else
				LUtils.Wait(1,stream_read.execute)
			end
		end
	end
	stream_read = create_read_stream(nil, handshake_read,handshake_on_message, handshake_on_disconnect, nil)
end

function M.OnConnection(isSucess,errStr)
	-- printInfo("=== [%s] = [%s] = [%s] = [%s]",_lf_,this.isShutDown,isSucess,errStr)
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
	if stream_read then
		stream_read.on_disconnect(isError)
	end
end

function M.DoHeart()
	if not stream_write then
		return
	end
	if this.nextHeart then
		if this.nextHeart <= 0 then
			this.nextHeart = this.nextHeart + this.heartInterval
			this.SendHeart()
		else
			this.nextHeart = this.nextHeart - 1
		end
	else
		this.nextHeart = this.heartInterval
	end
end

function M.SendHeart()
	this.SendRequest("ping",{any = LTimer.GetSvTime()},this.OnHeart)
end

function M.OnHeart(svMsg)
	if svMsg.e == 0 then
		local now = LTimer.GetSvTime()
		local diff = now - svMsg.any
		LTimer.SetSvTime( svMsg.time )
		-- printInfo("=== OnHeart = [%s] = [%s]",diff,Time.time)
	end
end

function M.Clean()
	stream_read, stream_write = nil, nil
	host, sender = nil, nil
	_cursor,_cb_requs = 0,{}
end

function M.ShutDown(isExit)
	-- printInfo("=== ShutDown = [%s]",isExit)
	this.isShutDown = (isExit == true)
    _csMgr:ShutDown()
end

function M._ExitLogin()
	-- printInfo("=== _ExitLogin = ")
	HideCircle( true )
	this.Clean()
	this.isShutDown = nil
	_evt.Brocast( Evt_Re_Login )
end

local function _Connect(addr,port,callback)
	if this._lfConnected then
		return
	end
	this._Init_Sproto()
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

function M.Connect(addr,port,node,callback)
	this._ConnectInfo = {
		addr = addr,
		port = port
	}
	_Connect(addr,port,function(ok, err)
		if not ok then
			callback(false, err) -- 通知逻辑连接失败
		else
			handshake_new(callback, node)
		end
	end)
end

function M.Response(response,result)
	--返回服务器主动请求数据
	local msg = string.pack(">s2", response(result))
	stream_write.append(msg)
end

function M.SendRequest( cmd,data,callback )
	if not cmd then
		return
	end

	if not tb_contains( _not_circle_cmd,cmd ) then
		ShowCircle()
	end

	local _cur = _cursor + 1
	_cursor = _cur
	_cb_requs[_cur] = { cmd = cmd, callback = callback }
	local msg = string.pack(">s2", sender(cmd, data, _cur))
	stream_write.append(msg)
	if this._isHook then
		ON_HOOK_OCCUR {
			name = cmd,
			session = _cur,
			request = json.encode(data)
		}
	end
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
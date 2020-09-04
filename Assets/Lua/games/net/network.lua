-- 网络层
require("games/net/protocal")
local _cfgPc = _G.Protocal
local M,_evt = {},Event
local this = M

function M.Init(funcMsg,funcConnect,funcWriteFinish,funcDisConnect)
    this._lfMsg = funcMsg
    this._lfConnect = funcConnect
    this._lfDisConnect = funcDisConnect
    this._lfWriteFinish = funcWriteFinish

    _cfgPc = _cfgPc or _G.Protocal
	_evt.AddListener(_cfgPc.Connect, this.OnConnectSuccess)
    _evt.AddListener(_cfgPc.Exception, this.OnException)
    _evt.AddListener(_cfgPc.Disconnect, this.OnDisconnect)
    _evt.AddListener(_cfgPc.Message, this.OnMessage)
    _evt.AddListener(_cfgPc.Write, this.OnWrite)
    _evt.AddListener(_cfgPc.ConnectFail, this.OnConnectFail)
end

--卸载网络监听--
function M.Unload()
    _evt.RemoveListener(_cfgPc.Connect)
    _evt.RemoveListener(_cfgPc.Exception)
    _evt.RemoveListener(_cfgPc.Disconnect)
    _evt.RemoveListener(_cfgPc.Message)
    _evt.RemoveListener(_cfgPc.Write)
end

function M.OnSocket(code,btBuffer)
	_evt.Brocast(tostring(code), btBuffer)
end

function M.OnConnectSuccess()
    this.OnConnect( true )
end

function M.OnConnectFail(btBuffer)
    local _err = btBuffer:ReadString()
    this.OnConnect( false,_err )
end

--当连接建立时--
function M.OnConnect(isSuccess,errStr)
   if this._lfConnect then this._lfConnect( isSuccess,errStr ) end
end

--异常断线--
function M.OnException()
    if this._lfDisConnect then this._lfDisConnect(true) end
end

--连接中断，或者被踢掉--
function M.OnDisconnect()
    if this._lfDisConnect then this._lfDisConnect(false) end
end

--登录返回--
function M.OnMessage(btBuffer)
    if this._lfMsg then this._lfMsg(btBuffer) end
end

function M.OnWrite()
    if this._lfWriteFinish then this._lfWriteFinish() end
end

return M
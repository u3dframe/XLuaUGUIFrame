-- 网络层
require("games/net/protocal")
local _cfgPc = _G.Protocal
local M,_evt = {},Event
local this = M

function M.Init(funcMsg,funcConnect,funcDisConnect)
    this._lfMsg = funcMsg
    this._lfConnect = funcConnect
    this._lfDisConnect = funcDisConnect
    
    _cfgPc = _cfgPc or _G.Protocal
	_evt.AddListener(_cfgPc.Connect, this.OnConnect)
    _evt.AddListener(_cfgPc.Exception, this.OnException)
    _evt.AddListener(_cfgPc.Disconnect, this.OnDisconnect)
    _evt.AddListener(_cfgPc.Message, this.OnMessage)
end

--卸载网络监听--
function M.Unload()
    _evt.RemoveListener(_cfgPc.Connect)
    _evt.RemoveListener(_cfgPc.Exception)
    _evt.RemoveListener(_cfgPc.Disconnect)
    _evt.RemoveListener(_cfgPc.Message)
end

function M.OnSocket(code,btBuffer)
	_evt.Brocast(tostring(code), btBuffer)
end

--当连接建立时--
function M.OnConnect()
   if this._lfConnect then this._lfConnect() end
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

return M
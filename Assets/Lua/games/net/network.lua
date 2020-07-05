-- 网络层

local M = {}
local this = M;

function M:Init()
	Event.AddListener(Protocal.Connect, this.OnConnect); 
    Event.AddListener(Protocal.Exception, this.OnException); 
    Event.AddListener(Protocal.Disconnect, this.OnDisconnect);
    Event.AddListener(Protocal.Message, this.OnMessage);

    this._cfunc = {}
    this._cfunc[ProtocalType.BINARY] = this._CallBinary;
    this._cfunc[ProtocalType.PB_LUA] = this._CallPBLua;
    this._cfunc[ProtocalType.PBC] = this._CallPBC;
    this._cfunc[ProtocalType.SPROTO] = this._CallSproto;
end

--卸载网络监听--
function M.Unload()
    Event.RemoveListener(Protocal.Connect);
    Event.RemoveListener(Protocal.Exception);
    Event.RemoveListener(Protocal.Disconnect);
    Event.RemoveListener(Protocal.Message);
    logWarn('Unload Network...');
end

function M.OnSocket(code,btBuffer)
	Event.Brocast(tostring(code), btBuffer);
end

--当连接建立时--
function M.OnConnect() 
    logWarn("Game Server connected!!");
end

--异常断线--
function M.OnException() 
    -- NetManager:SendConnect();
   	logError("OnException------->>>>");
end

--连接中断，或者被踢掉--
function M.OnDisconnect() 
    logError("OnDisconnect------->>>>");
end

--登录返回--
function M.OnMessage(btBuffer)
    local _cf = this._cfunc[Curr_PType];
    if _cf  then
        _cf(btBuffer)
    end
end

function M._CallBinary(btBuffer)
end

function M._CallPBLua(btBuffer)
end

function M._CallPBC(btBuffer)
end

function M._CallSproto(btBuffer)
end

return M
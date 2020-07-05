--协议消息回调--
Protocal = {
	Connect		= '1001';	--连接服务器
	Exception   = '1002';	--异常掉线
	Disconnect  = '1003';	--正常断线   
	Message		= '1004';	--接收消息
}

--协议类型--
ProtocalType = {
	BINARY = 0,
	PB_LUA = 1,
	PBC = 2,
	SPROTO = 3,
}

Curr_PType = ProtocalType.SPROTO
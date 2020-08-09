using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using TNet;

public class NetworkManager : GobjLifeListener {
	static NetworkManager _instance;
	static public NetworkManager instance {
		get {
			if (IsNull(_instance)) {
				GameObject _gobj = GameMgr.mgrGobj;
				_instance = UtilityHelper.Get<NetworkManager>(_gobj,true);
			}
			return _instance;
		}
	}

	static readonly object m_lockObject = new object();
	static Queue<KeyValuePair<int, ByteBuffer>> mEvents = new Queue<KeyValuePair<int, ByteBuffer>>();

	private SocketClient socket = null;
	string lua_func = "Network.OnSocket";
	String m_host = null;
	int m_port = 0;

	/// <summary>
	///  初始化
	/// </summary>
	protected override void OnCall4Awake(){
		InitSocket();
		this.csAlias = "NetMgr";
		m_isOnUpdate = true;
		GameMgr.RegisterUpdate(this);
	}

	/// <summary>
	///  更新 - 接受到数据
	/// </summary>
	public override void OnUpdate(float dt,float unscaledDt) {
		if (mEvents.Count > 0) {
			while (mEvents.Count > 0) {
				KeyValuePair<int, ByteBuffer> _event = mEvents.Dequeue();
				// 通知到lua那边
				OnCF2Lua(_event.Key, _event.Value);
				// 放入对象池				
				ByteBuffer.ReBack(_event.Value);
			}
		}
	}

	/// <summary>
	/// 销毁
	/// </summary>
	protected override void OnCall4Destroy() {
		GameMgr.DiscardUpdate(this);
		socket.OnRemove();
	}

	protected override void OnClear(){
		mEvents.Clear();
		socket = null;
	}

	/// <summary>
	/// 通知到lua那边
	/// </summary>
	void OnCF2Lua(int code, ByteBuffer data) {
		if (data == null)
			return;

		bool isState = LuaHelper.CFuncLua(lua_func, code, data);
		if (!isState)
			Debug.LogErrorFormat("=== OnCF2Lua Fails,lua func = [{0}], code = [{1}]", lua_func, code);
	}

	public NetworkManager InitNet(string host, int port, string luaFunc) {
		if (!string.IsNullOrEmpty(host)) {
			this.m_host = host;
		}
		if (port > 0) {
			this.m_port = port;
		}
		if (!string.IsNullOrEmpty(luaFunc))
			this.lua_func = luaFunc;
		return this;
	}

	private void InitSocket(){
		if(socket != null) return;
		socket = new SocketClient();
		socket.OnRegister();
	}

	///------------------------------------------------------------------------------------
	public static void AddEvent(int code, ByteBuffer data) {
		lock (m_lockObject) {
			mEvents.Enqueue(new KeyValuePair<int, ByteBuffer>(code, data));
		}
	}

	public bool ShutDown() {
		if (this.socket == null)
			return false;

		this.socket.Close();
		return true;
	}

	public void Connect(string host, int port) {
		InitSocket();
		
		bool isReConnect = !string.Equals(this.m_host,host) || this.m_port != port;
		bool isConnect = isReConnect || !this.socket.IsConnected();
		if(!isConnect) return;
		if(isReConnect) ShutDown();
		this.InitNet(host,port,this.lua_func);
		SendConnect();
	}

	/// <summary>
	/// 发送链接请求
	/// </summary>
	public void SendConnect() {
		if (this.m_host == null || this.m_port <= 0) {
			return;
		}
		socket.SendConnect(this.m_host, this.m_port);
	}

	/// <summary>
	/// 发送SOCKET消息
	/// </summary>
	public void SendMessage(ByteBuffer buffer) {
		socket.SendMessage(buffer);
	}

	public void SendBytes(byte[] msg) {
		socket.SendMessage(msg);
	}
}
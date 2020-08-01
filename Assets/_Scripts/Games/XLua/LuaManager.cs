using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using XLua;
using System.Runtime.InteropServices;
#if UNITY_5_4_OR_NEWER
using UnityEngine.SceneManagement;
#endif
using Core;

public class LuaManager : GobjLifeListener
{
	static LuaManager _instance;
	static public LuaManager instance{
		get{
			if (IsNull(_instance)) {
				GameObject _gobj = GameMgr.mgrGobj;
				_instance = UtilityHelper.Get<LuaManager>(_gobj,true);
			}
			return _instance;
		}
	}

	internal static LuaEnv luaEnv = new LuaEnv(); //all lua behaviour shared one luaenv only!
	internal static float lastGCTime = 0;
	internal const float GCInterval = 5;//1 second 

	private DF_OnUpdate luaUpdate,luaFixedUpdate;
	private DF_OnSceneChange luaSceneChange;
	private Action luaLateUpdate,luaOnApplicationQuit;
	public bool m_isPaused{get; private set;}
	private DF_OnBool luaAppPaused;

	public void Init(){}

	/// <summary>
	///  初始化
	/// </summary>
	protected override void OnCall4Awake(){
		this.csAlias = "LuaMgr";
		luaEnv.AddLoader(new LuaFileLoader());
		InitSelfLibs();
		m_isOnUpdate = true;
	}

	protected override void OnCall4Start(){
		luaEnv.DoString("require('Main');","Main");
		var _luaG = luaEnv.Global;
		var luaStart = _luaG.Get<Action>("Main");
		luaUpdate = _luaG.Get<DF_OnUpdate>("Update");
		luaFixedUpdate = _luaG.Get<DF_OnUpdate>("FixedUpdate");
		luaLateUpdate = _luaG.Get<Action>("LateUpdate");
		luaOnApplicationQuit = _luaG.Get<Action>("OnApplicationQuit");
		luaSceneChange = _luaG.Get<DF_OnSceneChange>("OnLevelWasLoaded");
		luaAppPaused = _luaG.Get<DF_OnBool>("OnApplicationPause");
		if (luaStart != null)
		{
			luaStart();
		}

#if UNITY_5_4_OR_NEWER
		SceneManager.sceneLoaded += _OnSceneLoaded;
#endif
	}

#if UNITY_5_4_OR_NEWER
    void _OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        OnLevelLoaded(scene.buildIndex);
    }
#else
    protected void OnLevelWasLoaded(int level)
    {
        OnLevelLoaded(level);
    }
#endif

	void OnLevelLoaded(int level){
		if(luaSceneChange != null) luaSceneChange(level);
	}

	void Update() {

		if(!m_isOnUpdate) return;

		if(luaUpdate != null) luaUpdate(Time.deltaTime,Time.unscaledDeltaTime);

		if (Time.unscaledTime - lastGCTime > GCInterval)
		{
			luaEnv.Tick();
			lastGCTime = Time.unscaledTime;
		}
	}

	void LateUpdate() {
		if(luaLateUpdate != null) luaLateUpdate();
	}

	void FixedUpdate() {
		if(luaFixedUpdate != null) luaFixedUpdate(Time.fixedDeltaTime,Time.fixedUnscaledDeltaTime);
	}
	
	protected new void OnApplicationQuit(){
		if(luaOnApplicationQuit != null) luaOnApplicationQuit();
		base.OnApplicationQuit();
	}

	void OnApplicationFocus(bool hasFocus){
        this.m_isPaused = !hasFocus;
		_ExcCF_Pause();
    }

    void OnApplicationPause(bool pauseStatus){
        this.m_isPaused = pauseStatus;
		_ExcCF_Pause();
    }

	private void _ExcCF_Pause(){
		if(luaAppPaused != null) luaAppPaused(this.m_isPaused);
	}

	[DllImport("xlua", CallingConvention = CallingConvention.Cdecl)]
	public static extern int luaopen_lpeg(IntPtr L);

	[DllImport("xlua", CallingConvention = CallingConvention.Cdecl)]
	public static extern int luaopen_sproto_core(IntPtr L);

	[MonoPInvokeCallback(typeof(XLua.LuaDLL.lua_CSFunction))]
	public static int LoadSprotoCore(IntPtr L)
	{
		return luaopen_sproto_core(L);
	}

	[MonoPInvokeCallback(typeof(XLua.LuaDLL.lua_CSFunction))]
	public static int LoadLpeg(IntPtr L)
	{
		return luaopen_lpeg(L);
	}

	void InitSelfLibs()
	{
		luaEnv.AddBuildin("sproto.core", LoadSprotoCore);
		luaEnv.AddBuildin("lpeg", LoadLpeg);
	}

	public void LuaGC(){
		luaEnv.GC();
	}

	public bool CFuncLua(string funcName, params object[] args) {
		LuaFunction func = luaEnv.Global.GetInPath<LuaFunction>(funcName);
		if (func != null) {
			int lens = 0;
			if(args != null){
				lens = args.Length;
			}
			switch(lens){
				case 0:
					func.Call();
					break;
				case 1:
					func.Action(args[0]);
					break;
				case 2:
					func.Action(args[0],args[1]);
					break;
				default:
					func.Call(args);
					break;
			}
			return true;
		}
		return false;
	}

	protected override void OnClear(){
		luaUpdate = null;
		luaFixedUpdate = null;
		luaLateUpdate = null;
		luaOnApplicationQuit = null;
		luaSceneChange = null;
		luaAppPaused = null;
		StopAllCoroutines();
	}

	protected override void OnCall4Destroy(){
		luaEnv.Dispose();
	}
}

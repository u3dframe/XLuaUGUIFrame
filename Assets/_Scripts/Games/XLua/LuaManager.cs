using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using XLua;
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
				_instance = _gobj.GetComponent<LuaManager>();
				if (IsNull(_instance))
				{
					_instance = _gobj.AddComponent<LuaManager> ();
				}
			}
			return _instance;
		}
	}

	internal static LuaEnv luaEnv = new LuaEnv(); //all lua behaviour shared one luaenv only!
	internal static float lastGCTime = 0;
	internal const float GCInterval = 1;//1 second 

	private DF_OnUpdate luaUpdate;
	private DF_OnSceneChange luaSceneChange;
	private Action luLateUpdate,luaOnApplicationQuit;

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
		luLateUpdate = _luaG.Get<Action>("LateUpdate");
		luaOnApplicationQuit = _luaG.Get<Action>("OnApplicationQuit");
		luaSceneChange = _luaG.Get<DF_OnSceneChange>("OnLevelWasLoaded");
		if (luaStart != null)
		{
			luaStart();
		}
	}

#if UNITY_5_4_OR_NEWER
    void OnSceneLoaded(Scene scene, LoadSceneMode mode)
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
		OnUpdate(Time.deltaTime);
	}

	void LateUpdate() {
		if(luLateUpdate != null) luLateUpdate();
	}
	
	void OnApplicationQuit(){
		if(luaOnApplicationQuit != null) luaOnApplicationQuit();
	}

	void InitSelfLibs()
	{
		/*
        luaState.BeginPreLoad();
        luaState.RegFunction("sproto.core", luaopen_sproto_core);
        luaState.EndPreLoad();
		*/
	}

	public void LuaGC(){
		luaEnv.GC();
	}

	public bool CFuncLua(string funcName, params object[] args) {
		LuaFunction func = luaEnv.Global.Get<LuaFunction>(funcName);
		if (func != null) {
			int lens = 0;
			if(args != null){
				lens = args.Length;
			}
			switch(lens){
				case 1:
					func.Action(args[0]);
					break;
				case 2:
					func.Action(args[0],args[1]);
					break;
				default:
					func.Call();
					break;
			}
			return true;
		}
		return false;
	}

	public override void OnUpdate(float dt){
		if(luaUpdate != null) luaUpdate(dt);

		if (Time.time - lastGCTime > GCInterval)
		{
			luaEnv.Tick();
			lastGCTime = Time.time;
		}
	}

	protected override void OnCall4Destroy(){
		luaEnv.Dispose();
		luaUpdate = null;
	}
}

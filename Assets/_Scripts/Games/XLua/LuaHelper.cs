using UnityEngine;
using System.Collections.Generic;
using System.Reflection;
using System;
using UnityEngine.Playables;

public sealed class LuaHelper : UtilityHelper {
	/// <summary>
	/// 清理内存
	/// </summary>
	static public void ClearMemory() {
		GC.Collect(); Resources.UnloadUnusedAssets();
		var mgr = LuaManager.instance;
		if (mgr != null) mgr.LuaGC();
	}

	// [Obsolete]
	static public bool CFuncLuaMore(string funcName, params object[] args) {
		var mgr = LuaManager.instance;
		if (mgr != null) { return mgr.CFuncLua(funcName,args); } 
		return false;
	}

	static public bool CFuncLua(string funcName) {
		return CFuncLuaMore(funcName);
	}

	static public bool CFuncLua(string funcName,object obj1) {
		return CFuncLuaMore(funcName,obj1);
	}

	static public bool CFuncLua(string funcName,object obj1,object obj2) {
		return CFuncLuaMore(funcName,obj1,obj2);
	}

	static public bool CFuncLua(string funcName,object obj1,object obj2,object obj3) {
		return CFuncLuaMore(funcName,obj1,obj2,obj3);
	}

	static public bool CFuncLua(string funcName,object obj1,object obj2,object obj3,object obj4) {
		return CFuncLuaMore(funcName,obj1,obj2,obj3,obj4);
	}

	static public bool CFuncLua(string funcName,object obj1,object obj2,object obj3,object obj4,object obj5) {
		return CFuncLuaMore(funcName,obj1,obj2,obj3,obj4,obj5);
	}

	static public bool CFuncLua(string funcName,object obj1,object obj2,object obj3,object obj4,object obj5,object obj6) {
		return CFuncLuaMore(funcName,obj1,obj2,obj3,obj4,obj5,obj6);
	}

	static public Camera GetOrAddCamera(GameObject gobj){
		return Get<Camera>(gobj,true);
	}

	static public Camera GetOrAddCamera(Transform trsf){
		return Get<Camera>(trsf,true);
	}

	static public Animator GetOrAddAnimator(GameObject gobj){
		return Get<Animator>(gobj,true);
	}

	static public Animator GetOrAddAnimator(Transform trsf){
		return Get<Animator>(trsf,true);
	}

	static public PlayableDirector GetOrAddPlayableDirector(GameObject gobj)
	{
		return Get<PlayableDirector>(gobj, true);
	}

	static public PlayableDirector GetOrAddPlayableDirector(Transform trsf)
	{
		return Get<PlayableDirector>(trsf, true);
	}

}
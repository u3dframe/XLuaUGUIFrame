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

	static public bool IsElement(object obj) {
		if(IsNull(obj))	return false;
		return obj is PrefabElement;
	}

	static public bool IsGLife(object obj) {
		if(IsNull(obj))	return false;
		return obj is GobjLifeListener;
	}

	static public void GetRectSize(GameObject gobj,ref float w,ref float h) {
		w = 0;h = 0;
		if(IsNull(gobj)) return;
		GetRectSize(gobj.transform,ref w,ref h);
	}

	static public void GetRectSize(Transform trsf,ref float w,ref float h) {
		w = 0;h = 0;
		if(IsNull(trsf)) return;
		RectTransform _r = trsf as RectTransform;
		var v2 = _r.rect.size;
		w = v2.x;
		h = v2.y;
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